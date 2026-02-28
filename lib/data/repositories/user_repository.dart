// lib/data/repositories/user_repository.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/core/services/storage/local_storage.dart';
import 'package:menahariya/data/providers/user_provider.dart';
import 'package:menahariya/data/models/user/user_model.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final UserProvider _userProvider = UserProvider.instance;
  final SecureStorage _secureStorage = SecureStorage();
  final LocalStorage _localStorage = LocalStorage();

  // Cache keys
  static const String _cacheUserProfile = 'user_profile';
  static const String _cacheUserPreferences = 'user_preferences';
  static const Duration _cacheDuration = Duration(hours: 1);

  // Get Current User with Caching
  Future<UserModel> getCurrentUser({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _localStorage.getCachedData(_cacheUserProfile);
        if (cached != null) {
          return UserModel.fromJson(cached);
        }
      }

      final response = await _userProvider.getCurrentUser();

      if (response.success && response.data != null) {
        // Cache the result
        await _localStorage.cacheData(
          _cacheUserProfile,
          response.data!.toJson(),
          expiry: _cacheDuration,
        );

        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to get user profile',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleUserError(e);
    }
  }

  // Update Profile
  Future<UserModel> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _userProvider.updateProfile(updates);

      if (response.success && response.data != null) {
        // Update cache
        await _localStorage.cacheData(
          _cacheUserProfile,
          response.data!.toJson(),
          expiry: _cacheDuration,
        );

        // Update secure storage
        await _secureStorage.writeObject('user_data', response.data!.toJson());

        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to update profile',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleUserError(e);
    }
  }

  // Upload Avatar
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final response = await _userProvider.uploadAvatar(imageFile);

      if (response.success && response.data != null) {
        final imageUrl = response.data!['url'];

        // Update cached user with new avatar
        final currentUser = await getCurrentUser();
        if (currentUser != null) {
          await updateProfile({'profileImage': imageUrl});
        }

        return imageUrl;
      }

      throw ApiException(
        message: response.message ?? 'Failed to upload avatar',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleUserError(e);
    }
  }

  // Get User Preferences with Caching
  Future<Map<String, dynamic>> getUserPreferences({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _localStorage.getCachedData(_cacheUserPreferences);
        if (cached != null) {
          return cached;
        }
      }

      final response = await _userProvider.getUserPreferences();

      if (response.success) {
        final preferences = response.data ?? {};

        // Cache the result
        await _localStorage.cacheData(
          _cacheUserPreferences,
          preferences,
          expiry: _cacheDuration,
        );

        return preferences;
      }

      return {};
    } catch (e) {
      print('Error getting user preferences: $e');
      return {};
    }
  }

  // Update User Preferences
  Future<Map<String, dynamic>> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final response = await _userProvider.updateUserPreferences(preferences);

      if (response.success) {
        // Update cache
        await _localStorage.cacheData(
          _cacheUserPreferences,
          response.data ?? {},
          expiry: _cacheDuration,
        );

        return response.data ?? {};
      }

      return {};
    } catch (e) {
      print('Error updating user preferences: $e');
      return {};
    }
  }

  // Get User Statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final response = await _userProvider.getUserStatistics();

      if (response.success) {
        return response.data ?? {};
      }

      return {};
    } catch (e) {
      print('Error getting user statistics: $e');
      return {};
    }
  }

  // Driver: Get Driver Statistics
  Future<Map<String, dynamic>> getDriverStatistics() async {
    try {
      final response = await _userProvider.getDriverStatistics();

      if (response.success) {
        return response.data ?? {};
      }

      return {};
    } catch (e) {
      print('Error getting driver statistics: $e');
      return {};
    }
  }

  // Driver: Update Availability
  Future<bool> updateDriverAvailability(bool isAvailable) async {
    try {
      final response = await _userProvider.updateDriverAvailability(isAvailable);
      return response.success;
    } catch (e) {
      print('Error updating driver availability: $e');
      return false;
    }
  }

  // Driver: Get Today's Stats
  Future<Map<String, dynamic>> getDriverTodayStats() async {
    try {
      final response = await _userProvider.getDriverTodayStats();

      if (response.success) {
        return response.data ?? {};
      }

      return {};
    } catch (e) {
      print('Error getting driver today stats: $e');
      return {};
    }
  }

  // Delete Account
  Future<bool> deleteAccount(String password) async {
    try {
      final response = await _userProvider.deleteAccount(password);

      if (response.success) {
        // Clear all cached data
        await _secureStorage.deleteAll();
        await _localStorage.clearAll();
        return true;
      }

      return false;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  // Toggle Favorite
  Future<bool> toggleFavorite(String type, String id) async {
    try {
      final response = await _userProvider.toggleFavorite(type, id);
      return response.success;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Get Favorites
  Future<List<Map<String, dynamic>>> getFavorites(String type) async {
    try {
      final response = await _userProvider.getFavorites(type);

      if (response.success) {
        return response.data ?? [];
      }

      return [];
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  // Clear User Cache
  Future<void> clearCache() async {
    await _localStorage.clear(_cacheUserProfile);
    await _localStorage.clear(_cacheUserPreferences);
  }

  // Handle User Errors
  ApiException _handleUserError(ApiException e) {
    switch (e.statusCode) {
      case 404:
        return ApiException(
          message: 'User not found',
          statusCode: 404,
        );
      case 409:
        return ApiException(
          message: 'Email already in use',
          statusCode: 409,
        );
      default:
        return e;
    }
  }
}