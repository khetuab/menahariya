// lib/modules/passenger/controllers/trip_detail_controller.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/core/utils/extensions/string_extension.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/amenity/amenity_model.dart';
import '../../../data/models/ticket/seat_model.dart';

class PassengerTripDetailController extends GetxController {
  static PassengerTripDetailController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;

  // Trip ID from arguments
  late final String tripId;

  // Observables
  final _isLoading = false.obs;
  final _trip = Rxn<TripModel>();
  final _seats = <SeatModel>[].obs;
  final _selectedSeats = <SeatModel>[].obs;
  final _amenities = <AmenityModel>[].obs;
  final _busImages = <String>[].obs;
  final _reviews = <Review>[].obs;
  final _averageRating = 0.0.obs;
  final _totalReviews = 0.obs;
  final _isFavorite = false.obs;

  // Seat layout
  final _seatLayout = <String, dynamic>{}.obs;
  final _isLoadingSeats = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoadingSeats => _isLoadingSeats.value;
  TripModel? get trip => _trip.value;
  List<SeatModel> get seats => _seats;
  List<SeatModel> get selectedSeats => _selectedSeats;
  List<AmenityModel> get amenities => _amenities;
  List<String> get busImages => _busImages;
  List<Review> get reviews => _reviews;
  double get averageRating => _averageRating.value;
  int get totalReviews => _totalReviews.value;
  bool get isFavorite => _isFavorite.value;
  Map<String, dynamic> get seatLayout => _seatLayout;

  // Computed getters
  double get totalPrice {
    return _selectedSeats.fold<double>(
      0,
          (sum, seat) => sum + (seat.price ?? _trip.value?.price ?? 0),
    );
  }

  String get formattedTotalPrice => CurrencyFormatter.format(totalPrice);

  int get availableSeatsCount {
    return _seats.where((s) => s.status == 'available').length;
  }

  @override
  void onInit() {
    super.onInit();
    _getArguments();
    _loadTripDetails();
    _setupSocketListeners();
    _checkFavoriteStatus();
  }


