// lib/modules/passenger/controllers/trip_detail_controller.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';

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

  // Getters
  bool get isLoading => _isLoading.value;
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

        _trip.value = TripModel.fromJson(data['trip']);
        _amenities.value = (data['amenities'] as List)
            .map((a) => AmenityModel.fromJson(a))
            .toList();
        _busImages.value = List<String>.from(data['images'] ?? []);
        _reviews.value = (data['reviews'] as List)
            .map((r) => Review.fromJson(r))
            .toList();

        _calculateAverageRating();
      }

      // Load seats separately
      await _loadSeats();
    } catch (e) {
      print('Error loading trip details: $e');
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
      final response = await _apiClient.get(
        ApiEndpoints.seatsAvailable,
        queryParameters: {'trip_id': tripId},
      );

      if (response != null && response['data'] != null) {
        final data = response['data'];
        _seatLayout.value = data['layout'] ?? {};

        final List<dynamic> seatsList = data['seats'] ?? [];
        _seats.value = seatsList
            .map((s) => SeatModel.fromJson(s))
            .toList();
      }
    } catch (e) {
      print('Error loading seats: $e');
    }
  }

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

  void toggleSeatSelection(SeatModel seat) {
    if (seat.status != 'available') return;

    void toggleSeatSelection(SeatModel seat) {
      if (seat.status != 'available') return;

      if (_selectedSeats.contains(seat)) {
        _selectedSeats.remove(seat);
        _releaseSeatLock(seat);
      } else {
        // Ensure RHS is not null
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
    }
  }

  void _lockSeat(SeatModel seat) {
    _socketService.lockSeat(
      tripId,
      int.parse(seat.number),
      AppConstants.seatLockDuration,
    );
  }

  void _releaseSeatLock(SeatModel seat) {
    _socketService.releaseSeat(
      tripId,
      int.parse(seat.number),
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
    } catch (e) {
      print('Error toggling favorite: $e');
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
    }
  }

  void proceedToBooking() {
    if (_selectedSeats.isEmpty) {
      Get.snackbar(
        'No Seats Selected',
        'Please select at least one seat to continue',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      '/passenger/booking/summary',
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
      id: json['id'],
      userName: json['userName'],
      userImage: json['userImage'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      date: DateTime.parse(json['date']),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }
}