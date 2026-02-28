// lib/modules/splash/bindings/splash_binding.dart

import 'package:get/get.dart';
import 'package:menahariya/modules/splash/controllers/splash_controller.dart';

import '../../auth/controllers/auth_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load splash controller
    Get.lazyPut<SplashController>(
          () => SplashController(),
      fenix: true,
    );
  }
}

// Alternative: Permanent binding if splash controller needs to persist
class SplashPermanentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(
      SplashController(),
      permanent: true,
    );
  }
}

// Binding with additional dependencies
class SplashWithDependenciesBinding extends Bindings {
  @override
  void dependencies() {
    // Load only essential services needed for splash
    Get.lazyPut<SplashController>(() => SplashController());

    // Preload auth controller for faster navigation
    Get.lazyPut(() => AuthController(), fenix: true);
  }
}