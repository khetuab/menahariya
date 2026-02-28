// lib/core/widgets/app_bars/main_app_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/icon_button_widget.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;
  final PreferredSizeWidget? bottom;
  final bool showNotificationBadge;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const MainAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.onBackPressed,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.titleColor,
    this.elevation = AppDimens.elevation2,
    this.bottom,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultBgColor = backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.white);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: titleColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          fontWeight: AppFonts.semiBold,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: defaultBgColor,
      elevation: elevation,
      leading: showBackButton
          ? (leading ??
          BackButtonWidget(
            onPressed: onBackPressed ?? () => Get.back(),
            color: titleColor,
          ))
          : leading,
      actions: [
        ...?actions,
        if (showNotificationBadge)
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButtonWidget(
                icon: Icons.notifications_rounded,
                onPressed: onNotificationTap ?? () => Get.toNamed('/notifications'),
                backgroundColor: Colors.transparent,
                iconColor: titleColor,
              ),
              if (notificationCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: defaultBgColor,
                        width: 2,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        notificationCount > 9 ? '9+' : '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
      bottom: bottom,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              defaultBgColor,
              defaultBgColor.withOpacity(0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String hintText;
  final ValueChanged<String> onSearch;
  final VoidCallback? onFilter;
  final VoidCallback? onBack;
  final TextEditingController? controller;

  const SearchAppBar({
    Key? key,
    required this.hintText,
    required this.onSearch,
    this.onFilter,
    this.onBack,
    this.controller,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 80);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      elevation: 0,
      leading: BackButtonWidget(onPressed: onBack ?? () => Get.back()),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(right: AppDimens.padding16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where to?',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            Text(
              'Search Destination',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey50,
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: hintText,
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.padding16,
                      ),
                    ),
                    onSubmitted: onSearch,
                  ),
                ),
              ),
              if (onFilter != null) ...[
                const SizedBox(width: AppDimens.margin12),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                    onPressed: onFilter,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}