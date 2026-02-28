// lib/core/widgets/app_bars/auth_app_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/icon_button_widget.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? image;
  final Color? backgroundColor;

  const AuthAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.image,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(180);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
            isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimens.radius30),
          bottomRight: Radius.circular(AppDimens.radius30),
        ),
      ),
      child: Stack(
        children: [
          // Decorative Pattern
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // Back Button
          if (showBackButton)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: IconButtonWidget(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: onBackPressed ?? () => Get.back(),
                backgroundColor: Colors.white.withOpacity(0.2),
                iconColor: Colors.white,
              ),
            ),

          // Logo/Image
          if (image != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: AppDimens.shadowBlurMedium,
                        spreadRadius: AppDimens.shadowSpreadNone,
                      ),
                    ],
                  ),
                  child: image,
                ),
              ),
            ),

          // Title and Subtitle
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: AppFonts.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppDimens.margin4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;

  const OnboardingAppBar({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: currentPage > 0
          ? BackButtonWidget(
        onPressed: () => Get.back(),
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      )
          : null,
      actions: [
        TextButton(
          onPressed: onSkip,
          child: Text(
            currentPage == totalPages - 1 ? 'Done' : 'Skip',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              fontWeight: AppFonts.medium,
            ),
          ),
        ),
      ],
    );
  }
}