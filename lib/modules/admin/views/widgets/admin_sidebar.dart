// lib/modules/admin/widgets/admin_drawer.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/environment/env_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../admin_profile_view.dart';

class AdminDrawer extends StatelessWidget {
  final int currentIndex;

  const AdminDrawer({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authController = Get.find<AuthController>();

    // Get base URL without /api suffix for static files
    final apiUrl = EnvConfig.instance.apiBaseUrl;
    // Remove /api from the URL for static files (uploads are served from root)
    final staticBaseUrl = apiUrl.replaceAll('/api', '');

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Obx(() => UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight,
            ),
            accountName: Text(
              authController.currentUser?.fullName ?? 'Admin User ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(authController.currentUser?.email ?? 'admin@menahariya.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              child: _buildProfileImage(authController, staticBaseUrl),
            ),
            onDetailsPressed: () => Get.to(() => const AdminProfileView()),
          )),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  index: 0,
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  route: AppRoutes.adminDashboard,
                ),
                _buildDrawerItem(
                  context,
                  index: 1,
                  icon: Icons.directions_bus_rounded,
                  label: 'Trips',
                  route: AppRoutes.adminTrips,
                ),
                _buildDrawerItem(
                  context,
                  index: 2,
                  icon: Icons.confirmation_number_rounded,
                  label: 'Bookings',
                  route: AppRoutes.adminBookings,
                ),
                _buildDrawerItem(
                  context,
                  index: 3,
                  icon: Icons.people_rounded,
                  label: 'Users',
                  route: AppRoutes.adminUsers,
                ),
                _buildDrawerItem(
                  context,
                  index: 4,
                  icon: Icons.inventory_2_rounded,
                  label: 'Cargo',
                  route: AppRoutes.adminCargo,
                ),
                _buildDrawerItem(
                  context,
                  index: 5,
                  icon: Icons.analytics_rounded,
                  label: 'Reports',
                  route: AppRoutes.adminReports,
                ),
                _buildDrawerItem(
                  context,
                  index: 6,
                  icon: Icons.payments_rounded,
                  label: 'Payments',
                  route: AppRoutes.adminPayments,
                ),
                _buildDrawerItem(
                  context,
                  index: 12,
                  icon: Icons.local_offer_rounded,
                  label: 'Promotions',
                  route: '/admin/promotions',
                ),
                _buildDrawerItem(
                  context,
                  index: 7,
                  icon: Icons.map_rounded,
                  label: 'Routes',
                  route: AppRoutes.adminRoutes,
                ),
                _buildDrawerItem(
                  context,
                  index: 8,
                  icon: Icons.local_shipping_rounded,
                  label: 'Vehicles',
                  route: AppRoutes.adminVehicles,
                ),
                _buildDrawerItem(
                  context,
                  index: 9,
                  icon: Icons.notifications_rounded,
                  label: 'Notifications',
                  route: AppRoutes.adminNotifications,
                ),
                _buildDrawerItem(
                  context,
                  index: 10,
                  icon: Icons.headset_mic_outlined,
                  label: 'Support',
                  route: AppRoutes.adminSupport,
                ),
                _buildDrawerItem(
                  context,
                  index: 11,
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  route: AppRoutes.adminSettings,
                ),
              ],
            ),
          ),
          // Logout Button
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Logout'),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(AuthController authController, String staticBaseUrl) {
    final profileImage = authController.currentUser?.profileImage;

    if (profileImage != null && profileImage.isNotEmpty) {
      // Check if it's already a full URL or relative path
      String imageUrl;
      if (profileImage.startsWith('http')) {
        imageUrl = profileImage;
      } else {
        // Remove any double slashes
        final cleanPath = profileImage.startsWith('/') ? profileImage : '/$profileImage';
        imageUrl = '$staticBaseUrl$cleanPath';
      }

      debugPrint('Loading profile image from: $imageUrl');

      return ClipOval(
        child: Image.network(
          imageUrl,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircularProgressIndicator();
          },
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(authController),
        ),
      );
    }

    return _buildDefaultAvatar(authController);
  }

  Widget _buildDefaultAvatar(AuthController authController) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: Text(
        authController.currentUser?.fullName.isNotEmpty == true
            ? authController.currentUser!.fullName[0].toUpperCase()
            : 'A',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required int index,
        required IconData icon,
        required String label,
        required String route,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = currentIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected
              ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
              : null,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: isDark
          ? AppColors.primaryGreen.withOpacity(0.1)
          : AppColors.primaryGreen.withOpacity(0.05),
      onTap: () {
        // Close drawer first
        Navigator.pop(context);

        if (currentIndex != index) {
          // Use toNamed instead of offAllNamed to keep navigation stack
          Get.toNamed(route);
        }
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final authController = Get.find<AuthController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}