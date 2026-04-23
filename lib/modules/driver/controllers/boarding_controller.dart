import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/core/utils/app_snackbar.dart';

import '../../../data/models/passenger/passenger_model.dart';

class BoardingController extends GetxController {
  static BoardingController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;

  // Current trip ID
  String tripId = '';

  // Observables
  final _isLoading = false.obs;
  final _isScanning = false.obs;
  final _currentPassenger = Rxn<PassengerModel>();
  final _boardingList = <PassengerModel>[].obs;
  final _checkedInPassengers = <PassengerModel>[].obs;
  final _pendingPassengers = <PassengerModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedBoardingMethod = BoardingMethod.scan.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isScanning => _isScanning.value;
  PassengerModel? get currentPassenger => _currentPassenger.value;
  List<PassengerModel> get boardingList => _boardingList;
  List<PassengerModel> get checkedInPassengers => _checkedInPassengers;
  List<PassengerModel> get pendingPassengers => _pendingPassengers;
  String get searchQuery => _searchQuery.value;
  BoardingMethod get selectedMethod => _selectedBoardingMethod.value;

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
    // Try to get from arguments
    final args = Get.arguments;
    print('📦 BoardingController arguments: $args');

    if (args != null && args['tripId'] != null) {
      tripId = args['tripId'];
    }
    // Try to get from URL parameters
    else if (Get.parameters.containsKey('tripId')) {
      tripId = Get.parameters['tripId']!;
    }

    if (tripId.isEmpty) {
      print('⚠️ BoardingController: No tripId found');
    } else {
      print('✅ BoardingController: tripId = $tripId');
      loadBoardingList();
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

      final response = await _apiClient.get(
        '/driver/boarding-list/$tripId',
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> passengers = response['data'];
        _boardingList.value = passengers
            .map((p) => PassengerModel.fromJson(p as Map<String, dynamic>))
            .toList();

        _categorizePassengers();
        print('✅ Loaded ${_boardingList.length} passengers');
      } else {
        _boardingList.value = [];
      }
    } catch (e) {
      print('Error loading boarding list: $e');
      _boardingList.value = [];
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

    try {
      _isLoading.value = true;

      print('🔍 Validating ticket: $ticketCode for trip: $tripId');

      final response = await _apiClient.post(
        '/tickets/validate',
        data: {
          'tripId': tripId,
          'ticketCode': ticketCode,
        },
      );

      print('📥 Validation response: $response');

      if (response != null && response['data'] != null) {
        final data = response['data'];

        if (data['valid'] == true) {
          final passengerData = data['passenger'] ?? {};
          final passenger = PassengerModel(
            id: passengerData['id']?.toString() ?? passengerData['ticketNumber']?.toString() ?? ticketCode,
            name: passengerData['name']?.toString() ?? 'Unknown',
            phone: passengerData['phone']?.toString() ?? '',
            email: passengerData['email']?.toString(),
            seatNumber: passengerData['seatNumber']?.toString() ?? '',
            ticketNumber: passengerData['ticketNumber']?.toString() ?? ticketCode,
            checkedIn: false,
          );

          _currentPassenger.value = passenger;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppSnackbar.show(
              'Ticket Valid',
              'Passenger: ${passenger.name}\nSeat: ${passenger.seatNumber}',

            );
          });

          // Automatically check in after validation
          await markPassengerCheckedIn(passenger.id);

          return true;
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppSnackbar.show('Invalid Ticket', data['message'] ?? 'Ticket is not valid');
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