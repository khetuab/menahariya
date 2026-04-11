// lib/modules/auth/controllers/login_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/storage/shared_prefs.dart';
import 'package:menahariya/core/utils/validators/auth_validator.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../../core/routes/app_routes.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final AuthController _authController = AuthController.instance;
  final SharedPrefs _sharedPrefs = SharedPrefs();

  // Form controllers
  late final TextEditingController phoneController;
  late final TextEditingController passwordController;

  // Focus nodes
  late final FocusNode phoneFocusNode;
  late final FocusNode passwordFocusNode;

  // Observables
  final _isPasswordVisible = false.obs;
  final _rememberMe = false.obs;
  final _phoneError = Rxn<String>();
  final _passwordError = Rxn<String>();

  // Getters
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get rememberMe => _rememberMe.value;
  String? get phoneError => _phoneError.value;
  String? get passwordError => _passwordError.value;
  bool get isFormValid => _phoneError.value == null && _passwordError.value == null;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadSavedCredentials();
  }

  void _initializeControllers() {
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    phoneFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  Future<void> _loadSavedCredentials() async {
    final savedPhone = await _sharedPrefs.getString('saved_phone');
    final rememberMe = _sharedPrefs.getRememberMe();

    if (rememberMe && savedPhone != null) {
      phoneController.text = savedPhone;
      _rememberMe.value = true;
    }
  }

  // Toggle password visibility
  // In login_controller.dart
  void togglePasswordVisibility() {
    print('🔓 Toggling password visibility from $_isPasswordVisible to ${!_isPasswordVisible.value}');
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  // Toggle remember me
  void toggleRememberMe(bool? value) {
    _rememberMe.value = value ?? false;
  }

  // Validate phone
  void validatePhone(String value) {
    _phoneError.value = AuthValidator.validatePhone(value);
  }

  // Validate password
  void validatePassword(String value) {
    _passwordError.value = AuthValidator.validatePassword(value);
  }

  // Clear validation errors
  void clearErrors() {
    _phoneError.value = null;
    _passwordError.value = null;
  }

  // Handle login
  // In your login method, before sending the request:
  // lib/modules/auth/controllers/login_controller.dart

  // lib/modules/auth/controllers/login_controller.dart

  Future<void> handleLogin() async {
    // Validate all fields
    validatePhone(phoneController.text);
    validatePassword(passwordController.text);

    if (!isFormValid) return;

    // Remove spaces first
    String cleanPhone = phoneController.text.replaceAll(RegExp(r'\s+'), '');

    // CRITICAL FIX: Ensure phone has 10 digits with leading 09
    String formattedPhone = cleanPhone;

    // If it's 9 digits starting with 9, add leading zero
    if (cleanPhone.length == 9 && cleanPhone.startsWith('9')) {
      formattedPhone = '0$cleanPhone';
      print('📞 Converted 9-digit to 10-digit: "$cleanPhone" -> "$formattedPhone"');
    }
    // If it's already 10 digits starting with 09, keep as is
    else if (cleanPhone.length == 10 && cleanPhone.startsWith('09')) {
      formattedPhone = cleanPhone;
    }
    // If it's in international format, convert
    else if (cleanPhone.length == 12 && cleanPhone.startsWith('251')) {
      formattedPhone = '0${cleanPhone.substring(3)}';
      print('📞 Converted international to local: "$cleanPhone" -> "$formattedPhone"');
    }

    print('📞 Final phone format for backend: "$formattedPhone"');

    // Save remember me preference
    await _sharedPrefs.setBool(
      AppConstants.prefKeyRememberMe,
      _rememberMe.value,
    );

    if (_rememberMe.value) {
      await _sharedPrefs.setString('saved_phone', formattedPhone);
    } else {
      await _sharedPrefs.remove('saved_phone');
    }

    // Perform login with formatted phone
    final success = await _authController.login(
      formattedPhone,
      passwordController.text,
    );

    if (success) {
      print('✅ Login successful!');
      if (!_rememberMe.value) {
        phoneController.clear();
      }
      passwordController.clear();
    } else {
      print('❌ Login failed');
    }
  }
  // Navigate to register
  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  // Navigate to forgot password
  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  // Clear focus
  void unfocusFields() {
    phoneFocusNode.unfocus();
    passwordFocusNode.unfocus();
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }
}