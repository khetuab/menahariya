// lib/modules/passenger/views/profile/profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/modules/passenger/controllers/profile_controller.dart';

import '../../controllers/notification_controller.dart';

class ProfileView extends GetView<PassengerProfileController> {
  const ProfileView({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Get.toNamed('/passenger/profile/settings'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(context),

              const SizedBox(height: AppDimens.margin24),

              // Stats Grid
              _buildStatsGrid(context),

              const SizedBox(height: AppDimens.margin24),

              // Menu Items
              _buildMenuSection(context),

              const SizedBox(height: AppDimens.margin24),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
                child: PrimaryButton(
                  text: 'Logout',
                  onPressed: controller.logout,
                  backgroundColor: Colors.transparent,
                  textColor: isDark ? AppColors.errorLight : AppColors.error,
                  borderColor: isDark ? AppColors.errorLight : AppColors.error,
                ),
              ),
              const SizedBox(height: AppDimens.margin60),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
            isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      child: Row(
        children: [
          // Profile Image
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: controller.profileImageUrl != null
                    ? NetworkImage(controller.profileImageUrl!)
                    : null,
                child: controller.profileImageUrl == null
                    ? Text(
                  controller.user.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePickerDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: isDark ? AppColors.primaryGreen : AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppDimens.margin16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.user.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin4),
                Text(
                  controller.user.phone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                if (controller.user.email != null) ...[
                  const SizedBox(height: AppDimens.margin2),
                  Text(
                    controller.user.email!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
                const SizedBox(height: AppDimens.margin8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.padding8,
                    vertical: AppDimens.padding4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimens.radius20),
                  ),
                  child: Text(
                    controller.loyaltyTier ?? 'Bronze Member',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppDimens.gridSpacingMedium,
      mainAxisSpacing: AppDimens.gridSpacingMedium,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          icon: Icons.confirmation_number_rounded,
          label: 'Trips',
          value: '${controller.totalTrips}',
          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
        ),
        _buildStatCard(
          context,
          icon: Icons.inventory_2_rounded,
          label: 'Cargo',
          value: '${controller.totalCargo}',
          color: isDark ? AppColors.warningLight : AppColors.warning,
        ),
        _buildStatCard(
          context,
          icon: Icons.stars_rounded,
          label: 'Points',
          value: '${controller.loyaltyPoints}',
          color: isDark ? AppColors.successLight : AppColors.success,
        ),
        _buildStatCard(
          context,
          icon: Icons.calendar_today_rounded,
          label: 'Member Since',
          value: controller.memberSinceText,
          color: isDark ? AppColors.infoLight : AppColors.info,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
      }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppDimens.margin4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildMenuItem(
          context,
          icon: Icons.person_rounded,
          title: 'Edit Profile',
          onTap: () => Get.toNamed('/passenger/edit-profile'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.history_rounded,
          title: 'Booking History',
          onTap: () => Get.toNamed('/passenger/booking-history'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.inventory_2_rounded,
          title: 'Cargo History',
          onTap: () => Get.toNamed('/passenger/cargo-history'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.payment_rounded,
          title: 'Payment Methods',
          onTap: () => Get.toNamed('/passenger/payment'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.notifications_rounded,
          title: 'Notifications',
          onTap: () => Get.toNamed('/passenger/notifications'),
          trailing: Obx(() {
            final count = Get.find<PassengerNotificationController>().unreadCount;
            if (count > 0) {
              return Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return const Icon(Icons.chevron_right_rounded);
          }),
        ),
        _buildMenuItem(
          context,
          icon: Icons.security_rounded,
          title: 'Privacy & Security',
          onTap: controller.viewPrivacyPolicy,
        ),
        _buildMenuItem(
          context,
          icon: Icons.help_rounded,
          title: 'Help & Support',
          onTap: controller.contactSupport,
        ),
        _buildMenuItem(
          context,
          icon: Icons.info_rounded,
          title: 'About',
          onTap: controller.viewTermsAndConditions,
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        Widget? trailing,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
      ),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  void _showImagePickerDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimens.padding20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimens.radius20),
            topRight: Radius.circular(AppDimens.radius20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimens.margin20),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                controller.pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                controller.pickImageFromGallery();
              },
            ),
            if (controller.profileImageUrl != null) ...[
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  // Remove photo
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}