// lib/modules/admin/widgets/admin_confirmation_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/buttons/secondary_button.dart';

class AdminConfirmationDialog {
  static Future<bool> show({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = Colors.red,
  }) async {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius16),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.padding24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: confirmColor,
              ),
              const SizedBox(height: AppDimens.margin16),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppFonts.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.margin12),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.margin24),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: cancelText,
                      onPressed: () => Get.back(result: false),
                    ),
                  ),
                  const SizedBox(width: AppDimens.margin12),
                  Expanded(
                    child: PrimaryButton(
                      text: confirmText,
                      onPressed: () => Get.back(result: true),
                      backgroundColor: confirmColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? false;
  }
}