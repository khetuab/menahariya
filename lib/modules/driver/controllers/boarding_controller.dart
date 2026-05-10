// lib/modules/driver/controllers/boarding_controller.dart

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/core/utils/app_snackbar.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import '../../../data/models/passenger/passenger_model.dart';
import '../views/boarding/boarding_management_view.dart';

class BoardingController extends GetxController {
  static BoardingController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;

  // Current trip ID - make sure this gets set properly
  final _tripId = ''.obs;
  String get tripId => _tripId.value;
  set tripId(String value) {
    _tripId.value = value;
    print('✈️ BoardingController: tripId set to $value');
  }

  // Observables
  final _isLoading = false.obs;
  final _isScanning = false.obs;
  final _currentPassenger = Rxn<PassengerModel>();
  final _boardingList = <PassengerModel>[].obs;
  final _checkedInPassengers = <PassengerModel>[].obs;
  final _pendingPassengers = <PassengerModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedBoardingMethod = BoardingMethod.scan.obs;
  final _currentTripRoute = ''.obs;
  final _currentTripDetails = Rxn<TripModel>();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isScanning => _isScanning.value;
  PassengerModel? get currentPassenger => _currentPassenger.value;
  List<PassengerModel> get boardingList => _boardingList;
  List<PassengerModel> get checkedInPassengers => _checkedInPassengers;
  List<PassengerModel> get pendingPassengers => _pendingPassengers;
  String get searchQuery => _searchQuery.value;
  BoardingMethod get selectedMethod => _selectedBoardingMethod.value;
  String get currentTripRoute => _currentTripRoute.value;
  TripModel? get currentTripDetails => _currentTripDetails.value;

  final _availableTrips = <TripModel>[].obs;
  final _isLoadingTrips = false.obs;
  final _currentTripId = ''.obs;

  List<TripModel> get availableTrips => _availableTrips;
  bool get isLoadingTrips => _isLoadingTrips.value;
  String get currentTripId => _currentTripId.value;

  // Statistics
  int get totalPassengers => _boardingList.length;
  int get checkedInCount => _checkedInPassengers.length;
  int get pendingCount => _pendingPassengers.length;
  double get boardingProgress => totalPassengers > 0
      ? checkedInCount / totalPassengers
      : 0;

  @override
  void onInit() {
    super.onInit();
    _getTripId();
    _setupSocketListeners();
  }

  void _getTripId() {
    // Try multiple sources to get tripId
    print('🔍 BoardingController: Getting tripId...');

    // Method 1: From Get.arguments
    final args = Get.arguments;
    print('📦 Get.arguments: $args');

    if (args != null) {
      if (args is Map) {
        if (args.containsKey('tripId')) {
          tripId = args['tripId'].toString();
          print('✅ Got tripId from arguments: $tripId');
        } else if (args.containsKey('trip')) {
          final trip = args['trip'];
          if (trip is TripModel) {
            tripId = trip.id;
          } else if (trip is Map && trip.containsKey('id')) {
            tripId = trip['id'].toString();
          }
          print('✅ Got tripId from trip object: $tripId');
        }
      }
    }

    // Method 2: From URL parameters
    if (tripId.isEmpty && Get.parameters.containsKey('tripId')) {
      tripId = Get.parameters['tripId']!;
      print('✅ Got tripId from URL parameters: $tripId');
    }

    // Method 3: From current user's active trip via API
    if (tripId.isEmpty) {
      _loadActiveTrip();
    }

    if (tripId.isNotEmpty) {
      loadTripDetails();
      loadBoardingList();
    } else {
      print('⚠️ BoardingController: No tripId found');
    }
  }

  void clearSelectedTrip() {
    _tripId.value = '';
    _currentPassenger.value = null;
    _boardingList.clear();
    _checkedInPassengers.clear();
    _pendingPassengers.clear();
    _currentTripRoute.value = '';
    _currentTripDetails.value = null;
  }

