// lib/modules/driver/controllers/cargo_list_controller.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/cargo/cargo_model.dart';

class CargoListController extends GetxController {
  static CargoListController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Current trip ID
  late final String tripId;

  // Observables
  final _isLoading = false.obs;
  final _cargoList = <CargoModel>[].obs;
  final _filteredCargo = <CargoModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedFilter = CargoFilter.all.obs;
  final _selectedCargo = Rxn<CargoModel>();
  final _totalWeight = 0.0.obs;
  final _totalValue = 0.0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<CargoModel> get cargoList => _filteredCargo;
  String get searchQuery => _searchQuery.value;
  CargoFilter get selectedFilter => _selectedFilter.value;
  CargoModel? get selectedCargo => _selectedCargo.value;
  double get totalWeight => _totalWeight.value;
  double get totalValue => _totalValue.value;

  // Statistics
  int get totalCount => _cargoList.length;
  int get loadedCount => _cargoList.where((c) => c.status == 'loaded').length;
  int get pendingCount => _cargoList.where((c) => c.status == 'registered').length;

  @override
  void onInit() {
    super.onInit();
    _getTripId();
    loadCargoList();
  }

  void _getTripId() {
    final args = Get.arguments;
    if (args != null && args['tripId'] != null) {
      tripId = args['tripId'];
    }
  }

  Future<void> loadCargoList() async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '/driver/cargo-list/$tripId',
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> cargo = response['data'];
        _cargoList.value = cargo
            .map((c) => CargoModel.fromJson(c))
            .toList();

        _calculateTotals();
        _applyFilters();
      }
    } catch (e) {
      print('Error loading cargo list: $e');
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

    // Apply status filter
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

    // Apply search query
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

      final response = await _apiClient.get(
        '${ApiEndpoints.cargo}/$cargoId',
      );

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
          'tripId': tripId,
          'cargoId': cargoId,
        },
      );

      // Update local state
      final index = _cargoList.indexWhere((c) => c.id == cargoId);
      if (index != -1) {
        _cargoList[index] = _cargoList[index].copyWith(status: 'loaded');
        _cargoList.refresh();
        _applyFilters();
        _calculateTotals();
      }

      Get.snackbar(
        'Success',
        'Cargo marked as loaded',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error marking cargo loaded: $e');
      Get.snackbar(
        'Error',
        'Failed to update cargo status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void clearSelection() {
    _selectedCargo.value = null;
  }

  Future<void> refreshList() async {
    loadCargoList();
  }

  List<CargoModel> getCargoByDestination(String destination) {
    return _cargoList.where((c) => c.destination == destination).toList();
  }

  Map<String, dynamic> getCargoSummary() {
    return {
      'totalCount': totalCount,
      'loadedCount': loadedCount,
      'pendingCount': pendingCount,
      'totalWeight': totalWeight,
      'totalValue': totalValue,
    };
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