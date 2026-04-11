// lib/modules/admin/controllers/admin_notification_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/notification/notification_model.dart';

class AdminNotificationController extends GetxController {
  static AdminNotificationController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Observables
  final _isLoading = false.obs;
  final _isSending = false.obs;
  final _notifications = <NotificationModel>[].obs;
  final _selectedNotification = Rxn<NotificationModel>();
  final _searchQuery = ''.obs;
  final _typeFilter = ''.obs;

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;
  final _totalCount = 0.obs;

  // Form controllers for sending notifications
  late final TextEditingController titleController;
  late final TextEditingController bodyController;
  late final TextEditingController targetUsersController;

  // Selection
  final _selectedType = 'system'.obs;
  final _selectedPriority = 'normal'.obs;
  final _selectedTarget = 'all'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSending => _isSending.value;
  List<NotificationModel> get notifications => _notifications;
  NotificationModel? get selectedNotification => _selectedNotification.value;
  String get searchQuery => _searchQuery.value;
  String get typeFilter => _typeFilter.value;
  bool get hasMorePages => _hasMorePages.value;
  int get totalCount => _totalCount.value;
  String get selectedType => _selectedType.value;
  String get selectedPriority => _selectedPriority.value;
  String get selectedTarget => _selectedTarget.value;

  // Available options
  final List<String> notificationTypes = [
    'system',
    'booking',
    'payment',
    'trip',
    'cargo',
    'promo',
  ];

  final List<String> priorities = ['high', 'normal', 'low'];
  final List<String> targets = ['all', 'passengers', 'drivers', 'staff', 'specific'];

  // Statistics
  int get totalNotifications => _notifications.length;
  int get unreadNotifications => _notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchNotifications();
  }

  void _initializeControllers() {
    titleController = TextEditingController();
    bodyController = TextEditingController();
    targetUsersController = TextEditingController();
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

      final params = <String, dynamic>{
        'page': _currentPage.value,
        'limit': AppConstants.defaultPageSize,
      };

      if (_searchQuery.value.isNotEmpty) params['search'] = _searchQuery.value;
      if (_typeFilter.value.isNotEmpty && _typeFilter.value != 'all') {
        params['type'] = _typeFilter.value;
      }

      // ✅ Use admin endpoint
      final response = await _apiClient.get(
        ApiEndpoints.adminNotificationsAll,
        queryParameters: params,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> notificationsData = response['data'];
        final newNotifications = notificationsData
            .map((n) => NotificationModel.fromJson(n))
            .toList();

        if (_currentPage.value == 1) {
          _notifications.value = newNotifications;
        } else {
          _notifications.addAll(newNotifications);
        }

        _totalCount.value = response['total'] ?? _notifications.length;
        _hasMorePages.value = newNotifications.length >= AppConstants.defaultPageSize;
        _currentPage.value++;
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      AppSnackbar.show('Error', 'Failed to load notifications');
    } finally {
      _isLoading.value = false;
      //_isRefreshing.value = false;
    }
  }

  Future<bool> sendNotification() async {
    if (titleController.text.isEmpty || bodyController.text.isEmpty) {
      AppSnackbar.show('Error', 'Please enter title and message');
      return false;
    }

    try {
      _isSending.value = true;

      final notificationData = {
        'title': titleController.text.trim(),
        'body': bodyController.text.trim(),
        'type': _selectedType.value,
        'priority': _selectedPriority.value,
        'target': _selectedTarget.value,
      };

      if (_selectedTarget.value == 'specific' && targetUsersController.text.isNotEmpty) {
        notificationData['userIds'] = targetUsersController.text;
      }

      // ✅ Use admin endpoint
      final response = await _apiClient.post(
        ApiEndpoints.adminNotificationsSend,
        data: notificationData,
      );

      if (response != null && response['success'] == true) {
        clearForm();
        await fetchNotifications(refresh: true);
        Get.back(); // Close the bottom sheet
        AppSnackbar.show('Success', response['message'] ?? 'Notification sent successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending notification: $e');
      AppSnackbar.show('Error', 'Failed to send notification');
      return false;
    } finally {
      _isSending.value = false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Notification'),
          content: const Text('Are you sure you want to delete this notification?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm != true) return false;

      _isLoading.value = true;

      // ✅ Use admin endpoint
      final response = await _apiClient.delete(
        '${ApiEndpoints.adminNotificationsDelete}/$notificationId',
      );

      if (response != null && response['success'] == true) {
        _notifications.removeWhere((n) => n.id == notificationId);
        AppSnackbar.show('Success', 'Notification deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting notification: $e');
      AppSnackbar.show('Error', 'Failed to delete notification');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    bodyController.clear();
    targetUsersController.clear();
    _selectedType.value = 'system';
    _selectedPriority.value = 'normal';
    _selectedTarget.value = 'all';
  }

  void setType(String type) {
    _selectedType.value = type;
  }

  void setPriority(String priority) {
    _selectedPriority.value = priority;
  }

  void setTarget(String target) {
    _selectedTarget.value = target;
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    fetchNotifications(refresh: true);
  }

  void setTypeFilter(String type) {
    _typeFilter.value = type;
    fetchNotifications(refresh: true);
  }

  void clearFilters() {
    _searchQuery.value = '';
    _typeFilter.value = '';
    fetchNotifications(refresh: true);
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications(refresh: true);
  }

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    targetUsersController.dispose();
    super.onClose();
  }
}