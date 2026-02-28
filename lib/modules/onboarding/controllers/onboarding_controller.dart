// lib/modules/onboarding/controllers/onboarding_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/storage/shared_prefs.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  final SharedPrefs _sharedPrefs = SharedPrefs();

  // Page controller
  final PageController pageController = PageController();

  // Observables
  final _currentPage = 0.obs;
  final _isLastPage = false.obs;

  // Getters
  int get currentPage => _currentPage.value;
  bool get isLastPage => _isLastPage.value;

  // Onboarding pages data
  final List<OnboardingPage> pages = const [
    OnboardingPage(
      title: 'Welcome to Menahariya Smart',
      description: 'Your trusted partner for inter-city travel in Ethiopia. Book tickets, track your journey, and travel with ease.',
      image: 'assets/images/onboarding1.png',
      icon: Icons.directions_bus_rounded,
      color: AppColors.primaryGreen,
    ),
    OnboardingPage(
      title: 'Easy Ticket Booking',
      description: 'Search for trips, select your seats, and book tickets instantly. No more waiting in long queues.',
      image: 'assets/images/onboarding2.png',
      icon: Icons.confirmation_number_rounded,
      color: AppColors.primaryYellow,
    ),
    OnboardingPage(
      title: 'Track Your Cargo',
      description: 'Send and receive cargo with real-time tracking. Know exactly where your package is at all times.',
      image: 'assets/images/onboarding3.png',
      icon: Icons.inventory_2_rounded,
      color: AppColors.primaryRed,
    ),
  ];

  // Update current page when swiped
  void onPageChanged(int index) {
    _currentPage.value = index;
    _isLastPage.value = index == pages.length - 1;
  }

  // Go to next page
  void nextPage() {
    if (_currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  // Skip onboarding
  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }

  // Complete onboarding and navigate to appropriate screen
  Future<void> completeOnboarding() async {
    // Save that user has seen onboarding
    await _sharedPrefs.setBool(AppConstants.prefKeyOnboardingSeen, true);

    // Navigate based on auth status
    final authController = Get.find<AuthController>();

    if (authController.isAuthenticated) {
      switch (authController.userRole) {
        case AppConstants.rolePassenger:
          Get.offAllNamed(AppRoutes.passengerDashboard);
          break;
        case AppConstants.roleDriver:
          Get.offAllNamed(AppRoutes.driverDashboard);
          break;
        default:
          Get.offAllNamed(AppRoutes.passengerDashboard);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

// Onboarding Page Model
class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final IconData icon;
  final Color color;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
    required this.color,
  });
}