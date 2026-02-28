// lib/data/repositories/notification_repository.dart

import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/core/services/storage/local_storage.dart';
import 'package:menahariya/data/providers/notification_provider.dart';
import 'package:menahariya/data/models/notification/notification_model.dart';

class NotificationRepository extends GetxController {
  static NotificationRepository get instance => Get.find();

  final NotificationProvider _notificationProvider = NotificationProvider.instance;
  final LocalStorage _localStorage = LocalStorage();

  // Cache keys
  static const String _cacheNotifications = 'notifications';
  static const String _cacheUnreadCount = 'unread_count';
  static const Duration _cacheDuration = Duration(minutes: 2);

  // Get All Notifications with Pagination
  Future<List<NotificationModel>> getAllNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache for first page only
      if (!forceRefresh && page == 1 && type == null) {
        final cached = await _localStorage.getCachedData(_cacheNotifications);
        if (cached != null) {
          return (cached as List)
              .map((item) => NotificationModel.fromJson(item))
              .toList();
        }
      }

      final response = await _notificationProvider.getAllNotifications(
        page: page,
        limit: limit,
        type: type,
      );

      if (response.success) {
        final notifications = response.data ?? [];

        // Cache first page results
        if (page == 1 && type == null) {
          await _localStorage.cacheData(
            _cacheNotifications,
            notifications.map((n) => n.toJson()).toList(),
            expiry: _cacheDuration,
          );
        }

        return notifications;
      }

      return [];
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Get Unread Notifications
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final response = await _notificationProvider.getUnreadNotifications();

      if (response.success) {
        return response.data ?? [];
      }

      return [];
    } catch (e) {
      print('Error getting unread notifications: $e');
      return [];
    }
  }

  // Get Unread Count with Caching
  Future<int> getUnreadCount({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _localStorage.getCachedData(_cacheUnreadCount);
        if (cached != null) {
          return cached['count'] ?? 0;
        }
      }

      final response = await _notificationProvider.getUnreadCount();

      if (response.success) {
        final count = response.data ?? 0;

        // Cache the result
        await _localStorage.cacheData(
          _cacheUnreadCount,
          {'count': count},
          expiry: _cacheDuration,
        );

        return count;
      }

      return 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Mark Notification as Read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _notificationProvider.markAsRead(notificationId);

      if (response.success) {
        // Update caches
        await _updateUnreadCount(-1);
        await _refreshNotificationsCache();
        return true;
      }

      return false;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark All as Read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _notificationProvider.markAllAsRead();

      if (response.success) {
        // Reset caches
        await _localStorage.cacheData(
          _cacheUnreadCount,
          {'count': 0},
          expiry: _cacheDuration,
        );
        await _refreshNotificationsCache();
        return true;
      }

      return false;
    } catch (e) {
      print('Error marking all as read: $e');
      return false;
    }
  }

  // Delete Notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _notificationProvider.deleteNotification(notificationId);

      if (response.success) {
        await _refreshNotificationsCache();
        return true;
      }

      return false;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Delete All Notifications
  Future<bool> deleteAllNotifications() async {
    try {
      final response = await _notificationProvider.deleteAllNotifications();

      if (response.success) {
        // Clear caches
        await _localStorage.clear(_cacheNotifications);
        await _localStorage.cacheData(
          _cacheUnreadCount,
          {'count': 0},
          expiry: _cacheDuration,
        );
        return true;
      }

      return false;
    } catch (e) {
      print('Error deleting all notifications: $e');
      return false;
    }
  }

  // Get Notification Settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final response = await _notificationProvider.getNotificationSettings();

      if (response.success) {
        return response.data ?? {};
      }

      return {};
    } catch (e) {
      print('Error getting notification settings: $e');
      return {};
    }
  }

  // Update Notification Settings
  Future<Map<String, dynamic>> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      final response = await _notificationProvider.updateNotificationSettings(settings);

      if (response.success) {
        return response.data ?? {};
      }

      return {};
    } catch (e) {
      print('Error updating notification settings: $e');
      return {};
    }
  }

  // Register Push Token
  Future<bool> registerPushToken(String token, String deviceType) async {
    try {
      final response = await _notificationProvider.registerPushToken(token, deviceType);
      return response.success;
    } catch (e) {
      print('Error registering push token: $e');
      return false;
    }
  }

  // Unregister Push Token
  Future<bool> unregisterPushToken(String token) async {
    try {
      final response = await _notificationProvider.unregisterPushToken(token);
      return response.success;
    } catch (e) {
      print('Error unregistering push token: $e');
      return false;
    }
  }

  // Driver: Get Driver Notifications
  Future<List<NotificationModel>> getDriverNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _notificationProvider.getDriverNotifications(
        page: page,
        limit: limit,
      );

      if (response.success) {
        return response.data ?? [];
      }

      return [];
    } catch (e) {
      print('Error getting driver notifications: $e');
      return [];
    }
  }

  // Driver: Mark All Driver Notifications as Read
  Future<bool> markAllDriverNotificationsAsRead() async {
    try {
      final response = await _notificationProvider.markAllDriverNotificationsAsRead();
      return response.success;
    } catch (e) {
      print('Error marking all driver notifications as read: $e');
      return false;
    }
  }

  // Private helper methods
  Future<void> _updateUnreadCount(int delta) async {
    final current = await getUnreadCount(forceRefresh: true);
    await _localStorage.cacheData(
      _cacheUnreadCount,
      {'count': current + delta},
      expiry: _cacheDuration,
    );
  }

  Future<void> _refreshNotificationsCache() async {
    // Invalidate cache
    await _localStorage.clear(_cacheNotifications);
    // Fetch new data
    await getAllNotifications(forceRefresh: true);
  }

  // Clear all caches
  Future<void> clearCache() async {
    await _localStorage.clear(_cacheNotifications);
    await _localStorage.clear(_cacheUnreadCount);
  }
}