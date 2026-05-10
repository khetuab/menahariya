import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';

class DriverTripHistoryController extends GetxController {
  static DriverTripHistoryController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Observables
  final _isLoading = false.obs;
  final _isFetchingStats = false.obs;
  final _trips = <TripModel>[].obs;
  final _filteredTrips = <TripModel>[].obs;
  final _selectedStatus = 'all'.obs;
  final _searchQuery = ''.obs;
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;

  // Statistics Observables
  final _totalTrips = 0.obs;
  final _completedTrips = 0.obs;
  final _cancelledTrips = 0.obs;
  final _upcomingTrips = 0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isFetchingStats => _isFetchingStats.value;
  List<TripModel> get trips => _filteredTrips;
  String get selectedStatus => _selectedStatus.value;
  String get searchQuery => _searchQuery.value;
  bool get hasMorePages => _hasMorePages.value;

  // Statistics Getters
  int get totalTrips => _totalTrips.value;
  int get completedTrips => _completedTrips.value;
  int get cancelledTrips => _cancelledTrips.value;
  int get upcomingTrips => _upcomingTrips.value;

  // Status options
  final List<String> statusOptions = [
    'all',
    'scheduled',
    'in_progress',
    'completed',
    'cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchTripHistory();
  }

  Future<void> fetchStatistics() async {
    try {
      _isFetchingStats.value = true;

      print('📊 Fetching trip statistics...');

      final statsResponse = await _apiClient.get(
        '/driver/trips?limit=1000',
      );

      if (statsResponse != null && statsResponse['data'] != null) {
        final List<dynamic> allTrips = statsResponse['data'];
        _totalTrips.value = allTrips.length;
        _completedTrips.value = allTrips.where((t) => t['status'] == 'completed').length;
        _cancelledTrips.value = allTrips.where((t) => t['status'] == 'cancelled').length;
        _upcomingTrips.value = allTrips.where((t) => t['status'] == 'scheduled').length;

        print('📊 Statistics Updated:');
        print('   Total Trips: ${_totalTrips.value}');
        print('   Completed: ${_completedTrips.value}');
        print('   Cancelled: ${_cancelledTrips.value}');
        print('   Upcoming: ${_upcomingTrips.value}');
      } else {
        print('⚠️ No statistics data received');
        _setDefaultStatistics();
      }
    } catch (e) {
      print('❌ Error fetching statistics: $e');
      _setDefaultStatistics();
    } finally {
      _isFetchingStats.value = false;
    }
  }

  void _setDefaultStatistics() {
    _totalTrips.value = 0;
    _completedTrips.value = 0;
    _cancelledTrips.value = 0;
    _upcomingTrips.value = 0;
  }

  Future<void> fetchTripHistory({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _trips.clear();
    }

    if (!_hasMorePages.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      // Fetch statistics first
      await fetchStatistics();

      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'page': _currentPage.value,
        'limit': 20,
      };

      if (_selectedStatus.value != 'all') {
        queryParams['status'] = _selectedStatus.value;
      }

      if (_searchQuery.value.isNotEmpty) {
        queryParams['search'] = _searchQuery.value;
      }

      print('📋 Fetching trip history with params: $queryParams');

      final response = await _apiClient.get(
        '/driver/trips/history',
        queryParameters: queryParams,
      );

      if (response != null && response['data'] != null) {
        List<TripModel> newTrips = [];

        if (response['data'] is List) {
          newTrips = (response['data'] as List)
              .map((t) => TripModel.fromJson(t))
              .toList();
          print('✅ Loaded ${newTrips.length} trips');
        }

        if (refresh) {
          _trips.value = newTrips;
        } else {
          _trips.addAll(newTrips);
        }

        _applyFilters();

        // Update pagination
        if (response['pagination'] != null) {
          _hasMorePages.value = _currentPage.value < response['pagination']['pages'];
          print('📄 Pagination: Page ${_currentPage.value} of ${response['pagination']['pages']}');
        } else {
          _hasMorePages.value = newTrips.length >= 20;
        }

        _currentPage.value++;
      } else {
        print('⚠️ No data in response');
        _trips.clear();
        _filteredTrips.clear();
      }
    } catch (e) {
      print('❌ Error fetching trip history: $e');

      // Show error only for user-initiated refreshes
      if (refresh) {
        Get.snackbar(
          'Error',
          'Failed to load trip history. Please check your connection.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }

      _trips.clear();
      _filteredTrips.clear();
      _setDefaultStatistics();
    } finally {
      _isLoading.value = false;
    }
  }

  void _applyFilters() {
    var filtered = List<TripModel>.from(_trips);

    // Apply status filter
    if (_selectedStatus.value != 'all') {
      filtered = filtered.where((t) => t.status == _selectedStatus.value).toList();
      print('📊 Filtering by status: ${_selectedStatus.value} → ${filtered.length} trips');
    }

    // Apply search
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((t) =>
      t.origin.toLowerCase().contains(query) ||
          t.destination.toLowerCase().contains(query) ||
          t.id.toLowerCase().contains(query)).toList();
      print('🔍 Search query: "$query" → ${filtered.length} trips');
    }

    _filteredTrips.value = filtered;
    print('🔍 Final filtered trips: ${_filteredTrips.length}');
  }

  void setStatusFilter(String status) {
    print('📊 Setting status filter to: $status');
    _selectedStatus.value = status;
    fetchTripHistory(refresh: true);
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  Future<void> refreshTrips() async {
    print('🔄 Manual refresh requested');
    await fetchTripHistory(refresh: true);
  }

  void loadMoreTrips() {
    if (_hasMorePages.value && !_isLoading.value) {
      print('📄 Loading more trips (page ${_currentPage.value})');
      fetchTripHistory();
    }
  }

  void clearFilters() {
    print('🧹 Clearing all filters');
    _selectedStatus.value = 'all';
    _searchQuery.value = '';
    fetchTripHistory(refresh: true);
  }

  @override
  void onClose() {
    print('🗑️ DriverTripHistoryController disposed');
    super.onClose();
  }
}