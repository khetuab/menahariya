// lib/core/widgets/dialogs/message_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';

class MessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? iconColor;
  final Widget? content;
  final bool autoClose;

  const MessageDialog({
    Key? key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
    this.icon,
    this.iconColor,
    this.content,
    this.autoClose = true,
  }) : super(key: key);

  static void showSuccess({
    required String message,
    String title = 'Success',
    VoidCallback? onPressed,
  }) {
    Get.dialog(
      MessageDialog(
        title: title,
        message: message,
        icon: Icons.check_circle_rounded,
        iconColor: AppColors.success,
        onPressed: onPressed,
      ),
    );
  }

  static void showError({
    required String message,
    String title = 'Error',
    VoidCallback? onPressed,
  }) {
    Get.dialog(
      MessageDialog(
        title: title,
        message: message,
        icon: Icons.error_rounded,
        iconColor: AppColors.error,
        onPressed: onPressed,
      ),
    );
  }

  static void showInfo({
    required String message,
    String title = 'Information',
    VoidCallback? onPressed,
  }) {
    Get.dialog(
      MessageDialog(
        title: title,
        message: message,
        icon: Icons.info_rounded,
        iconColor: AppColors.info,
        onPressed: onPressed,
      ),
    );
  }

  static void showWarning({
    required String message,
    String title = 'Warning',
    VoidCallback? onPressed,
  }) {
    Get.dialog(
      MessageDialog(
        title: title,
        message: message,
        icon: Icons.warning_rounded,
        iconColor: AppColors.warning,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      elevation: AppDimens.elevation8,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius20),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.padding24),
        constraints: BoxConstraints(
          maxWidth: AppDimens.dialogMaxWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(AppDimens.padding16),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primaryGreen).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppDimens.iconSize48,
                  color: iconColor ?? AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: AppDimens.margin16),
            ],

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.margin8),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            // Custom Content
            if (content != null) ...[
              const SizedBox(height: AppDimens.margin16),
              content!,
            ],

            const SizedBox(height: AppDimens.margin24),

            // Button
            PrimaryButton(
              text: buttonText,
              onPressed: () {
                onPressed?.call();
                if (autoClose) Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}