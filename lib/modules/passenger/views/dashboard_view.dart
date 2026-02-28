// lib/modules/passenger/views/dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/modules/passenger/controllers/dashboard_controller.dart';
import 'package:menahariya/modules/passenger/views/home/home_view.dart';
import 'package:menahariya/modules/passenger/views/search/search_view.dart';
import 'package:menahariya/modules/passenger/views/tickets/my_tickets_view.dart';
import 'package:menahariya/modules/passenger/views/cargo/cargo_registration_view.dart';
import 'package:menahariya/modules/passenger/views/profile/profile_view.dart';

class PassengerDashboardView extends GetView<PassengerDashboardController> {
  const PassengerDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: Obx(() => IndexedStack(
        index: controller.currentIndex,
        children: const [
          HomeView(),
          PassengerSearchView(),
          MyTicketsView(),
          CargoRegistrationView(),
          ProfileView(),
        ],
      )),
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.transparent : AppColors.grey200.withOpacity(0.5),
              blurRadius: AppDimens.shadowBlurMedium,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: controller.currentIndex,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
            fontWeight: AppFonts.medium,
          ),
          unselectedLabelStyle: theme.textTheme.bodySmall,
          items: List.generate(5, (index) {
            return BottomNavigationBarItem(
              icon: Icon(controller.screenIcons[index]),
              label: controller.screenTitles[index],
            );
          }),
        ),
      )),
    );
  }
}