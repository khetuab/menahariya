// lib/modules/auth/controllers/reset_password_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/utils/validators/auth_validator.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../../core/routes/app_routes.dart';

class ResetPasswordController extends GetxController {
  static ResetPasswordController get instance => Get.find();

  final AuthController _authController = AuthController.instance;

  // Arguments
  late final String phone;

  // Controllers
  late final TextEditingController otpController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  // Focus nodes
  late final FocusNode otpFocusNode;
  late final FocusNode newPasswordFocusNode;
  late final FocusNode confirmPasswordFocusNode;

  // Observables
  final _isPasswordVisible = false.obs;
  final _isConfirmPasswordVisible = false.obs;
  final _isLoading = false.obs;
  final _timerSeconds = 60.obs;
  final _canResend = false.obs;

  // Error observables
  final _otpError = Rxn<String>();
  final _newPasswordError = Rxn<String>();
  final _confirmPasswordError = Rxn<String>();

  // Password strength
  final _passwordStrength = 0.0.obs;

  // Timer
  Timer? _timer;

  // Getters
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible.value;
  bool get isLoading => _isLoading.value;
  int get timerSeconds => _timerSeconds.value;
  bool get canResend => _canResend.value;

  String? get otpError => _otpError.value;
  String? get newPasswordError => _newPasswordError.value;
  String? get confirmPasswordError => _confirmPasswordError.value;
  double get passwordStrength => _passwordStrength.value;

  bool get isFormValid {
    return _otpError.value == null &&
        _newPasswordError.value == null &&
        _confirmPasswordError.value == null &&
        otpController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        otpController.text.length == AppConstants.otpLength;
  }

  @override
  void onInit() {
    super.onInit();
    _getArguments();
    _initializeControllers();
    _startTimer();
    _setupPasswordListener();
  }

  void _getArguments() {
    final args = Get.arguments;
    phone = args != null ? args['phone'] ?? '' : '';
  }

  void _initializeControllers() {
    otpController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    otpFocusNode = FocusNode();
    newPasswordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
  }

  void _setupPasswordListener() {
    newPasswordController.addListener(_calculatePasswordStrength);
  }

  void _calculatePasswordStrength() {
    final password = newPasswordController.text;
    if (password.isEmpty) {
      _passwordStrength.value = 0.0;
      return;
    }

    double strength = 0.0;

    // Length check
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.15;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;

    // Contains numbers
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;

    // Contains special characters
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.15;

    _passwordStrength.value = strength.clamp(0.0, 1.0);
  }

  void _startTimer() {
    _timerSeconds.value = 60;
    _canResend.value = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds.value > 0) {
        _timerSeconds.value--;
      } else {
        _canResend.value = true;
        timer.cancel();
      }
    });
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible.value = !_isConfirmPasswordVisible.value;
  }

  // Validation methods
  void validateOtp(String value) {
    _otpError.value = AuthValidator.validateOTP(value);
  }

  void validateNewPassword(String value) {
    _newPasswordError.value = AuthValidator.validatePassword(value);
    // Re-validate confirm password
    if (confirmPasswordController.text.isNotEmpty) {
      validateConfirmPassword(confirmPasswordController.text);
    }
  }

  void validateConfirmPassword(String value) {
    _confirmPasswordError.value = AuthValidator.validateConfirmPassword(
      newPasswordController.text,
      value,
    );
  }

  // Clear errors
  void clearErrors() {
    _otpError.value = null;
    _newPasswordError.value = null;
    _confirmPasswordError.value = null;
  }

  // Handle reset password
  Future<void> handleReset() async {
    // Validate all fields
    validateOtp(otpController.text);
    validateNewPassword(newPasswordController.text);
    validateConfirmPassword(confirmPasswordController.text);

    if (!isFormValid) return;

    _isLoading.value = true;

    final success = await _authController.resetPassword(
      phone: phone,
      otp: otpController.text,
      newPassword: newPasswordController.text,
    );

    _isLoading.value = false;

    if (success) {
      // Clear form
      otpController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      // Navigate to login
      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Success',
        'Password reset successfully. Please login with your new password.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Resend OTP
  Future<void> resendOtp() async {
    if (!_canResend.value) return;

    _isLoading.value = true;

    final success = await _authController.forgotPassword(phone);

    _isLoading.value = false;

    if (success) {
      otpController.clear();
      _startTimer();

      Get.snackbar(
        'Success',
        'OTP resent successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get password strength color
  Color getPasswordStrengthColor() {
    if (_passwordStrength.value < 0.3) return Colors.red;
    if (_passwordStrength.value < 0.6) return Colors.orange;
    if (_passwordStrength.value < 0.8) return Colors.yellow.shade700;
    return Colors.green;
  }

  // Get password strength text
  String getPasswordStrengthText() {
    if (_passwordStrength.value < 0.3) return 'Weak';
    if (_passwordStrength.value < 0.6) return 'Fair';
    if (_passwordStrength.value < 0.8) return 'Good';
    return 'Strong';
  }

  // Clear focus
  void unfocusFields() {
    otpFocusNode.unfocus();
    newPasswordFocusNode.unfocus();
    confirmPasswordFocusNode.unfocus();
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    otpFocusNode.dispose();
    newPasswordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }
}