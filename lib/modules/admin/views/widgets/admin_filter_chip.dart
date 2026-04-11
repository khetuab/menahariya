// lib/modules/admin/widgets/admin_filter_chip.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_fonts.dart';

class AdminFilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String? selectedValue;
  final Function(String) onSelected;
  final Color? color;

  const AdminFilterChip({
    Key? key,
    required this.label,
    required this.value,
    this.selectedValue,
    required this.onSelected,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = selectedValue == value;
    final chipColor = color ?? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          fontSize: 13,
          fontWeight: isSelected ? AppFonts.medium : AppFonts.regular,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      backgroundColor: isDark ? AppColors.grey800 : AppColors.grey100,
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius20),
        side: BorderSide(
          color: isSelected ? chipColor : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding12,
        vertical: AppDimens.padding8,
      ),
    );
  }
}