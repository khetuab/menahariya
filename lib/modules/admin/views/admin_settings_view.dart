// lib/modules/admin/views/admin_settings_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_dialogs.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_sidebar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/custom_textfield.dart';
import '../controllers/admin_settings_controller.dart';

class AdminSettingsView extends GetView<AdminSettingsController> {
  const AdminSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AdminDrawer(currentIndex: 10),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: controller.saveSettings,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Settings Tabs
            _buildSettingsTabs(context),
            // Settings Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.padding16),
                child: _buildSettingsContent(context),
              ),
            ),
            // Save Button (floating at bottom)
            Container(
              padding: const EdgeInsets.all(AppDimens.padding16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              child: PrimaryButton(
                text: 'Save Changes',
                onPressed: controller.saveSettings,
                isLoading: controller.isSaving,
                icon: Icons.save_rounded,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSettingsTabs(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding12),
        itemCount: SettingsTab.values.length,
        itemBuilder: (context, index) {
          final tab = SettingsTab.values[index];
          final isSelected = controller.activeTab == tab;
          return GestureDetector(
            onTap: () => controller.setActiveTab(tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  _getTabName(tab),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isSelected
                        ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    fontWeight: isSelected ? AppFonts.semiBold : AppFonts.regular,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    switch (controller.activeTab) {
      case SettingsTab.general:
        return _buildGeneralSettings(context);
      case SettingsTab.booking:
        return _buildBookingSettings(context);
      case SettingsTab.cargo:
        return _buildCargoSettings(context);
      case SettingsTab.payment:
        return _buildPaymentSettings(context);
      case SettingsTab.notification:
        return _buildNotificationSettings(context);
      case SettingsTab.security:
        return _buildSecuritySettings(context);
      case SettingsTab.maintenance:
        return _buildMaintenanceSettings(context);
    }
  }

  Widget _buildGeneralSettings(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'General Settings',
          children: [
            _buildInfoTile(
              title: 'System Name',
              value: 'MENAHARIYA SMART',
              icon: Icons.business_rounded,
            ),
            _buildInfoTile(
              title: 'Timezone',
              value: 'East Africa Time (EAT)',
              icon: Icons.access_time_rounded,
            ),
            _buildInfoTile(
              title: 'Date Format',
              value: 'YYYY-MM-DD',
              icon: Icons.calendar_today_rounded,
            ),
            _buildInfoTile(
              title: 'Currency',
              value: 'Ethiopian Birr (ETB)',
              icon: Icons.attach_money_rounded,
            ),
          ],
        ),
        const SizedBox(height: AppDimens.margin16),
        _buildSectionCard(
          title: 'System Actions',
          children: [
            _buildActionTile(
              title: 'Clear Cache',
              subtitle: 'Clear temporary application cache',
              icon: Icons.clear_all_rounded,
              iconColor: Colors.orange,
              onTap: () => _showClearCacheDialog(),
            ),
            _buildActionTile(
              title: 'Backup Database',
              subtitle: 'Create a backup of system data',
              icon: Icons.backup_rounded,
              iconColor: Colors.blue,
              onTap: controller.backupDatabase,
            ),
            _buildActionTile(
              title: 'Export Data',
              subtitle: 'Export system data to CSV',
              icon: Icons.file_download_rounded,
              iconColor: Colors.teal,
              onTap: () => _showExportDialog(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingSettings(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Booking Configuration',
          children: [
            _buildNumberField(
              label: 'Max Seats Per Booking',
              controller: controller.maxSeatsPerBookingController,
              icon: Icons.chair_rounded,
            ),
            _buildNumberField(
              label: 'Seat Lock Duration (minutes)',
              controller: controller.seatLockDurationController,
              icon: Icons.lock_clock_rounded,
            ),
            _buildNumberField(
              label: 'Cancellation Window (hours)',
              controller: controller.cancellationWindowController,
              icon: Icons.timer_off_rounded,
            ),
            _buildNumberField(
              label: 'Cancellation Fee (%)',
              controller: controller.cancellationFeeController,
              icon: Icons.percent_rounded,
            ),
            _buildToggleTile(
              title: 'Enable Travel Insurance',
              value: controller.enableInsurance,
              onChanged: controller.toggleEnableInsurance,
            ),
            // Fixed: Use Obx to observe the boolean value
            Obx(() {
              if (controller.enableInsurance.value) {
                return _buildNumberField(
                  label: 'Insurance Rate (%)',
                  controller: controller.insuranceRateController,
                  icon: Icons.security_rounded,
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCargoSettings(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Cargo Configuration',
          children: [
            _buildNumberField(
              label: 'Base Rate (ETB per kg)',
              controller: controller.baseRatePerKgController,
              icon: Icons.monitor_weight_rounded,
            ),
            _buildNumberField(
              label: 'Fragile Surcharge (%)',
              controller: controller.fragileSurchargeController,
              icon: Icons.warning_amber_rounded,
            ),
            _buildNumberField(
              label: 'Perishable Surcharge (%)',
              controller: controller.perishableSurchargeController,
              icon: Icons.restaurant_rounded,
            ),
            _buildNumberField(
              label: 'Refrigeration Surcharge (%)',
              controller: controller.refrigerationSurchargeController,
              icon: Icons.ac_unit_rounded,
            ),
            _buildNumberField(
              label: 'Minimum Fee (ETB)',
              controller: controller.minFeeController,
              icon: Icons.attach_money_rounded,
            ),
            _buildNumberField(
              label: 'Max Weight per Trip (kg)',
              controller: controller.maxWeightPerTripController,
              icon: Icons.fitness_center_rounded,
            ),
            _buildToggleTile(
              title: 'Require Dimensions',
              value: controller.requireDimensions,
              onChanged: controller.toggleRequireDimensions,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSettings(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Payment Methods',
          children: controller.availablePaymentMethods.map((method) {
            return Obx(() => _buildToggleTile(
              title: _getPaymentMethodName(method),
              value: RxBool(controller.enabledPaymentMethodsList.contains(method)),
              onChanged: (value) => controller.togglePaymentMethod(method, value),
            ));
          }).toList(),
        ),
        const SizedBox(height: AppDimens.margin16),
        _buildSectionCard(
          title: 'Wallet Settings',
          children: [
            _buildNumberField(
              label: 'Min Balance',
              controller: controller.walletMinBalanceController,
              icon: Icons.account_balance_wallet_rounded,
              prefix: 'ETB',
            ),
            _buildNumberField(
              label: 'Max Balance',
              controller: controller.walletMaxBalanceController,
              icon: Icons.account_balance_wallet_rounded,
              prefix: 'ETB',
            ),
          ],
        ),
        const SizedBox(height: AppDimens.margin16),
        _buildSectionCard(
          title: 'Payment Processing',
          children: [
            _buildNumberField(
              label: 'Payment Timeout (minutes)',
              controller: controller.paymentTimeoutController,
              icon: Icons.timer_rounded,
            ),
            _buildToggleTile(
              title: 'Auto-confirm Payments',
              value: controller.autoConfirmPayments,
              onChanged: controller.toggleAutoConfirmPayments,
            ),
            _buildNumberField(
              label: 'Refund Processing Days',
              controller: controller.refundProcessingDaysController,
              icon: Icons.payment,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Notification Channels',
          children: [
            _buildToggleTile(
              title: 'SMS Notifications',
              subtitle: 'Send SMS alerts to users',
              value: controller.enableSms,
              onChanged: controller.toggleEnableSms,
            ),
            _buildToggleTile(
              title: 'Email Notifications',
              subtitle: 'Send email alerts to users',
              value: controller.enableEmail,
              onChanged: controller.toggleEnableEmail,
            ),
            _buildToggleTile(
              title: 'Push Notifications',
              subtitle: 'Send in-app push notifications',
              value: controller.enablePush,
              onChanged: controller.toggleEnablePush,
            ),
          ],
        ),
        const SizedBox(height: AppDimens.margin16),
        _buildSectionCard(
          title: 'Test Notification',
          children: [
            _buildActionTile(
              title: 'Send Test Notification',
              subtitle: 'Send a test push notification',
              icon: Icons.send_rounded,
              iconColor: Colors.blue,
              onTap: () => _showTestNotificationDialog(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecuritySettings(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Security Configuration',
          children: [
            _buildNumberField(
              label: 'Session Timeout (minutes)',
              controller: controller.sessionTimeoutController,
              icon: Icons.timer_rounded,
            ),
            _buildNumberField(
              label: 'Max Login Attempts',
              controller: controller.maxLoginAttemptsController,
              icon: Icons.login_rounded,
            ),
            _buildNumberField(
              label: 'Password Expiry (days)',
              controller: controller.passwordExpiryDaysController,
              icon: Icons.lock_rounded,
            ),
            _buildToggleTile(
              title: 'Require MFA for Admin',
              subtitle: 'Multi-factor authentication for admin accounts',
              value: controller.requireMfaForAdmin,
              onChanged: controller.toggleRequireMfaForAdmin,
            ),
            _buildToggleTile(
              title: 'Enable Audit Logging',
              subtitle: 'Log all admin actions',
              value: controller.enableAuditLogging,
              onChanged: controller.toggleEnableAuditLogging,
            ),
          ],
        ),
        const SizedBox(height: AppDimens.margin16),
        _buildSectionCard(
          title: 'Security Actions',
          children: [
            _buildActionTile(
              title: 'Force Logout All Users',
              subtitle: 'Logout all active sessions',
              icon: Icons.logout_rounded,
              iconColor: Colors.red,
              onTap: () => _showForceLogoutDialog(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaintenanceSettings(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Maintenance Mode',
          children: [
            _buildToggleTile(
              title: 'Enable Maintenance Mode',
              subtitle: 'Put the system in maintenance mode',
              value: controller.maintenanceMode,
              onChanged: controller.toggleMaintenanceMode,
            ),
            // Fixed: Use Obx to conditionally show widgets
            Obx(() {
              if (controller.maintenanceMode.value) {
                return Column(
                  children: [
                    const SizedBox(height: AppDimens.margin12),
                    CustomTextField(
                      label: 'Maintenance Message',
                      controller: controller.maintenanceMessageController,
                      hint: 'Message to show to users',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppDimens.margin12),
                    _buildNumberField(
                      label: 'Estimated Duration (minutes)',
                      controller: controller.estimatedDurationController,
                      icon: Icons.timer_rounded,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          const SizedBox(width: AppDimens.margin12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium),
                Text(value, style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? prefix,
  }) {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.margin12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          prefixText: prefix != null ? '$prefix ' : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius8),
            borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius8),
            borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius8),
            borderSide: BorderSide(color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
          ),
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    String? subtitle,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium),
                if (subtitle != null)
                  Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Obx(() => Switch(
            value: value.value, // Use .value to get the bool
            onChanged: onChanged,
            activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          )),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Get.context!.theme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: theme.textTheme.bodyMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  void _showClearCacheDialog() async {
    final confirmed = await AdminConfirmationDialog.show(
      title: 'Clear Cache',
      message: 'Are you sure you want to clear the system cache? This may temporarily slow down the system.',
      confirmText: 'Clear',
      confirmColor: Colors.orange,
    );

    if (confirmed) {
      await controller.clearCache();
    }
  }

  void _showExportDialog() {
    Get.snackbar('Coming Soon', 'Export functionality will be available soon');
  }

  void _showTestNotificationDialog() {
    Get.snackbar('Test Notification', 'Test notification sent successfully');
  }

  void _showForceLogoutDialog() async {
    final confirmed = await AdminConfirmationDialog.show(
      title: 'Force Logout',
      message: 'Are you sure you want to logout all active users?',
      confirmText: 'Force Logout',
      confirmColor: Colors.red,
    );

    if (confirmed) {
      Get.snackbar('Success', 'All users have been logged out');
    }
  }

  String _getTabName(SettingsTab tab) {
    switch (tab) {
      case SettingsTab.general: return 'General';
      case SettingsTab.booking: return 'Booking';
      case SettingsTab.cargo: return 'Cargo';
      case SettingsTab.payment: return 'Payment';
      case SettingsTab.notification: return 'Notification';
      case SettingsTab.security: return 'Security';
      case SettingsTab.maintenance: return 'Maintenance';
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'telebirr': return 'Telebirr';
      case 'cbe_birr': return 'CBE Birr';
      case 'card': return 'Card Payment';
      case 'wallet': return 'Wallet Balance';
      case 'cash': return 'Cash';
      default: return method;
    }
  }
}