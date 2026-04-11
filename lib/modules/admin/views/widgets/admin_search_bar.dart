// lib/modules/admin/widgets/admin_search_bar.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';

class AdminSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String hintText;
  final VoidCallback? onFilterTap;
  final VoidCallback? onRefreshTap;

  const AdminSearchBar({
    Key? key,
    this.controller,
    this.onChanged,
    this.hintText = 'Search...',
    this.onFilterTap,
    this.onRefreshTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding16,
                  vertical: AppDimens.padding12,
                ),
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            const SizedBox(width: AppDimens.margin8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : AppColors.grey100,
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list_rounded, size: 20),
                onPressed: onFilterTap,
                tooltip: 'Filter',
              ),
            ),
          ],
          if (onRefreshTap != null) ...[
            const SizedBox(width: AppDimens.margin8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : AppColors.grey100,
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: onRefreshTap,
                tooltip: 'Refresh',
              ),
            ),
          ],
        ],
      ),
    );
  }
}