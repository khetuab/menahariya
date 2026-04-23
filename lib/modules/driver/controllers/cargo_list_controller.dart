// lib/modules/driver/controllers/cargo_list_controller.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/utils/app_snackbar.dart';
import 'package:menahariya/data/models/cargo/cargo_model.dart';

class CargoListController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;

  final _tripId = ''.obs;
  String get tripId => _tripId.value;

  final _isLoading = false.obs;
  final _cargoList = <CargoModel>[].obs;
  final _filteredCargo = <CargoModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedFilter = CargoFilter.all.obs;
  final _selectedCargo = Rxn<CargoModel>();
  final _totalWeight = 0.0.obs;
  final _totalValue = 0.0.obs;

  bool get isLoading => _isLoading.value;
  List<CargoModel> get cargoList => _filteredCargo;
  String get searchQuery => _searchQuery.value;
  CargoFilter get selectedFilter => _selectedFilter.value;
  CargoModel? get selectedCargo => _selectedCargo.value;
  double get totalWeight => _totalWeight.value;
  double get totalValue => _totalValue.value;

  int get totalCount => _cargoList.length;
  int get loadedCount => _cargoList.where((c) => c.status == 'loaded').length;
  int get pendingCount => _cargoList.where((c) => c.status == 'registered').length;

  @override
  void onInit() {
    super.onInit();
    // Do not auto-load; wait for setTripId()
  }

  void setTripId(String id) {
    if (_tripId.value == id) return;
    _tripId.value = id;
    loadCargoList();
  }

  Future<void> loadCargoList() async {
    if (_tripId.value.isEmpty) {
      print('⚠️ Cannot load cargo list: tripId is empty');
      return;
    }

    try {
      _isLoading.value = true;
      print('📦 Loading cargo list for trip: ${_tripId.value}');

      final response = await _apiClient.get('/driver/cargo-list/${_tripId.value}');

      if (response != null && response['data'] != null) {
        final List<dynamic> cargo = response['data'];
        _cargoList.value = cargo
            .map((c) => CargoModel.fromJson(c))
            .toList();
        print('✅ Loaded ${_cargoList.length} cargo items');
        _calculateTotals();
        _applyFilters();
      } else {
        _cargoList.value = [];
      }
    } catch (e) {
      print('Error loading cargo list: $e');
      _cargoList.value = [];
    } finally {
      _isLoading.value = false;
    }
  }

  void _calculateTotals() {
    _totalWeight.value = _cargoList.fold(0, (sum, cargo) => sum + cargo.weight);
    _totalValue.value = _cargoList.fold(0, (sum, cargo) => sum + (cargo.declaredValue ?? 0));
  }

  void _applyFilters() {
    var filtered = List<CargoModel>.from(_cargoList);

    switch (_selectedFilter.value) {
      case CargoFilter.all:
        break;
      case CargoFilter.registered:
        filtered = filtered.where((c) => c.status == 'registered').toList();
        break;
      case CargoFilter.loaded:
        filtered = filtered.where((c) => c.status == 'loaded').toList();
        break;
      case CargoFilter.fragile:
        filtered = filtered.where((c) => c.isFragile).toList();
        break;
    }

    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((c) {
        return c.trackingCode.toLowerCase().contains(query) ||
            c.receiverName.toLowerCase().contains(query) ||
            (c.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    _filteredCargo.value = filtered;
  }

  void setFilter(CargoFilter filter) {
    _selectedFilter.value = filter;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  Future<void> selectCargo(String cargoId) async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.get('${ApiEndpoints.cargo}/$cargoId');
      if (response != null && response['data'] != null) {
        _selectedCargo.value = CargoModel.fromJson(response['data']);
      }
    } catch (e) {
      print('Error loading cargo details: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> markCargoLoaded(String cargoId) async {
    try {
      await _apiClient.post(
        '/driver/mark-cargo-loaded',
        data: {
          'tripId': _tripId.value,
          'cargoId': cargoId,
        },
      );

      final index = _cargoList.indexWhere((c) => c.id == cargoId);
      if (index != -1) {
        _cargoList[index] = _cargoList[index].copyWith(status: 'loaded');
        _cargoList.refresh();
        _applyFilters();
        _calculateTotals();
      }

      AppSnackbar.show('Success', 'Cargo marked as loaded');
    } catch (e) {
      print('Error marking cargo loaded: $e');
      AppSnackbar.show('Error', 'Failed to update cargo status');
    }
  }

  void clearSelection() {
    _selectedCargo.value = null;
  }

  Future<void> refreshList() async {
    await loadCargoList();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

enum CargoFilter {
  all,
  registered,
  loaded,
  fragile,
}

extension CargoFilterExtension on CargoFilter {
  String get displayName {
    switch (this) {
      case CargoFilter.all:
        return 'All Cargo';
      case CargoFilter.registered:
        return 'Registered';
      case CargoFilter.loaded:
        return 'Loaded';
      case CargoFilter.fragile:
        return 'Fragile';
    }
  }
}