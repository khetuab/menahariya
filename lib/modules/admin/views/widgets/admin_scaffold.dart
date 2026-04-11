// lib/modules/admin/widgets/admin_scaffold.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import 'admin_sidebar.dart';

class AdminScaffold extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final int currentIndex;
  final bool showBackButton;

  const AdminScaffold({
    Key? key,
    required this.child,
    required this.title,
    this.actions,
    required this.currentIndex,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: showBackButton
            ? IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        )
            : null,
        actions: actions,
      ),
      drawer: const AdminDrawer(currentIndex: 0), // Will be overridden by each view
      body: child,
    );
  }
}