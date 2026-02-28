// lib/modules/auth/controllers/register_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/utils/validators/auth_validator.dart';
import 'package:menahariya/core/utils/helpers/string_helper.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';
import 'package:menahariya/data/models/user/register_request.dart';

import '../../../core/routes/app_routes.dart';

class RegisterController extends GetxController {
  static RegisterController get instance => Get.find();

  final AuthController _authController = AuthController.instance;

  // Form controllers
  late final TextEditingController fullNameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  // Focus nodes
  late final FocusNode fullNameFocusNode;
  late final FocusNode phoneFocusNode;
  late final FocusNode emailFocusNode;
  late final FocusNode passwordFocusNode;
  late final FocusNode confirmPasswordFocusNode;

  // Observables
  final _isPasswordVisible = false.obs;
  final _isConfirmPasswordVisible = false.obs;
  final _agreeToTerms = false.obs;

  // Error observables
  final _fullNameError = Rxn<String>();
  final _phoneError = Rxn<String>();
  final _emailError = Rxn<String>();
  final _passwordError = Rxn<String>();
  final _confirmPasswordError = Rxn<String>();
  final _termsError = Rxn<String>();

  // Password strength
  final _passwordStrength = 0.0.obs;

  // Getters
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible.value;
  bool get agreeToTerms => _agreeToTerms.value;
  String? get fullNameError => _fullNameError.value;
  String? get phoneError => _phoneError.value;
  String? get emailError => _emailError.value;
  String? get passwordError => _passwordError.value;
  String? get confirmPasswordError => _confirmPasswordError.value;
  String? get termsError => _termsError.value;
  double get passwordStrength => _passwordStrength.value;

