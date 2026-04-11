// lib/modules/passenger/views/support/privacy_security_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/modules/passenger/controllers/profile_controller.dart';

class PrivacySecurityView extends GetView<PassengerProfileController> {
  const PrivacySecurityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.padding16),
        children: [
          // Account Security Section
          _buildSection(
            context,
            title: 'Account Security',
            icon: Icons.security_rounded,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.lock_rounded,
                title: 'Change Password',
                subtitle: 'Update your password regularly',
                onTap: () => _showChangePasswordDialog(context),
                showArrow: true,
              ),
              _buildMenuItem(
                context,
                icon: Icons.fingerprint_rounded,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face ID',
                onTap: () {},
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                  activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.smartphone_rounded,
                title: 'Two-Factor Authentication',
                subtitle: 'Add an extra layer of security',
                onTap: () {},
                showArrow: true,
              ),
            ],
          ),

          const SizedBox(height: AppDimens.margin16),

          // Privacy Settings Section
          _buildSection(
            context,
            title: 'Privacy Settings',
            icon: Icons.privacy_tip_rounded,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.visibility_off_rounded,
                title: 'Profile Visibility',
                subtitle: 'Control who can see your profile',
                onTap: () {},
                showArrow: true,
              ),
              _buildMenuItem(
                context,
                icon: Icons.location_on_rounded,
                title: 'Location Privacy',
                subtitle: 'Manage location sharing preferences',
                onTap: () {},
                showArrow: true,
              ),
              _buildMenuItem(
                context,
                icon: Icons.notifications_rounded,
                title: 'Notification Preferences',
                subtitle: 'Customize what you receive',
                onTap: () => Get.toNamed('/settings/notifications'),
                showArrow: true,
              ),
            ],
          ),

          const SizedBox(height: AppDimens.margin16),

          // Data Management Section
          _buildSection(
            context,
            title: 'Data Management',
            icon: Icons.data_usage_rounded,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.file_download_rounded,
                title: 'Download My Data',
                subtitle: 'Get a copy of your data',
                onTap: () => _showDownloadDataDialog(context),
                showArrow: true,
              ),
              _buildMenuItem(
                context,
                icon: Icons.delete_sweep_rounded,
                title: 'Clear History',
                subtitle: 'Remove search and browsing history',
                onTap: () => _showClearHistoryDialog(context),
                showArrow: true,
              ),
              _buildMenuItem(
                context,
                icon: Icons.delete_forever_rounded,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                onTap: () => _showDeleteAccountDialog(context),
                showArrow: true,
                isDanger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppDimens.padding8, bottom: AppDimens.padding8),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: AppDimens.margin8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        Widget? trailing,
        bool showArrow = false,
        bool isDanger = false,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding16,
          vertical: AppDimens.padding12,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isDanger ? Colors.red : (isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
              child: Icon(
                icon,
                color: isDanger
                    ? (isDark ? AppColors.errorLight : AppColors.error)
                    : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimens.margin12),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDanger
                          ? (isDark ? AppColors.errorLight : AppColors.error)
                          : null,
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                  const SizedBox(height: AppDimens.margin4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing widget
            if (trailing != null)
              SizedBox(
                width: 50,
                child: trailing,
              )
            else if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppDimens.margin12),
              TextField(
                controller: controller.newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppDimens.margin12),
              TextField(
                controller: controller.confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.changePassword();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showDownloadDataDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Download Your Data'),
        content: const Text(
          'You can download a copy of your personal data including profile information, booking history, and trip details. This may take a few minutes to prepare.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Request Sent',
                'We\'ll email you when your data is ready',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'This will permanently delete your search history and browsing data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'History Cleared',
                'Your search history has been cleared',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear History'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to delete your account? This action is permanent and cannot be undone.',
            ),
            const SizedBox(height: AppDimens.margin16),
            TextField(
              controller: TextEditingController(),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter your password to confirm',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Implement delete account logic
              Get.snackbar(
                'Account Deleted',
                'Your account has been deactivated',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}