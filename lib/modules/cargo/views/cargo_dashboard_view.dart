// lib/modules/cargo/views/cargo_dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

class CargoDashboardView extends StatelessWidget {
  const CargoDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authController = AuthController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargo Dashboard'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => authController.logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(  // Wrap with SingleChildScrollView to prevent overflow
        padding: const EdgeInsets.all(AppDimens.padding16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.all(AppDimens.padding16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryOrange, Colors.orange.shade300],
                ),
                borderRadius: BorderRadius.circular(AppDimens.radius12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome,',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  Text(
                    authController.currentUser?.fullName ?? 'Staff',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimens.margin8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Cargo Staff',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.margin24),

            // Quick Actions Grid
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppFonts.semiBold),
            ),
            const SizedBox(height: AppDimens.margin12),

            // Fixed GridView with proper constraints
            SizedBox(
              height: 280, // Fixed height for the grid
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppDimens.margin12,
                mainAxisSpacing: AppDimens.margin12,
                childAspectRatio: 1.2,
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.inventory_2_rounded,
                    title: 'View Cargo',
                    color: Colors.teal,
                    onTap: () => Get.toNamed('/staff/cargo/list'),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.update_rounded,
                    title: 'Update Status',
                    color: Colors.orange,
                    onTap: () => Get.toNamed('/staff/cargo/update'),
                  ),
                  // _buildActionCard(
                  //   context,
                  //   icon: Icons.receipt_rounded,
                  //   title: 'Generate Receipt',
                  //   color: Colors.blue,
                  //   onTap: () => Get.toNamed('/staff/cargo/receipt'),
                  // ),
                  // _buildActionCard(
                  //   context,
                  //   icon: Icons.support_agent_rounded,
                  //   title: 'Support',
                  //   color: Colors.purple,
                  //   onTap: () => Get.toNamed('/staff/support'),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: AppDimens.margin8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: AppFonts.medium),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}