// lib/modules/admin/widgets/admin_empty_state.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_fonts.dart';

class AdminEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const AdminEmptyState({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    this.onAction,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
            ),
            const SizedBox(height: AppDimens.margin16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.margin8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: AppDimens.margin24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}