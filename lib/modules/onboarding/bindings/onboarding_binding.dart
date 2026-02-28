// lib/modules/onboarding/bindings/onboarding_binding.dart

import 'package:get/get.dart';
import 'package:menahariya/modules/onboarding/controllers/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}