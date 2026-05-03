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

  // Getters
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

  // Statistics
  int get totalTrips => _trips.length;
  int get scheduledTrips => _trips.where((t) => t.status == 'scheduled').length;
  int get inProgressTrips => _trips.where((t) => t.status == 'in_progress').length;
  int get completedTrips => _trips.where((t) => t.status == 'completed').length;
  int get cancelledTrips => _trips.where((t) => t.status == 'cancelled').length;

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

  void _applyFilters() {
    var filtered = List<TripModel>.from(_trips);

    // Apply status filter
    if (_statusFilter.value.isNotEmpty) {
      filtered = filtered.where((t) => t.status == _statusFilter.value).toList();
    }

    // Apply route filter
    if (_routeFilter.value != null && _routeFilter.value!.isNotEmpty) {
      filtered = filtered.where((t) => t.routeId == _routeFilter.value).toList();
    }

    // Apply date filter
    if (_dateFilter.value != null) {
      filtered = filtered.where((t) {
        return DateUtils.isSameDay(
          t.departureTime.toLocal(),
          _dateFilter.value!,
        );
      }).toList();
    }

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((t) =>
      t.origin.toLowerCase().contains(query) ||
          t.destination.toLowerCase().contains(query) ||
          t.id.toLowerCase().contains(query)).toList();
    }

    _filteredTrips.value = filtered;
  }

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
      // Change from '/users/drivers' to '/users?role=driver'
      final response = await _apiClient.get(
        ApiEndpoints.users,
        queryParameters: {
          'role': 'driver',
          'limit': 100,
          'active': true,
        },
      );

      print('📥 [TRIP] Drivers response status: ${response != null}');

      if (response != null && response['data'] != null) {
        final List<dynamic> driversData = response['data'];
        print('✅ [TRIP] Found ${driversData.length} drivers');

        _drivers.value = driversData.map((d) => UserModel.fromJson(d)).toList();
        print('📋 [TRIP] Drivers loaded: ${_drivers.length}');
      } else {
        print('⚠️ [TRIP] No drivers data found');
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

  Future<bool> createTrip(Map<String, dynamic> tripData) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.trips,
        data: tripData,
      );

      if (response != null && response['success'] == true) {

        final newTrip = TripModel.fromJson(response['data']);

        // Add immediately
        _trips.insert(0, newTrip);

        // Refresh filtered UI
        _applyFilters();

        AppSnackbar.show('Success', 'Trip created successfully');

        // Optional background refresh
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

  @override
  void onClose() {
    routeIdController.dispose();
    vehicleIdController.dispose();
    driverIdController.dispose();
    departureTimeController.dispose();
    searchController.dispose();
    arrivalTimeController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.onClose();
  }
}