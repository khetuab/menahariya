// lib/modules/auth/controllers/otp_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/utils/validators/auth_validator.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../../core/routes/app_routes.dart';

class OtpController extends GetxController {
  static OtpController get instance => Get.find();

  final AuthController _authController = AuthController.instance;

  // Arguments
  late final String phone;
  late final String? userId;

  // Controllers
  late final List<TextEditingController> otpControllers;
  late final List<FocusNode> otpFocusNodes;

  // Observables
  final _otpCode = ''.obs;
  final _timerSeconds = 60.obs;
  final _canResend = false.obs;
  final _isVerifying = false.obs;
  Timer? _timer;

  // Getters
  String get otpCode => _otpCode.value;
  int get timerSeconds => _timerSeconds.value;
  bool get canResend => _canResend.value;
  bool get isVerifying => _isVerifying.value;
  bool get isOtpComplete => _otpCode.value.length == AppConstants.otpLength;

  @override
  void onInit() {
    super.onInit();
    _getArguments();
    _initializeControllers();
    _startTimer();
  }

  void _getArguments() {
    final args = Get.arguments;
    if (args != null) {
      phone = args['phone'] ?? '';
      userId = args['userId'];
    } else {
      phone = '';
      userId = null;
    }
  }

  void _initializeControllers() {
    otpControllers = List.generate(
      AppConstants.otpLength,
          (index) => TextEditingController(),
    );
    otpFocusNodes = List.generate(
      AppConstants.otpLength,
          (index) => FocusNode(),
    );

    // Add listeners
    for (int i = 0; i < AppConstants.otpLength; i++) {
      otpControllers[i].addListener(() => _onOtpChanged(i));
    }
  }

  void _onOtpChanged(int index) {
    final value = otpControllers[index].text;

    // Auto advance to next field
    if (value.isNotEmpty && index < AppConstants.otpLength - 1) {
      otpFocusNodes[index + 1].requestFocus();
    }

    // Update combined OTP
    _updateOtpCode();
  }

  void _updateOtpCode() {
    String code = '';
    for (var controller in otpControllers) {
      code += controller.text;
    }
    _otpCode.value = code;
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

  // Handle paste
  void handlePaste(String pastedText) {
    final digits = pastedText.replaceAll(RegExp(r'\D'), '');
    if (digits.length == AppConstants.otpLength) {
      for (int i = 0; i < AppConstants.otpLength; i++) {
        otpControllers[i].text = digits[i];
      }
      otpFocusNodes.last.unfocus();
    }
  }

  // Handle backspace
  void handleBackspace(int index) {
    if (index > 0 && otpControllers[index].text.isEmpty) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  // Verify OTP
  Future<void> verifyOtp() async {
    if (!isOtpComplete) return;

    _isVerifying.value = true;

    final success = await _authController.verifyOTP(
      phone,
      _otpCode.value,
      userId: userId,
    );

    _isVerifying.value = false;

    if (!success) {
      // Clear OTP fields on error
      clearOtpFields();
    }
  }

  // Resend OTP
  Future<void> resendOtp() async {
    if (!_canResend.value) return;

    final success = await _authController.resendOTP(phone);

    if (success) {
      clearOtpFields();
      _startTimer();

      Get.snackbar(
        'Success',
        'OTP resent successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Clear OTP fields
  void clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    otpFocusNodes.first.requestFocus();
    _updateOtpCode();
  }

  // Change phone number
  void changePhoneNumber() {
    _timer?.cancel();
    Get.offNamed(AppRoutes.register);
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}