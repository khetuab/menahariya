// lib/modules/passenger/controllers/notification_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/core/services/notification/local_notification.dart';
import 'package:menahariya/data/models/notification/notification_model.dart';

import '../../../core/routes/app_routes.dart';
import '../views/cargo/cargo_tracking_view.dart';

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
// In passenger/controllers/notification_controller.dart

  void handleNotificationTap(NotificationModel notification) {
    print('👆 Notification tapped: ${notification.title}');
    print('📋 Type: ${notification.type}');
    print('📋 Data: ${notification.data}');

    // Mark as read
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
    // ============ BOOKING & TICKET ============
      case 'booking':
      case 'ticket':
        final ticketId = notification.data?['ticketId'] ?? notification.data?['id'];
        if (ticketId != null) {
          Get.toNamed('/passenger/my-tickets');
          _showTicketInfoDialog(notification, ticketId);
        } else {
          _showNotificationDialog(notification);
        }
        break;

    // ============ PAYMENT ============
      case 'payment':
        final paymentId = notification.data?['paymentId'] ?? notification.data?['id'];
        if (paymentId != null) {
          _showPaymentSuccessDialog(notification);
        } else {
          _showNotificationDialog(notification);
        }
        break;

    // ============ TRIP ============
      case 'trip':
        final tripId = notification.data?['tripId'] ?? notification.data?['id'];
        if (tripId != null) {
          _showTripInfoDialog(notification, tripId);
        } else {
          _showNotificationDialog(notification);
        }
        break;

    // ============ CARGO ============
      case 'cargo':
        final trackingCode = notification.data?['trackingCode'] ??
            notification.data?['code'] ??
            notification.data?['cargoId'];
        if (trackingCode != null) {
          _showCargoStatusDialog(notification, trackingCode);
        } else {
          _showNotificationDialog(notification);
        }
        break;

    // ============ SUPPORT ============
      case 'support':
        final ticketId = notification.data?['ticketId'] ?? notification.data?['id'];
        if (ticketId != null) {
          Get.toNamed('/passenger/support/tickets');
          _showSupportReplyDialog(notification, ticketId);
        } else {
          _showNotificationDialog(notification);
        }
        break;

    // ============ PROMOTIONS ============
      case 'promo':
      case 'promotion':
      case 'offer':
        _showPromotionDialog(notification);
        break;

    // ============ SYSTEM ALERTS ============
      case 'system':
      case 'system_alert':
      case 'alert':
        _showSystemAlertDialog(notification);
        break;

    // ============ REMINDERS ============
      case 'reminder':
        _showReminderDialog(notification);
        break;

    // ============ UPDATE ============
      case 'update':
      case 'app_update':
        _showUpdateDialog(notification);
        break;

    // ============ SECURITY ============
      case 'security':
        _showSecurityAlertDialog(notification);
        break;

    // ============ DEFAULT ============
      default:
        _showNotificationDialog(notification);
    }
  }

