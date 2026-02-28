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
  void togglePasswordVisibility() {
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
  Future<void> handleLogin() async {
    // Validate all fields
    validatePhone(phoneController.text);
    validatePassword(passwordController.text);

    if (!isFormValid) return;

    // Save remember me preference
    await _sharedPrefs.setBool(
      AppConstants.prefKeyRememberMe,
      _rememberMe.value,
    );

    if (_rememberMe.value) {
      await _sharedPrefs.setString('saved_phone', phoneController.text);
    } else {
      await _sharedPrefs.remove('saved_phone');
    }

    // Perform login
    final success = await _authController.login(
      phoneController.text,
      passwordController.text,
    );

    if (success) {
      // Clear form
      if (!_rememberMe.value) {
        phoneController.clear();
      }
      passwordController.clear();
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