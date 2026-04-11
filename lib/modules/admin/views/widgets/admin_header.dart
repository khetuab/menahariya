// lib/modules/admin/widgets/admin_header.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_fonts.dart';

class AdminHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final List<Widget>? actions;

  const AdminHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.onNotificationTap,
    this.onProfileTap,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding24,
        vertical: AppDimens.padding16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: AppFonts.bold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar (optional)
          Container(
            width: 300,
            margin: const EdgeInsets.only(right: AppDimens.margin16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radius30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding16,
                  vertical: AppDimens.padding12,
                ),
              ),
            ),
          ),

          // Action Buttons
          if (actions != null) ...actions!,

          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: onNotificationTap,
            tooltip: 'Notifications',
          ),

          // Profile Icon
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: onProfileTap,
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }
}