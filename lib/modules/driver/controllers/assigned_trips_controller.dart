// lib/modules/driver/controllers/assigned_trips_controller.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';

class AssignedTripsController extends GetxController {
  static AssignedTripsController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Observables
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _assignedTrips = <TripModel>[].obs;
  final _filteredTrips = <TripModel>[].obs;
  final _currentFilter = TripFilter.all.obs;
  final _searchQuery = ''.obs;

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  List<TripModel> get assignedTrips => _filteredTrips;
  TripFilter get currentFilter => _currentFilter.value;
  String get searchQuery => _searchQuery.value;
  bool get hasMorePages => _hasMorePages.value;

  // Filtered trips by status
  List<TripModel> get scheduledTrips =>
      _assignedTrips.where((t) => t.status == 'scheduled').toList();

  List<TripModel> get inProgressTrips =>
      _assignedTrips.where((t) => t.status == 'in_progress').toList();

  List<TripModel> get completedTrips =>
      _assignedTrips.where((t) => t.status == 'completed').toList();

  @override
  void onInit() {
    super.onInit();
    fetchAssignedTrips();
  }

  Future<void> fetchAssignedTrips({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _assignedTrips.clear();
    }

    if (!_hasMorePages.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        ApiEndpoints.driverAssignedTrips,
        queryParameters: {
          'page': _currentPage.value,
          'limit': AppConstants.defaultPageSize,
          'status': _currentFilter.value != TripFilter.all
              ? _currentFilter.value.toString().split('.').last
              : null,
        },
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> tripsData = response['data'];
        final newTrips = tripsData.map((t) => TripModel.fromJson(t)).toList();

        if (_currentPage.value == 1) {
          _assignedTrips.value = newTrips;
        } else {
          _assignedTrips.addAll(newTrips);
        }

        _applyFilters();
        _hasMorePages.value = newTrips.length >= AppConstants.defaultPageSize;
        _currentPage.value++;
      }
    } catch (e) {
      print('Error fetching assigned trips: $e');
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  void _applyFilters() {
    var filtered = List<TripModel>.from(_assignedTrips);

    // Apply status filter
    if (_currentFilter.value != TripFilter.all) {
      final filterStatus = _currentFilter.value.toString().split('.').last;
      filtered = filtered.where((t) => t.status == filterStatus).toList();
    }

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.routeName.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
            t.origin.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
            t.destination.toLowerCase().contains(_searchQuery.value.toLowerCase());
      }).toList();
    }

    _filteredTrips.value = filtered;
  }

  void setFilter(TripFilter filter) {
    _currentFilter.value = filter;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  Future<void> refreshTrips() async {
    _isRefreshing.value = true;
    await fetchAssignedTrips(refresh: true);
    _isRefreshing.value = false;
  }

  Future<void> loadMore() async {
    if (_hasMorePages.value && !_isLoading.value) {
      await fetchAssignedTrips();
    }
  }

  TripModel? getTripById(String tripId) {
    return _assignedTrips.firstWhereOrNull((t) => t.id == tripId);
  }

  int getTripCountByStatus(String status) {
    return _assignedTrips.where((t) => t.status == status).length;
  }

  void clearFilters() {
    _currentFilter.value = TripFilter.all;
    _searchQuery.value = '';
    _applyFilters();
  }
}

enum TripFilter {
  all,
  scheduled,
  in_progress,
  completed,
}

extension TripFilterExtension on TripFilter {
  String get displayName {
    switch (this) {
      case TripFilter.all:
        return 'All Trips';
      case TripFilter.scheduled:
        return 'Scheduled';
      case TripFilter.in_progress:
        return 'In Progress';
      case TripFilter.completed:
        return 'Completed';
    }
  }
}