// lib/modules/common/views/under_construction_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';

class UnderConstructionView extends StatelessWidget {
  final String? featureName;
  final String? message;
  final DateTime? estimatedRelease;
  final VoidCallback? onBack;
  final VoidCallback? onNotify;

  const UnderConstructionView({
    Key? key,
    this.featureName,
    this.message,
    this.estimatedRelease,
    this.onBack,
    this.onNotify,
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
              // Construction illustration
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.warning.withOpacity(0.2) : AppColors.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.construction_rounded,
                        size: 80,
                        color: isDark ? AppColors.warningLight : AppColors.warning,
                      ),
                      const SizedBox(height: AppDimens.margin8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.padding12,
                          vertical: AppDimens.padding4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.warningLight : AppColors.warning,
                          borderRadius: BorderRadius.circular(AppDimens.radius20),
                        ),
                        child: Text(
                          'In Progress',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: AppFonts.medium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppDimens.margin40),

              // Title
              Text(
                featureName != null
                    ? '$featureName is Under Construction'
                    : 'Under Construction',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppFonts.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimens.margin16),

              // Message
              Text(
                message ?? 'We are working hard to bring this feature to you soon.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              if (estimatedRelease != null) ...[
                const SizedBox(height: AppDimens.margin24),
                Container(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey50,
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: AppDimens.iconSize16,
                        color: isDark ? AppColors.warningLight : AppColors.warning,
                      ),
                      const SizedBox(width: AppDimens.margin8),
                      Text(
                        'Expected release: ${estimatedRelease!.day}/${estimatedRelease!.month}/${estimatedRelease!.year}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: AppFonts.medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppDimens.margin40),

              // Action buttons
              Row(
                children: [
                  if (onBack != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onBack,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
                        ),
                        child: const Text('Go Back'),
                      ),
                    ),
                  if (onBack != null && onNotify != null)
                    const SizedBox(width: AppDimens.margin12),
                  if (onNotify != null)
                    Expanded(
                      child: PrimaryButton(
                        text: 'Notify Me',
                        onPressed: onNotify!,
                        icon: Icons.notifications_rounded,
                      ),
                    ),
                ],
              ),

              if (onBack == null && onNotify == null) ...[
                PrimaryButton(
                  text: 'Back to Home',
                  onPressed: () => Get.offAllNamed('/'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Feature Coming Soon Card
class ComingSoonCard extends StatelessWidget {
  final String featureName;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  const ComingSoonCard({
    Key? key,
    required this.featureName,
    required this.description,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap ?? () => Get.toNamed('/under-construction', arguments: {'feature': featureName}),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.padding12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.warning.withOpacity(0.2) : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                ),
                child: Icon(
                  icon,
                  color: isDark ? AppColors.warningLight : AppColors.warning,
                  size: AppDimens.iconSize32,
                ),
              ),
              const SizedBox(width: AppDimens.margin16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      featureName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                    const SizedBox(height: AppDimens.margin4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding8,
                  vertical: AppDimens.padding4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.warning.withOpacity(0.2) : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radius20),
                ),
                child: Text(
                  'Coming Soon',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.warningLight : AppColors.warning,
                    fontWeight: AppFonts.medium,
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