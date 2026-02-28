// lib/modules/driver/views/profile/settings_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/modules/driver/controllers/profile_controller.dart';

class DriverSettingsView extends GetView<DriverProfileController> {
  const DriverSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          children: [
            // Account Settings Section
            _buildSection(
              context,
              title: 'Account Settings',
              children: [
                _buildTile(
                  context,
                  icon: Icons.person_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () => Get.toNamed('/driver/profile/edit'),
                ),
                _buildTile(
                  context,
                  icon: Icons.lock_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _buildTile(
                  context,
                  icon: Icons.email_rounded,
                  title: 'Email Address',
                  subtitle: controller.user.email ?? 'Add email address',
                  onTap: () => _showEditEmailDialog(context),
                ),
                _buildTile(
                  context,
                  icon: Icons.phone_rounded,
                  title: 'Phone Number',
                  subtitle: controller.user.phone,
                  onTap: () => _showEditPhoneDialog(context),
                ),
              ],
            ),

            const SizedBox(height: AppDimens.margin16),

            // Notifications Section
            _buildSection(
              context,
              title: 'Notifications',
              children: [
                _buildSwitchTile(
                  context,
                  icon: Icons.notifications_rounded,
                  title: 'Push Notifications',
                  subtitle: 'Receive trip assignments and updates',
                  value: controller.notificationsEnabled.obs,
                  onChanged: controller.toggleNotifications,
                ),
                _buildSwitchTile(
                  context,
                  icon: Icons.sms_rounded,
                  title: 'SMS Notifications',
                  subtitle: 'Receive text messages for important updates',
                  value: false.obs,
                  onChanged: (value) {},
                ),
                _buildSwitchTile(
                  context,
                  icon: Icons.email_rounded,
                  title: 'Email Notifications',
                  subtitle: 'Receive email summaries',
                  value: false.obs,
                  onChanged: (value) {},
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
                _buildTile(
                  context,
                  icon: Icons.font_download_rounded,
                  title: 'Font Size',
                  subtitle: 'Adjust text size',
                  onTap: () => _showFontSizeDialog(context),
                ),
              ],
            ),

            const SizedBox(height: AppDimens.margin16),

            // Privacy & Security Section
            _buildSection(
              context,
              title: 'Privacy & Security',
              children: [
                _buildSwitchTile(
                  context,
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Login',
                  subtitle: 'Use fingerprint or face ID',
                  value: false.obs,
                  onChanged: (value) {},
                ),
                _buildTile(
                  context,
                  icon: Icons.security_rounded,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add extra security to your account',
                  onTap: () {},
                ),
                _buildTile(
                  context,
                  icon: Icons.history_rounded,
                  title: 'Login History',
                  subtitle: 'View recent login activity',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: AppDimens.margin16),

            // Payment Settings Section
            _buildSection(
              context,
              title: 'Payment Settings',
              children: [
                _buildTile(
                  context,
                  icon: Icons.credit_card_rounded,
                  title: 'Payment Methods',
                  subtitle: 'Manage your payment options',
                  onTap: () {},
                ),
                _buildTile(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Earnings Summary',
                  subtitle: 'View your earnings and payouts',
                  onTap: () => Get.toNamed('/driver/earnings'),
                ),
                _buildTile(
                  context,
                  icon: Icons.receipt_rounded,
                  title: 'Tax Information',
                  subtitle: 'Update your tax details',
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
                  subtitle: 'Get help with common issues',
                  onTap: () {},
                ),
                _buildTile(
                  context,
                  icon: Icons.support_agent_rounded,
                  title: 'Contact Support',
                  subtitle: 'Reach out to our team',
                  onTap: () => _showContactSupportDialog(context),
                ),
                _buildTile(
                  context,
                  icon: Icons.description_rounded,
                  title: 'Terms & Conditions',
                  subtitle: 'Read our terms of service',
                  onTap: () {},
                ),
                _buildTile(
                  context,
                  icon: Icons.privacy_tip_rounded,
                  title: 'Privacy Policy',
                  subtitle: 'Learn how we protect your data',
                  onTap: () {},
                ),
                _buildTile(
                  context,
                  icon: Icons.info_rounded,
                  title: 'About',
                  subtitle: 'App version 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),

            const SizedBox(height: AppDimens.margin24),

            // Logout Button
            PrimaryButton(
              text: 'Logout',
              onPressed: controller.logout,
              backgroundColor: Colors.transparent,
              textColor: isDark ? AppColors.errorLight : AppColors.error,
              borderColor: isDark ? AppColors.errorLight : AppColors.error,
            ),

            const SizedBox(height: AppDimens.margin16),

            // Delete Account
            Center(
              child: TextButton(
                onPressed: _showDeleteAccountDialog,
                child: Text(
                  'Delete Account',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.errorLight : AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppDimens.padding8, bottom: AppDimens.padding8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
          ),
        ),
        Card(
          elevation: AppDimens.elevation1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius12),
          ),
          child: Column(children: children),
        ),
      ],
    );
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
      leading: Container(
        padding: const EdgeInsets.all(AppDimens.padding8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey800 : AppColors.grey100,
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          size: AppDimens.iconSize20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: AppFonts.medium,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
      onTap: onTap,
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
      secondary: Container(
        padding: const EdgeInsets.all(AppDimens.padding8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey800 : AppColors.grey100,
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          size: AppDimens.iconSize20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: AppFonts.medium,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      value: value.value,
      onChanged: onChanged,
      activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
    ));
  }

  Widget _buildLanguageTile(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppDimens.padding8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey800 : AppColors.grey100,
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        child: Icon(
          Icons.language_rounded,
          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          size: AppDimens.iconSize20,
        ),
      ),
      title: Text(
        'Language',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: AppFonts.medium,
        ),
      ),
      subtitle: Obx(() => Text(
        controller.language == 'en' ? 'English' : 'አማርኛ',
        style: theme.textTheme.bodySmall,
      )),
      trailing: PopupMenuButton<String>(
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
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
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_rounded),
              ),
            ),
            const SizedBox(height: AppDimens.margin12),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_rounded),
              ),
            ),
            const SizedBox(height: AppDimens.margin12),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_rounded),
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
              Get.snackbar(
                'Success',
                'Password changed successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
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

  void _showEditEmailDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Email'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_rounded),
          ),
          keyboardType: TextInputType.emailAddress,
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
                'Success',
                'Email updated successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditPhoneDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Phone'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_rounded),
          ),
          keyboardType: TextInputType.phone,
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
                'Success',
                'Phone number updated successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Small'),
              leading: Radio<String>(
                value: 'small',
                groupValue: 'medium',
                onChanged: (value) {},
                activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
            ),
            ListTile(
              title: const Text('Medium'),
              leading: Radio<String>(
                value: 'medium',
                groupValue: 'medium',
                onChanged: (value) {},
                activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
            ),
            ListTile(
              title: const Text('Large'),
              leading: Radio<String>(
                value: 'large',
                groupValue: 'medium',
                onChanged: (value) {},
                activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
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
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How can we help you?'),
            const SizedBox(height: AppDimens.margin12),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe your issue...',
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
              Get.snackbar(
                'Support Request Sent',
                'We\'ll get back to you soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryYellow,
                    AppColors.primaryRed,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.margin16),
            const Text(
              'MENAHARIYA SMART',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimens.margin8),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimens.margin16),
            const Text(
              '© 2024 Wolkite University\nDepartment of Software Engineering',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Account Deleted',
                'Your account has been scheduled for deletion',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.errorLight : AppColors.error,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}