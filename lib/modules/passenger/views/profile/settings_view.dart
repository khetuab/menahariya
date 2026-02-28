// lib/modules/passenger/views/profile/settings_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/modules/passenger/controllers/profile_controller.dart';

class SettingsView extends GetView<PassengerProfileController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: Obx(() => ListView(
        padding: const EdgeInsets.all(AppDimens.padding16),
        children: [
          // Notifications Section
          _buildSection(
            context,
            title: 'Notifications',
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.notifications_rounded,
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                value: controller.notificationsEnabled.obs,
                onChanged: controller.toggleNotifications,
              ),
              _buildSwitchTile(
                context,
                icon: Icons.campaign,
                title: 'Promotional Notifications',
                subtitle: 'Receive offers and promotions',
                value: controller.receivePromotions.obs,
                onChanged: controller.togglePromotions,
              ),
            ],
          ),

          const SizedBox(height: AppDimens.margin16),

          // Appearance Section
          _buildSection(
            context,
            title: 'Appearance',
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: 'Switch to dark theme',
                value: controller.darkMode.obs,
                onChanged: controller.toggleDarkMode,
              ),
              _buildLanguageTile(context),
            ],
          ),

          const SizedBox(height: AppDimens.margin16),

          // Privacy Section
          _buildSection(
            context,
            title: 'Privacy & Data',
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.history_rounded,
                title: 'Save Search History',
                subtitle: 'Store your recent searches',
                value: controller.saveHistory.obs,
                onChanged: controller.toggleSaveHistory,
              ),
              _buildSwitchTile(
                context,
                icon: Icons.file_download_rounded,
                title: 'Auto-download Tickets',
                subtitle: 'Automatically download tickets',
                value: controller.autoDownloadTickets.obs,
                onChanged: controller.toggleAutoDownload,
              ),
            ],
          ),

          const SizedBox(height: AppDimens.margin16),

          // Security Section
          _buildSection(
            context,
            title: 'Security',
            children: [
              _buildTile(
                context,
                icon: Icons.lock_rounded,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () => _showChangePasswordDialog(context),
              ),
              _buildTile(
                context,
                icon: Icons.fingerprint_rounded,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face ID',
                onTap: () {},
              ),
              _buildTile(
                context,
                icon: Icons.security_rounded,
                title: 'Two-Factor Authentication',
                subtitle: 'Add extra security',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: AppDimens.margin16),

          // Support Section
          _buildSection(
            context,
            title: 'Support',
            children: [
              _buildTile(
                context,
                icon: Icons.help_rounded,
                title: 'Help Center',
                subtitle: 'Get help with your questions',
                onTap: controller.viewFAQs,
              ),
              _buildTile(
                context,
                icon: Icons.support_agent_rounded,
                title: 'Contact Support',
                subtitle: 'Reach out to our team',
                onTap: controller.contactSupport,
              ),
              _buildTile(
                context,
                icon: Icons.description_rounded,
                title: 'Terms & Conditions',
                subtitle: 'Read our terms of service',
                onTap: controller.viewTermsAndConditions,
              ),
              _buildTile(
                context,
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                subtitle: 'Learn how we protect your data',
                onTap: controller.viewPrivacyPolicy,
              ),
            ],
          ),

          const SizedBox(height: AppDimens.margin24),

          // App Info
          Container(
            padding: const EdgeInsets.all(AppDimens.padding16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : AppColors.grey50,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'App Version',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '1.0.0',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last Updated',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '2024-01-15',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.margin24),

          // Logout Button
          SecondaryButton(
            text: 'Logout',
            onPressed: controller.logout,
            textColor: isDark ? AppColors.errorLight : AppColors.error,
            borderColor: isDark ? AppColors.errorLight : AppColors.error,
            icon: Icons.logout_rounded,
          ),

          const SizedBox(height: AppDimens.margin16),
        ],
      )),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppDimens.padding8, bottom: AppDimens.padding8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
              color: theme.primaryColor,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required RxBool value,
        required Function(bool) onChanged,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() => SwitchListTile(
      secondary: Icon(
        icon,
        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value.value,
      onChanged: onChanged,
      activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
    ));
  }

  Widget _buildTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        Icons.language_rounded,
        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
      ),
      title: const Text('Language'),
      subtitle: Obx(() => Text(
        controller.language == 'en' ? 'English' : 'አማርኛ',
      )),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.arrow_drop_down_rounded),
        onSelected: controller.setLanguage,
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'en',
            child: Text('English'),
          ),
          const PopupMenuItem(
            value: 'am',
            child: Text('አማርኛ'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: Column(
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
}