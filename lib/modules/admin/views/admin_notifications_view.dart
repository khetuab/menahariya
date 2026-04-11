// lib/modules/admin/views/admin_notifications_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_dialogs.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_empty_state.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_sidebar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/inputs/custom_textfield.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/admin_notification_controller.dart';

class AdminNotificationsView extends GetView<AdminNotificationController> {
  const AdminNotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AdminDrawer(currentIndex: 9),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showSendNotificationSheet(context),
            tooltip: 'Send Notification',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshNotifications,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty && !controller.isLoading) {
          return AdminEmptyState(
            title: 'No Notifications',
            message: 'No notifications have been sent yet',
            icon: Icons.notifications_off_rounded,
            onAction: () => _showSendNotificationSheet(context),
            actionText: 'Send First Notification',
          );
        }

        return Column(
          children: [
            // Filter Bar
            _buildFilterBar(context),
            // Notifications List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshNotifications,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  itemCount: controller.notifications.length + (controller.hasMorePages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.notifications.length && controller.hasMorePages) {
                      return _buildLoadMoreIndicator();
                    }
                    if (index >= controller.notifications.length) {
                      return const SizedBox();
                    }
                    final notification = controller.notifications[index];
                    return _buildNotificationCard(context, notification);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search notifications...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding12,
                  vertical: AppDimens.padding10,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.margin8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : AppColors.grey100,
              borderRadius: BorderRadius.circular(AppDimens.radius8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.typeFilter.isEmpty ? null : controller.typeFilter,
                hint: const Text('Type'),
                items: [
                  const DropdownMenuItem(value: '', child: Text('All')),
                  ...controller.notificationTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeDisplayName(type)),
                    );
                  }).toList(), // ✅ Add .toList() here
                ],
                onChanged: (value) => controller.setTypeFilter(value ?? ''),
                icon: Icon(Icons.arrow_drop_down_rounded,
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, dynamic notification) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.margin12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: () => _showNotificationDetails(notification),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: _getTypeColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimens.margin12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: AppFonts.medium,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (notification.priority != null && notification.priority!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.padding8,
                              vertical: AppDimens.padding4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(notification.priority!).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimens.radius12),
                            ),
                            child: Text(
                              notification.priority!.toUpperCase(),
                              style: TextStyle(
                                color: _getPriorityColor(notification.priority!),
                                fontSize: 10,
                                fontWeight: AppFonts.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.margin4),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimens.margin4),
                    // Recipient info
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 12,
                          color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            notification.isBroadcast
                                ? 'Sent to: All Users'
                                : 'To: ${notification.userFullName ?? notification.userDisplayName}${notification.userRole != null ? ' (${notification.userRole})' : ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.margin2),
                    Text(
                      _formatDateTime(notification.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                onPressed: () => _showDeleteDialog(notification.id),
                tooltip: 'Delete',
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(AppDimens.padding16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  void _showSendNotificationSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Reset form
    controller.clearForm();

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Send Notification',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey800 : AppColors.grey100,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title
                const Text('Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.titleController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter notification title',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.title_rounded, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                  ),
                ),
                const SizedBox(height: 16),

                // Message
                const Text('Message', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.bodyController,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter notification message',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.message_rounded, size: 18),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                  ),
                ),
                const SizedBox(height: 16),

                // Type
                const Text('Notification Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: controller.selectedType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                  ),
                  items: controller.notificationTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (value) => controller.setType(value ?? 'system'),
                ),
                const SizedBox(height: 16),

                // Priority
                const Text('Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: controller.selectedPriority,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                  ),
                  items: controller.priorities.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(priority.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => controller.setPriority(value ?? 'normal'),
                ),
                const SizedBox(height: 16),

                // Target Audience
                const Text('Target Audience', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: controller.selectedTarget,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                  ),
                  items: controller.targets.map((target) {
                    return DropdownMenuItem(
                      value: target,
                      child: Text(_getTargetDisplayName(target)),
                    );
                  }).toList(),
                  onChanged: (value) => controller.setTarget(value ?? 'all'),
                ),

                // Specific Users (conditional)
                Obx(() {
                  if (controller.selectedTarget == 'specific') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text('User IDs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller.targetUsersController,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Enter user IDs separated by commas',
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.people_rounded, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            filled: true,
                            fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                }),

                const SizedBox(height: 24),

                // Send Button
                Obx(() => PrimaryButton(
                  text: 'Send Notification',
                  onPressed: controller.sendNotification,
                  isLoading: controller.isSending,
                  icon: Icons.send_rounded,
                )),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetails(dynamic notification) {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notification Details',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin24),
                // Type and Priority
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.padding12,
                        vertical: AppDimens.padding6,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(notification.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimens.radius20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(notification.type),
                            color: _getTypeColor(notification.type),
                            size: 16,
                          ),
                          const SizedBox(width: AppDimens.margin4),
                          Text(
                            _getTypeDisplayName(notification.type),
                            style: TextStyle(
                              color: _getTypeColor(notification.type),
                              fontSize: 12,
                              fontWeight: AppFonts.medium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    if (notification.priority != null && notification.priority!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.padding12,
                          vertical: AppDimens.padding6,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(notification.priority!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimens.radius20),
                        ),
                        child: Text(
                          notification.priority!.toUpperCase(),
                          style: TextStyle(
                            color: _getPriorityColor(notification.priority!),
                            fontSize: 12,
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Title
                Text(
                  notification.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: AppFonts.bold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin8),
                // Recipient
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 14,
                      color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.isBroadcast
                            ? 'Sent to: All Users'
                            : 'To: ${notification.userFullName ?? notification.userDisplayName}${notification.userRole != null ? ' (${notification.userRole})' : ''}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin8),
                // Date
                Text(
                  _formatDateTime(notification.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                  ),
                ),
                const SizedBox(height: AppDimens.margin16),
                const Divider(),
                const SizedBox(height: AppDimens.margin16),
                // Body
                Text(
                  notification.body,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppDimens.margin24),
                // Delete Button
                SecondaryButton(
                  text: 'Delete Notification',
                  onPressed: () {
                    Get.back();
                    _showDeleteDialog(notification.id);
                  },
                  icon: Icons.delete_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(String notificationId) async {
    final confirmed = await AdminConfirmationDialog.show(
      title: 'Delete Notification',
      message: 'Are you sure you want to delete this notification?',
      confirmText: 'Delete',
    );

    if (confirmed) {
      await controller.deleteNotification(notificationId);
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'system': return 'System';
      case 'booking': return 'Booking';
      case 'payment': return 'Payment';
      case 'trip': return 'Trip';
      case 'cargo': return 'Cargo';
      case 'promo': return 'Promotion';
      default: return type;
    }
  }

  String _getTargetDisplayName(String target) {
    switch (target) {
      case 'all': return 'All Users';
      case 'passengers': return 'Passengers Only';
      case 'drivers': return 'Drivers Only';
      case 'staff': return 'Staff Only';
      case 'specific': return 'Specific Users';
      default: return target;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'system': return Icons.computer_rounded;
      case 'booking': return Icons.confirmation_number_rounded;
      case 'payment': return Icons.payments_rounded;
      case 'trip': return Icons.directions_bus_rounded;
      case 'cargo': return Icons.inventory_2_rounded;
      case 'promo': return Icons.local_offer_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'system': return Colors.blue;
      case 'booking': return Colors.green;
      case 'payment': return Colors.orange;
      case 'trip': return Colors.purple;
      case 'cargo': return Colors.teal;
      case 'promo': return Colors.pink;
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high': return Colors.red;
      case 'normal': return Colors.blue;
      case 'low': return Colors.grey;
      default: return Colors.blue;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
}