// lib/modules/onboarding/views/onboarding_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/modules/onboarding/controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient with Ethiopian flag colors
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGreen,
                  AppColors.primaryYellow,
                  AppColors.primaryRed,
                ],
                stops: const [0.1, 0.5, 0.9],
              ),
            ),
            child: Container(
              color: isDark
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.9),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: controller.skipOnboarding,
                        child: Text(
                          'Skip',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.primaryYellow
                                : AppColors.primaryGreen,
                            fontWeight: AppFonts.medium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PageView - Takes remaining space
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    itemCount: controller.pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(context, controller.pages[index]);
                    },
                  ),
                ),

                // Bottom section - Fixed height
                Container(
                  padding: const EdgeInsets.all(AppDimens.padding24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.pages.length,
                              (index) => Obx(
                                () => _buildDotIndicator(
                              index,
                              controller.currentPage == index,
                              isDark,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimens.margin24),

                      // Next/Get Started button
                      Obx(
                            () => PrimaryButton(
                          text: controller.isLastPage ? 'Get Started' : 'Next',
                          onPressed: controller.nextPage,
                          icon: controller.isLastPage
                              ? Icons.check_circle_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingPage page) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon container
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: page.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: page.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: page.color.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      page.icon,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppDimens.margin40),

          // Title
          Text(
            page.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.bold,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimens.margin16),

          // Description
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? Colors.white.withOpacity(0.8)
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index, bool isSelected, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isSelected ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppColors.primaryYellow : AppColors.primaryGreen)
            : (isDark ? Colors.white30 : Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}