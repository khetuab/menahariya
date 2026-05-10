// lib/modules/admin/controllers/admin_trip_controller.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/trip/route_model.dart';
import '../../../data/models/trip/trip_model.dart';
import '../../../data/models/vehicle/vehicle_model.dart';
import '../../../data/models/user/user_model.dart';

// ==================== MODELS ====================

class DriverAvailabilityCheck {
  final bool available;
  final List<String> reasons;
  final bool autoAccept;

  DriverAvailabilityCheck({
    required this.available,
    required this.reasons,
    this.autoAccept = false,
  });

  factory DriverAvailabilityCheck.fromJson(Map<String, dynamic> json) {
    return DriverAvailabilityCheck(
      available: json['available'] ?? false,
      reasons: List<String>.from(json['reasons'] ?? []),
      autoAccept: json['autoAccept'] ?? false,
    );
  }
}

class DriverAvailabilityInfo {
  final DriverInfo driver;
  final bool available;
  final List<String> reasons;
  final bool autoAccept;

  DriverAvailabilityInfo({
    required this.driver,
    required this.available,
    required this.reasons,
    required this.autoAccept,
  });

  factory DriverAvailabilityInfo.fromJson(Map<String, dynamic> json) {
    return DriverAvailabilityInfo(
      driver: DriverInfo.fromJson(json['driver']),
      available: json['available'] ?? false,
      reasons: List<String>.from(json['reasons'] ?? []),
      autoAccept: json['autoAccept'] ?? false,
    );
  }
}

class DriverInfo {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final int totalTrips;

  DriverInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.totalTrips,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalTrips: json['totalTrips'] ?? 0,
    );
  }
}

class DriverAvailabilityResponse {
  final bool available;
  final List<String> reasons;
  final bool autoAccept;

  DriverAvailabilityResponse({
    required this.available,
    required this.reasons,
    this.autoAccept = false,
  });

  factory DriverAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return DriverAvailabilityResponse(
      available: json['available'] ?? false,
      reasons: List<String>.from(json['reasons'] ?? []),
      autoAccept: json['autoAccept'] ?? false,
    );
  }
}

// ==================== CONTROLLER ====================

class AdminTripController extends GetxController {
  static AdminTripController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  final searchController = TextEditingController();

  // Observables
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _trips = <TripModel>[].obs;
  final _filteredTrips = <TripModel>[].obs;
  final _selectedTrip = Rxn<TripModel>();
  final _vehicles = <VehicleModel>[].obs;
  final _drivers = <UserModel>[].obs;
  final _routes = <RouteModel>[].obs;
  final _searchQuery = ''.obs;
  final _statusFilter = ''.obs;
  final _dateFilter = Rxn<DateTime>();
  final _routeFilter = Rxn<String>();

  // Driver availability tracking
  final _driverAvailabilityMap = <String, DriverAvailabilityCheck>{}.obs;

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;
  final _totalCount = 0.obs;

  // Form controllers for creating/editing trips
  late final TextEditingController routeIdController;
  late final TextEditingController vehicleIdController;
  late final TextEditingController driverIdController;
  late final TextEditingController departureTimeController;
  late final TextEditingController arrivalTimeController;
  late final TextEditingController priceController;
  late final TextEditingController notesController;

  // Available drivers for auto-assignment
  final _availableDrivers = <DriverAvailabilityInfo>[].obs;
  final _isCheckingAvailability = false.obs;

  // ==================== GETTERS ====================

  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  List<TripModel> get trips => _filteredTrips;
  TripModel? get selectedTrip => _selectedTrip.value;
  List<VehicleModel> get vehicles => _vehicles;
  List<UserModel> get drivers => _drivers;
  List<RouteModel> get routes => _routes;
  String get searchQuery => _searchQuery.value;
  String get statusFilter => _statusFilter.value;
  DateTime? get dateFilter => _dateFilter.value;
  String? get routeFilter => _routeFilter.value;
  bool get hasMorePages => _hasMorePages.value;
  int get totalCount => _totalCount.value;

