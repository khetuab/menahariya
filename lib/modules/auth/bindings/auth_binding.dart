// lib/modules/auth/bindings/auth_binding.dart

import 'package:get/get.dart';
import 'package:menahariya/modules/auth/controllers/login_controller.dart';
import 'package:menahariya/modules/auth/controllers/register_controller.dart';
import 'package:menahariya/modules/auth/controllers/otp_controller.dart';
import 'package:menahariya/modules/auth/controllers/forgot_password_controller.dart';
import 'package:menahariya/modules/auth/controllers/reset_password_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Auth controller is already initialized in InitialBinding
    // Get.put(AuthController(), permanent: true);

    // Lazy load auth controllers
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<RegisterController>(() => RegisterController(), fenix: true);
    Get.lazyPut<OtpController>(() => OtpController(), fenix: true);
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController(), fenix: true);
    Get.lazyPut<ResetPasswordController>(() => ResetPasswordController(), fenix: true);
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
          () => LoginController(),
      fenix: true, // 🔥 REQUIRED
    );
  }
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(() => OtpController());
  }
}

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
  }
}

class ResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResetPasswordController>(() => ResetPasswordController());
  }
}