// ============ DIALOG METHODS ============

  void _showNotificationDialog(NotificationModel notification) {
    Get.dialog(
      AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            if (notification.data != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Additional info: ${notification.data}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTicketInfoDialog(NotificationModel notification, String ticketId) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.confirmation_number_rounded, color: Colors.blue),
            const SizedBox(width: 8),
            Text(notification.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code, size: 40, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ticket ID',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          ticketId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/passenger/ticket/$ticketId');
            },
            child: const Text('View Ticket'),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialog(NotificationModel notification) {
    final amount = notification.data?['amount'] ?? '';
    final method = notification.data?['method'] ?? '';

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (amount.isNotEmpty) ...[
                    const Text('Amount Paid', style: TextStyle(color: Colors.grey)),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                  if (method.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('via $method', style: const TextStyle(color: Colors.grey)),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/passenger/my-tickets');
            },
            child: const Text('View Tickets'),
          ),
        ],
      ),
    );
  }

  void _showTripInfoDialog(NotificationModel notification, String tripId) {
    final origin = notification.data?['origin'] ?? '';
    final destination = notification.data?['destination'] ?? '';
    final date = notification.data?['date'] ?? notification.data?['departureTime'] ?? '';

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.directions_bus_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            Text(notification.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('From', style: TextStyle(color: Colors.grey)),
                            Text(origin, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.orange),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('To', style: TextStyle(color: Colors.grey)),
                            Text(destination, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (date.isNotEmpty) ...[
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(date),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/passenger/trip/$tripId');
            },
            child: const Text('View Trip'),
          ),
        ],
      ),
    );
  }

  void _showCargoStatusDialog(NotificationModel notification, String trackingCode) {
    final status = notification.data?['status'] ?? '';
    final location = notification.data?['location'] ?? '';

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.local_shipping_rounded, color: Colors.purple),
            const SizedBox(width: 8),
            Text(notification.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                children: [
                  // Tracking Code Row with Copy Button
                  Row(
                    children: [
                      const Icon(Icons.qr_code, size: 24, color: Colors.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tracking Code', style: TextStyle(color: Colors.grey)),
                            Text(
                              trackingCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Copy Button
                      InkWell(
                        onTap: () {
                          _copyToClipboard(trackingCode, 'Tracking code copied');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (status.isNotEmpty) ...[
                    const Divider(),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            status,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(location)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.to(() => const CargoTrackingView(), arguments: {'code': trackingCode});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('Track Cargo'),
          ),
        ],
      ),
    );
  }

// Add this helper method at the end of your controller
  void _copyToClipboard(String text, String successMessage) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied!',
      successMessage,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }
  void _showSupportReplyDialog(NotificationModel notification, String ticketId) {
    final reply = notification.data?['reply'] ?? notification.data?['message'] ?? '';

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.headset_mic_outlined, color: Colors.teal),
            const SizedBox(width: 8),
            const Text('Support Reply'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            if (reply.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Response:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(reply),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          // TextButton(
          //   onPressed: () => Get.back(),
          //   child: const Text('Close'),
          // ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              //Get.toNamed('/passenger/support/ticket/$ticketId');
            },
            child: const Text('View Ticket'),
          ),
        ],
      ),
    );
  }

  void _showPromotionDialog(NotificationModel notification) {
    final promoCode = notification.data?['code'] ?? notification.data?['promoCode'] ?? '';
    final discount = notification.data?['discount'] ?? '';
    final expiry = notification.data?['expiry'] ?? notification.data?['validUntil'] ?? '';

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.local_offer_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(notification.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (discount.isNotEmpty) ...[
                    Text(
                      discount,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (promoCode.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        promoCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                  if (expiry.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Valid until: $expiry',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (promoCode.isNotEmpty) {
                Get.toNamed('/passenger/home', arguments: {'promoCode': promoCode});
              } else {
                Get.toNamed('/passenger/home');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Apply Now'),
          ),
        ],
      ),
    );
  }

  void _showSystemAlertDialog(NotificationModel notification) {
    final priority = notification.data?['priority'] ?? 'normal';
    final actionUrl = notification.data?['action_url'] ?? '';

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              priority == 'high' ? Icons.warning_rounded : Icons.info_rounded,
              color: priority == 'high' ? Colors.red : Colors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(notification.title)),
          ],
        ),
        content: Text(notification.body),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Dismiss'),
          ),
          if (actionUrl.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Handle action URL if needed
              },
              child: const Text('Learn More'),
            ),
        ],
      ),
    );
  }

  void _showReminderDialog(NotificationModel notification) {
    final reminderTime = notification.data?['time'] ?? '';
    final item = notification.data?['item'] ?? '';

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.alarm_rounded, color: Colors.amber),
            const SizedBox(width: 8),
            Text(notification.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(notification.body),
            if (reminderTime.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Time: $reminderTime',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Dismiss'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (item.isNotEmpty) {
                // Navigate to relevant page based on item type
              }
            },
            child: const Text('Remind Me Later'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(NotificationModel notification) {
    final version = notification.data?['version'] ?? '';
    final isRequired = notification.data?['required'] ?? false;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.system_update_rounded, color: Colors.blue),
            const SizedBox(width: 8),
            Text(notification.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            if (version.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Version $version available',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
          ],
        ),
        actions: [
          if (!isRequired)
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Later'),
            ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Open app store link
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  void _showSecurityAlertDialog(NotificationModel notification) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(notification.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'For your security, please review your recent account activity.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Ignore'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/passenger/privacy-security');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Review Security'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'transit':
      case 'in_transit':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.purple;
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