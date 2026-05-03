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

  // Format phone number helper
  String _formatPhoneForBackend(String phone) {
    // Remove all spaces and non-digits
    String digits = phone.replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r'\D'), '');

    print('📞 Original phone input: "$phone", digits: "$digits"');

    // Format for backend (expects 10 digits starting with 09)
    if (digits.length == 9 && digits.startsWith('9')) {
      // 912345678 -> 0912345678
      return '0$digits';
    } else if (digits.length == 10 && digits.startsWith('09')) {
      // 0912345678 -> keep as is
      return digits;
    } else if (digits.length == 12 && digits.startsWith('251')) {
      // 251912345678 -> convert to 09 format
      return '0${digits.substring(3)}';
    } else if (digits.length == 13 && digits.startsWith('251')) {
      // +251912345678 (digits only) -> convert to 09 format
      return '0${digits.substring(3)}';
    }

    // Default: return as is
    return digits;
  }

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
    // Remove spaces for validation
    final cleanValue = value.replaceAll(RegExp(r'\s+'), '');
    _phoneError.value = AuthValidator.validatePhone(cleanValue);
  }

  // Clear error
  void clearError() {
    _phoneError.value = null;
  }

  // Handle submit
  Future<void> handleSubmit() async {
    // Validate the phone (using clean version)
    validatePhone(phoneController.text);

    if (!isFormValid) return;

    _isLoading.value = true;

    // Format phone number properly
    final formattedPhone = _formatPhoneForBackend(phoneController.text);
    print('📞 Formatted phone for backend: "$formattedPhone"');

    final success = await _authController.forgotPassword(formattedPhone);

    _isLoading.value = false;

    if (success) {
      // Navigate to reset password screen
      Get.toNamed(
        AppRoutes.resetPassword,
        arguments: {'phone': formattedPhone},
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