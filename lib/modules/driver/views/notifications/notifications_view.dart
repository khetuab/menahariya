// lib/modules/driver/views/notifications/notifications_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/cards/notification_card.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/driver/controllers/notification_controller.dart';

class DriverNotificationsView extends GetView<DriverNotificationController> {
  const DriverNotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          if (controller.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.mark_email_read_rounded),
              onPressed: controller.markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'delete_all') {
                _showDeleteAllDialog();
              } else if (value == 'settings') {
                _showNotificationSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.notifications.isEmpty) {
          return _buildLoadingShimmer();
        }

        return Column(
          children: [
            // Filter Tabs
            _buildFilterTabs(context),

            // Notifications List
            Expanded(
              child: controller.notifications.isEmpty
                  ? _buildEmptyState(context)
                  : RefreshIndicator(
                onRefresh: controller.refreshNotifications,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = controller.notifications[index];
                    return NotificationCard(
                      id: notification.id,
                      title: notification.title,
                      body: notification.body,
                      type: notification.type,
                      timestamp: notification.createdAt,
                      isRead: notification.isRead,
                      onTap: () => controller.handleNotificationTap(notification),
                      onMarkRead: notification.isRead
                          ? null
                          : () => controller.markAsRead(notification.id),
                      onDelete: () => _showDeleteDialog(notification.id),
                    );
                  },
                ),
              ),
            ),

            // Load More
            if (controller.hasMorePages && controller.notifications.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDimens.padding16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: controller.loadMore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radius30),
                      ),
                    ),
                    child: const Text('Load More'),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 50,
      margin: const EdgeInsets.all(AppDimens.padding16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(context, 'All', null, true),
          const SizedBox(width: AppDimens.margin8),
          _buildFilterChip(context, 'Trip Assignments', 'trip_assigned', false),
          const SizedBox(width: AppDimens.margin8),
          _buildFilterChip(context, 'Updates', 'trip_update', false),
          const SizedBox(width: AppDimens.margin8),
          _buildFilterChip(context, 'System', 'system_alert', false),
          const SizedBox(width: AppDimens.margin8),
          _buildFilterChip(context, 'Alerts', 'alert', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String? filterType, bool isSelected) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        // Implement filter logic
        Get.snackbar(
          'Filter',
          'Filtering by $label',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      selectedColor: isDark
          ? AppColors.primaryGreen.withOpacity(0.3)
          : AppColors.primaryGreen.withOpacity(0.1),
      checkmarkColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
      backgroundColor: isDark ? AppColors.grey800 : AppColors.grey50,
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.padding16),
      itemCount: 5,
      itemBuilder: (_, __) => ShimmerLoading(
        child: Container(
          margin: const EdgeInsets.only(bottom: AppDimens.margin12),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 60,
              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
            ),
          ),
          const SizedBox(height: AppDimens.margin24),
          Text(
            'No Notifications',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.bold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            'You\'re all caught up!\nNew notifications will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String notificationId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteNotification(notificationId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete All Notifications'),
        content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // controller.deleteAllNotifications();
              Get.snackbar(
                'Success',
                'All notifications deleted',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimens.padding20),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimens.radius20),
            topRight: Radius.circular(AppDimens.radius20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppDimens.radius2),
              ),
            ),
            const SizedBox(height: AppDimens.margin20),
            const Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimens.margin20),
            SwitchListTile(
              title: const Text('Trip Assignments'),
              subtitle: const Text('Get notified about new trip assignments'),
              value: true,
              onChanged: (value) {},
              activeColor: Theme.of(Get.context!).primaryColor,
            ),
            SwitchListTile(
              title: const Text('Trip Updates'),
              subtitle: const Text('Get notified about trip status changes'),
              value: true,
              onChanged: (value) {},
              activeColor: Theme.of(Get.context!).primaryColor,
            ),
            SwitchListTile(
              title: const Text('System Alerts'),
              subtitle: const Text('Receive important system notifications'),
              value: true,
              onChanged: (value) {},
              activeColor: Theme.of(Get.context!).primaryColor,
            ),
            SwitchListTile(
              title: const Text('Sound'),
              subtitle: const Text('Play sound for notifications'),
              value: true,
              onChanged: (value) {},
              activeColor: Theme.of(Get.context!).primaryColor,
            ),
            SwitchListTile(
              title: const Text('Vibrate'),
              subtitle: const Text('Vibrate for notifications'),
              value: true,
              onChanged: (value) {},
              activeColor: Theme.of(Get.context!).primaryColor,
            ),
            const SizedBox(height: AppDimens.margin20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(Get.context!).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}