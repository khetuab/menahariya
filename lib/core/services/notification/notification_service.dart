// lib/core/services/notification/notification_service.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/data/models/notification/notification_model.dart';

import 'local_notification.dart';

class NotificationService extends GetxService {
  static NotificationService get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;
  final SecureStorage _storage = SecureStorage();

  // Observable notifications list
  final _notifications = <NotificationModel>[].obs;
  List<NotificationModel> get notifications => _notifications;

  // Unread count
  final _unreadCount = 0.obs;
  int get unreadCount => _unreadCount.value;

  // Loading states
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _initNotificationListener();
  }

  void _initNotificationListener() {
    // Listen for real-time notifications via socket
    _socketService.onNotification((data) {
      _handleNewNotification(data);
    });
  }

  // Fetch notifications from API
  Future<void> fetchNotifications({bool refresh = false}) async {
    try {
      _isLoading.value = true;

      if (refresh) {
        _notifications.clear();
      }

      final response = await _apiClient.get(
        ApiEndpoints.notificationsAll,
        queryParameters: {
          'page': 1,
          'limit': 50,
        },
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> notificationList = response['data'];
        final newNotifications = notificationList
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        _notifications.assignAll(newNotifications);
        _updateUnreadCount();
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Fetch unread notifications
  Future<void> fetchUnreadNotifications() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notificationsUnread,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> notificationList = response['data'];
        final unreadNotifications = notificationList
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        // Merge with existing notifications
        _mergeNotifications(unreadNotifications);
        _updateUnreadCount();
      }
    } catch (e) {
      print('Error fetching unread notifications: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.patch(
        '${ApiEndpoints.notificationsMarkRead}/$notificationId',
      );

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _notifications.refresh();
        _updateUnreadCount();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch(
        ApiEndpoints.notificationsMarkAllRead,
      );

      // Update local state
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      _notifications.refresh();
      _unreadCount.value = 0;
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete(
        '${ApiEndpoints.notificationsDelete}/$notificationId',
      );

      // Remove from local list
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAll() async {
    try {
      // Call API to clear all
      await _apiClient.delete(
        ApiEndpoints.notificationsAll,
      );

      // Clear local list
      _notifications.clear();
      _unreadCount.value = 0;
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // Handle new real-time notification
  void _handleNewNotification(Map<String, dynamic> data) {
    try {
      final notification = NotificationModel.fromJson(data);

      // Add to beginning of list
      _notifications.insert(0, notification);

      // Update unread count
      if (!notification.isRead) {
        _unreadCount.value++;
      }

      // Show local notification
      _showLocalNotification(notification);

      // Refresh list
      _notifications.refresh();
    } catch (e) {
      print('Error handling new notification: $e');
    }
  }

  // Show local notification
  void _showLocalNotification(NotificationModel notification) {
    // This will be handled by LocalNotificationService
    // Just trigger the method
    Get.find<LocalNotificationService>().showNotification(
      id: int.tryParse(notification.id.substring(0, 8)) ?? 0,
      title: notification.title,
      body: notification.body,
      payload: jsonEncode({
        'type': notification.type,
        'id': notification.id,
        'data': notification.data,
      }),
    );
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  // Merge notifications (avoid duplicates)
  void _mergeNotifications(List<NotificationModel> newNotifications) {
    final existingIds = _notifications.map((n) => n.id).toSet();

    for (final notification in newNotifications) {
      if (!existingIds.contains(notification.id)) {
        _notifications.add(notification);
      }
    }

    // Sort by date (newest first)
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get notification by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get recent notifications
  List<NotificationModel> getRecentNotifications({int limit = 10}) {
    return _notifications.take(limit).toList();
  }

  // Clear all data (on logout)
  void clear() {
    _notifications.clear();
    _unreadCount.value = 0;
  }
}