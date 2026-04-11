// lib/modules/admin/controllers/admin_user_controller.dart

import 'dart:async';

import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/user/user_model.dart';
import 'package:flutter/material.dart';

class AdminUserController extends GetxController {
  static AdminUserController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  Timer? _debounce;
  final searchController = TextEditingController();
  // Observables
  final _isLoading = false.obs;
  final _isSaving = false.obs;
  final _isRefreshing = false.obs;
  final _users = <UserModel>[].obs;
  final _filteredUsers = <UserModel>[].obs;
  final _selectedUser = Rxn<UserModel>();
  final _searchQuery = ''.obs;
  final _roleFilter = ''.obs;
  final _statusFilter = true.obs; // true = active, false = inactive

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;
  final _totalCount = 0.obs;

  // Form controllers for creating/editing users
  late final TextEditingController fullNameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  late final TextEditingController addressController;
  late final TextEditingController cityController;
  late final TextEditingController licenseNumberController;
  late final TextEditingController licenseExpiryController;

  // Role selection
  final _selectedRole = 'passenger'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  List<UserModel> get users => _users;
  bool get isSaving => _isSaving.value;
  UserModel? get selectedUser => _selectedUser.value;
  String get searchQuery => _searchQuery.value;
  String get roleFilter => _roleFilter.value;
  bool get statusFilter => _statusFilter.value;
  bool get hasMorePages => _hasMorePages.value;
  int get totalCount => _totalCount.value;
  String get selectedRole => _selectedRole.value;

  // Statistics
  int get totalUsers => _users.length;
  int get totalPassengers => _users.where((u) => u.isPassenger).length;
  int get totalDrivers => _users.where((u) => u.isDriver).length;
  int get totalStaff => _users.where((u) => u.isStaff).length;
  int get totalAdmins => _users.where((u) => u.isAdmin).length;
  int get activeUsers => _users.where((u) => u.isActive).length;
  int get inactiveUsers => _users.where((u) => !u.isActive).length;

  // Available roles
  final List<String> availableRoles = [
    'passenger',
    'driver',
    'ticketing_staff',
    'cargo_staff',
    'admin',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchUsers();
  }

  void _initializeControllers() {
    fullNameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    addressController = TextEditingController();
    cityController = TextEditingController();
    licenseNumberController = TextEditingController();
    licenseExpiryController = TextEditingController();
  }

  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _users.clear();
    }

    if (!_hasMorePages.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      final params = <String, dynamic>{
        'page': _currentPage.value,
        'limit': AppConstants.defaultPageSize,
      };

      if (_searchQuery.value.isNotEmpty) params['search'] = _searchQuery.value;
      if (_roleFilter.value.isNotEmpty) params['role'] = _roleFilter.value;
      if (_statusFilter.value != null) params['active'] = _statusFilter.value;

      final response = await _apiClient.get(
        ApiEndpoints.users,
        queryParameters: params,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> usersData = response['data'];
        final newUsers = usersData.map((u) => UserModel.fromJson(u)).toList();

        if (_currentPage.value == 1) {
          _users.value = newUsers;
        } else {
          _users.addAll(newUsers);
        }

        //_applyFilters();
        _totalCount.value = response['total'] ?? _users.length;
        _hasMorePages.value = newUsers.length >= AppConstants.defaultPageSize;
        _currentPage.value++;
      }
    } catch (e) {
      print('Error fetching users: $e');
      AppSnackbar.show('Error', 'Failed to load users');
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  void _applyFilters() {
    var filtered = List<UserModel>.from(_users);

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((u) =>
      u.fullName.toLowerCase().contains(query) ||
          u.phone.toLowerCase().contains(query) ||
          (u.email?.toLowerCase().contains(query) ?? false)).toList();
    }

    _filteredUsers.value = filtered;
  }

  Future<UserModel?> getUserDetails(String userId) async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.get('${ApiEndpoints.users}/$userId');
      if (response != null && response['data'] != null) {
        final user = UserModel.fromJson(response['data']);
        _selectedUser.value = user;
        return user;
      }
      return null;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.users,
        data: userData,
      );

      if (response != null && response['success'] == true) {
        await fetchUsers(refresh: true);
        AppSnackbar.show('Success', 'User created successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating user: $e');
      AppSnackbar.show('Error', 'Failed to create user');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.patch(
        '${ApiEndpoints.users}/$userId',
        data: updates,
      );

      if (response != null && response['success'] == true) {
        await fetchUsers(refresh: true);
        AppSnackbar.show('Success', 'User updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user: $e');
      AppSnackbar.show('Error', 'Failed to update user');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.patch(
        '${ApiEndpoints.users}/$userId/status',
        data: {'isActive': isActive},
      );

      if (response != null && response['success'] == true) {
        await fetchUsers(refresh: true);
        AppSnackbar.show('Success', isActive ? 'User activated' : 'User deactivated');
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling user status: $e');
      AppSnackbar.show('Error', 'Failed to update user status');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> resetUserPassword(String userId, String newPassword) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        '${ApiEndpoints.users}/$userId/reset-password',
        data: {'password': newPassword},
      );

      if (response != null && response['success'] == true) {
        AppSnackbar.show('Success', 'Password reset successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error resetting password: $e');
      AppSnackbar.show('Error', 'Failed to reset password');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.delete('${ApiEndpoints.users}/$userId');
      if (response != null && response['success'] == true) {
        await fetchUsers(refresh: true); // Refresh instead of local removal
        AppSnackbar.show('Success', 'User deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting user: $e');
      AppSnackbar.show('Error', 'Failed to delete user');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void setRoleFilter(String role) {
    _roleFilter.value = role;
    fetchUsers(refresh: true);
  }

  void setStatusFilter(bool active) {
    _statusFilter.value = active;
    fetchUsers(refresh: true);
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    searchController.text = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchUsers(refresh: true);
    });
  }

  void setSelectedRole(String role) {
    _selectedRole.value = role;
  }

  void clearFilters() {
    _searchQuery.value = '';
    _roleFilter.value = '';
    searchController.clear();
    _statusFilter.value = true;
    fetchUsers(refresh: true);
  }

  Future<void> refreshUsers() async {
    _isRefreshing.value = true;
    await fetchUsers(refresh: true);
    _isRefreshing.value = false;
  }

  Future<void> loadMoreUsers() async {
    if (_hasMorePages.value && !_isLoading.value) {
      await fetchUsers();
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    _debounce?.cancel();
    phoneController.dispose();
    emailController.dispose();
    searchController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    cityController.dispose();
    licenseNumberController.dispose();
    licenseExpiryController.dispose();
    super.onClose();
  }
}