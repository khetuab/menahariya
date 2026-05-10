// lib/modules/driver/views/profile/profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/modules/driver/controllers/profile_controller.dart';

import '../support/driver_my_tickets_view.dart';
import '../support/support_view.dart';
import 'edit_profile_view.dart';

class DriverProfileView extends GetView<DriverProfileController> {
  const DriverProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Get.toNamed('/driver/profile/settings'),
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

              // Rating Section
              _buildRatingSection(context),

              const SizedBox(height: AppDimens.margin24),

              // License Info
              _buildLicenseInfo(context),

              const SizedBox(height: AppDimens.margin24),

              // Menu Items
              _buildMenuItems(context),

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
            ],
          ),
        );
      }),
    );
  }

  // In profile_view.dart, update _buildProfileHeader to handle null user:

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Add null check
    final user = controller.user;
    if (user == null) {
      return const SizedBox.shrink(); // Or a loading indicator
    }

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
                  user.fullName[0].toUpperCase(),
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
                  user.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.yellow, size: 16),
                    const SizedBox(width: AppDimens.margin2),
                    Text(
                      '${controller.rating.toStringAsFixed(1)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin8),
                    Text(
                      '(${controller.totalReviews} reviews)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.padding8,
                    vertical: AppDimens.padding4,
                  ),
                  decoration: BoxDecoration(
                    color: controller.isOnline
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimens.radius20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: controller.isOnline
                              ? AppColors.success
                              : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppDimens.margin4),
                      Text(
                        controller.isOnline ? 'Online' : 'Offline',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
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
      crossAxisCount: 3,
      crossAxisSpacing: AppDimens.gridSpacingMedium,
      mainAxisSpacing: AppDimens.gridSpacingMedium,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          context,
          label: 'Total Trips',
          value: '${controller.totalTrips}',
          icon: Icons.route_rounded,
          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
        ),
        _buildStatCard(
          context,
          label: 'Distance',
          value: '${controller.totalDistance} km',
          icon: Icons.speed_rounded,
          color: isDark ? AppColors.infoLight : AppColors.info,
        ),
        _buildStatCard(
          context,
          label: 'Experience',
          value: '${DateTime.now().difference(controller.driverSince ?? DateTime.now()).inDays ~/ 365} yrs',
          icon: Icons.work_rounded,
          color: isDark ? AppColors.warningLight : AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {required String label, required String value, required IconData icon, required Color color}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppDimens.margin2),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
                'Rating Breakdown',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all reviews
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.margin12),
          _buildRatingBar(context, 'Professionalism', 4.5),
          _buildRatingBar(context, 'Punctuality', 4.8),
          _buildRatingBar(context, 'Safety', 5.0),
          _buildRatingBar(context, 'Communication', 4.3),
        ],
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context, String label, double rating) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radius2),
              child: LinearProgressIndicator(
                value: rating / 5,
                minHeight: 6,
                backgroundColor: isDark ? AppColors.grey700 : AppColors.grey300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.warningLight : AppColors.warning,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.margin8),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = controller.user;

    if (user == null) {
      return const SizedBox.shrink(); // or loading widget
    }

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'License Information',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin12),
          _buildInfoRow(
            context,
            'License Number',
            user.licenseNumber ?? 'Not provided',
          ),
          _buildInfoRow(
            context,
            'Expiry Date',
            user.licenseExpiry?.toString().substring(0, 10) ?? 'Not provided',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppFonts.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          icon: Icons.person_rounded,
          title: 'Edit Profile',
          onTap: () => Get.to(()=>DriverEditProfileView()),
        ),
        _buildMenuItem(
          context,
          icon: Icons.access_time_rounded,
          title: 'Availability',
          onTap: () => Get.toNamed('/driver/availability'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.history_rounded,
          title: 'Trip History',
          onTap: () => Get.toNamed('/driver/trips'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.help_rounded,
          title: 'Help & Support',
          onTap: () => Get.to(()=> SupportView()),
        ),
        _buildMenuItem(
          context,
          icon: Icons.chat,
          title: 'Chats with admin',
          onTap: () => Get.to(()=> DriverMyTicketsView()),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
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
          ],
        ),
      ),
    );
  }
}