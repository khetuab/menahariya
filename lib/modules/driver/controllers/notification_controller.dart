// lib/modules/driver/controllers/notification_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/data/models/notification/notification_model.dart';

import '../../../core/utils/app_snackbar.dart';

class DriverNotificationController extends GetxController {
  static DriverNotificationController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;

  // Observables
  final RxBool _isLoading = false.obs;
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxInt _unreadCount = 0.obs;
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMorePages = true.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<NotificationModel> get notifications => _notifications.toList();
  int get unreadCount => _unreadCount.value;
  bool get hasMorePages => _hasMorePages.value;

  // Filtered notification types
  List<NotificationModel> get tripAssignments =>
      _notifications.where((n) => n.type == 'trip_assigned').toList();

  List<NotificationModel> get tripUpdates =>
      _notifications.where((n) => n.type == 'trip_update').toList();

  List<NotificationModel> get systemAlerts =>
      _notifications.where((n) => n.type == 'system_alert').toList();

  @override
  void onInit() {
    super.onInit();
    _setupSocketListeners();
    fetchNotifications();
  }

  void _setupSocketListeners() {
    _socketService.on('driver_notification', _handleNewNotification);
    _socketService.on('trip_assigned', _handleTripAssigned);
    _socketService.on('trip_updated', _handleTripUpdated);
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _notifications.clear();
    }

    if (!_hasMorePages.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '/driver/notifications',
        queryParameters: {
          'page': _currentPage.value,
          'limit': AppConstants.defaultPageSize,
        },
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> notificationsData = response['data'];

        final List<NotificationModel> newNotifications = notificationsData
            .map((n) => NotificationModel.fromJson(n))
            .toList();

        if (_currentPage.value == 1) {
          _notifications.value = newNotifications;
        } else {
          _notifications.addAll(newNotifications);
        }

        _updateUnreadCount();
        _hasMorePages.value =
            newNotifications.length >= AppConstants.defaultPageSize;

        _currentPage.value++;
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _handleNewNotification(dynamic data) {
    try {
      final notification = NotificationModel.fromJson(data);
      _notifications.insert(0, notification);

      if (!notification.isRead) {
        _unreadCount.value++;

        AppSnackbar.show(
          notification.title,
          notification.body,
        );
      }

      _notifications.refresh();
    } catch (e) {
      print('Error handling new notification: $e');
    }
  }

  void _handleTripAssigned(dynamic data) {
    try {
      final notification = NotificationModel(
        id: data['id'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        userId: data['userid'] ?? '',
        title: 'New Trip Assigned',
        body:
        'You have been assigned a new trip from ${data['origin']} to ${data['destination']}',
        type: 'trip_assigned',
        data: data,
        createdAt: DateTime.now(),
        isRead: false,
      );

      _notifications.insert(0, notification);
      _unreadCount.value++;

      Get.dialog(
        AlertDialog(
          title: const Text('New Trip Assignment'),
          content: Text(
            'Trip from ${data['origin']} to ${data['destination']}\n'
                'Departure: ${data['departureTime']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('View Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed('/driver/trip/${data['id']}');
              },
              child: const Text('View Now'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error handling trip assigned: $e');
    }
  }

  void _handleTripUpdated(dynamic data) {
    try {
      final notification = NotificationModel(
        id: data['id'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Trip Update',
        body: data['message'] ?? 'Your trip has been updated',
        type: 'trip_update',
        data: data,
        createdAt: DateTime.now(),
        isRead: false,
        userId: data['userid'] ?? '',
      );

      _notifications.insert(0, notification);
      _unreadCount.value++;
    } catch (e) {
      print('Error handling trip update: $e');
    }
  }

  void _updateUnreadCount() {
    _unreadCount.value =
        _notifications.where((n) => !n.isRead).length;
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications(refresh: true);
  }

  Future<void> loadMore() async {
    if (_hasMorePages.value && !_isLoading.value) {
      await fetchNotifications();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.patch(
        '${ApiEndpoints.notificationsMarkRead}/$notificationId',
      );

      final index =
      _notifications.indexWhere((n) => n.id == notificationId);

      if (index != -1) {
        _notifications[index] =
            _notifications[index].copyWith(isRead: true);

        _notifications.refresh();
        _updateUnreadCount();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch('/driver/notifications/mark-all-read');

      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] =
            _notifications[i].copyWith(isRead: true);
      }

      _notifications.refresh();
      _unreadCount.value = 0;

      AppSnackbar.show(
        'Success',
        'All notifications marked as read',
      );
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete(
        '${ApiEndpoints.notificationsDelete}/$notificationId',
      );

      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();

      AppSnackbar.show(
        'Success',
        'Notification deleted',
      );
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    switch (notification.type) {
      case 'trip_assigned':
      case 'trip_update':
        final tripId =
            notification.data?['tripId'] ?? notification.data?['id'];

        if (tripId != null) {
          Get.toNamed('/driver/trip/$tripId');
        }
        break;

      case 'system_alert':
        Get.toNamed('/driver/alerts');
        break;

      default:
        Get.toNamed('/driver/notification/${notification.id}');
    }
  }

  @override
  void onClose() {
    _socketService.off('driver_notification', _handleNewNotification);
    _socketService.off('trip_assigned', _handleTripAssigned);
    _socketService.off('trip_updated', _handleTripUpdated);
    super.onClose();
  }
}