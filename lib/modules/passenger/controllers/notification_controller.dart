// lib/modules/passenger/controllers/notification_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/core/services/notification/local_notification.dart';
import 'package:menahariya/data/models/notification/notification_model.dart';

class PassengerNotificationController extends GetxController {
  static PassengerNotificationController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;
  final LocalNotificationService _localNotification = LocalNotificationService.instance;

  // Observables
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _notifications = <NotificationModel>[].obs;
  final _unreadCount = 0.obs;
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;
  final _selectedFilter = NotificationFilter.all.obs;
  final _selectedNotification = Rxn<NotificationModel>();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount.value;
  bool get hasMorePages => _hasMorePages.value;
  NotificationFilter get selectedFilter => _selectedFilter.value;
  NotificationModel? get selectedNotification => _selectedNotification.value;

  // Filtered notifications
  List<NotificationModel> get filteredNotifications {
    switch (_selectedFilter.value) {
      case NotificationFilter.all:
        return _notifications;
      case NotificationFilter.unread:
        return _notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.bookings:
        return _notifications.where((n) => n.type == 'booking').toList();
      case NotificationFilter.payments:
        return _notifications.where((n) => n.type == 'payment').toList();
      case NotificationFilter.trips:
        return _notifications.where((n) => n.type == 'trip').toList();
      case NotificationFilter.cargo:
        return _notifications.where((n) => n.type == 'cargo').toList();
      case NotificationFilter.promotions:
        return _notifications.where((n) => n.type == 'promo').toList();
    }
  }

  @override
  void onInit() {
    super.onInit();
    _setupSocketListeners();
    fetchNotifications();
  }

  void _setupSocketListeners() {
    _socketService.onNotification(_handleNewNotification);
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

      // FIX: Convert filter to proper type string that matches backend
      String? typeParam;
      switch (_selectedFilter.value) {
        case NotificationFilter.all:
          typeParam = null;  // Don't send type for 'all'
          break;
        case NotificationFilter.unread:
          typeParam = null;  // Unread is handled separately via different endpoints
          break;
        case NotificationFilter.bookings:
          typeParam = 'booking';  // Backend expects 'booking' not 'bookings'
          break;
        case NotificationFilter.payments:
          typeParam = 'payment';  // Backend expects 'payment' not 'payments'
          break;
        case NotificationFilter.trips:
          typeParam = 'trip';  // Backend expects 'trip' not 'trips'
          break;
        case NotificationFilter.cargo:
          typeParam = 'cargo';
          break;
        case NotificationFilter.promotions:
          typeParam = 'promo';  // Backend expects 'promo' not 'promotions'
          break;
      }

      final queryParams = <String, dynamic>{
        'page': _currentPage.value,
        'limit': AppConstants.defaultPageSize,
      };

      if (typeParam != null) {
        queryParams['type'] = typeParam;
      }

      print('🔍 Fetching notifications with type: $typeParam'); // Debug log

      final response = await _apiClient.get(
        ApiEndpoints.notificationsAll,
        queryParameters: queryParams,
      );

      if (response != null && response['data'] != null) {
        List<NotificationModel> newNotifications = [];

        // Handle different response structures
        if (response['data'] is List) {
          newNotifications = (response['data'] as List)
              .map((n) => NotificationModel.fromJson(n))
              .toList();
        } else {
          newNotifications = [];
        }

        print('✅ Loaded ${newNotifications.length} notifications for type: $typeParam');

        if (_currentPage.value == 1) {
          _notifications.value = newNotifications;
        } else {
          _notifications.addAll(newNotifications);
        }

        // Update unread count only for 'all' filter
        if (response['meta'] != null && response['meta']['unreadCount'] != null) {
          _unreadCount.value = response['meta']['unreadCount'];
        } else {
          _updateUnreadCount();
        }

        _hasMorePages.value = newNotifications.length >= AppConstants.defaultPageSize;
        _currentPage.value++;
      }
    } catch (e) {
      print('❌ Error fetching notifications: $e');
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  void _handleNewNotification(dynamic data) {
    try {
      final notification = NotificationModel.fromJson(data);

      // Insert at beginning
      _notifications.insert(0, notification);

      if (!notification.isRead) {
        _unreadCount.value++;

        // Show local notification
        _localNotification.showNotification(
          id: int.parse(notification.id.substring(0, 8), radix: 16) % 10000,
          title: notification.title,
          body: notification.body,
          payload: notification.id,
        );
      }

      _notifications.refresh();
    } catch (e) {
      print('Error handling new notification: $e');
    }
  }

  void addNotification(NotificationModel notification) {
    if (!_notifications.any((n) => n.id == notification.id)) {
      _notifications.insert(0, notification);
      if (!notification.isRead) {
        _unreadCount.value++;
      }
      _notifications.refresh();
    }
  }

  void _updateUnreadCount() {
    _unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  void setFilter(NotificationFilter filter) {
    if (_selectedFilter.value == filter) return;
    _selectedFilter.value = filter;

    // For 'unread' filter, use a different endpoint
    if (filter == NotificationFilter.unread) {
      _fetchUnreadNotifications();
    } else {
      fetchNotifications(refresh: true);
    }
  }

// Add this new method for unread notifications
  Future<void> _fetchUnreadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _notifications.clear();
    }

    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        ApiEndpoints.notificationsUnread,  // Use the unread endpoint
        queryParameters: {
          'limit': AppConstants.defaultPageSize,
        },
      );