  void _getArguments() {
    final args = Get.arguments;
    if (args != null && args['tripId'] != null) {
      tripId = args['tripId'];
    } else {
      Get.back();
      Get.snackbar(
        'Error',
        'Trip information not found',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _setupSocketListeners() {
    // Listen for real-time seat updates
    _socketService.on('seat_update', _handleSeatUpdate);
    _socketService.on('seat_locked', _handleSeatLocked);
    _socketService.on('seat_released', _handleSeatReleased);

    // Join trip room for real-time updates
    _socketService.joinTripRoom(tripId);
  }

  void handleTripUpdate(Map<String, dynamic> data) {
    if (data['tripId'] == tripId) {
      final String status = data['status'];
      final DateTime? departureTime = data['departureTime'] != null
          ? DateTime.parse(data['departureTime'])
          : null;
      final DateTime? arrivalTime = data['arrivalTime'] != null
          ? DateTime.parse(data['arrivalTime'])
          : null;

      // Update trip data
      _trip.update((trip) {
        if (trip != null) {
          if (status.isNotEmpty) trip.status = status;
          if (departureTime != null) trip.departureTime = departureTime;
          if (arrivalTime != null) trip.arrivalTime = arrivalTime;
        }
      });

      // Show notification
      Get.snackbar(
        'Trip Update',
        'Your trip status has been updated to $status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update driver location from socket
  void updateDriverLocation(Map<String, dynamic> data) {
    if (data['tripId'] == tripId) {
      final double lat = data['lat'];
      final double lng = data['lng'];

      // Update driver location on map
      // This would be used if you have a map view
      print('Driver location updated: $lat, $lng');
    }
  }

  Future<void> _loadTripDetails() async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '${ApiEndpoints.tripsDetails}/$tripId',
      );

      if (response != null && response['data'] != null) {
        final data = response['data'];

        // Safely parse trip data
        _trip.value = TripModel.fromJson(data['trip'] ?? {});

        // Safely parse amenities
        if (data['amenities'] != null && data['amenities'] is List) {
          _amenities.value = (data['amenities'] as List)
              .map((a) => a is Map<String, dynamic>
              ? AmenityModel.fromJson(a)
              : AmenityModel.fromJson({'name': a.toString()}))
              .toList();
        }

        // Safely parse images
        _busImages.value = data['images'] != null && data['images'] is List
            ? List<String>.from(data['images'])
            : [];

        // Safely parse reviews
        if (data['reviews'] != null && data['reviews'] is List) {
          _reviews.value = (data['reviews'] as List)
              .whereType<Map<String, dynamic>>()
              .map((r) => Review.fromJson(r))
              .toList();
        }

        _calculateAverageRating();
      }

      // Load seats after trip details
      await _loadSeats();
    } catch (e) {
      print('❌ Error loading trip details: $e');
      Get.snackbar(
        'Error',
        'Failed to load trip details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadSeats() async {
    try {
      _isLoadingSeats.value = true;

      print('🪑 Loading seats for trip: $tripId');

      final response = await _apiClient.get(
        ApiEndpoints.seatsAvailable,
        queryParameters: {'trip_id': tripId},
      );

      if (response != null && response['data'] != null) {
        final data = response['data'];
        print('✅ Seats API response received');
        print('📦 Response data keys: ${data.keys}');

        // Parse seat layout if available
        if (data['layout'] != null) {
          _seatLayout.value = Map<String, dynamic>.from(data['layout']);
          print('📐 Seat layout loaded: ${_seatLayout.keys}');
          print('📐 Layout rows: ${_seatLayout['rows']}');
          print('📐 Layout columns: ${_seatLayout['columns']}');
        } else {
          // Create default layout if not provided
          _seatLayout.value = {
            'rows': 12,
            'columns': 4,
            'layout': '2+2',
            'windowSeats': ['A1', 'A4', 'B1', 'B4'],
            'aisleSeats': ['A2', 'A3', 'B2', 'B3'],
            'exitSeats': ['A1', 'A4', 'L1', 'L4']
          };
          print('📐 Using default seat layout');
        }

        // if (data['layout'] == null) {
        //   // Create a default layout based on the seats we have
        //   if (_seats.isNotEmpty) {
        //     final rows = _seats.map((s) => s.row).toSet().toList()..sort();
        //     final columns = _seats.map((s) => s.column).reduce((a, b) => a > b ? a : b);
        //
        //     _seatLayout.value = {
        //       'rows': rows.length,
        //       'columns': columns,
        //       'layout': '2+2',
        //     };
        //     print('📐 Created dynamic layout: ${_seatLayout.value}');
        //   }
        // }
        // Parse seats
        if (data['seats'] != null && data['seats'] is List) {
          final seatsList = data['seats'] as List;
          print('🔢 Raw seats count: ${seatsList.length}');

          // Log first seat for debugging
          if (seatsList.isNotEmpty) {
            print('📌 First seat data: ${seatsList.first}');
          }

          _seats.value = seatsList
              .map((s) {
            try {
              return SeatModel.fromJson(s);
            } catch (e) {
              print('❌ Error parsing seat: $e, data: $s');
              return null;
            }
          })
              .whereType<SeatModel>()
              .toList();

          print('✅ Parsed ${_seats.length} seats from API');

          // Log seat status distribution
          final available = _seats.where((s) => s.status == 'available').length;
          final booked = _seats.where((s) => s.status == 'booked').length;
          final locked = _seats.where((s) => s.status == 'locked').length;
          print('📊 Seat stats - Available: $available, Booked: $booked, Locked: $locked');

          // Log first few seats for verification
          if (_seats.isNotEmpty) {
            print('✅ First seat: ${_seats.first.number} - ${_seats.first.status}');
          }
        } else {
          print('⚠️ No seats data in response');
          _seats.value = [];
        }
      } else {
        print('⚠️ Invalid response format for seats');
        _seats.value = [];
      }
    } catch (e) {
      print('❌ Error loading seats: $e');
      _seats.value = [];
      Get.snackbar(
        'Error',
        'Failed to load seats. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingSeats.value = false;
    }
  }
  // REMOVED: _generateMockSeats method - No more mock data!

  void _calculateAverageRating() {
    if (_reviews.isEmpty) {
      _averageRating.value = 0;
      _totalReviews.value = 0;
      return;
    }

    _totalReviews.value = _reviews.length;
    final sum = _reviews.fold<double>(0, (sum, r) => sum + r.rating);
    _averageRating.value = sum / _reviews.length;
  }

  void _handleSeatUpdate(dynamic data) {
    if (data['tripId'] == tripId) {
      _loadSeats();
    }
  }

  void _handleSeatLocked(dynamic data) {
    if (data['tripId'] == tripId) {
      final seatNumber = data['seatNumber'];
      final index = _seats.indexWhere((s) => s.number == seatNumber);

      if (index != -1) {
        _seats[index] = _seats[index].copyWith(
          status: 'locked',
          lockedUntil: DateTime.parse(data['lockedUntil']),
        );
        _seats.refresh();
      }
    }
  }

  // In PassengerTripDetailController, add this getter:

  bool get isTripBookable {
    if (_trip.value == null) return false;

    // Check if trip status is 'scheduled'
    final isScheduled = _trip.value!.status.toLowerCase() == 'scheduled';

    // Check if departure time is in the future (at least 30 minutes from now)
    final now = DateTime.now();
    final departureTime = _trip.value!.departureTime;
    final isFutureTrip = departureTime.isAfter(now.add(const Duration(minutes: 30)));

    return isScheduled && isFutureTrip;
  }

  String get tripBookabilityMessage {
    if (_trip.value == null) return 'Trip information not available';

    if (_trip.value!.status.toLowerCase() != 'scheduled') {
      return 'This trip is ${_trip.value!.status} and cannot be booked';
    }

    final now = DateTime.now();
    final departureTime = _trip.value!.departureTime;
    if (!departureTime.isAfter(now.add(const Duration(minutes: 30)))) {
      return 'Booking closed - Trip departs soon';
    }

    return 'Available for booking';
  }

  void _handleSeatReleased(dynamic data) {
    if (data['tripId'] == tripId) {
      final seatNumber = data['seatNumber'];
      final index = _seats.indexWhere((s) => s.number == seatNumber);

      if (index != -1) {
        _seats[index] = _seats[index].copyWith(status: 'available');
        _seats.refresh();
      }
    }
  }

  // In PassengerTripDetailController, update toggleSeatSelection:

  void toggleSeatSelection(SeatModel seat) {
    if (seat.status != 'available') return;

    if (_selectedSeats.contains(seat)) {
      _selectedSeats.remove(seat);
      _releaseSeatLock(seat);
    } else {
      final maxSeats = _trip.value?.maxSeatsPerBooking ?? 10;

      if (_selectedSeats.length < maxSeats) {
        _selectedSeats.add(seat);
        _lockSeat(seat);
      } else {
        Get.snackbar(
          'Maximum Seats',
          'You can only select up to $maxSeats seats',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    // Refresh the UI
    update();
  }

  void _lockSeat(SeatModel seat) {
    _socketService.lockSeat(
      tripId,
      seat.number.toIntOrNull()!, // Fixed: seat.number is String, no need to parse int
      AppConstants.seatLockDuration,
    );
  }

  void _releaseSeatLock(SeatModel seat) {
    _socketService.releaseSeat(
      tripId,
      seat.number.toIntOrNull()!, // Fixed: seat.number is String, no need to parse int
    );
  }

  Future<void> toggleFavorite() async {
    try {
      if (_isFavorite.value) {
        await _apiClient.delete('/favorites/trip/$tripId');
      } else {
        await _apiClient.post('/favorites/trip', data: {'tripId': tripId});
      }
      _isFavorite.value = !_isFavorite.value;

      Get.snackbar(
        'Success',
        _isFavorite.value ? 'Added to favorites' : 'Removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error toggling favorite: $e');
      Get.snackbar(
        'Error',
        'Failed to update favorite',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final response = await _apiClient.get('/favorites/check/trip/$tripId');
      if (response != null && response['data'] != null) {
        _isFavorite.value = response['data']['isFavorite'] ?? false;
      }
    } catch (e) {
      print('Error checking favorite status: $e');
      // Don't show error to user, just log it
    }
  }

  // In PassengerTripDetailController, update the proceedToBooking method:

  void proceedToBooking() {
    if (_selectedSeats.isEmpty) {
      Get.snackbar(
        'No Seats Selected',
        'Please select at least one seat to continue',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Use the correct route name from AppRoutes
    Get.toNamed(
      AppRoutes.passengerBookingSummary, // This is '/passenger/booking-summary'
      arguments: {
        'trip': _trip.value,
        'selectedSeats': _selectedSeats.map((s) => s.toJson()).toList(),
        'totalPrice': totalPrice,
      },
    );
  }

  void viewAllReviews() {
    Get.toNamed(
      '/passenger/trip/reviews',
      arguments: {'tripId': tripId},
    );
  }

  void viewBusImages() {
    Get.toNamed(
      '/passenger/trip/images',
      arguments: {'images': _busImages},
    );
  }

  void reportIssue() {
    Get.toNamed(
      '/passenger/trip/report',
      arguments: {'tripId': tripId},
    );
  }

  @override
  void onClose() {
    // Release any locked seats
    for (var seat in _selectedSeats) {
      _releaseSeatLock(seat);
    }

    // Remove socket listeners
    _socketService.off('seat_update', _handleSeatUpdate);
    _socketService.off('seat_locked', _handleSeatLocked);
    _socketService.off('seat_released', _handleSeatReleased);

    // Leave trip room
    _socketService.leaveTripRoom(tripId);

    super.onClose();
  }
}

class Review {
  final String id;
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String>? images;

  Review({
    required this.id,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    required this.date,
    this.images,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? json['id'] ?? '',
      userName: json['userName'] ?? json['user']?['name'] ?? 'Anonymous',
      userImage: json['userImage'] ?? json['user']?['image'],
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      date: DateTime.parse(json['date'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }
}