  // Driver availability getters
  Map<String, DriverAvailabilityCheck> get driverAvailabilityMap => _driverAvailabilityMap;
  List<DriverAvailabilityInfo> get availableDrivers => _availableDrivers;
  bool get isCheckingAvailability => _isCheckingAvailability.value;

  // Statistics
  int get totalTrips => _trips.length;
  int get scheduledTrips => _trips.where((t) => t.status == 'scheduled').length;
  int get inProgressTrips => _trips.where((t) => t.status == 'in_progress').length;
  int get completedTrips => _trips.where((t) => t.status == 'completed').length;
  int get cancelledTrips => _trips.where((t) => t.status == 'cancelled').length;

  // ==================== LIFECYCLE ====================

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchTrips();
    fetchDropdownData();
  }

  void _initializeControllers() {
    routeIdController = TextEditingController();
    vehicleIdController = TextEditingController();
    driverIdController = TextEditingController();
    departureTimeController = TextEditingController();
    arrivalTimeController = TextEditingController();
    priceController = TextEditingController();
    notesController = TextEditingController();
  }

  // ==================== DRIVER AVAILABILITY METHODS ====================

  // In admin_trip_controller.dart, update the checkDriverAvailabilityForTrip method

  Future<DriverAvailabilityCheck?> checkDriverAvailabilityForTrip(String driverId) async {
    try {
      final departureTime = departureTimeController.text;
      final routeId = routeIdController.text;

      if (departureTime.isEmpty) {
        print('⚠️ Departure time not set');
        return null;
      }

      // Get route details for distance
      double distance = 100;
      if (routeId.isNotEmpty) {
        final route = _routes.firstWhere(
              (r) => r.id == routeId,
          orElse: () => RouteModel(
            id: '',
            origin: '',
            destination: '',
            distance: 100,
            duration: 0,
            basePrice: 0,
            isActive: true,
            stops: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            name: '',
          ),
        );
        distance = route.distance ?? 100;
      }

      print('🔍 Checking availability for driver: $driverId');
      print('📅 Departure time: $departureTime');
      print('📏 Distance: $distance km');

      final response = await _apiClient.post(
        '/admin/drivers/check-availability',
        data: {
          'driverId': driverId,
          'departureTime': departureTime,
          'distance': distance,
          'type': 'Standard',
        },
      );

      if (response != null && response['data'] != null) {
        final availability = DriverAvailabilityCheck(
          available: response['data']['available'] ?? false,
          reasons: List<String>.from(response['data']['reasons'] ?? []),
          autoAccept: response['data']['autoAccept'] ?? false,
        );

        _driverAvailabilityMap[driverId] = availability;

        print('✅ Driver availability: ${availability.available}');
        if (!availability.available) {
          print('❌ Reasons: ${availability.reasons}');
        }

        return availability;
      }

      return null;

    } catch (e) {
      print('❌ Error checking driver availability: $e');

      // Return a default response for testing
      // This will prevent the trip from being created if driver is offline
      final defaultAvailability = DriverAvailabilityCheck(
        available: false,
        reasons: ['Unable to check availability. Please ensure driver is online and available.'],
        autoAccept: false,
      );
      _driverAvailabilityMap[driverId] = defaultAvailability;

      return defaultAvailability;
    }
  }

  /// Get all available drivers for a trip
  Future<List<DriverAvailabilityInfo>> getAvailableDriversForTrip({
    required DateTime departureTime,
    double distance = 100,
    String type = 'Standard',
  }) async {
    try {
      _isCheckingAvailability.value = true;

      final response = await _apiClient.get(
        '/admin/trips/available-drivers',
        queryParameters: {
          'departureTime': departureTime.toIso8601String(),
          'distance': distance,
          'type': type,
        },
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> driversData = response['data'];
        _availableDrivers.value = driversData
            .map((d) => DriverAvailabilityInfo.fromJson(d))
            .toList();
        return _availableDrivers;
      }
      return [];

    } catch (e) {
      print('Error getting available drivers: $e');
      AppSnackbar.show('Error', 'Failed to get available drivers');
      return [];
    } finally {
      _isCheckingAvailability.value = false;
    }
  }

  /// Auto-assign driver to a trip
  Future<Map<String, dynamic>?> autoAssignDriverToTrip(String tripId) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        '/admin/trips/$tripId/auto-assign-driver',
      );

      if (response != null && response['success'] == true) {
        AppSnackbar.show('Success', 'Driver auto-assigned successfully');
        await fetchTrips(refresh: true);
        return response['data'];
      }
      return null;

    } catch (e) {
      print('Error auto-assigning driver: $e');
      AppSnackbar.show('Error', 'Failed to auto-assign driver');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get available drivers (alias for backward compatibility)
  Future<List<DriverAvailabilityInfo>> getAvailableDrivers({
    required DateTime departureTime,
    double distance = 100,
    String type = 'Standard',
  }) async {
    return getAvailableDriversForTrip(
      departureTime: departureTime,
      distance: distance,
      type: type,
    );
  }

  /// Auto-assign driver (alias for backward compatibility)
  Future<Map<String, dynamic>?> autoAssignDriver(String tripId) async {
    return autoAssignDriverToTrip(tripId);
  }

  // ==================== TRIP CRUD OPERATIONS ====================

  /// Create trip with driver availability validation
  Future<bool> createTripWithValidation(Map<String, dynamic> tripData) async {
    try {
      _isLoading.value = true;

      // First check if driver is available
      final driverId = tripData['driverId'];
      if (driverId != null) {
        final availability = await checkDriverAvailabilityForTrip(driverId);

        if (availability != null && !availability.available) {
          _showUnavailableDriverDialog(availability);
          return false;
        }
      }

      // If available, create trip
      final response = await _apiClient.post(
        ApiEndpoints.trips,
        data: tripData,
      );

      if (response != null && response['success'] == true) {
        final newTrip = TripModel.fromJson(response['data']);
        _trips.insert(0, newTrip);
        _applyFilters();

        AppSnackbar.show('Success', 'Trip created successfully');

        if (response['driverAutoAccepted'] == true) {
          AppSnackbar.show(
            'Auto-accepted',
            'Driver will automatically accept this trip',
          );
        }

        await fetchTrips(refresh: true);
        return true;
      }
      return false;

    } catch (e) {
      print('Error creating trip: $e');
      AppSnackbar.show('Error', 'Failed to create trip');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Check driver availability (for validation)
  Future<DriverAvailabilityResponse> checkDriverAvailability({
    required String driverId,
    required DateTime departureTime,
    required double distance,
    required String type,
  }) async {
    try {
      final response = await _apiClient.post(
        '/admin/drivers/check-availability',
        data: {
          'driverId': driverId,
          'departureTime': departureTime.toIso8601String(),
          'distance': distance,
          'type': type,
        },
      );

      if (response != null && response['data'] != null) {
        return DriverAvailabilityResponse.fromJson(response['data']);
      }

      return DriverAvailabilityResponse(
        available: false,
        reasons: ['Unable to check availability'],
      );

    } catch (e) {
      print('Error checking driver availability: $e');
      return DriverAvailabilityResponse(
        available: false,
        reasons: ['Error checking availability'],
      );
    }
  }

  /// Create trip (simple version)
  Future<bool> createTrip(Map<String, dynamic> tripData) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.trips,
        data: tripData,
      );

      if (response != null && response['success'] == true) {
        final newTrip = TripModel.fromJson(response['data']);
        _trips.insert(0, newTrip);
        _applyFilters();
        AppSnackbar.show('Success', 'Trip created successfully');
        fetchTrips(refresh: true);
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating trip: $e');
      AppSnackbar.show('Error', 'Failed to create trip');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update trip
  Future<bool> updateTrip(String tripId, Map<String, dynamic> updates) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.patch(
        '${ApiEndpoints.trips}/$tripId',
        data: updates,
      );

      if (response != null && response['success'] == true) {
        await fetchTrips(refresh: true);
        AppSnackbar.show('Success', 'Trip updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating trip: $e');
      AppSnackbar.show('Error', 'Failed to update trip');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete trip
  Future<bool> deleteTrip(String tripId) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.delete('${ApiEndpoints.trips}/$tripId');

      if (response != null && response['success'] == true) {
        _trips.removeWhere((t) => t.id == tripId);
        _applyFilters();
        fetchTrips(refresh: true);
        AppSnackbar.show('Success', 'Trip deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting trip: $e');
      AppSnackbar.show('Error', 'Failed to delete trip');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Cancel trip
  Future<bool> cancelTrip(String tripId, String reason) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        '${ApiEndpoints.trips}/$tripId/cancel',
        data: {'reason': reason},
      );

      if (response != null && response['success'] == true) {
        _trips.removeWhere((trip) => trip.id == tripId);
        _applyFilters();
        fetchTrips(refresh: true);
        AppSnackbar.show('Success', 'Trip cancelled successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error cancelling trip: $e');
      AppSnackbar.show('Error', 'Failed to cancel trip');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get trip details
  Future<TripModel?> getTripDetails(String tripId) async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.get('${ApiEndpoints.trips}/$tripId');
      if (response != null && response['data'] != null) {
        final trip = TripModel.fromJson(response['data']);
        _selectedTrip.value = trip;
        return trip;
      }
      return null;
    } catch (e) {
      print('Error fetching trip details: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== FETCH METHODS ====================

  /// Fetch trips with pagination and filters
  Future<void> fetchTrips({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _trips.clear();
    }

    if (!_hasMorePages.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      final params = <String, dynamic>{
        'page': _currentPage.value,
        'limit': AppConstants.defaultPageSize,
      };

      if (_searchQuery.value.isNotEmpty) params['search'] = _searchQuery.value;
      if (_statusFilter.value.isNotEmpty) params['status'] = _statusFilter.value;
      if (_dateFilter.value != null) {
        params['date'] =
        '${_dateFilter.value!.year.toString().padLeft(4, '0')}-'
            '${_dateFilter.value!.month.toString().padLeft(2, '0')}-'
            '${_dateFilter.value!.day.toString().padLeft(2, '0')}';
      }
      if (_routeFilter.value != null) params['routeId'] = _routeFilter.value;

      final response = await _apiClient.get(
        ApiEndpoints.trips,
        queryParameters: params,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> tripsData = response['data'];
        final newTrips = tripsData.map((t) => TripModel.fromJson(t)).toList();

        if (_currentPage.value == 1) {
          _trips.value = newTrips;
        } else {
          _trips.addAll(newTrips);
        }

        _applyFilters();
        _totalCount.value = response['total'] ?? _trips.length;
        _hasMorePages.value = newTrips.length >= AppConstants.defaultPageSize;
        _currentPage.value++;
      }
    } catch (e) {
      print('Error fetching trips: $e');
      AppSnackbar.show('Error', 'Failed to load trips');
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  /// Fetch dropdown data (vehicles, drivers, routes)
  Future<void> fetchDropdownData() async {
    try {
      await Future.wait([
        _fetchVehicles(),
        _fetchDrivers(),
        _fetchRoutes(),
      ]);
    } catch (e) {
      print('Error fetching dropdown data: $e');
    }
  }

  Future<void> _fetchVehicles() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.vehicles);
      if (response != null && response['data'] != null) {
        final List<dynamic> vehiclesData = response['data'];
        _vehicles.value = vehiclesData.map((v) => VehicleModel.fromJson(v)).toList();
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
    }
  }

  Future<void> _fetchDrivers() async {
    try {
      print('🔍 [TRIP] Fetching drivers...');
      final response = await _apiClient.get(
        ApiEndpoints.users,
        queryParameters: {
          'role': 'driver',
          'limit': 100,
          'active': true,
        },
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> driversData = response['data'];
        _drivers.value = driversData.map((d) => UserModel.fromJson(d)).toList();
        print('✅ [TRIP] Found ${_drivers.length} drivers');
      } else {
        _drivers.value = [];
      }
    } catch (e) {
      print('❌ [TRIP] Error fetching drivers: $e');
      _drivers.value = [];
    }
  }

  Future<void> _fetchRoutes() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.routes);
      if (response != null && response['data'] != null) {
        final List<dynamic> routesData = response['data'];
        _routes.value = routesData.map((r) => RouteModel.fromJson(r)).toList();
      }
    } catch (e) {
      print('Error fetching routes: $e');
    }
  }

  // ==================== FILTER METHODS ====================

  void _applyFilters() {
    var filtered = List<TripModel>.from(_trips);

    if (_statusFilter.value.isNotEmpty) {
      filtered = filtered.where((t) => t.status == _statusFilter.value).toList();
    }

    if (_routeFilter.value != null && _routeFilter.value!.isNotEmpty) {
      filtered = filtered.where((t) => t.routeId == _routeFilter.value).toList();
    }

    if (_dateFilter.value != null) {
      filtered = filtered.where((t) {
        return DateUtils.isSameDay(
          t.departureTime.toLocal(),
          _dateFilter.value!,
        );
      }).toList();
    }

    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((t) =>
      t.origin.toLowerCase().contains(query) ||
          t.destination.toLowerCase().contains(query) ||
          t.id.toLowerCase().contains(query)
      ).toList();
    }

    _filteredTrips.value = filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    searchController.text = query;
    _applyFilters();
  }

  void setStatusFilter(String status) {
    _statusFilter.value = status;
    fetchTrips(refresh: true);
  }

  void setDateFilter(DateTime? date) {
    _dateFilter.value = date;
    fetchTrips(refresh: true);
  }

  void setRouteFilter(String? routeId) {
    _routeFilter.value = routeId;
    fetchTrips(refresh: true);
  }

  void clearFilters() {
    _searchQuery.value = '';
    _statusFilter.value = '';
    _dateFilter.value = null;
    _routeFilter.value = null;
    searchController.clear();
    fetchTrips(refresh: true);
  }

  Future<void> refreshTrips() async {
    _isRefreshing.value = true;
    await fetchTrips(refresh: true);
    _isRefreshing.value = false;
  }

  Future<void> loadMoreTrips() async {
    if (_hasMorePages.value && !_isLoading.value) {
      await fetchTrips();
    }
  }

  // ==================== DIALOG METHODS ====================

  void _showUnavailableDriverDialog(DriverAvailabilityCheck availability) {
    Get.dialog(
      AlertDialog(
        title: const Text('Driver Unavailable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This driver cannot be assigned to the trip for the following reasons:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...availability.reasons.map((reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(reason)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showAvailableDriversDialog();
            },
            child: const Text('View Available Drivers'),
          ),
        ],
      ),
    );
  }

  void _showAvailableDriversDialog() async {
    final departureTimeStr = departureTimeController.text;
    if (departureTimeStr.isEmpty) {
      AppSnackbar.show('Error', 'Please select departure time first');
      return;
    }

    final drivers = await getAvailableDriversForTrip(
      departureTime: DateTime.parse(departureTimeStr),
    );

    final availableDrivers = drivers.where((d) => d.available).toList();

    if (availableDrivers.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text('No Drivers Available'),
          content: const Text('No drivers are available for this trip time.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Available Drivers'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableDrivers.length,
            itemBuilder: (context, index) {
              final driver = availableDrivers[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(driver.driver.name[0].toUpperCase()),
                ),
                title: Text(driver.driver.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⭐ Rating: ${driver.driver.rating.toStringAsFixed(1)}'),
                    Text('🚕 Total Trips: ${driver.driver.totalTrips}'),
                    if (driver.autoAccept)
                      const Chip(
                        label: Text('Auto-Accept', style: TextStyle(fontSize: 10)),
                        backgroundColor: Colors.green,
                      ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    driverIdController.text = driver.driver.id;
                    AppSnackbar.show('Driver Selected', driver.driver.name);
                  },
                  child: const Text('Select'),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ==================== CLEANUP ====================

  @override
  void onClose() {
    routeIdController.dispose();
    vehicleIdController.dispose();
    driverIdController.dispose();
    departureTimeController.dispose();
    arrivalTimeController.dispose();
    priceController.dispose();
    notesController.dispose();
    searchController.dispose();
    super.onClose();
  }
}