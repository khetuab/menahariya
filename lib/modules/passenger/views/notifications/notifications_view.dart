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
                controller.deleteAllNotifications();
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
        bottom: TabBar(
          controller: TabController(
            length: NotificationFilter.values.length,
            vsync: Scaffold.of(context),
          ),
          tabs: NotificationFilter.values.map((filter) {
            return Tab(text: filter.displayName);
          }).toList(),
          isScrollable: true,
          labelColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          indicatorColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
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
              // Filter Chips (Alternative to tabs)
              // _buildFilterChips(context),

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
                      onDelete: () => controller.deleteNotification(notification.id),
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

  Widget _buildFilterChips(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: NotificationFilter.values.map((filter) {
          return Obx(() => Padding(
            padding: const EdgeInsets.only(right: AppDimens.padding8),
            child: FilterChip(
              label: Text(filter.displayName),
              selected: controller.selectedFilter == filter,
              onSelected: (_) => controller.setFilter(filter),
              selectedColor: isDark
                  ? AppColors.primaryGreen.withOpacity(0.3)
                  : AppColors.primaryGreen.withOpacity(0.1),
              checkmarkColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
          ));
        }).toList(),
      ),
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
}