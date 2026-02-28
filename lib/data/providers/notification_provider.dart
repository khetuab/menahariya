// lib/data/providers/notification_provider.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/data/models/notification/notification_model.dart';
import 'package:menahariya/data/models/common/api_response.dart';

class NotificationProvider extends GetxController {
  static NotificationProvider get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Get All Notifications
  Future<ApiResponse<List<NotificationModel>>> getAllNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notificationsAll,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null) 'type': type,
        },
      );

      return ApiResponse<List<NotificationModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Unread Notifications
  Future<ApiResponse<List<NotificationModel>>> getUnreadNotifications() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.notificationsUnread);

      return ApiResponse<List<NotificationModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Unread Count
  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/notifications/unread/count');

      return ApiResponse<int>.fromJson(
        response,
            (data) => data['count'] ?? 0,
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Mark Notification as Read
  Future<ApiResponse<dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.notificationsMarkRead}/$notificationId',
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Mark All as Read
  Future<ApiResponse<dynamic>> markAllAsRead() async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.notificationsMarkAllRead,
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Delete Notification
  Future<ApiResponse<dynamic>> deleteNotification(String notificationId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.notificationsDelete}/$notificationId',
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Delete All Notifications
  Future<ApiResponse<dynamic>> deleteAllNotifications() async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.notificationsAll,
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Notification Settings
  Future<ApiResponse<Map<String, dynamic>>> getNotificationSettings() async {
    try {
      final response = await _apiClient.get('/notifications/settings');

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

  // Update Notification Settings
  Future<ApiResponse<Map<String, dynamic>>> updateNotificationSettings(
      Map<String, dynamic> settings,
      ) async {
    try {
      final response = await _apiClient.put(
        '/notifications/settings',
        data: settings,
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

  // Register Push Token
  Future<ApiResponse<dynamic>> registerPushToken(String token, String deviceType) async {
    try {
      final response = await _apiClient.post(
        '/notifications/register-token',
        data: {
          'token': token,
          'deviceType': deviceType,
        },
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Unregister Push Token
  Future<ApiResponse<dynamic>> unregisterPushToken(String token) async {
    try {
      final response = await _apiClient.post(
        '/notifications/unregister-token',
        data: {'token': token},
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Driver: Get Driver Notifications
  Future<ApiResponse<List<NotificationModel>>> getDriverNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/driver/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );

      return ApiResponse<List<NotificationModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Driver: Mark All Driver Notifications as Read
  Future<ApiResponse<dynamic>> markAllDriverNotificationsAsRead() async {
    try {
      final response = await _apiClient.patch(
        '/driver/notifications/mark-all-read',
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}