      if (response != null && response['data'] != null) {
        List<NotificationModel> newNotifications = [];

        if (response['data'] is List) {
          newNotifications = (response['data'] as List)
              .map((n) => NotificationModel.fromJson(n))
              .toList();
        }

        print('✅ Loaded ${newNotifications.length} unread notifications');

        _notifications.value = newNotifications;
        _updateUnreadCount();
      }
    } catch (e) {
      print('❌ Error fetching unread notifications: $e');
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    _isRefreshing.value = true;
    await fetchNotifications(refresh: true);
    _isRefreshing.value = false;
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

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch(ApiEndpoints.notificationsMarkAllRead);

      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      _notifications.refresh();
      _unreadCount.value = 0;

      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
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

      Get.snackbar(
        'Success',
        'Notification deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Clear All'),
          content: const Text('Are you sure you want to delete all notifications?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _apiClient.delete(ApiEndpoints.notificationsAll);
        _notifications.clear();
        _unreadCount.value = 0;

        Get.snackbar(
          'Success',
          'All notifications deleted',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }

  Future<void> fetchNotificationDetails(String notificationId) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '${ApiEndpoints.notifications}/$notificationId',
      );

      if (response != null && response['data'] != null) {
        _selectedNotification.value = NotificationModel.fromJson(response['data']);

        // Mark as read when viewing
        if (!_selectedNotification.value!.isRead) {
          await markAsRead(notificationId);
        }
      }
    } catch (e) {
      print('Error fetching notification details: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void clearSelectedNotification() {
    _selectedNotification.value = null;
  }

  void handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case 'booking':
      case 'ticket':
        Get.toNamed(
          '/passenger/ticket/${notification.data?['ticketId']}',
          arguments: {'ticketId': notification.data?['ticketId']},
        );
        break;
      case 'payment':
        Get.toNamed(
          '/passenger/payment/${notification.data?['paymentId']}',
        );
        break;
      case 'trip':
        Get.toNamed(
          '/passenger/trip/${notification.data?['tripId']}',
        );
        break;
      case 'cargo':
        Get.toNamed(
          '/passenger/cargo/track',
          arguments: {'trackingCode': notification.data?['trackingCode']},
        );
        break;
      default:
      // Just open notification details
        Get.toNamed(
          '/passenger/notification/${notification.id}',
          arguments: {'notification': notification},
        );
    }
  }

  @override
  void onClose() {
    _socketService.off('notification', _handleNewNotification);
    super.onClose();
  }
}

enum NotificationFilter {
  all,
  unread,
  bookings,
  payments,
  trips,
  cargo,
  promotions,
}

extension NotificationFilterExtension on NotificationFilter {
  String get displayName {
    switch (this) {
      case NotificationFilter.all:
        return 'All';
      case NotificationFilter.unread:
        return 'Unread';
      case NotificationFilter.bookings:
        return 'Bookings';
      case NotificationFilter.payments:
        return 'Payments';
      case NotificationFilter.trips:
        return 'Trips';
      case NotificationFilter.cargo:
        return 'Cargo';
      case NotificationFilter.promotions:
        return 'Promotions';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationFilter.all:
        return Icons.notifications_rounded;
      case NotificationFilter.unread:
        return Icons.mark_email_unread_rounded;
      case NotificationFilter.bookings:
        return Icons.confirmation_number_rounded;
      case NotificationFilter.payments:
        return Icons.payments_rounded;
      case NotificationFilter.trips:
        return Icons.directions_bus_rounded;
      case NotificationFilter.cargo:
        return Icons.inventory_2_rounded;
      case NotificationFilter.promotions:
        return Icons.local_offer_rounded;
    }
  }
}