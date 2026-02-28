// lib/modules/driver/controllers/trip_detail_controller.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/data/models/passenger/passenger_model.dart';
import 'package:menahariya/data/models/cargo/cargo_model.dart';
import 'package:menahariya/data/models/vehicle/vehicle_model.dart';

class DriverTripDetailController extends GetxController {
  static DriverTripDetailController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;

  // Trip ID from arguments
  late final String tripId;

  // Observables
  final _isLoading = false.obs;
  final _trip = Rxn<TripModel>();
  final _vehicle = Rxn<VehicleModel>();
  final _passengers = <PassengerModel>[].obs;
  final _cargoList = <CargoModel>[].obs;
  final _checkedInCount = 0.obs;
  final _totalPassengers = 0.obs;
  final _boardingProgress = 0.0.obs;
  final _departureTime = Rxn<DateTime>();
  final _estimatedArrival = Rxn<DateTime>();
  final _routeMap = Rxn<String>(); // URL or data for map

  // Getters
  bool get isLoading => _isLoading.value;
  TripModel? get trip => _trip.value;
  VehicleModel? get vehicle => _vehicle.value;
  List<PassengerModel> get passengers => _passengers;
  List<CargoModel> get cargoList => _cargoList;
  int get checkedInCount => _checkedInCount.value;
  int get totalPassengers => _totalPassengers.value;
  double get boardingProgress => _boardingProgress.value;
  DateTime? get departureTime => _departureTime.value;
  DateTime? get estimatedArrival => _estimatedArrival.value;
  String? get routeMap => _routeMap.value;

  // Computed getters
  bool get allPassengersCheckedIn => _checkedInCount.value >= _totalPassengers.value;
  int get pendingPassengers => _totalPassengers.value - _checkedInCount.value;
  String get boardingStatusText {
    if (allPassengersCheckedIn) return 'All passengers checked in';
    return '$pendingPassengers passengers remaining';
  }

  @override
  void onInit() {
    super.onInit();
    _getArguments();
    _loadTripDetails();
    _setupSocketListeners();
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

  // Handle trip updates from socket
  void handleTripUpdate(Map<String, dynamic> data) {
    if (data['tripId'] == tripId) {
      final String status = data['status'];

      // Update trip status
      _trip.update((trip) {
        if (trip != null && status.isNotEmpty) {
          trip.status = status;
        }
      });

      // Refresh data
      refreshTripDetails();
    }
  }

  // Get active trip IDs for socket reconnection
  List<String> getActiveTripIds() {
    return [tripId];
  }
  void _setupSocketListeners() {
    _socketService.on('passenger_checked_in', _handlePassengerCheckIn);
    _socketService.on('cargo_updated', _handleCargoUpdate);
    _socketService.on('trip_status_changed', _handleTripStatusChange);
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
        _vehicle.value = VehicleModel.fromJson(data['vehicle']);
        _passengers.value = (data['passengers'] as List)
            .map((p) => PassengerModel.fromJson(p))
            .toList();
        _cargoList.value = (data['cargo'] as List)
            .map((c) => CargoModel.fromJson(c))
            .toList();

        _totalPassengers.value = _passengers.length;
        _checkedInCount.value = _passengers.where((p) => p.checkedIn).length;
        _calculateBoardingProgress();

        _departureTime.value = DateTime.parse(data['trip']['departureTime']);
        _estimatedArrival.value = DateTime.parse(data['trip']['arrivalTime']);
        _routeMap.value = data['routeMap'];
      }
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

  void _handlePassengerCheckIn(dynamic data) {
    if (data['tripId'] == tripId) {
      final passengerId = data['passengerId'];
      final index = _passengers.indexWhere((p) => p.id == passengerId);

      if (index != -1) {
        _passengers[index] = _passengers[index].copyWith(checkedIn: true);
        _checkedInCount.value++;
        _calculateBoardingProgress();

        _passengers.refresh();
      }
    }
  }

  void _handleCargoUpdate(dynamic data) {
    if (data['tripId'] == tripId) {
      _loadTripDetails(); // Reload all cargo data
    }
  }

  void _handleTripStatusChange(dynamic data) {
    if (data['tripId'] == tripId) {
      final newStatus = data['status'];
      _trip.update((val) {
        val?.status = newStatus;
      });
    }
  }

  void _calculateBoardingProgress() {
    if (_totalPassengers.value == 0) {
      _boardingProgress.value = 0;
    } else {
      _boardingProgress.value = _checkedInCount.value / _totalPassengers.value;
    }
  }

  void refreshTripDetails() {
    _loadTripDetails();
  }

  Future<void> updateTripStatus(String status) async {
    try {
      await _apiClient.patch(
        '${ApiEndpoints.trips}/$tripId/status',
        data: {'status': status},
      );

      _trip.update((val) {
        val?.status = status;
      });

      Get.snackbar(
        'Success',
        'Trip status updated to $status',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error updating trip status: $e');
      Get.snackbar(
        'Error',
        'Failed to update trip status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<PassengerModel> getPassengersByBoardingStatus(bool checkedIn) {
    return _passengers.where((p) => p.checkedIn == checkedIn).toList();
  }

  Map<String, int> getPassengerStatistics() {
    return {
      'total': _totalPassengers.value,
      'checkedIn': _checkedInCount.value,
      'pending': pendingPassengers,
    };
  }

  @override
  void onClose() {
    _socketService.off('passenger_checked_in', _handlePassengerCheckIn);
    _socketService.off('cargo_updated', _handleCargoUpdate);
    _socketService.off('trip_status_changed', _handleTripStatusChange);
    super.onClose();
  }
}