  Future<void> selectTripForBoarding(TripModel trip) async {
    print('✈️ Selecting trip for boarding: ${trip.origin} → ${trip.destination}');

    // Set the trip ID
    _tripId.value = trip.id;
    _currentTripRoute.value = '${trip.origin} → ${trip.destination}';
    _currentTripDetails.value = trip;

    // Load boarding list for this trip
    await loadBoardingList();
  }
  Future<void> loadAvailableTrips() async {
    try {
      _isLoadingTrips.value = true;
      print('📋 Loading available trips for boarding...');

      final response = await _apiClient.get(
        ApiEndpoints.driverTrips,
        queryParameters: {'status': 'scheduled', 'limit': 50},
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> trips = response['data'];
        _availableTrips.value = trips.map((t) => TripModel.fromJson(t)).toList();
        print('✅ Loaded ${_availableTrips.length} trips for boarding');

        // Also try to get current active trip
        await _loadCurrentActiveTrip();
      }
    } catch (e) {
      print('❌ Error loading available trips: $e');
      _availableTrips.value = [];
    } finally {
      _isLoadingTrips.value = false;
    }
  }

  Future<void> _loadCurrentActiveTrip() async {
    try {
      final response = await _apiClient.get('/driver/current-trip');
      if (response != null && response['data'] != null) {
        final trip = TripModel.fromJson(response['data']);
        _currentTripId.value = trip.id;
        print('✅ Current active trip: ${trip.origin} → ${trip.destination}');
      }
    } catch (e) {
      print('No current active trip: $e');
    }
  }

  Future<void> _loadActiveTrip() async {
    try {
      print('🔄 Loading active trip from API...');
      final response = await _apiClient.get('/driver/current-trip');
      if (response != null && response['data'] != null) {
        final trip = TripModel.fromJson(response['data']);
        tripId = trip.id;
        print('✅ Got tripId from active trip API: $tripId');
        loadTripDetails();
        loadBoardingList();
      }
    } catch (e) {
      print('❌ Error loading active trip: $e');
    }
  }

  Future<void> loadTripDetails() async {
    if (tripId.isEmpty) return;

    try {
      print('📋 Loading trip details for: $tripId');
      final response = await _apiClient.get('/trips/$tripId');

      if (response != null && response['data'] != null) {
        final tripData = response['data'];
        final trip = tripData['trip'] ?? tripData;

        _currentTripDetails.value = TripModel.fromJson(trip);
        _currentTripRoute.value = '${trip['origin']} → ${trip['destination']}';
        print('✅ Trip details loaded: ${_currentTripRoute.value}');
      } else {
        print('⚠️ Trip details response empty');
      }
    } catch (e) {
      print('❌ Error loading trip details: $e');
    }
  }

  void _setupSocketListeners() {
    _socketService.on('passenger_checked_in', _handlePassengerCheckIn);
  }

