// lib/modules/driver/controllers/dashboard_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/core/utils/app_snackbar.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';
import 'package:menahariya/modules/driver/controllers/assigned_trips_controller.dart';
import 'package:menahariya/modules/driver/controllers/trip_detail_controller.dart';
import 'package:menahariya/modules/driver/controllers/boarding_controller.dart';
import 'package:menahariya/modules/driver/controllers/validation_controller.dart';
import 'package:menahariya/modules/driver/controllers/passenger_list_controller.dart';
import 'package:menahariya/modules/driver/controllers/cargo_list_controller.dart';
import 'package:menahariya/modules/driver/controllers/trip_status_controller.dart';
import 'package:menahariya/modules/driver/controllers/incident_controller.dart';
import 'package:menahariya/modules/driver/controllers/profile_controller.dart';
import 'package:menahariya/modules/driver/controllers/notification_controller.dart';

import 'driver_state_controller.dart';

class DriverDashboardController extends GetxController {
  static DriverDashboardController get instance => Get.find();
  final DriverStateController _driverStateController = Get.find<DriverStateController>();

  // Core services
  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;
  final AuthController _authController = AuthController.instance;

  // Child controllers (will be lazy loaded)
  late final AssignedTripsController assignedTripsController;
  late final DriverTripDetailController tripDetailController;
  late final BoardingController boardingController;
  late final ValidationController validationController;
  late final PassengerListController passengerListController;
  late final CargoListController cargoListController;
  late final TripStatusController tripStatusController;
  late final IncidentController incidentController;
  late final DriverProfileController profileController;
  late final DriverNotificationController notificationController;

  // Observables
  final _currentIndex = 0.obs;
  final _isLoading = false.obs;
  final _driverName = ''.obs;
  final _todayTrips = 0.obs;
  final _completedTrips = 0.obs;
  final _totalPassengers = 0.obs;
  final _totalCargo = 0.obs;
  final _currentTrip = Rxn<TripModel>();
  final _upcomingTrips = <TripModel>[].obs;
  final _notificationsCount = 0.obs;

  // Getters
  int get currentIndex => _currentIndex.value;
  bool get isLoading => _isLoading.value;
  String get driverName => _driverName.value;
  bool get isOnline => _driverStateController.isOnline.value;
  int get todayTrips => _todayTrips.value;
  int get completedTrips => _completedTrips.value;
  int get totalPassengers => _totalPassengers.value;
  int get totalCargo => _totalCargo.value;
  TripModel? get currentTrip => _currentTrip.value;
  List<TripModel> get upcomingTrips => _upcomingTrips;
  int get notificationsCount => _notificationsCount.value;

  // Screen titles and icons
  final List<String> screenTitles = const [
    'Dashboard',
    'Trips',
    'Boarding',
    'Profile',
  ];

  final List<IconData> screenIcons = const [
    Icons.dashboard_rounded,
    Icons.route_rounded,
    Icons.airport_shuttle_rounded,
    //Icons.qr_code_scanner_rounded,
    Icons.person_rounded,
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadDriverData();
    _setupSocketListeners();
    // Listen to centralized state changes
    ever(_driverStateController.isOnline, (_) {
      // Refresh dashboard when online status changes
      refreshDashboard();
    });
  }


  // Update the _initializeControllers method in dashboard_controller.dart

  void _initializeControllers() {
    // Use try-catch to handle controllers that might not exist yet
    try {
      assignedTripsController = Get.find<AssignedTripsController>();
    } catch (e) {
      assignedTripsController = Get.put(AssignedTripsController());
    }

    // try {
    //   tripDetailController = Get.find<DriverTripDetailController>();
    // } catch (e) {
    //   tripDetailController = Get.put(DriverTripDetailController());
    // }

    try {
      boardingController = Get.find<BoardingController>();
    } catch (e) {
      boardingController = Get.put(BoardingController());
    }

    try {
      validationController = Get.find<ValidationController>();
    } catch (e) {
      validationController = Get.put(ValidationController());
    }

    try {
      passengerListController = Get.find<PassengerListController>();
    } catch (e) {
      passengerListController = Get.put(PassengerListController());
    }

    try {
      cargoListController = Get.find<CargoListController>();
    } catch (e) {
      cargoListController = Get.put(CargoListController());
    }

    try {
      tripStatusController = Get.find<TripStatusController>();
    } catch (e) {
      tripStatusController = Get.put(TripStatusController());
    }

    try {
      incidentController = Get.find<IncidentController>();
    } catch (e) {
      incidentController = Get.put(IncidentController());
    }

    try {
      profileController = Get.find<DriverProfileController>();
    } catch (e) {
      profileController = Get.put(DriverProfileController());
    }

    try {
      notificationController = Get.find<DriverNotificationController>();
    } catch (e) {
      notificationController = Get.put(DriverNotificationController());
    }
  }


