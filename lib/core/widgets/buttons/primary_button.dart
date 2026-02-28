// lib/core/widgets/buttons/primary_button.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final bool isFullWidth;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets? padding;
  final bool hasShadow;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = AppDimens.buttonHeightLarge,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.isFullWidth = true,
    this.borderRadius = AppDimens.radius8,
    this.fontSize = AppDimens.fontSize16,
    this.fontWeight = AppFonts.semiBold,
    this.padding,
    this.hasShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: isFullWidth ? (width ?? double.infinity) : width,
      height: height,
      child: ElevatedButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ??
              (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
          foregroundColor: textColor ?? AppColors.white,
          disabledBackgroundColor: (backgroundColor ?? AppColors.primaryGreen)
              .withOpacity(AppDimens.opacityMedium),
          disabledForegroundColor: AppColors.white.withOpacity(AppDimens.opacityMedium),
          elevation: hasShadow ? AppDimens.elevation2 : AppDimens.elevation0,
          shadowColor: AppColors.primaryGreen.withOpacity(AppDimens.opacityLow),
          padding: padding ?? EdgeInsets.symmetric(
            horizontal: AppDimens.padding24,
            vertical: AppDimens.padding12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null ? BorderSide(color: borderColor!) : BorderSide.none,
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ),
          const SizedBox(width: AppDimens.margin12),
          Text(
            'Processing...',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
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
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}