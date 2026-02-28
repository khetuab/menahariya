// lib/modules/common/views/not_found_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';

class NotFoundView extends StatelessWidget {
  final String? message;
  final String? resourceType;
  final VoidCallback? onBack;
  final VoidCallback? onHome;

  const NotFoundView({
    Key? key,
    this.message,
    this.resourceType,
    this.onBack,
    this.onHome,
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
              // 404 illustration
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '404',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                      fontWeight: AppFonts.bold,
                      fontSize: 120,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.padding16,
                        vertical: AppDimens.padding4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight,
                        borderRadius: BorderRadius.circular(AppDimens.radius20),
                      ),
                      child: Text(
                        'Not Found',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: AppFonts.semiBold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimens.margin40),

              // Dynamic message based on resource type
              if (resourceType != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimens.padding12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey50,
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconForResource(resourceType!),
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      ),
                      const SizedBox(width: AppDimens.margin8),
                      Text(
                        resourceType!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: AppFonts.semiBold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.margin16),
              ],

              // Message
              Text(
                message ?? 'The page or resource you are looking for does not exist.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

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
                  if (onBack != null && onHome != null)
                    const SizedBox(width: AppDimens.margin12),
                  if (onHome != null)
                    Expanded(
                      child: PrimaryButton(
                        text: 'Go Home',
                        onPressed: onHome!,
                      ),
                    ),
                ],
              ),

              if (onBack == null && onHome == null) ...[
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

  IconData _getIconForResource(String resourceType) {
    switch (resourceType.toLowerCase()) {
      case 'trip':
      case 'trips':
        return Icons.route_rounded;
      case 'ticket':
      case 'tickets':
        return Icons.confirmation_number_rounded;
      case 'cargo':
        return Icons.inventory_2_rounded;
      case 'user':
      case 'profile':
        return Icons.person_rounded;
      case 'payment':
        return Icons.payment_rounded;
      default:
        return Icons.error_outline_rounded;
    }
  }
}

// Resource Not Found Dialog
class ResourceNotFoundDialog extends StatelessWidget {
  final String resourceType;
  final String? resourceId;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const ResourceNotFoundDialog({
    Key? key,
    required this.resourceType,
    this.resourceId,
    this.onDismiss,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppDimens.margin16),
            Text(
              'Not Found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: AppFonts.bold,
              ),
            ),
            const SizedBox(height: AppDimens.margin8),
            Text(
              resourceId != null
                  ? 'The $resourceType with ID "$resourceId" could not be found.'
                  : 'The requested $resourceType could not be found.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimens.margin24),
            Row(
              children: [
                if (onDismiss != null)
                  Expanded(
                    child: TextButton(
                      onPressed: onDismiss,
                      child: const Text('Dismiss'),
                    ),
                  ),
                if (onRetry != null) ...[
                  if (onDismiss != null) const SizedBox(width: AppDimens.margin8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                      ),
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}