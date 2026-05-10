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
  final RxList<NotificationModel> _filteredNotifications = <NotificationModel>[].obs;
  final RxInt _unreadCount = 0.obs;
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMorePages = true.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalItems = 0.obs;
  final RxString _currentFilter = RxString('');

  // Getters
  bool get isLoading => _isLoading.value;
  int get unreadCount => _unreadCount.value;
  bool get hasMorePages => _hasMorePages.value;
  int get totalItems => _totalItems.value;
  int get totalPages => _totalPages.value;
  String? get currentFilter => _currentFilter.value.isEmpty ? null : _currentFilter.value;

  // Get displayed notifications based on filter
  List<NotificationModel> get notifications {
    if (_currentFilter.value.isEmpty) {
      return _notifications.toList();
    } else {
      return _filteredNotifications.toList();
    }
  }

  // Filtered notification types (for quick access)
  List<NotificationModel> get tripAssignments =>
      _notifications.where((n) => n.type == 'trip_assigned').toList();

  List<NotificationModel> get tripUpdates =>
      _notifications.where((n) => n.type == 'trip_update').toList();

  List<NotificationModel> get systemAlerts =>
      _notifications.where((n) => n.type == 'system_alert').toList();

  @override
  void onInit() {
    super.onInit();
    print('🔔 NotificationController initialized');
    _setupSocketListeners();
    // Use a small delay to ensure everything is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchNotifications();
      fetchUnreadCount();
    });
  }

  void _setupSocketListeners() {
    _socketService.on('driver_notification', _handleNewNotification);
    _socketService.on('trip_assigned', _handleTripAssigned);
    _socketService.on('trip_updated', _handleTripUpdated);
  }

  Future<void> fetchUnreadCount() async {
    try {
      print('🔔 Fetching unread count...');
      final response = await _apiClient.get('/driver/notifications/unread-count');
      print('🔔 Unread count response: $response');
      if (response != null) {
        if (response['count'] != null) {
          _unreadCount.value = response['count'];
        } else if (response['data'] != null) {
          _unreadCount.value = response['data'];
        }
      }
    } catch (e) {
      print('❌ Error fetching unread count: $e');
      _unreadCount.value = 0;
    }
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      print('🔄 Refreshing notifications...');
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _notifications.clear();
      _filteredNotifications.clear();
      _currentFilter.value = '';
      _totalPages.value = 1;
      _totalItems.value = 0;
    }

    if (!_hasMorePages.value) {
      print('⚠️ No more pages to load');
      return;
    }

    if (_isLoading.value) {
      print('⏳ Already loading, skipping...');
      return;
    }

    try {
      _isLoading.value = true;
      print('🔔 Fetching notifications - Page: ${_currentPage.value}');

      final response = await _apiClient.get(
        '/driver/notifications',
        queryParameters: {
          'page': _currentPage.value,
          'limit': AppConstants.defaultPageSize,
        },
      );

      print('🔔 Notifications response received');

      if (response != null) {
        List<NotificationModel> newNotifications = [];

        // Handle different response formats
        if (response['data'] != null && response['data'] is List) {
          newNotifications = (response['data'] as List)
              .map((n) => NotificationModel.fromJson(n))
              .toList();
          print('✅ Found ${newNotifications.length} notifications from data field');

          // Handle pagination
          if (response['pagination'] != null) {
            _totalPages.value = response['pagination']['pages'] ?? 1;
            _totalItems.value = response['pagination']['total'] ?? 0;
            _hasMorePages.value = _currentPage.value < _totalPages.value;
            print('📄 Pagination: page $_currentPage.value of $_totalPages, total $_totalItems');
          } else {
            _hasMorePages.value = newNotifications.length >= AppConstants.defaultPageSize;
          }
        }
        else if (response['notifications'] != null && response['notifications'] is List) {
          newNotifications = (response['notifications'] as List)
              .map((n) => NotificationModel.fromJson(n))
              .toList();
          print('✅ Found ${newNotifications.length} notifications from notifications field');
          _hasMorePages.value = false;
        }
        else if (response is List) {
          newNotifications = response
              .map((n) => NotificationModel.fromJson(n))
              .toList();
          print('✅ Found ${newNotifications.length} notifications from direct array');
          _hasMorePages.value = false;
        }

        // Update notifications list
        if (_currentPage.value == 1) {
          _notifications.value = newNotifications;
          print('📱 Set ${_notifications.length} notifications to list');
        } else {
          _notifications.addAll(newNotifications);
          print('📱 Added ${newNotifications.length} notifications, total now ${_notifications.length}');
        }

        // Re-apply filter if one is active
        if (_currentFilter.value.isNotEmpty) {
          _applyFilter();
        }

        _updateUnreadCount();

        if (_hasMorePages.value && newNotifications.isNotEmpty) {
          _currentPage.value++;
        }
      } else {
        print('⚠️ No notifications found in response');
        if (_currentPage.value == 1) {
          _notifications.clear();
          _filteredNotifications.clear();
        }
      }
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      if (_currentPage.value == 1) {
        _notifications.clear();
        _filteredNotifications.clear();
      }
    } finally {
      _isLoading.value = false;
      // Force UI update
      _notifications.refresh();
      _filteredNotifications.refresh();
    }
  }

  void _applyFilter() {
    if (_currentFilter.value.isEmpty) {
      return;
    }

    _filteredNotifications.value = _notifications
        .where((notification) => notification.type == _currentFilter.value)
        .toList();
    print('📱 Filter applied: ${_currentFilter.value}, showing ${_filteredNotifications.length} notifications');
  }

  void setFilter(String? filterType) {
    print('🔍 Setting filter to: ${filterType ?? 'All'}');
    _currentFilter.value = filterType ?? '';

    if (filterType == null || filterType.isEmpty) {
      // Show all notifications
      _filteredNotifications.clear();
      print('📱 Showing all ${_notifications.length} notifications');
    } else {
      // Filter notifications by type
      _filteredNotifications.value = _notifications
          .where((notification) => notification.type == filterType)
          .toList();
      print('📱 Showing ${_filteredNotifications.length} notifications of type: $filterType');
    }

    // Refresh the UI
    _filteredNotifications.refresh();
  }

  void _updateUnreadCount() {
    _unreadCount.value = _notifications.where((n) => !n.isRead).length;
    print('📊 Updated unread count: ${_unreadCount.value}');
  }

  Future<void> refreshNotifications() async {
    print('🔄 Manual refresh triggered');
    await fetchNotifications(refresh: true);
    await fetchUnreadCount();
  }

  Future<void> loadMore() async {
    if (_hasMorePages.value && !_isLoading.value) {
      print('📥 Loading more notifications...');
      await fetchNotifications();
    }
  }

  void _handleNewNotification(dynamic data) {
    try {
      print('🔔 New notification received: $data');
      final notification = NotificationModel.fromJson(data);
      _notifications.insert(0, notification);

      // Update filtered list if filter matches
      if (_currentFilter.value.isEmpty || notification.type == _currentFilter.value) {
        _filteredNotifications.insert(0, notification);
      }

      if (!notification.isRead) {
        _unreadCount.value++;

        AppSnackbar.show(
          notification.title,
          notification.body,
        );
      }

      _notifications.refresh();
      _filteredNotifications.refresh();
    } catch (e) {
      print('Error handling new notification: $e');
    }
  }

  void _handleTripAssigned(dynamic data) {
    try {
      print('🚐 Trip assigned notification: $data');
      final notification = NotificationModel(
        id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: data['userId'] ?? data['userid'] ?? '',
        title: 'New Trip Assigned',
        body: 'You have been assigned a new trip from ${data['origin']} to ${data['destination']}',
        type: 'trip_assigned',  // Use 'trip_assigned' consistently
        data: data,
        createdAt: DateTime.now(),
        isRead: false,
      );

      _notifications.insert(0, notification);

      if (_currentFilter.value.isEmpty || notification.type == _currentFilter.value) {
        _filteredNotifications.insert(0, notification);
      }

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
                Get.toNamed('/driver/trip/${data['id'] ?? data['tripId']}');
              },
              child: const Text('View Now'),
            ),
          ],
        ),
      );

      _notifications.refresh();
      _filteredNotifications.refresh();
    } catch (e) {
      print('Error handling trip assigned: $e');
    }
  }

  void _handleTripUpdated(dynamic data) {
    try {
      print('🔄 Trip update notification: $data');
      final notification = NotificationModel(
        id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: data['userId'] ?? data['userid'] ?? '',
        title: 'Trip Update',
        body: data['message'] ?? 'Your trip has been updated',
        type: 'trip_update',  // Use 'trip_update' consistently
        data: data,
        createdAt: DateTime.now(),
        isRead: false,
      );

      _notifications.insert(0, notification);

      if (_currentFilter.value.isEmpty || notification.type == _currentFilter.value) {
        _filteredNotifications.insert(0, notification);
      }

      _unreadCount.value++;
      _notifications.refresh();
      _filteredNotifications.refresh();
    } catch (e) {
      print('Error handling trip update: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      print('📖 Marking notification as read: $notificationId');
      await _apiClient.patch(
        '${ApiEndpoints.notificationsMarkRead}/$notificationId',
      );

      // Update in main list
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }

      // Update in filtered list
      final filteredIndex = _filteredNotifications.indexWhere((n) => n.id == notificationId);
      if (filteredIndex != -1) {
        _filteredNotifications[filteredIndex] = _filteredNotifications[filteredIndex].copyWith(isRead: true);
      }

      _notifications.refresh();
      _filteredNotifications.refresh();
      _updateUnreadCount();
      print('✅ Notification marked as read');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      print('📖 Marking all notifications as read');
      await _apiClient.patch('/driver/notifications/mark-all-read');

      // Update all notifications in main list
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }

      // Update all notifications in filtered list
      for (var i = 0; i < _filteredNotifications.length; i++) {
        _filteredNotifications[i] = _filteredNotifications[i].copyWith(isRead: true);
      }

      _notifications.refresh();
      _filteredNotifications.refresh();
      _unreadCount.value = 0;

      AppSnackbar.show(
        'Success',
        'All notifications marked as read',
      );
    } catch (e) {
      print('❌ Error marking all as read: $e');
      AppSnackbar.show('Error', 'Failed to mark all as read');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      print('🗑️ Deleting notification: $notificationId');
      await _apiClient.delete(
        '${ApiEndpoints.notificationsDelete}/$notificationId',
      );

      _notifications.removeWhere((n) => n.id == notificationId);
      _filteredNotifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      _notifications.refresh();
      _filteredNotifications.refresh();

      AppSnackbar.show(
        'Success',
        'Notification deleted',
      );
    } catch (e) {
      print('❌ Error deleting notification: $e');
      AppSnackbar.show('Error', 'Failed to delete notification');
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    print('👆 Notification tapped: ${notification.title}');
    print('📋 Notification type: ${notification.type}');
    print('📋 Notification data: ${notification.data}');

    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    switch (notification.type) {
      case 'trip_assigned':
      case 'trip_update':
      case 'trip':  // Add this to handle 'trip' type
        final tripId = notification.data?['tripId'] ??
            notification.data?['id'] ??
            notification.data?['trip_id'];

        if (tripId != null) {
          print('✅ Navigating to trip: $tripId');
          Get.toNamed('/driver/trip/$tripId');
        } else {
          print('⚠️ No trip ID found in notification');
          // Try to extract from other possible fields
          print('Available data keys: ${notification.data?.keys}');
        }
        break;

      case 'system_alert':
        Get.toNamed('/driver/alerts');
        break;

      default:
        print('Unknown notification type: ${notification.type}');
        // Optional: Show a dialog with the notification content
        Get.dialog(
          AlertDialog(
            title: Text(notification.title),
            content: Text(notification.body),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
    }
  }

  @override
  void onClose() {
    print('🔔 NotificationController closing');
    _socketService.off('driver_notification', _handleNewNotification);
    _socketService.off('trip_assigned', _handleTripAssigned);
    _socketService.off('trip_updated', _handleTripUpdated);
    super.onClose();
  }
}