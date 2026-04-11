// lib/data/providers/auth_provider.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/data/models/user/login_request.dart';
import 'package:menahariya/data/models/user/register_request.dart';
import 'package:menahariya/data/models/common/api_response.dart';

class AuthProvider extends GetxController {
  static AuthProvider get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Login
  Future<ApiResponse<Map<String, dynamic>>> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authLogin,
        data: request.toJson(),
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
            (data) => Map<String, dynamic>.from(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Register
  Future<ApiResponse<Map<String, dynamic>>> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authRegister,
        data: request.toJson(),
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
            (data) => Map<String, dynamic>.from(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Verify OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyOTP({
    required String phone,
    required String otp,
    String? userId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authVerifyOTP,
        data: {
          'phone': phone,
          'otp': otp,
          'userId': userId,
        },
        requiresAuth: false
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
            (data) => Map<String, dynamic>.from(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Resend OTP
  Future<ApiResponse<dynamic>> resendOTP(String phone) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authResendOTP,
        data: {'phone': phone},
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Forgot Password
  Future<ApiResponse<dynamic>> forgotPassword(String phone) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authForgotPassword,
        data: {'phone': phone},
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Reset Password
  Future<ApiResponse<dynamic>> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authResetPassword,
        data: {
          'phone': phone,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Change Password
  Future<ApiResponse<dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authChangePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Refresh Token
  Future<ApiResponse<Map<String, dynamic>>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        requiresAuth: false,
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
            (data) => Map<String, dynamic>.from(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Logout
  Future<ApiResponse<dynamic>> logout() async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authLogout,
        requiresAuth: true,
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Verify Token
  Future<ApiResponse<bool>> verifyToken() async {
    try {
      final response = await _apiClient.get(
        '/auth/verify',
        requiresAuth: true,
      );

      return ApiResponse<bool>.fromJson(
        response,
            (data) => data['valid'] ?? false,
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}