// lib/modules/auth/controllers/forgot_password_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/utils/validators/auth_validator.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../../core/routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  static ForgotPasswordController get instance => Get.find();

  final AuthController _authController = AuthController.instance;

  // Controllers
  late final TextEditingController phoneController;

  // Focus nodes
  late final FocusNode phoneFocusNode;

  // Observables
  final _isLoading = false.obs;
  final _phoneError = Rxn<String>();

  // Getters
  bool get isLoading => _isLoading.value;
  String? get phoneError => _phoneError.value;
  bool get isFormValid => _phoneError.value == null && phoneController.text.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    phoneController = TextEditingController();
    phoneFocusNode = FocusNode();
  }

  // Validate phone
  void validatePhone(String value) {
    _phoneError.value = AuthValidator.validatePhone(value);
  }

  // Clear error
  void clearError() {
    _phoneError.value = null;
  }

  // Handle submit
  Future<void> handleSubmit() async {
    validatePhone(phoneController.text);

    if (!isFormValid) return;

    _isLoading.value = true;

    final success = await _authController.forgotPassword(phoneController.text);

    _isLoading.value = false;

    if (success) {
      // Navigate to reset password screen
      Get.toNamed(
        AppRoutes.resetPassword,
        arguments: {'phone': phoneController.text},
      );
    }
  }

  // Navigate back to login
  void goToLogin() {
    Get.offNamed(AppRoutes.login);
  }

  // Clear focus
  void unfocusFields() {
    phoneFocusNode.unfocus();
  }

  @override
  void onClose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    super.onClose();
  }
}