// lib/modules/admin/controllers/admin_cargo_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/cargo/cargo_model.dart';

class AdminCargoController extends GetxController {
  static AdminCargoController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  final searchController = TextEditingController();

  // Observables
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _cargoList = <CargoModel>[].obs;
  final _filteredCargo = <CargoModel>[].obs;
  final _selectedCargo = Rxn<CargoModel>();
  final _searchQuery = ''.obs;
  final _statusFilter = ''.obs;
  final _dateFilter = Rxn<DateTime>();
  final _destinationFilter = ''.obs;

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;
  final _totalCount = 0.obs;
  final _totalRevenue = 0.0.obs;
  final _totalWeight = 0.0.obs;

  // Form controllers for updating cargo
  late final TextEditingController statusController;
  late final TextEditingController locationController;
  late final TextEditingController notesController;

  // Statistics
  final _statsTotal = 0.obs;
  final _statsRegistered = 0.obs;
  final _statsLoaded = 0.obs;
  final _statsInTransit = 0.obs;
  final _statsDelivered = 0.obs;
  final _statsCancelled = 0.obs;
  final _statsRevenue = 0.0.obs;
  final _statsWeight = 0.0.obs;


  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  List<CargoModel> get cargoList => _filteredCargo;
  CargoModel? get selectedCargo => _selectedCargo.value;
  String get searchQuery => _searchQuery.value;
  String get statusFilter => _statusFilter.value;
  DateTime? get dateFilter => _dateFilter.value;
  String get destinationFilter => _destinationFilter.value;
  bool get hasMorePages => _hasMorePages.value;
  int get totalCount => _totalCount.value;
  double get totalRevenue => _totalRevenue.value;
  double get statsRevenue => _statsRevenue.value;
  double get statsWeight => _statsWeight.value;
  double get totalWeight => _totalWeight.value;

  // Statistics getters
  int get totalCargo => _statsTotal.value;
  int get registeredCargo => _statsRegistered.value;
  int get loadedCargo => _statsLoaded.value;
  int get inTransitCargo => _statsInTransit.value;
  int get deliveredCargo => _statsDelivered.value;
  int get cancelledCargo => _statsCancelled.value;

  // Available statuses for filter
  final List<String> availableStatuses = [
    'all',
    'registered',
    'loaded',
    'in_transit',
    'delivered',
    'cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchCargoList();
    fetchStatistics();
  }

  void _initializeControllers() {
    statusController = TextEditingController();
    locationController = TextEditingController();
    notesController = TextEditingController();
  }

  Future<void> fetchStatistics() async {
    try {
      final response = await _apiClient.get('/admin/cargo/stats');
      if (response != null && response['data'] != null) {
        final data = response['data'];
        _statsTotal.value = data['totalCargo'] ?? 0;
        _statsRegistered.value = data['registeredCargo'] ?? 0;
        _statsLoaded.value = data['loadedCargo'] ?? 0;
        _statsInTransit.value = data['inTransitCargo'] ?? 0;
        _statsDelivered.value = data['deliveredCargo'] ?? 0;
        _statsCancelled.value = data['cancelledCargo'] ?? 0;
        _statsRevenue.value = data['totalRevenue']?.toDouble() ?? 0;
        _statsWeight.value = data['totalWeight']?.toDouble() ?? 0;
      }
    } catch (e) {
      print('Error fetching cargo stats: $e');
    }
  }

