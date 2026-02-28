// lib/modules/driver/widgets/driver_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';

class DriverBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int notificationCount;

  const DriverBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : AppColors.grey200.withOpacity(0.5),
            blurRadius: AppDimens.shadowBlurMedium,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: AppFonts.medium,
        ),
        unselectedLabelStyle: theme.textTheme.bodySmall,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.route_rounded),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.qr_code_scanner_rounded),
                if (notificationCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        notificationCount > 9 ? '9+' : '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Scan',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Boarding',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Alternative compact version for tablets
class DriverBottomNavCompact extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int notificationCount;

  const DriverBottomNavCompact({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radius20),
          topRight: Radius.circular(AppDimens.radius20),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : AppColors.grey200.withOpacity(0.5),
            blurRadius: AppDimens.shadowBlurMedium,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard_rounded, 'Home', 0,context),
          _buildNavItem(Icons.route_rounded, 'Trips', 1,context),
          _buildNavItemWithBadge(Icons.qr_code_scanner_rounded, 'Scan', 2,context),
          _buildNavItem(Icons.assignment_rounded, 'Board', 3,context),
          _buildNavItem(Icons.person_rounded, 'Profile', 4,context),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,BuildContext context) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding12,
          vertical: AppDimens.padding4,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radius20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                fontWeight: isSelected ? AppFonts.medium : AppFonts.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(IconData icon, String label, int index,BuildContext context) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding12,
          vertical: AppDimens.padding4,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radius20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
                if (notificationCount > 0 && index == 2)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        notificationCount > 9 ? '9+' : '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                fontWeight: isSelected ? AppFonts.medium : AppFonts.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}