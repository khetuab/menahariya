// lib/data/repositories/auth_repository.dart

import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/data/providers/auth_provider.dart';
import 'package:menahariya/data/models/user/user_model.dart';
import 'package:menahariya/data/models/user/login_request.dart';
import 'package:menahariya/data/models/user/register_request.dart';

class AuthRepository extends GetxController {
  static AuthRepository get instance => Get.find();

  final AuthProvider _authProvider = AuthProvider.instance;
  final SecureStorage _secureStorage = SecureStorage();

  // Login with caching
  Future<Map<String, dynamic>> login(LoginRequest request) async {
    try {
      final response = await _authProvider.login(request);

      if (response.success) {
        // Cache user data and tokens
        final userData = response.data?['user'];
        final tokens = response.data?['tokens'];

        if (userData != null) {
          await _secureStorage.writeObject('user_data', userData);
          await _secureStorage.write('access_token', tokens?['accessToken']);
          await _secureStorage.write('refresh_token', tokens?['refreshToken']);

          return {
            'user': UserModel.fromJson(userData),
            'tokens': tokens,
          };
        }
      }

      throw ApiException(
        message: response.message ?? 'Login failed',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Register
  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    try {
      final response = await _authProvider.register(request);

      if (response.success) {
        return {
          'userId': response.data?['userId'],
          'message': response.message,
        };
      }

      throw ApiException(
        message: response.message ?? 'Registration failed',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP({
    required String phone,
    required String otp,
    String? userId,
  }) async {
    try {
      final response = await _authProvider.verifyOTP(
        phone: phone,
        otp: otp,
        userId: userId,
      );

      if (response.success) {
        final userData = response.data?['user'];
        final tokens = response.data?['tokens'];

        if (userData != null) {
          await _secureStorage.writeObject('user_data', userData);
          await _secureStorage.write('access_token', tokens?['accessToken']);
          await _secureStorage.write('refresh_token', tokens?['refreshToken']);

          return {
            'user': UserModel.fromJson(userData),
            'tokens': tokens,
          };
        }
      }

      throw ApiException(
        message: response.message ?? 'OTP verification failed',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Resend OTP
  Future<bool> resendOTP(String phone) async {
    try {
      final response = await _authProvider.resendOTP(phone);
      return response.success;
    } on ApiException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String phone) async {
    try {
      final response = await _authProvider.forgotPassword(phone);
      return response.success;
    } on ApiException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Reset Password
  Future<bool> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _authProvider.resetPassword(
        phone: phone,
        otp: otp,
        newPassword: newPassword,
      );
      return response.success;
    } on ApiException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Change Password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _authProvider.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return response.success;
    } on ApiException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Refresh Token
  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read('refresh_token');
      if (refreshToken == null) return null;

      final response = await _authProvider.refreshToken(refreshToken);

      if (response.success) {
        final newToken = response.data?['accessToken'];
        if (newToken != null) {
          await _secureStorage.write('access_token', newToken);
          return newToken;
        }
      }
      return null;
    } on ApiException catch (e) {
      print('Token refresh failed: ${e.message}');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authProvider.logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Clear all cached data regardless of API response
      await _secureStorage.deleteAll();
    }
  }

  // Verify Token
  Future<bool> verifyToken() async {
    try {
      final response = await _authProvider.verifyToken();
      return response.data ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get Cached User
  Future<UserModel?> getCachedUser() async {
    try {
      final userData = await _secureStorage.readObject('user_data');
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error reading cached user: $e');
      return null;
    }
  }

  // Get Cached Token
  Future<String?> getCachedToken() async {
    return await _secureStorage.read('access_token');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getCachedToken();
    return token != null;
  }

  // Handle Auth Errors
  ApiException _handleAuthError(ApiException e) {
    switch (e.statusCode) {
      case 401:
        return ApiException(
          message: 'Invalid phone number or password',
          statusCode: 401,
        );
      case 403:
        return ApiException(
          message: 'Account is locked. Please try again later.',
          statusCode: 403,
        );
      case 409:
        return ApiException(
          message: 'Phone number already registered',
          statusCode: 409,
        );
      case 422:
        return ApiException(
          message: e.firstValidationError ?? 'Validation failed',
          statusCode: 422,
        );
      default:
        return e;
    }
  }
}