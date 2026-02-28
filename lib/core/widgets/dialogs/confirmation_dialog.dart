// lib/core/widgets/dialogs/confirmation_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final IconData? icon;
  final Color? iconColor;
  final Widget? content;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
    this.iconColor,
    this.content,
  }) : super(key: key);

  static Future<bool?> show({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
    Color? iconColor,
  }) {
    return Get.dialog<bool>(
      ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        icon: icon,
        iconColor: iconColor,
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
            // Icon (if provided)
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(AppDimens.padding16),
                decoration: BoxDecoration(
                  color: (iconColor ?? (isDestructive ? AppColors.error : AppColors.primaryGreen))
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppDimens.iconSize40,
                  color: iconColor ?? (isDestructive ? AppColors.error : AppColors.primaryGreen),
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

            // Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: cancelText,
                    onPressed: () {
                      onCancel?.call();
                      Get.back(result: false);
                    },
                  ),
                ),
                const SizedBox(width: AppDimens.margin12),
                Expanded(
                  child: PrimaryButton(
                    text: confirmText,
                    onPressed: () {
                      onConfirm?.call();
                      Get.back(result: true);
                    },
                    backgroundColor: isDestructive ? AppColors.error : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Specialized confirmation dialogs
class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );
  }
}

class CancelBookingDialog extends StatelessWidget {
  const CancelBookingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Cancel Booking',
      message: 'Are you sure you want to cancel this booking? This action cannot be undone.',
      confirmText: 'Cancel Booking',
      isDestructive: true,
      icon: Icons.cancel_rounded,
    );
  }
}