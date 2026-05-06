// lib/modules/passenger/views/support/privacy_security_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/modules/passenger/controllers/profile_controller.dart';

import '../../../../core/routes/app_routes.dart';

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
                onTap: () => Get.toNamed(AppRoutes.changePassword),
                showArrow: true,
              ),
              _buildMenuItem(
                context,
                icon: Icons.fingerprint_rounded,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face ID',
                onTap: () {},
                trailing: Obx(() => Switch(
                  value: controller.isBiometricEnabled,
                  onChanged: controller.toggleBiometricLogin,
                  activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                )),
              ),
              _buildMenuItem(
                context,
                icon: Icons.smartphone_rounded,
                title: 'Two-Factor Authentication',
                subtitle: controller.is2FAEnabled ? 'Enabled' : 'Add an extra layer of security',
                onTap: controller.is2FAEnabled
                    ? () => _show2FADialog(context)
                    : () => controller.setupTwoFactorAuth(),
                trailing: Obx(() => Switch(
                  value: controller.is2FAEnabled,
                  onChanged: (_) => controller.is2FAEnabled
                      ? controller.disableTwoFactorAuth()
                      : controller.setupTwoFactorAuth(),
                  activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                )),
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
                subtitle: _getVisibilityText(controller.profileVisibility),
                onTap: () {},
                showArrow: true,
              ),
              _buildMenuItem(
                context,
                icon: Icons.location_on_rounded,
                title: 'Location Privacy',
                subtitle: controller.locationSharingEnabled
                    ? '${controller.locationAccuracy == 'precise' ? 'Precise' : 'Approximate'} location sharing'
                    : 'Location sharing disabled',
                onTap: () {},
                showArrow: true,
              ),
              _buildMenuItem(
                context,
                icon: Icons.notifications_rounded,
                title: 'Notification Preferences',
                subtitle: 'Customize what you receive',
                onTap: () {},
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

  String _getVisibilityText(String visibility) {
    switch (visibility) {
      case 'public':
        return 'Anyone can see your profile';
      case 'private':
        return 'Only you can see your profile';
      case 'contacts_only':
        return 'Only your contacts can see your profile';
      default:
        return 'Public';
    }
  }

  void _showVisibilityDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        title: const Text('Profile Visibility'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Public'),
              subtitle: const Text('Anyone can see your profile'),
              value: 'public',
              groupValue: controller.profileVisibility,
              onChanged: (value) {
                controller.updateProfileVisibility(value!);
                Get.back();
              },
              activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            RadioListTile(
              title: const Text('Private'),
              subtitle: const Text('Only you can see your profile'),
              value: 'private',
              groupValue: controller.profileVisibility,
              onChanged: (value) {
                controller.updateProfileVisibility(value!);
                Get.back();
              },
              activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            RadioListTile(
              title: const Text('Contacts Only'),
              subtitle: const Text('Only your contacts can see your profile'),
              value: 'contacts_only',
              groupValue: controller.profileVisibility,
              onChanged: (value) {
                controller.updateProfileVisibility(value!);
                Get.back();
              },
              activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPrivacyDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Privacy',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppDimens.margin16),
                Obx(() => SwitchListTile(
                  title: const Text('Share Location'),
                  subtitle: const Text('Allow app to access your location'),
                  value: controller.locationSharingEnabled,
                  onChanged: controller.toggleLocationSharing,
                  activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                )),
                if (controller.locationSharingEnabled)
                  Column(
                    children: [
                      const Divider(),
                      RadioListTile(
                        title: const Text('Precise Location'),
                        subtitle: const Text('Share exact location'),
                        value: 'precise',
                        groupValue: controller.locationAccuracy,
                        onChanged: (value) => controller.updateLocationAccuracy(value!),
                        activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      ),
                      RadioListTile(
                        title: const Text('Approximate Location'),
                        subtitle: const Text('Share general area only'),
                        value: 'approximate',
                        groupValue: controller.locationAccuracy,
                        onChanged: (value) => controller.updateLocationAccuracy(value!),
                        activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _show2FADialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Two-Factor Authentication',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppDimens.margin16),
                const Text('Choose your preferred 2FA method:'),
                const SizedBox(height: AppDimens.margin12),
                RadioListTile(
                  title: const Text('Authenticator App'),
                  subtitle: const Text('Google Authenticator, Authy, etc.'),
                  value: 'authenticator',
                  groupValue: controller.twoFAMethod,
                  onChanged: (value) {
                    controller.setupTwoFactorAuth();
                    Get.back();
                  },
                ),
                RadioListTile(
                  title: const Text('SMS'),
                  subtitle: const Text('Receive codes via text message'),
                  value: 'sms',
                  groupValue: controller.twoFAMethod,
                  onChanged: (value) {
                    // Setup SMS 2FA
                    Get.back();
                  },
                ),
                RadioListTile(
                  title: const Text('Email'),
                  subtitle: const Text('Receive codes via email'),
                  value: 'email',
                  groupValue: controller.twoFAMethod,
                  onChanged: (value) {
                    // Setup Email 2FA
                    Get.back();
                  },
                ),
                const SizedBox(height: AppDimens.margin16),
                TextButton.icon(
                  onPressed: () => controller.disableTwoFactorAuth(),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Disable 2FA', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
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
              //controller.requestDataDownload();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryGreenLight
                  : AppColors.primaryGreen,
            ),
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
              controller.clearSearchHistory();
              controller.clearBrowseHistory();
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
    final passwordController = TextEditingController();

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
              controller: passwordController,
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
              if (passwordController.text.isEmpty) {
                Get.snackbar('Error', 'Please enter your password');
                return;
              }
              Get.back();
              controller.deleteAccount(passwordController.text);
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