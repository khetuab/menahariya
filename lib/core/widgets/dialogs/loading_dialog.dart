// lib/core/widgets/dialogs/loading_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';

class LoadingDialog {
  static void show({
    String message = 'Loading...',
    bool barrierDismissible = false,
  }) {
    Get.dialog(
      _LoadingDialogContent(message: message),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      useSafeArea: true,
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  static void showProgress({
    required double progress,
    String message = 'Processing...',
    bool barrierDismissible = false,
  }) {
    Get.dialog(
      _ProgressDialogContent(
        message: message,
        progress: progress,
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
    );
  }
}

class _LoadingDialogContent extends StatelessWidget {
  final String message;

  const _LoadingDialogContent({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      elevation: AppDimens.elevation8,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.padding24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Logo or Loader
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    isDark ? AppColors.primaryYellow : AppColors.primaryYellow,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.margin24),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: AppFonts.medium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDialogContent extends StatelessWidget {
  final String message;
  final double progress;

  const _ProgressDialogContent({
    Key? key,
    required this.message,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      elevation: AppDimens.elevation8,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.padding24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: AppFonts.medium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.margin16),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radius8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: isDark ? AppColors.grey700 : AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.margin8),

            // Percentage
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                fontWeight: AppFonts.semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}