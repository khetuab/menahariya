// lib/modules/admin/widgets/admin_drawer.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
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

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          // Add this at the top of your drawer, before the navigation items
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight,
            ),
            accountName: Text(
              authController.currentUser?.fullName ?? 'Admin User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(authController.currentUser?.email ?? 'admin@menahariya.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: authController.currentUser?.profileImage != null
                  ? ClipOval(
                child: Image.network(
                  authController.currentUser!.profileImage!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.person, size: 30),
                ),
              )
                  : Text(
                authController.currentUser?.fullName[0].toUpperCase() ?? 'A',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            onDetailsPressed: () => Get.to(()=>AdminProfileView()),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.padding24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
                  isDark ? AppColors.primaryGreen : AppColors.primaryGreenDark,
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.margin12),
                Text(
                  authController.currentUser?.fullName ?? 'Admin',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimens.margin4),
                Text(
                  authController.currentUser?.role?.toUpperCase() ?? 'ADMIN',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
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
                  route: '/admin/dashboard',
                ),
                _buildDrawerItem(
                  context,
                  index: 1,
                  icon: Icons.directions_bus_rounded,
                  label: 'Trips',
                  route: '/admin/trips',
                ),
                _buildDrawerItem(
                  context,
                  index: 2,
                  icon: Icons.confirmation_number_rounded,
                  label: 'Bookings',
                  route: '/admin/bookings',
                ),
                _buildDrawerItem(
                  context,
                  index: 3,
                  icon: Icons.people_rounded,
                  label: 'Users',
                  route: '/admin/users',
                ),
                _buildDrawerItem(
                  context,
                  index: 4,
                  icon: Icons.inventory_2_rounded,
                  label: 'Cargo',
                  route: '/admin/cargo',
                ),
                _buildDrawerItem(
                  context,
                  index: 5,
                  icon: Icons.analytics_rounded,
                  label: 'Reports',
                  route: '/admin/reports',
                ),
                _buildDrawerItem(
                  context,
                  index: 6,
                  icon: Icons.payments_rounded,
                  label: 'Payments',
                  route: '/admin/payments',
                ),
                _buildDrawerItem(
                  context,
                  index: 7,
                  icon: Icons.map_rounded,
                  label: 'Routes',
                  route: '/admin/routes',
                ),
                _buildDrawerItem(
                  context,
                  index: 8,
                  icon: Icons.local_shipping_rounded,
                  label: 'Vehicles',
                  route: '/admin/vehicles',
                ),
                _buildDrawerItem(
                  context,
                  index: 9,
                  icon: Icons.notifications_rounded,
                  label: 'Notifications',
                  route: '/admin/notifications',
                ),
                _buildDrawerItem(
                  context,
                  index: 10,
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  route: '/admin/settings',
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
        Navigator.pop(context);
        if (currentIndex != index) {
          Get.offAllNamed(route);
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