  Future<void> loadBoardingList() async {
    if (tripId.isEmpty) {
      print('⚠️ Cannot load boarding list: tripId is empty');
      return;
    }

    try {
      _isLoading.value = true;
      print('📋 Loading boarding list for trip: $tripId');

      List<PassengerModel> allPassengers = [];

      // Try multiple endpoints
      final endpoints = [
        '/driver/boarding-list/$tripId',
        '/tickets/by-trip/$tripId',
        '/bookings/by-trip/$tripId',
        '/driver/passenger-list/$tripId',
      ];

      for (final endpoint in endpoints) {
        try {
          print('🔍 Trying endpoint: $endpoint');
          final response = await _apiClient.get(endpoint);

          if (response != null && response['data'] != null) {
            final List<dynamic> data = response['data'];
            if (data.isNotEmpty) {
              allPassengers = data.map((p) => PassengerModel.fromJson(p as Map<String, dynamic>)).toList();
              print('✅ Found ${allPassengers.length} passengers from $endpoint');
              if (allPassengers.isNotEmpty) break;
            }
          }
        } catch (e) {
          print('⚠️ Endpoint $endpoint failed: $e');
        }
      }

      // If still no passengers, check if trip has any bookings
      if (allPassengers.isEmpty) {
        print('📋 No passengers found from regular endpoints, checking trip details...');

        // Get trip details to see route information
        final tripResponse = await _apiClient.get('/trips/$tripId');
        if (tripResponse != null && tripResponse['data'] != null) {
          final tripData = tripResponse['data'];
          final trip = tripData['trip'] ?? tripData;
          print('📋 Trip route: ${trip['origin']} → ${trip['destination']}');

          // Try to get tickets by route
          final ticketsResponse = await _apiClient.get(
              '/tickets/search',
              queryParameters: {
                'origin': trip['origin'],
                'destination': trip['destination'],
                'date': DateTime.now().toIso8601String().substring(0, 10),
              }
          );

          if (ticketsResponse != null && ticketsResponse['data'] != null) {
            final List<dynamic> tickets = ticketsResponse['data'];
            allPassengers = tickets.map((t) => PassengerModel(
              id: t['_id'] ?? '',
              name: t['passengerName'] ?? 'Unknown',
              phone: t['passengerPhone'] ?? '',
              email: t['passengerEmail'],
              seatNumber: t['seatNumber'] ?? 'N/A',
              ticketNumber: t['ticketNumber'] ?? '',
              checkedIn: t['ticketStatus'] == 'used',
            )).toList();
            print('✅ Found ${allPassengers.length} passengers from route search');
          }
        }
      }

      if (allPassengers.isEmpty) {
        print('⚠️ No passengers found for trip $tripId');

        // For testing - create mock passengers
        print('📋 Creating mock passengers for testing...');
        allPassengers = List.generate(5, (index) => PassengerModel(
          id: 'mock_$index',
          name: 'Test Passenger ${index + 1}',
          phone: '09${10000000 + index}',
          email: 'test${index + 1}@example.com',
          seatNumber: '${index + 1}A',
          ticketNumber: 'TICKET${1000 + index}',
          checkedIn: false,
        ));

        // Show a snackbar to indicate mock data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppSnackbar.show(
            'Demo Mode',
            'Using mock data for testing. No real passengers found.',
          );
        });
      }

      _boardingList.value = allPassengers;
      _categorizePassengers();

      print('✅ Total passengers loaded: ${_boardingList.length}');
      print('📊 Checked in: ${_checkedInPassengers.length}, Pending: ${_pendingPassengers.length}');

    } catch (e) {
      print('❌ Error loading boarding list: $e');
      _boardingList.value = [];
      _checkedInPassengers.clear();
      _pendingPassengers.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  void _categorizePassengers() {
    _checkedInPassengers.value = _boardingList.where((p) => p.checkedIn).toList();
    _pendingPassengers.value = _boardingList.where((p) => !p.checkedIn).toList();
  }

  void _handlePassengerCheckIn(dynamic data) {
    if (data['tripId'] == tripId) {
      final passengerId = data['passengerId'];
      final index = _boardingList.indexWhere((p) => p.id == passengerId);

      if (index != -1) {
        _boardingList[index] = _boardingList[index].copyWith(checkedIn: true);
        _boardingList.refresh();
        _categorizePassengers();
      }
    }
  }

  Future<bool> validateTicket(String ticketCode) async {
    if (ticketCode.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbar.show('Error', 'Please enter a ticket code');
      });
      return false;
    }

    if (tripId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbar.show('Error', 'No active trip selected');
      });
      return false;
    }

    try {
      _isLoading.value = true;

      print('🔍 Validating ticket: $ticketCode for trip: $tripId');

      final response = await _apiClient.post(
        '/tickets/validate',
        data: {
          'tripId': tripId,  // Now this will have a value
          'ticketCode': ticketCode,
        },
      );

      print('📥 Validation response: $response');

      if (response != null && response['data'] != null) {
        final data = response['data'];

        if (data['valid'] == true) {
          final passengerData = data['passenger'] ?? {};
          final tripData = data['trip'] ?? {};

          final passenger = PassengerModel(
            id: passengerData['id']?.toString() ?? passengerData['ticketNumber']?.toString() ?? ticketCode,
            name: passengerData['name']?.toString() ?? 'Unknown',
            phone: passengerData['phone']?.toString() ?? '',
            email: passengerData['email']?.toString(),
            seatNumber: passengerData['seatNumber']?.toString() ?? '',
            ticketNumber: passengerData['ticketNumber']?.toString() ?? ticketCode,
            checkedIn: false,
            tripOrigin: tripData['origin']?.toString(),
            tripDestination: tripData['destination']?.toString(),
            departureTime: tripData['departureTime'] != null
                ? DateTime.tryParse(tripData['departureTime'].toString())
                : null,
          );

          _currentPassenger.value = passenger;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppSnackbar.show(
              'Ticket Valid',
              'Passenger: ${passenger.name}\nSeat: ${passenger.seatNumber}',
             // duration: const Duration(seconds: 3),
            );
          });

          return true;
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppSnackbar.show('Invalid Ticket', data['message'] ?? 'Ticket is not valid for this trip');
          });
          return false;
        }
      }
      return false;
    } catch (e) {
      print('Error validating ticket: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbar.show('Error', 'Failed to validate ticket. Please try again.');
      });
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> markPassengerCheckedIn(String passengerId) async {
    try {
      _isLoading.value = true;

      print('✅ Marking passenger checked in: $passengerId for trip: $tripId');

      final response = await _apiClient.post(
        '/driver/mark-checked-in',
        data: {
          'tripId': tripId,
          'passengerId': passengerId,
        },
      );

      print('📥 Check-in response: $response');

      if (response != null && response['success'] == true) {
        // Update local state
        final index = _boardingList.indexWhere((p) => p.id == passengerId);
        if (index != -1) {
          _boardingList[index] = _boardingList[index].copyWith(checkedIn: true);
          _boardingList.refresh();
          _categorizePassengers();
        }

        // Clear current passenger if it's the same one
        if (_currentPassenger.value?.id == passengerId) {
          _currentPassenger.value = null;
        }

        // Emit socket event
        _socketService.emit('passenger_checked_in', {
          'tripId': tripId,
          'passengerId': passengerId,
          'timestamp': DateTime.now().toIso8601String(),
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppSnackbar.show('Success', 'Passenger checked in successfully');
        });

        return true;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppSnackbar.show('Error', response?['message'] ?? 'Failed to check in passenger');
        });
        return false;
      }
    } catch (e) {
      print('Error marking passenger checked in: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbar.show('Error', 'Failed to check in passenger');
      });
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> searchPassenger(String query) async {
    _searchQuery.value = query;

    if (query.isEmpty) {
      _categorizePassengers();
      return;
    }

    final lowerQuery = query.toLowerCase();
    _pendingPassengers.value = _boardingList
        .where((p) => !p.checkedIn && (
        p.name.toLowerCase().contains(lowerQuery) ||
            p.ticketNumber.toLowerCase().contains(lowerQuery) ||
            p.seatNumber.toLowerCase().contains(lowerQuery)
    ))
        .toList();
  }

  void setBoardingMethod(BoardingMethod method) {
    _selectedBoardingMethod.value = method;
  }

  void setScanning(bool scanning) {
    _isScanning.value = scanning;
  }

  void clearCurrentPassenger() {
    _currentPassenger.value = null;
  }

  void refreshBoardingStatus() {
    loadBoardingList();
  }

  @override
  void onClose() {
    _socketService.off('passenger_checked_in', _handlePassengerCheckIn);
    super.onClose();
  }
}

enum BoardingMethod {
  scan,
  manual,
  list,
}