  // bool get isFormValid {
  //   return _fullNameError.value == null &&
  //       _phoneError.value == null &&
  //       _emailError.value == null &&
  //       _passwordError.value == null &&
  //       _confirmPasswordError.value == null &&
  //       _termsError.value == null &&
  //       fullNameController.text.isNotEmpty &&
  //       phoneController.text.isNotEmpty &&
  //       passwordController.text.isNotEmpty &&
  //       confirmPasswordController.text.isNotEmpty &&
  //       _agreeToTerms.value;
  // }

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _setupPasswordListener();
  }

  void _initializeControllers() {
    fullNameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    fullNameFocusNode = FocusNode();
    phoneFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
  }

  void _setupPasswordListener() {
    passwordController.addListener(_calculatePasswordStrength);
  }

  void _calculatePasswordStrength() {
    final password = passwordController.text;
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

  // Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible.value = !_isConfirmPasswordVisible.value;
  }

  // Toggle terms agreement
  void toggleTermsAgreement(bool? value) {
    _agreeToTerms.value = value ?? false;
    if (_agreeToTerms.value) {
      _termsError.value = null;
    }
  }

  // Validation methods
  void validateFullName(String value) {
    _fullNameError.value = AuthValidator.validateFullName(value);
  }

  // Update validatePhone method
  void validatePhone(String value) {
    // Remove spaces and check
    final cleanValue = value.replaceAll(RegExp(r'\s+'), '');

    if (cleanValue.isEmpty) {
      _phoneError.value = 'Phone number is required';
      return;
    }

    // Handle different input formats
    if (cleanValue.length == 9 && cleanValue.startsWith('9')) {
      // User entered 9 digits without leading zero
      final fullNumber = '0$cleanValue';
      _phoneError.value = AuthValidator.validatePhone(fullNumber);
    } else if (cleanValue.length == 10 && cleanValue.startsWith('09')) {
      // Correct format
      _phoneError.value = AuthValidator.validatePhone(cleanValue);
    } else if (cleanValue.length == 12 && cleanValue.startsWith('251')) {
      // International format
      _phoneError.value = AuthValidator.validatePhone(cleanValue);
    } else {
      _phoneError.value = 'Please enter a valid Ethiopian phone number (e.g., 0912345678)';
    }

    print('Phone validation: "$cleanValue" -> error: ${_phoneError.value}');
  }

  void validateEmail(String value) {
    _emailError.value = AuthValidator.validateEmail(value);
  }

  void validatePassword(String value) {
    _passwordError.value = AuthValidator.validatePassword(value);
    // Re-validate confirm password
    if (confirmPasswordController.text.isNotEmpty) {
      validateConfirmPassword(confirmPasswordController.text);
    }
  }

  void validateConfirmPassword(String value) {
    _confirmPasswordError.value = AuthValidator.validateConfirmPassword(
      passwordController.text,
      value,
    );
  }

  void validateTerms() {
    if (!_agreeToTerms.value) {
      _termsError.value = 'You must agree to the terms and conditions';
    } else {
      _termsError.value = null;
    }
  }

  // Clear all errors
  void clearErrors() {
    _fullNameError.value = null;
    _phoneError.value = null;
    _emailError.value = null;
    _passwordError.value = null;
    _confirmPasswordError.value = null;
    _termsError.value = null;
  }

  // Add this to your isFormValid getter to see what's happening
  bool get isFormValid {
    print('🔍 Checking form validity:');
    print('  - fullNameError: ${_fullNameError.value}');
    print('  - phoneError: ${_phoneError.value}');
    print('  - emailError: ${_emailError.value}');
    print('  - passwordError: ${_passwordError.value}');
    print('  - confirmPasswordError: ${_confirmPasswordError.value}');
    print('  - termsError: ${_termsError.value}');
    print('  - fullName not empty: ${fullNameController.text.isNotEmpty}');
    print('  - phone not empty: ${phoneController.text.isNotEmpty}');
    print('  - password not empty: ${passwordController.text.isNotEmpty}');
    print('  - confirmPassword not empty: ${confirmPasswordController.text.isNotEmpty}');
    print('  - agreeToTerms: ${_agreeToTerms.value}');

    return _fullNameError.value == null &&
        _phoneError.value == null &&
        _emailError.value == null &&
        _passwordError.value == null &&
        _confirmPasswordError.value == null &&
        _termsError.value == null &&
        fullNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        _agreeToTerms.value;
  }
  // Handle registration
  Future<void> handleRegister() async {
    print('📝 handleRegister called');

    // Validate all fields
    validateFullName(fullNameController.text);
    validatePhone(phoneController.text);
    validateEmail(emailController.text);
    validatePassword(passwordController.text);
    validateConfirmPassword(confirmPasswordController.text);
    validateTerms();

    // Small delay to let validations update
    await Future.delayed(const Duration(milliseconds: 100));

    if (!isFormValid) {
      print('❌ Form is invalid, cannot register');

      // Show error message to user
      Get.snackbar(
        'Validation Error',
        'Please check all fields and try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('✅ Form is valid, proceeding with registration');

    try {
      // Format phone number
      final formattedPhone = StringHelper.formatPhoneNumber(phoneController.text);
      final cleanPhone = formattedPhone.replaceAll(' ', '');

      final request = RegisterRequest(
        fullName: fullNameController.text.trim(),
        phone: cleanPhone,
        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        password: passwordController.text,
      );

      print('📤 Sending registration request: ${request.toJson()}');

      final success = await _authController.register(request);

      if (success) {
        print('✅ Registration successful');
        // Clear sensitive data
        passwordController.clear();
        confirmPasswordController.clear();

        // Show success message
        Get.snackbar(
          'Success',
          'Registration successful! Please verify your phone number.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print('❌ Registration failed');
      }
    } catch (e) {
      print('❌ Registration error: $e');
      Get.snackbar(
        'Error',
        'Registration failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Navigate to login
  void goToLogin() {
    Get.offNamed(AppRoutes.login);
  }

  // Open terms and conditions
  void openTerms() {
    Get.toNamed('/terms');
  }

  // Open privacy policy
  void openPrivacyPolicy() {
    Get.toNamed('/privacy');
  }

  // Clear focus
  void unfocusFields() {
    fullNameFocusNode.unfocus();
    phoneFocusNode.unfocus();
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();
    confirmPasswordFocusNode.unfocus();
  }

  // Get password strength color
  Color getPasswordStrengthColor() {
    if (_passwordStrength.value < 0.3) return Colors.red;
    if (_passwordStrength.value < 0.6) return Colors.orange;
    if (_passwordStrength.value < 0.8) return Colors.yellow;
    return Colors.green;
  }

  // Get password strength text
  String getPasswordStrengthText() {
    if (_passwordStrength.value < 0.3) return 'Weak';
    if (_passwordStrength.value < 0.6) return 'Fair';
    if (_passwordStrength.value < 0.8) return 'Good';
    return 'Strong';
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameFocusNode.dispose();
    phoneFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }
}