  Future<void> fetchCargoList({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _cargoList.clear();
    }

    if (!_hasMorePages.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      final params = <String, dynamic>{
        'page': _currentPage.value,
        'limit': AppConstants.defaultPageSize,
      };

      if (_searchQuery.value.isNotEmpty) params['search'] = _searchQuery.value;
      if (_statusFilter.value.isNotEmpty && _statusFilter.value != 'all') {
        params['status'] = _statusFilter.value;
      }
      if (_dateFilter.value != null) {
        params['date'] = _dateFilter.value!.toIso8601String().split('T')[0];
      }
      if (_destinationFilter.value.isNotEmpty) params['destination'] = _destinationFilter.value;

      final response = await _apiClient.get(
        '/admin/cargo',
        queryParameters: params,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> cargoData = response['data'];
        final newCargo = cargoData.map((c) => CargoModel.fromJson(c)).toList();

        if (_currentPage.value == 1) {
          _cargoList.value = newCargo;
        } else {
          _cargoList.addAll(newCargo);
        }

        _applyFilters();
        _totalCount.value = response['total'] ?? _cargoList.length;
        _hasMorePages.value = newCargo.length >= AppConstants.defaultPageSize;
        _currentPage.value++;

        _calculateTotals();
      }
    } catch (e) {
      print('Error fetching cargo list: $e');
      AppSnackbar.show('Error', 'Failed to load cargo');
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  void _applyFilters() {
    var filtered = List<CargoModel>.from(_cargoList);

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((c) =>
      c.trackingCode.toLowerCase().contains(query) ||
          c.senderName.toLowerCase().contains(query) ||
          c.receiverName.toLowerCase().contains(query)).toList();
    }

    // Apply destination filter
    if (_destinationFilter.value.isNotEmpty) {
      filtered = filtered.where((c) =>
          c.destination.toLowerCase().contains(_destinationFilter.value.toLowerCase())).toList();
    }

    _filteredCargo.value = filtered;
  }

  void _calculateTotals() {
    double revenue = 0;
    double weight = 0;

    for (var cargo in _cargoList) {
      if (cargo.isDelivered) {
        revenue += cargo.fee;
      }
      weight += cargo.weight;
    }

    _totalRevenue.value = revenue;
    _totalWeight.value = weight;
  }

  Future<CargoModel?> getCargoDetails(String cargoId) async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.get('${ApiEndpoints.cargo}/$cargoId');
      if (response != null && response['data'] != null) {
        final cargo = CargoModel.fromJson(response['data']);
        _selectedCargo.value = cargo;

        statusController.text = cargo.status;
        locationController.text = cargo.location ?? '';
        notesController.text = cargo.notes ?? '';

        return cargo;
      }
      return null;
    } catch (e) {
      print('Error fetching cargo details: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateCargoStatus(String cargoId, String status, {String? location, String? notes}) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.patch(
        '/admin/cargo/$cargoId/status',
        data: {
          'status': status,
          'location': location,
          'notes': notes,
        },
      );

      if (response != null && response['success'] == true) {
        await fetchCargoList(refresh: true);
        await fetchStatistics();
        AppSnackbar.show('Success', 'Cargo status updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating cargo status: $e');
      AppSnackbar.show('Error', 'Failed to update cargo status');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteCargo(String cargoId) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Cargo'),
          content: const Text('Are you sure you want to delete this cargo record?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm != true) return false;

      _isLoading.value = true;

      final response = await _apiClient.delete('/admin/cargo/$cargoId');

      if (response != null && response['success'] == true) {
        await fetchCargoList(refresh: true);
        await fetchStatistics();
        AppSnackbar.show('Success', 'Cargo deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting cargo: $e');
      AppSnackbar.show('Error', 'Failed to delete cargo');
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
    fetchCargoList(refresh: true);
  }

  void setDateFilter(DateTime? date) {
    _dateFilter.value = date;
    fetchCargoList(refresh: true);
  }

  void setDestinationFilter(String destination) {
    _destinationFilter.value = destination;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery.value = '';
    _statusFilter.value = '';
    _dateFilter.value = null;
    _destinationFilter.value = '';
    searchController.clear();
    fetchCargoList(refresh: true);
  }

  Future<void> refreshCargo() async {
    _isRefreshing.value = true;
    await fetchCargoList(refresh: true);
    await fetchStatistics();
    _isRefreshing.value = false;
  }

  Future<void> loadMoreCargo() async {
    if (_hasMorePages.value && !_isLoading.value) {
      await fetchCargoList();
    }
  }

  @override
  void onClose() {
    statusController.dispose();
    locationController.dispose();
    searchController.dispose();
    notesController.dispose();
    super.onClose();
  }
}