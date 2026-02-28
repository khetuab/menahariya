// lib/data/providers/user_provider.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/data/models/user/user_model.dart';
import 'package:menahariya/data/models/common/api_response.dart';

class UserProvider extends GetxController {
  static UserProvider get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Get Current User
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.usersProfile);

      return ApiResponse<UserModel>.fromJson(
        response,
            (data) => UserModel.fromJson(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Update Profile
  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.usersUpdateProfile,
        data: updates,
      );

      return ApiResponse<UserModel>.fromJson(
        response,
            (data) => UserModel.fromJson(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Upload Avatar
  Future<ApiResponse<Map<String, dynamic>>> uploadAvatar(File imageFile) async {
    try {
      final response = await _apiClient.uploadFile(
        ApiEndpoints.usersUpdateAvatar,
        imageFile.path,
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

  // Get User by ID
  Future<ApiResponse<UserModel>> getUserById(String userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.users}/$userId',
      );

      return ApiResponse<UserModel>.fromJson(
        response,
            (data) => UserModel.fromJson(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get User Preferences
  Future<ApiResponse<Map<String, dynamic>>> getUserPreferences() async {
    try {
      final response = await _apiClient.get('/user/preferences');

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

  // Update User Preferences
  Future<ApiResponse<Map<String, dynamic>>> updateUserPreferences(
      Map<String, dynamic> preferences,
      ) async {
    try {
      final response = await _apiClient.put(
        '/user/preferences',
        data: preferences,
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

  // Get User Statistics
  Future<ApiResponse<Map<String, dynamic>>> getUserStatistics() async {
    try {
      final response = await _apiClient.get('/user/statistics');

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

  // Driver: Get Driver Statistics
  Future<ApiResponse<Map<String, dynamic>>> getDriverStatistics() async {
    try {
      final response = await _apiClient.get('/driver/stats');

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

  // Driver: Update Availability
  Future<ApiResponse<dynamic>> updateDriverAvailability(bool isAvailable) async {
    try {
      final response = await _apiClient.post(
        '/driver/update-status',
        data: {'status': isAvailable ? 'online' : 'offline'},
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Driver: Get Today's Stats
  Future<ApiResponse<Map<String, dynamic>>> getDriverTodayStats() async {
    try {
      final response = await _apiClient.get('/driver/today-stats');

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

  // Delete Account
  Future<ApiResponse<dynamic>> deleteAccount(String password) async {
    try {
      final response = await _apiClient.delete(
        '/user/account',
        data: {'password': password},
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Toggle Favorite
  Future<ApiResponse<dynamic>> toggleFavorite(String type, String id) async {
    try {
      final response = await _apiClient.post(
        '/user/favorites/toggle',
        data: {'type': type, 'id': id},
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Favorites
  Future<ApiResponse<List<Map<String, dynamic>>>> getFavorites(String type) async {
    try {
      final response = await _apiClient.get(
        '/user/favorites',
        queryParameters: {'type': type},
      );

      return ApiResponse<List<Map<String, dynamic>>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}