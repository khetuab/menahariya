// lib/modules/auth/controllers/auth_controller.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/core/services/notification/local_notification.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/core/services/storage/local_storage.dart';
import 'package:menahariya/core/services/storage/shared_prefs.dart';
import 'package:menahariya/core/utils/app_snackbar.dart';
import 'package:menahariya/data/models/user/user_model.dart';
import 'package:menahariya/data/models/user/login_request.dart';
import 'package:menahariya/data/models/user/register_request.dart';
import 'package:menahariya/modules/admin/views/admin_dashboard_view.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  // Services
  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorage _secureStorage = SecureStorage();
  final LocalStorage _localStorage = LocalStorage();
  final SharedPrefs _sharedPrefs = SharedPrefs();
  final SocketService _socketService = SocketService.instance;
  final LocalNotificationService _notificationService = LocalNotificationService.instance;

  // Observables
  final _isLoading = false.obs;
  final _isAuthenticated = false.obs;
  final _currentUser = Rxn<UserModel>();
  final _userRole = Rxn<String>();
  final _userId = ''.obs;
  final _authToken = Rxn<String>();
  final _refreshToken = Rxn<String>();
  final _loginAttempts = 0.obs;
  final _isBlocked = false.obs;
  final _blockedUntil = Rxn<DateTime>();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;
  UserModel? get currentUser => _currentUser.value;
  String? get userRole => _userRole.value;
  String get userId => _userId.value;
  String? get authToken => _authToken.value;
  bool get isBlocked => _isBlocked.value;
  DateTime? get blockedUntil => _blockedUntil.value;

  // Computed getters
  bool get isPassenger => _userRole.value == AppConstants.rolePassenger;
  bool get isDriver => _userRole.value == AppConstants.roleDriver;
  bool get isAdmin => _userRole.value == AppConstants.roleAdmin;
  bool get isStaff => _userRole.value == AppConstants.roleTicketingStaff ||
      _userRole.value == AppConstants.roleCargoStaff;
  set currentUser(UserModel? user) {
    _currentUser.value = user;
    _currentUser.refresh();
  }

  @override
  void onInit() {
    super.onInit();
    _checkExistingSession();
  }

  // Check if user has existing session
  Future<void> _checkExistingSession() async {
    try {
      final token = await _secureStorage.read(AppConstants.prefKeyToken);
      final userData = await _secureStorage.readObject(AppConstants.prefKeyUser);

      if (token != null && userData != null) {
        _authToken.value = token;
        _currentUser.value = UserModel.fromJson(userData);
        _userRole.value = _currentUser.value?.role;
        _userId.value = _currentUser.value?.id ?? '';
        _isAuthenticated.value = true;

        // Initialize services
        await _initializeServices();

        // Navigate to appropriate dashboard
        _navigateToDashboard();
      }
    } catch (e) {
      print('Error checking session: $e');
      await logout();
    }
  }
  final _isGuest = false.obs;
  bool get isGuest => _isGuest.value;

  void enterGuestMode() {
    _isGuest.value = true;
  }
  // Initialize services after login
  Future<void> _initializeServices() async {
    try {
      // Connect socket
      await _socketService.connect();

      // Join user room
      if (_userId.value.isNotEmpty) {
        _socketService.joinUserRoom(_userId.value);
      }

      // Request notification permissions
      await _notificationService.requestPermissions();
      print('✅ Services initialized after login');
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  Future<bool> login(String phone, String password) async {
    if (_isBlocked.value) {
      _showBlockedMessage();
      return false;
    }

    try {
      _isLoading.value = true;
      final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');

      print('📞 AuthController.login with phone: "$cleanPhone"');

      final request = LoginRequest(
        phone: cleanPhone,
        password: password,
      );

      final response = await _apiClient.post(
        ApiEndpoints.authLogin,
        data: request.toJson(),
      );

      if (response != null && response['data'] != null) {
        final userData = response['data']['user'];
        final tokens = response['data']['tokens'];

        // Save user data
        // Save user data
        final user = UserModel.fromJson(userData);

// Update last login immediately
        _currentUser.value = user.copyWith(
          lastLogin: DateTime.now(),
        );

        _authToken.value = tokens['accessToken'];
        _refreshToken.value = tokens['refreshToken'];
        _userRole.value = _currentUser.value?.role;
        _userId.value = _currentUser.value?.id ?? '';

// Save to secure storage
        await _secureStorage.write(
          AppConstants.prefKeyToken,
          _authToken.value!,
        );

        await _secureStorage.writeObject(
          AppConstants.prefKeyUser,
          _currentUser.value!.toJson(),
        );

        await _secureStorage.write(
          'refresh_token',
          tokens['refreshToken'],
        );

        // Save to secure storage
        // await _secureStorage.write(AppConstants.prefKeyToken, _authToken.value!);
        // await _secureStorage.writeObject(AppConstants.prefKeyUser, userData);
        // await _secureStorage.write('refresh_token', tokens['refreshToken']);

        // Save remember me preference
        if (_sharedPrefs.getRememberMe()) {
          await _secureStorage.write('phone', phone);
        }

        // Reset login attempts
        _loginAttempts.value = 0;

        // Set authenticated
        _isAuthenticated.value = true;

        // Initialize services (including socket connection)
        await _initializeServices();

        // Navigate to dashboard
        FocusManager.instance.primaryFocus?.unfocus();
        _navigateToDashboard();

        return true;
      }
      return false;
    } on ApiException catch (e) {
      FocusManager.instance.primaryFocus?.unfocus();
      _handleLoginError(e);
      return false;
    } catch (e) {
      print('Login error: $e');
      AppSnackbar.show(
        'Error',
        'An unexpected error occurred',
      );
      return false;
    } finally {
      FocusManager.instance.primaryFocus?.unfocus();
      _isLoading.value = false;
    }
  }

  // Register new user
  Future<bool> register(RegisterRequest request) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.authRegister,
        data: request.toJson(),
      );

      if (response != null && response['data'] != null) {
        final userId = response['data']['userId'];

        // Navigate to OTP verification
        Get.toNamed(
          AppRoutes.otpVerification,
          arguments: {
            'phone': request.phone,
            'userId': userId,
          },
        );

        return true;
      }
      return false;
    } on ApiException catch (e) {
      AppSnackbar.show(
        'Registration Failed',
        e.message,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    // Update the current user observable
    _currentUser.value = updatedUser;

    // Update stored user data
    await _secureStorage.writeObject(AppConstants.prefKeyUser, updatedUser.toJson());

    print('✅ User data updated successfully ');
  }

  // Alternative: Update specific fields
  Future<void> updateUserFields(Map<String, dynamic> updates) async {
    if (_currentUser.value != null) {
      final updatedUser = _currentUser.value!.copyWith(
        fullName: updates['fullName'] ?? _currentUser.value!.fullName,
        phone: updates['phone'] ?? _currentUser.value!.phone,
        email: updates['email'] ?? _currentUser.value!.email,
        licenseNumber: updates['licenseNumber'] ?? _currentUser.value!.licenseNumber,
        licenseExpiry: updates['licenseExpiry'] != null
            ? DateTime.parse(updates['licenseExpiry'])
            : _currentUser.value!.licenseExpiry,
      );

      _currentUser.value = updatedUser;
      await _secureStorage.writeObject('user', updatedUser.toJson());
    }
  }
// Verify OTP
  Future<bool> verifyOTP(String phone, String otp, {String? userId}) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.authVerifyOTP,
        data: {
          'phone': phone,
          'otp': otp,
          'userId': userId,
        },
        requiresAuth: false
      );

      if (response != null && response['data'] != null) {
        final userData = response['data']['user'];
        final tokens = response['data']['tokens'];

        // Auto login after verification
        _currentUser.value = UserModel.fromJson(userData);
        _authToken.value = tokens['accessToken'];
        _refreshToken.value = tokens['refreshToken'];
        _userRole.value = _currentUser.value?.role;
        _userId.value = _currentUser.value?.id ?? '';

        await _secureStorage.write(AppConstants.prefKeyToken, _authToken.value!);
        await _secureStorage.writeObject(AppConstants.prefKeyUser, userData);
        await _secureStorage.write('refresh_token', tokens['refreshToken']);

        _isAuthenticated.value = true;

        // Initialize services (including socket connection)
        await _initializeServices();
        _navigateToDashboard();

        return true;
      }
      return false;
    } catch (e) {
      print('OTP verification error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  // Resend OTP
  Future<bool> resendOTP(String phone) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.authResendOTP,
        data: {'phone': phone},
        requiresAuth: false
      );

      if (response != null && response['success'] == true) {
        AppSnackbar.show(
          'Success',
          'OTP resent successfully',
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Resend OTP error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String phone) async {
    try {
      _isLoading.value = true;

      // Clean the phone number before sending
      final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r'\D'), '');

      // Format to 10-digit with leading 09 if needed
      String formattedPhone = cleanPhone;
      if (cleanPhone.length == 9 && cleanPhone.startsWith('9')) {
        formattedPhone = '0$cleanPhone';
      }

      print('📞 Forgot password for phone: "$formattedPhone"');

      final response = await _apiClient.post(
        ApiEndpoints.authForgotPassword,
        data: {'phone': formattedPhone},
      );

      if (response != null && response['success'] == true) {
        Get.toNamed(
          AppRoutes.resetPassword,
          arguments: {'phone': formattedPhone},
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Forgot password error: $e');
      AppSnackbar.show(
        'Error',
        e.toString().contains('No user found')
            ? 'No account found with this phone number'
            : 'Failed to send reset code',
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.authResetPassword,
        data: {
          'phone': phone,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      if (response != null && response['success'] == true) {
        AppSnackbar.show(
          'Success',
          'Password reset successfully',
        );

        // Navigate to login
        Get.offAllNamed(AppRoutes.login);

        return true;
      }
      return false;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading.value = true;

      // Call logout API
      await _apiClient.post(
        ApiEndpoints.authLogout,
        requiresAuth: true,
      );

      // Clear all storage
      await _secureStorage.deleteAll();
      await _localStorage.clearAll();

      // Disconnect socket
      _socketService.disconnect();

      // Reset state
      _currentUser.value = null;
      _authToken.value = null;
      _refreshToken.value = null;
      _userRole.value = null;
      _userId.value = '';
      _isAuthenticated.value = false;

      // Clear API client auth header
      _apiClient.clearAuthHeader();

      // Navigate to login
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print('Logout error: $e');

      // Force logout even if API fails
      await _secureStorage.deleteAll();
      _currentUser.value = null;
      _authToken.value = null;
      _isAuthenticated.value = false;
      Get.offAllNamed(AppRoutes.login);
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read('refresh_token');
      if (refreshToken == null) return false;

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response != null && response['data'] != null) {
        _authToken.value = response['data']['accessToken'];
        await _secureStorage.write(AppConstants.prefKeyToken, _authToken.value!);

        if (response['data']['refreshToken'] != null) {
          _refreshToken.value = response['data']['refreshToken'];
          await _secureStorage.write('refresh_token', _refreshToken.value!);
        }

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.patch(
        ApiEndpoints.usersUpdateProfile,
        data: updates,
      );

      if (response != null && response['data'] != null) {
        _currentUser.value = UserModel.fromJson(response['data']);

        // Update storage
        await _secureStorage.writeObject(
          AppConstants.prefKeyUser,
          _currentUser.value!.toJson(),
        );

        return true;
      }
      return false;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.authChangePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response != null && response['success'] == true) {
        AppSnackbar.show(
          'Success',
          'Password changed successfully',
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Change password error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Handle login errors
  void _handleLoginError(ApiException e) {
    _loginAttempts.value++;

    if (_loginAttempts.value >= 5) {
      _blockUser();
    }

    AppSnackbar.show('Login Failed',
      e.message,);

  }

  // Block user after too many attempts
  void _blockUser() {
    _isBlocked.value = true;
    _blockedUntil.value = DateTime.now().add(const Duration(minutes: 15));

    // Auto unblock after 15 minutes
    Timer(const Duration(minutes: 15), () {
      _isBlocked.value = false;
      _blockedUntil.value = null;
      _loginAttempts.value = 0;
    });
  }

  // Show blocked message
  void _showBlockedMessage() {
    final minutesLeft = _blockedUntil.value?.difference(DateTime.now()).inMinutes ?? 0;
    AppSnackbar.show(
      'Account Blocked',
      'Too many login attempts. Please try again in $minutesLeft minutes.',
      );

  }

  // Navigate to appropriate dashboard based on role
  void _navigateToDashboard() {
    switch (_userRole.value) {
      case AppConstants.rolePassenger:
        Get.offAllNamed(AppRoutes.passengerDashboard);
        break;
      case AppConstants.roleDriver:
        Get.offAllNamed(AppRoutes.driverDashboard);
        break;
      case AppConstants.roleAdmin:
      case AppConstants.roleTicketingStaff:
      case AppConstants.roleCargoStaff:
        Get.offAllNamed(AppRoutes.adminDashboard);
        break;
      default:
        Get.offAllNamed(AppRoutes.passengerDashboard);
    }
  }

  // Check if session is valid
  Future<bool> isSessionValid() async {
    try {
      final token = await _secureStorage.read(AppConstants.prefKeyToken);
      if (token == null) return false;

      // Verify token with backend
      final response = await _apiClient.get(
        '/auth/verify',
        requiresAuth: true,
      );

      return response != null && response['valid'] == true;
    } catch (e) {
      return false;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.users}/$userId',
      );

      if (response != null && response['data'] != null) {
        return UserModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  @override
  void onClose() {
    _socketService.disconnect();
    super.onClose();
  }
}