  Future<void> _loadTodayStats() async {
    try {
      final response = await _apiClient.get(
        '/driver/today-stats',
      );

      if (response != null && response['data'] != null) {
        _todayTrips.value = response['data']['todayTrips'] ?? 0;
        _completedTrips.value = response['data']['completedTrips'] ?? 0;
        _totalPassengers.value = response['data']['totalPassengers'] ?? 0;
        // Fix: Get cargo count from the response
        _totalCargo.value = response['data']['totalCargo'] ?? 0;

        print('📊 Driver stats - Cargo: ${_totalCargo.value}, Passengers: ${_totalPassengers.value}');
      }
    } catch (e) {
      print('Error loading today stats: $e');
      // If API fails, try to get from assigned trips
      await _loadCargoFromTrips();
    }
  }

// Add this method to fetch cargo from assigned trips
  Future<void> _loadCargoFromTrips() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.driverAssignedTrips,
        queryParameters: {'status': 'scheduled', 'limit': 10},
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> trips = response['data'];
        int totalCargo = 0;
        for (var trip in trips) {
          final tripId = trip['_id'];
          final cargoResponse = await _apiClient.get('/driver/cargo-list/$tripId');
          if (cargoResponse != null && cargoResponse['data'] != null) {
            totalCargo += (cargoResponse['data'] as List).length;
          }
        }
        _totalCargo.value = totalCargo;
      }
    } catch (e) {
      print('Error loading cargo from trips: $e');
    }
  }

  Future<void> _loadDriverData() async {
    try {
      _isLoading.value = true;

      // Set driver name from auth controller
      _driverName.value = _authController.currentUser?.fullName.split(' ').first ?? 'Driver';

      // Load dashboard statistics
      await Future.wait([
        _loadTodayStats(),
        _loadCurrentTrip(),
        _loadUpcomingTrips(),
        _loadNotificationsCount(),
      ]);
    } catch (e) {
      print('Error loading driver data : $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _setupSocketListeners() {
    // Listen for real-time updates
    _socketService.on('trip_assigned', _handleNewTripAssignment);
    _socketService.on('trip_updated', _handleTripUpdate);
    _socketService.on('boarding_update', _handleBoardingUpdate);
  }



  Future<void> _loadCurrentTrip() async {
    try {
      final response = await _apiClient.get(
        '/driver/current-trip',
      );

      if (response != null && response['data'] != null) {
        _currentTrip.value = TripModel.fromJson(response['data']);
      }
    } catch (e) {
      print('Error loading current trip: $e');
    }
  }

  Future<void> _loadUpcomingTrips() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.driverTrips,
        queryParameters: {'status': 'scheduled', 'limit': 5},
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> trips = response['data'];
        _upcomingTrips.value = trips.map((t) => TripModel.fromJson(t)).toList();
      }
    } catch (e) {
      print('Error loading upcoming trips: $e');
    }
  }

  Future<void> _loadNotificationsCount() async {
    try {
      final response = await _apiClient.get(
        '/driver/notifications/unread-count',
      );

      if (response != null && response['data'] != null) {
        _notificationsCount.value = response['data']['count'] ?? 0;
      }
    } catch (e) {
      print('Error loading notifications count: $e');
    }
  }

  void _handleNewTripAssignment(dynamic data) {
    _loadUpcomingTrips();
    _notificationsCount.value++;

    AppSnackbar.show(
      'New Trip Assigned',
      'You have a new trip assignment',
    );
  }

  void _handleTripUpdate(dynamic data) {
    _loadCurrentTrip();
    _loadUpcomingTrips();
  }

  void _handleBoardingUpdate(dynamic data) {
    // Refresh boarding status
    boardingController.refreshBoardingStatus();
  }

  void changeTab(int index) {
    if (_currentIndex.value == index) return;
    _currentIndex.value = index;
  }

  Future<void> toggleDriverStatus(bool online) async {
    await _driverStateController.updateDriverStatus(online);
  }

  Future<void> refreshDashboard() async {
    _loadDriverData();
  }

  void markNotificationsAsRead() {
    _notificationsCount.value = 0;
  }

  @override
  void onClose() {
    _socketService.off('trip_assigned', _handleNewTripAssignment);
    _socketService.off('trip_updated', _handleTripUpdate);
    _socketService.off('boarding_update', _handleBoardingUpdate);
    super.onClose();
  }
}