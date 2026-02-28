// lib/modules/common/views/server_error_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';

class ServerErrorView extends StatelessWidget {
  final String? errorCode;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onContactSupport;

  const ServerErrorView({
    Key? key,
    this.errorCode,
    this.errorMessage,
    this.onRetry,
    this.onContactSupport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error illustration
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.error.withOpacity(0.2) : AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 80,
                        color: isDark ? AppColors.errorLight : AppColors.error,
                      ),
                      const SizedBox(height: AppDimens.margin8),
                      Text(
                        errorCode ?? '500',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: isDark ? AppColors.errorLight : AppColors.error,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppDimens.margin40),

              // Title
              Text(
                'Server Error',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppFonts.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimens.margin16),

              // Message
              Text(
                errorMessage ?? 'An error occurred on our servers. Please try again later.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimens.margin40),

              // Action buttons
              if (onRetry != null)
                PrimaryButton(
                  text: 'Try Again',
                  onPressed: onRetry!,
                  icon: Icons.refresh_rounded,
                ),

              if (onRetry != null && onContactSupport != null)
                const SizedBox(height: AppDimens.margin12),

              if (onContactSupport != null)
                SecondaryButton(
                  text: 'Contact Support',
                  onPressed: onContactSupport!,
                  icon: Icons.support_agent_rounded,
                ),

              const SizedBox(height: AppDimens.margin16),

              // Back to home button
              TextButton(
                onPressed: () => Get.offAllNamed('/'),
                child: Text(
                  'Back to Home',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Server Maintenance View
class ServerMaintenanceView extends StatelessWidget {
  final DateTime? estimatedCompletion;
  final VoidCallback? onRefresh;

  const ServerMaintenanceView({
    Key? key,
    this.estimatedCompletion,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.build_rounded,
                size: 100,
                color: isDark ? AppColors.warningLight : AppColors.warning,
              ),

              const SizedBox(height: AppDimens.margin24),

              Text(
                'Under Maintenance',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppFonts.bold,
                ),
              ),

              const SizedBox(height: AppDimens.margin16),

              Text(
                'We are currently performing scheduled maintenance to improve our service.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              if (estimatedCompletion != null) ...[
                const SizedBox(height: AppDimens.margin24),
                Container(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey50,
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Estimated completion',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppDimens.margin4),
                      Text(
                        '${estimatedCompletion!.day}/${estimatedCompletion!.month}/${estimatedCompletion!.year} at ${estimatedCompletion!.hour}:${estimatedCompletion!.minute}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppFonts.semiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppDimens.margin40),

              if (onRefresh != null)
                PrimaryButton(
                  text: 'Check Again',
                  onPressed: onRefresh!,
                  icon: Icons.refresh_rounded,
                ),
            ],
          ),
        ),
      ),
    );
  }
}