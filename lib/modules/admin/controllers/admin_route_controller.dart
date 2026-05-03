// lib/modules/admin/controllers/admin_route_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/trip/route_model.dart';

class AdminRouteController extends GetxController {
  static AdminRouteController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Observables
  final _isLoading = false.obs;
  final _isSaving = false.obs;
  final _routes = <RouteModel>[].obs;
  final _filteredRoutes = <RouteModel>[].obs;
  final _selectedRoute = Rxn<RouteModel>();
  final _searchQuery = ''.obs;
  final _isEditing = false.obs;

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;
  final _totalCount = 0.obs;

  // Form controllers
  late final TextEditingController nameController;
  late final TextEditingController originController;
  late final TextEditingController destinationController;
  late final TextEditingController distanceController;
  late final TextEditingController durationController;
  late final TextEditingController basePriceController;
  late final TextEditingController stopsController;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  List<RouteModel> get routes => _filteredRoutes;
  RouteModel? get selectedRoute => _selectedRoute.value;
  String get searchQuery => _searchQuery.value;
  bool get isEditing => _isEditing.value;
  bool get hasMorePages => _hasMorePages.value;
  int get totalCount => _totalCount.value;

  // Statistics
  int get totalRoutes => _routes.length;
  int get activeRoutes => _routes.where((r) => r.isActive).length;
  int get inactiveRoutes => _routes.where((r) => !r.isActive).length;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchRoutes();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    originController = TextEditingController();
    destinationController = TextEditingController();
    distanceController = TextEditingController();
    durationController = TextEditingController();
    basePriceController = TextEditingController();
    stopsController = TextEditingController();
  }

  Future<void> fetchRoutes({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _routes.clear();
    }

    if (!_hasMorePages.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      final params = <String, dynamic>{
        'page': _currentPage.value,
        'limit': AppConstants.defaultPageSize,
      };

      if (_searchQuery.value.isNotEmpty) params['search'] = _searchQuery.value;

      final response = await _apiClient.get(
        ApiEndpoints.routes,
        queryParameters: params,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> routesData = response['data'];
        final newRoutes = routesData.map((r) => RouteModel.fromJson(r)).toList();

        if (_currentPage.value == 1) {
          _routes.value = newRoutes;
        } else {
          _routes.addAll(newRoutes);
        }

        _applyFilters();
        _totalCount.value = response['total'] ?? _routes.length;
        _hasMorePages.value = newRoutes.length >= AppConstants.defaultPageSize;
        _currentPage.value++;
      }
    } catch (e) {
      print('Error fetching routes: $e');
      AppSnackbar.show('Error', 'Failed to load routes');
    } finally {
      _isLoading.value = false;
    }
  }

  void _applyFilters() {
    var filtered = List<RouteModel>.from(_routes);

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((r) =>
      r.name.toLowerCase().contains(query) ||
          r.origin.toLowerCase().contains(query) ||
          r.destination.toLowerCase().contains(query)).toList();
    }

    _filteredRoutes.value = filtered;
  }

  Future<RouteModel?> getRouteDetails(String routeId) async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.get('${ApiEndpoints.routes}/$routeId');
      if (response != null && response['data'] != null) {
        final route = RouteModel.fromJson(response['data']);
        _selectedRoute.value = route;

        // Populate form controllers
        nameController.text = route.name;
        originController.text = route.origin;
        destinationController.text = route.destination;
        distanceController.text = route.distance.toString();
        durationController.text = route.duration.toString();
        basePriceController.text = route.basePrice.toString();
        if (route.stops != null) {
          stopsController.text = route.stops!.join(', ');
        }

        return route;
      }
      return null;
    } catch (e) {
      print('Error fetching route details: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createRoute() async {
    try {
      _isSaving.value = true;

      // ✅ Fix: Convert stops string to array
      List<String>? stops;
      if (stopsController.text.isNotEmpty) {
        stops = stopsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty) // Remove empty strings
            .toList();
      }

      final routeData = {
        'name': nameController.text.trim(),
        'origin': originController.text.trim(),
        'destination': destinationController.text.trim(),
        'distance': double.tryParse(distanceController.text) ?? 0,
        'duration': int.tryParse(durationController.text) ?? 0,
        'basePrice': double.tryParse(basePriceController.text) ?? 0,
        'stops': stops, // ✅ Now sending array, not string
        'isActive': true,
      };

      final response = await _apiClient.post(
        ApiEndpoints.routes, // Make sure this points to the correct endpoint
        data: routeData,
      );

      if (response != null && response['success'] == true) {
        await fetchRoutes(refresh: true);
        clearForm();
        _isEditing.value = false;
        AppSnackbar.show('Success', 'Route created successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating route: $e');
      AppSnackbar.show('Error', 'Failed to create route');
      return false;
    } finally {
      _isSaving.value = false;
    }
  }

  Future<bool> updateRoute(String routeId) async {
    try {
      _isSaving.value = true;

      // ✅ Fix: Convert stops string to array
      List<String>? stops;
      if (stopsController.text.isNotEmpty) {
        stops = stopsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      final updates = {
        'name': nameController.text.trim(),
        'origin': originController.text.trim(),
        'destination': destinationController.text.trim(),
        'distance': double.tryParse(distanceController.text) ?? 0,
        'duration': int.tryParse(durationController.text) ?? 0,
        'basePrice': double.tryParse(basePriceController.text) ?? 0,
        'stops': stops, // ✅ Now sending array, not string
      };

      final response = await _apiClient.patch(
        '${ApiEndpoints.routes}/$routeId',
        data: updates,
      );

      if (response != null && response['success'] == true) {
        await fetchRoutes(refresh: true);
        clearForm();
        _isEditing.value = false;
        AppSnackbar.show('Success', 'Route updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating route: $e');
      AppSnackbar.show('Error', 'Failed to update route');
      return false;
    } finally {
      _isSaving.value = false;
    }
  }

// Also update startEdit to properly populate the stops field
  void startEdit(RouteModel route) {
    _selectedRoute.value = route;
    nameController.text = route.name;
    originController.text = route.origin;
    destinationController.text = route.destination;
    distanceController.text = route.distance.toString();
    durationController.text = route.duration.toString();
    basePriceController.text = route.basePrice.toString();

    // ✅ Fix: Convert array back to comma-separated string for display
    if (route.stops != null && route.stops!.isNotEmpty) {
      stopsController.text = route.stops!.join(', ');
    } else {
      stopsController.text = '';
    }

    _isEditing.value = true;
  }

  Future<bool> deleteRoute(String routeId) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Route'),
          content: const Text('Are you sure you want to delete this route?'),
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

      final response = await _apiClient.delete('${ApiEndpoints.routes}/$routeId');

      if (response != null && response['success'] == true) {

        // Remove immediately from local list
        _routes.removeWhere((route) => route.id == routeId);

        // Re-apply filters so UI updates instantly
        _applyFilters();

        AppSnackbar.show('Success', 'Route deleted successfully');

        // Optional background refresh
        fetchRoutes(refresh: true);

        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting route: $e');
      AppSnackbar.show('Error', 'Failed to delete route');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> toggleRouteStatus(String routeId, bool isActive) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.patch(
        '${ApiEndpoints.routes}/$routeId/status',
        data: {'isActive': isActive},
      );

      if (response != null && response['success'] == true) {
        await fetchRoutes(refresh: true);
        AppSnackbar.show('Success', isActive ? 'Route activated' : 'Route deactivated');
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling route status: $e');
      AppSnackbar.show('Error', 'Failed to update route status');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }


  void clearForm() {
    nameController.clear();
    originController.clear();
    destinationController.clear();
    distanceController.clear();
    durationController.clear();
    basePriceController.clear();
    stopsController.clear();
    _selectedRoute.value = null;
  }

  void cancelEdit() {
    clearForm();
    _isEditing.value = false;
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery.value = '';
    fetchRoutes(refresh: true);
  }

  Future<void> refreshRoutes() async {
    await fetchRoutes(refresh: true);
  }

  @override
  void onClose() {
    nameController.dispose();
    originController.dispose();
    destinationController.dispose();
    distanceController.dispose();
    durationController.dispose();
    basePriceController.dispose();
    stopsController.dispose();
    super.onClose();
  }
}