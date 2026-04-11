// lib/modules/passenger/views/notifications/notifications_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/cards/notification_card.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/passenger/controllers/notification_controller.dart';

class PassengerNotificationsView extends GetView<PassengerNotificationController> {
  const PassengerNotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ FIX: Use a Builder to get a fresh context under the Scaffold
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
              }
            },
            itemBuilder: (context) => [
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
        // ✅ FIX: Create TabController properly with a Builder
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Builder(
            builder: (tabContext) {
              return TabBar(
                controller: TabController(
                  length: NotificationFilter.values.length,
                  vsync: Scaffold.of(tabContext), // ✅ Now safe!
                ),
                tabs: NotificationFilter.values.map((filter) {
                  return Tab(text: filter.displayName);
                }).toList(),
                isScrollable: true,
                labelColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                indicatorColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                onTap: (index) {
                  controller.setFilter(NotificationFilter.values[index]);
                },
              );
            },
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading && controller.notifications.isEmpty) {
          return _buildLoadingShimmer();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          child: Column(
            children: [
              // Notifications List
              Expanded(
                child: controller.filteredNotifications.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  itemCount: controller.filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = controller.filteredNotifications[index];
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

              // Load More
              if (controller.hasMorePages && controller.filteredNotifications.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: controller.loadMore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      ),
                      child: const Text('Load More'),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
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
          Icon(
            Icons.notifications_off_rounded,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            'No Notifications',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            'You\'re all caught up!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
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
        content: const Text('Are you sure you want to delete all notifications? '),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAllNotifications();
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
}