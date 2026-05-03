// lib/modules/admin/controllers/admin_vehicle_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/vehicle/vehicle_model.dart';
import '../../../data/models/user/user_model.dart';

class AdminVehicleController extends GetxController {
  static AdminVehicleController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  final searchController = TextEditingController();
  // Observables
  final _isLoading = false.obs;
  final _isSaving = false.obs;
  final _vehicles = <VehicleModel>[].obs;
  final _filteredVehicles = <VehicleModel>[].obs;
  final _selectedVehicle = Rxn<VehicleModel>();
  final _drivers = <UserModel>[].obs;
  final _searchQuery = ''.obs;
  final _statusFilter = ''.obs;
  final _typeFilter = ''.obs;
  final _isEditing = false.obs;

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;
  final _totalCount = 0.obs;

  // Form controllers
  late final TextEditingController plateNumberController;
  late final TextEditingController modelController;
  late final TextEditingController capacityController;
  late final TextEditingController cargoCapacityController;
  late final TextEditingController driverIdController;
  late final TextEditingController lastMaintenanceController;
  late final TextEditingController nextMaintenanceController;
  late final TextEditingController amenitiesController;

  // Dropdown selections
  final _selectedType = 'Standard'.obs;
  final _selectedStatus = 'active'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  List<VehicleModel> get vehicles => _filteredVehicles;
  VehicleModel? get selectedVehicle => _selectedVehicle.value;
  List<UserModel> get drivers => _drivers;
  String get searchQuery => _searchQuery.value;
  String get statusFilter => _statusFilter.value;
  String get typeFilter => _typeFilter.value;
  bool get isEditing => _isEditing.value;
  bool get hasMorePages => _hasMorePages.value;
  int get totalCount => _totalCount.value;
  String get selectedType => _selectedType.value;
  String get selectedStatus => _selectedStatus.value;

  // Available options
  final List<String> vehicleTypes = ['Standard', 'Executive', 'VIP', 'Luxury'];
  final List<String> vehicleStatuses = ['active', 'maintenance', 'inactive'];

