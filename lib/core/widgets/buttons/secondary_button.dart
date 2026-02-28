// lib/core/widgets/buttons/secondary_button.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final bool isFullWidth;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets? padding;

  const SecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = AppDimens.buttonHeightLarge,
    this.textColor,
    this.borderColor,
    this.icon,
    this.isFullWidth = true,
    this.borderRadius = AppDimens.radius8,
    this.fontSize = AppDimens.fontSize16,
    this.fontWeight = AppFonts.medium,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultTextColor = isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen;

    return SizedBox(
      width: isFullWidth ? (width ?? double.infinity) : width,
      height: height,
      child: OutlinedButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? defaultTextColor,
          side: BorderSide(
            color: borderColor ?? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
            width: 1.5,
          ),
          disabledForegroundColor: (textColor ?? defaultTextColor)
              .withOpacity(AppDimens.opacityMedium),
          padding: padding ?? EdgeInsets.symmetric(
            horizontal: AppDimens.padding24,
            vertical: AppDimens.padding12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppDimens.iconSize20,
            height: AppDimens.iconSize20,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: AppDimens.margin12),
          Text('Processing...'),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppDimens.iconSize20),
          const SizedBox(width: AppDimens.margin8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}