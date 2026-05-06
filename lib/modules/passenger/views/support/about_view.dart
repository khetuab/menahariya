// lib/modules/passenger/views/support/about_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';

class AboutView extends StatelessWidget {
  const AboutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: ListView(
        children: [
          // App Logo & Name
          Container(
            padding: const EdgeInsets.all(AppDimens.padding32),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
                        isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimens.radius20),
                  ),
                  child: const Icon(
                    Icons.directions_bus_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimens.margin16),
                Text(
                  'Menahariya',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: AppFonts.bold,
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: AppDimens.margin4),
                Text(
                  'Version 1.0.0',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const Divider(),

          // Description
          Padding(
            padding: const EdgeInsets.all(AppDimens.padding16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About the App',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin8),
                Text(
                  'Menahariya is Ethiopia\'s premier transport booking platform, connecting passengers with reliable bus services across the country. We make travel planning simple, secure, and convenient.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppDimens.margin16),
                Text(
                  'Features',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin8),
                _buildFeatureItem(context, '🚌 Easy Trip Booking', 'Book bus tickets in seconds'),
                _buildFeatureItem(context, '📦 Cargo Shipping', 'Ship packages safely'),
                _buildFeatureItem(context, '💳 Multiple Payments', 'Telebirr, CBE Birr, Cards'),
                _buildFeatureItem(context, '📍 Real-time Tracking', 'Track your bus and cargo'),
                _buildFeatureItem(context, '🎫 Digital Tickets', 'Paperless boarding passes'),
                _buildFeatureItem(context, '🔔 Smart Notifications', 'Stay updated on your trips'),
              ],
            ),
          ),

          const Divider(),

          // Developer Info
          Padding(
            padding: const EdgeInsets.all(AppDimens.padding16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Developed by',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin8),
                Text(
                  'Menahariya Technology Solutions',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: AppFonts.medium,
                  ),
                ),
                const SizedBox(height: AppDimens.margin4),
                Text(
                  '© 2026 Menahariya. All rights reserved.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const Divider(),

          // Links
          Padding(
            padding: const EdgeInsets.all(AppDimens.padding16),
            child: Column(
              children: [
                _buildLinkButton(context, 'Privacy Policy', () => Get.toNamed('/privacy')),
                const SizedBox(height: AppDimens.margin8),
                _buildLinkButton(context, 'Terms of Service', () => Get.toNamed('/terms')),
                const SizedBox(height: AppDimens.margin8),
                _buildLinkButton(context, 'Rate Us on Play Store', () => _rateApp()),
                const SizedBox(height: AppDimens.margin8),
                _buildLinkButton(context, 'Share App', () => _shareApp()),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.margin16),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String title, String description) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: AppFonts.medium)),
          Text(description, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildLinkButton(BuildContext context, String title, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  void _rateApp() {
    Get.snackbar(
      'Rate Us',
      'Thank you for supporting Menahariya!',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Implement app store rating
  }

  void _shareApp() {
    Clipboard.setData(const ClipboardData(text: 'Download Menahariya app for easy bus booking and cargo shipping!'));
    Get.snackbar(
      'Link Copied',
      'Share Menahariya with your friends!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}