  // Statistics
  int get totalVehicles => _vehicles.length;
  int get activeVehicles => _vehicles.where((v) => v.isAvailable).length;
  int get maintenanceVehicles => _vehicles.where((v) => v.status == 'maintenance').length;
  int get inactiveVehicles => _vehicles.where((v) => v.status == 'inactive').length;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchVehicles();
    fetchDrivers();
  }

  void _initializeControllers() {
    plateNumberController = TextEditingController();
    modelController = TextEditingController();
    capacityController = TextEditingController();
    cargoCapacityController = TextEditingController();
    driverIdController = TextEditingController();
    lastMaintenanceController = TextEditingController();
    nextMaintenanceController = TextEditingController();
    amenitiesController = TextEditingController();
  }

  Future<void> fetchVehicles({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _vehicles.clear();
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
      if (_typeFilter.value.isNotEmpty) params['type'] = _typeFilter.value;

      final response = await _apiClient.get(
        ApiEndpoints.vehicles,
        queryParameters: params,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> vehiclesData = response['data'];
        final newVehicles = vehiclesData.map((v) => VehicleModel.fromJson(v)).toList();

        if (_currentPage.value == 1) {
          _vehicles.value = newVehicles;
        } else {
          _vehicles.addAll(newVehicles);
        }

        _applyFilters();
        _totalCount.value = response['total'] ?? _vehicles.length;
        _hasMorePages.value = newVehicles.length >= AppConstants.defaultPageSize;
        _currentPage.value++;
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
      AppSnackbar.show('Error', 'Failed to load vehicles');
    } finally {
      _isLoading.value = false;
    }
  }

  void _applyFilters() {
    var filtered = List<VehicleModel>.from(_vehicles);

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((v) =>
      v.plateNumber.toLowerCase().contains(query) ||
          v.model.toLowerCase().contains(query)).toList();
    }

    _filteredVehicles.value = filtered;
  }

  Future<void> fetchDrivers() async {
    try {
      // Use the correct endpoint for fetching drivers
      final response = await _apiClient.get(ApiEndpoints.adminDrivers);
      if (response != null && response['data'] != null) {
        final List<dynamic> driversData = response['data'];
        _drivers.value = driversData.map((d) => UserModel.fromJson(d)).toList();
      }
    } catch (e) {
      print('Error fetching drivers: $e');
    }
  }

  Future<VehicleModel?> getVehicleDetails(String vehicleId) async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.get('${ApiEndpoints.vehicles}/$vehicleId');
      if (response != null && response['data'] != null) {
        final vehicle = VehicleModel.fromJson(response['data']);
        _selectedVehicle.value = vehicle;

        // Populate form controllers
        plateNumberController.text = vehicle.plateNumber;
        modelController.text = vehicle.model;
        capacityController.text = vehicle.capacity.toString();
        cargoCapacityController.text = (vehicle.cargoCapacity ?? 0).toString();
        driverIdController.text = vehicle.driverId ?? '';
        if (vehicle.lastMaintenance != null) {
          lastMaintenanceController.text = _formatDate(vehicle.lastMaintenance!);
        }
        if (vehicle.nextMaintenance != null) {
          nextMaintenanceController.text = _formatDate(vehicle.nextMaintenance!);
        }
        amenitiesController.text = vehicle.amenities.join(', ');
        _selectedType.value = vehicle.type;
        _selectedStatus.value = vehicle.status;

        return vehicle;
      }
      return null;
    } catch (e) {
      print('Error fetching vehicle details: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createVehicle() async {
    try {
      _isSaving.value = true;

      final amenities = amenitiesController.text.isNotEmpty
          ? amenitiesController.text.split(',').map((a) => a.trim()).toList()
          : [];

      // ✅ Parse dates as strings, not DateTime objects
      String? lastMaintenance;
      if (lastMaintenanceController.text.isNotEmpty) {
        final date = DateTime.tryParse(lastMaintenanceController.text);
        if (date != null) {
          lastMaintenance = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      }

      String? nextMaintenance;
      if (nextMaintenanceController.text.isNotEmpty) {
        final date = DateTime.tryParse(nextMaintenanceController.text);
        if (date != null) {
          nextMaintenance = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      }

      final vehicleData = {
        'plateNumber': plateNumberController.text.trim().toUpperCase(),
        'model': modelController.text.trim(),
        'type': _selectedType.value,
        'capacity': int.tryParse(capacityController.text) ?? 0,
        'cargoCapacity': double.tryParse(cargoCapacityController.text) ?? 0,
        'amenities': amenities,
        'status': _selectedStatus.value,
        'driverId': driverIdController.text.isEmpty ? null : driverIdController.text,
        'lastMaintenance': lastMaintenance, // ✅ Now sending as string
        'nextMaintenance': nextMaintenance, // ✅ Now sending as string
        'isActive': true,
      };

      print('📤 POST Request to: /vehicles');
      print('📦 Data: $vehicleData');

      final response = await _apiClient.post(
        ApiEndpoints.vehicles,
        data: vehicleData,
      );

      if (response != null && response['success'] == true) {
        await fetchVehicles(refresh: true);
        clearForm();
        _isEditing.value = false;
        AppSnackbar.show('Success', 'Vehicle created successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating vehicle: $e');
      AppSnackbar.show('Error', 'Failed to create vehicle');
      return false;
    } finally {
      _isSaving.value = false;
    }
  }

  Future<bool> updateVehicle(String vehicleId) async {
    try {
      _isSaving.value = true;

      final amenities = amenitiesController.text.isNotEmpty
          ? amenitiesController.text.split(',').map((a) => a.trim()).toList()
          : [];

      // ✅ Parse dates as strings
      String? lastMaintenance;
      if (lastMaintenanceController.text.isNotEmpty) {
        final date = DateTime.tryParse(lastMaintenanceController.text);
        if (date != null) {
          lastMaintenance = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      }

      String? nextMaintenance;
      if (nextMaintenanceController.text.isNotEmpty) {
        final date = DateTime.tryParse(nextMaintenanceController.text);
        if (date != null) {
          nextMaintenance = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      }

      final vehicleData = {
        'plateNumber': plateNumberController.text.trim().toUpperCase(),
        'model': modelController.text.trim(),
        'type': _selectedType.value,
        'capacity': int.tryParse(capacityController.text) ?? 0,
        'cargoCapacity': double.tryParse(cargoCapacityController.text) ?? 0,
        'amenities': amenities,
        'status': _selectedStatus.value,
        'driverId': driverIdController.text.isEmpty ? null : driverIdController.text,
        'lastMaintenance': lastMaintenance,
        'nextMaintenance': nextMaintenance,
      };

      final response = await _apiClient.patch(
        '${ApiEndpoints.vehicles}/$vehicleId',
        data: vehicleData,
      );

      if (response != null && response['success'] == true) {
        await fetchVehicles(refresh: true);
        clearForm();
        _isEditing.value = false;
        AppSnackbar.show('Success', 'Vehicle updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating vehicle: $e');
      AppSnackbar.show('Error', 'Failed to update vehicle');
      return false;
    } finally {
      _isSaving.value = false;
    }
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.vehicles}/$vehicleId',
      );

      if (response != null && response['success'] == true) {

        // Remove vehicle locally
        _vehicles.removeWhere(
              (vehicle) => vehicle.id == vehicleId,
        );

        // Refresh filtered list/UI
        _applyFilters();

        AppSnackbar.show(
          'Success',
          'Vehicle deleted successfully',
        );

        // Optional background refresh
        fetchVehicles(refresh: true);

        return true;
      }

      return false;
    } catch (e) {
      print('Error deleting vehicle: $e');

      AppSnackbar.show(
        'Error',
        'Failed to delete vehicle',
      );

      return false;
    }
  }
  void startEdit(VehicleModel vehicle) {
    _selectedVehicle.value = vehicle;
    plateNumberController.text = vehicle.plateNumber;
    modelController.text = vehicle.model;
    capacityController.text = vehicle.capacity.toString();
    cargoCapacityController.text = (vehicle.cargoCapacity ?? 0).toString();
    driverIdController.text = vehicle.driverId ?? '';
    if (vehicle.lastMaintenance != null) {
      lastMaintenanceController.text = _formatDate(vehicle.lastMaintenance!);
    }
    if (vehicle.nextMaintenance != null) {
      nextMaintenanceController.text = _formatDate(vehicle.nextMaintenance!);
    }
    amenitiesController.text = vehicle.amenities.join(', ');
    _selectedType.value = vehicle.type;
    _selectedStatus.value = vehicle.status;
    _isEditing.value = true;
  }

  void clearForm() {
    plateNumberController.clear();
    modelController.clear();
    capacityController.clear();
    cargoCapacityController.clear();
    driverIdController.clear();
    lastMaintenanceController.clear();
    nextMaintenanceController.clear();
    amenitiesController.clear();
    _selectedType.value = 'Standard';
    _selectedStatus.value = 'active';
    _selectedVehicle.value = null;
  }

  void cancelEdit() {
    clearForm();
    _isEditing.value = false;
  }

  void setType(String type) {
    _selectedType.value = type;
  }

  void setStatus(String status) {
    _selectedStatus.value = status;
  }

  void setStatusFilter(String status) {
    _statusFilter.value = status;
    _applyFilters(); // instant UI sync
    fetchVehicles(refresh: true);
  }

  void setTypeFilter(String type) {
    _typeFilter.value = type;
    _applyFilters(); // instant UI sync
    fetchVehicles(refresh: true); // backend sync
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    searchController.text = query; // Sync with TextEditingController
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery.value = '';
    _statusFilter.value = '';
    _typeFilter.value = '';
    searchController.clear();
    fetchVehicles(refresh: true);
  }

  Future<void> refreshVehicles() async {
    await fetchVehicles(refresh: true);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    plateNumberController.dispose();
    modelController.dispose();
    capacityController.dispose();
    cargoCapacityController.dispose();
    searchController.dispose();
    driverIdController.dispose();
    lastMaintenanceController.dispose();
    nextMaintenanceController.dispose();
    amenitiesController.dispose();
    super.onClose();
  }
}