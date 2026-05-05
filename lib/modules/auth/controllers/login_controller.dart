// lib/modules/auth/controllers/login_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/core/services/storage/shared_prefs.dart';
import 'package:menahariya/core/utils/permissions/permission_handler.dart';
import 'package:menahariya/core/utils/validators/auth_validator.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../../core/routes/app_routes.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final AuthController _authController = AuthController.instance;
  final SharedPrefs _sharedPrefs = SharedPrefs();
  final SecureStorage _secureStorage = SecureStorage();

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

  // Biometric observables
  final _isBiometricEnabled = false.obs;
  final _isBiometricLoginInProgress = false.obs;

  // Getters
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get rememberMe => _rememberMe.value;
  String? get phoneError => _phoneError.value;
  String? get passwordError => _passwordError.value;
  bool get isFormValid => _phoneError.value == null && _passwordError.value == null;

  // Biometric getters
  bool get isBiometricEnabled => _isBiometricEnabled.value;
  bool get isBiometricLoginInProgress => _isBiometricLoginInProgress.value;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadSavedCredentials();
    _checkBiometricAvailability();
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

    print('🔍 Loading saved credentials - savedPhone: $savedPhone, rememberMe: $rememberMe');

    if (rememberMe && savedPhone != null) {
      phoneController.text = savedPhone;
      _rememberMe.value = true;
      print('✅ Loaded saved phone: $savedPhone');
    }
  }

  // Check if biometric login is available
  Future<void> _checkBiometricAvailability() async {
    try {
      print('🔐 Checking biometric availability on login screen...');

      // Check SharedPrefs for biometric settings
      final biometricEnabled = await _sharedPrefs.getBool('biometric_enabled');
      final savedPhone = await _sharedPrefs.getString('biometric_phone');
      final savedPassword = await _sharedPrefs.getString('biometric_password');

      print('🔐 SharedPrefs - enabled: $biometricEnabled, phone: $savedPhone, hasPassword: ${savedPassword != null}');

      // Also check SecureStorage
      final secureCredentials = await _secureStorage.read('saved_credentials');
      final securePhone = await _secureStorage.read('saved_phone');
      print('🔐 SecureStorage - credentials: ${secureCredentials != null}, phone: $securePhone');

      // Determine if biometric is available
      if (biometricEnabled == true && savedPhone != null && savedPassword != null) {
        _isBiometricEnabled.value = true;
        print('✅ Biometric login AVAILABLE from SharedPrefs');

        // Ensure SecureStorage also has the credentials for the login method
        final credentials = '$savedPhone:$savedPassword';
        await _secureStorage.write('saved_credentials', credentials);
        await _secureStorage.write('saved_phone', savedPhone);
        print('✅ Synced credentials to SecureStorage');
      } else {
        _isBiometricEnabled.value = false;
        print('❌ Biometric login NOT AVAILABLE');
      }
    } catch (e) {
      print('❌ Error checking biometric availability: $e');
      _isBiometricEnabled.value = false;
    }
  }

  // Login with biometrics
  Future<void> loginWithBiometrics() async {
    if (_isBiometricLoginInProgress.value) return;

    try {
      _isBiometricLoginInProgress.value = true;
      print('🔐 Starting biometric login process...');

      // Check if biometrics are available on device
      final isAvailable = await PermissionHandler.checkBiometricSupport();
      print('🔐 Device biometric support: $isAvailable');

      if (!isAvailable) {
        Get.snackbar(
          'Biometric Not Available',
          'Please set up biometrics in your device settings',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get saved credentials from SharedPrefs
      final savedPhone = await _sharedPrefs.getString('biometric_phone');
      final savedPassword = await _sharedPrefs.getString('biometric_password');

      print('🔐 Retrieved from SharedPrefs - phone: $savedPhone, hasPassword: ${savedPassword != null}');

      if (savedPhone == null || savedPassword == null) {
        print('❌ No saved biometric credentials found in SharedPrefs');
        Get.snackbar(
          'No Saved Credentials',
          'Please login with password first',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Authenticate with biometrics
      print('🔐 Requesting biometric authentication...');
      final isAuthenticated = await PermissionHandler.authenticateWithBiometrics(
        reason: 'Verify your identity to login',
        biometricOnly: true,
      );

      print('🔐 Biometric authentication result: $isAuthenticated');

      if (!isAuthenticated) {
        print('❌ Biometric authentication failed or cancelled');
        return;
      }

      // Set phone in controller
      phoneController.text = savedPhone;
      print('📞 Set phone in controller: $savedPhone');

      // Perform login with saved credentials
      print('🔐 Attempting login with biometric credentials...');
      final loginSuccess = await _authController.login(savedPhone, savedPassword, saveCredentials: false);

      print('🔐 Login result: $loginSuccess');

      if (loginSuccess) {
        print('✅ Biometric login successful!');
      } else {
        print('❌ Biometric login failed - invalid credentials');
        Get.snackbar(
          'Login Failed',
          'Please login with password again',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

    } catch (e) {
      print('❌ Biometric login error: $e');
      Get.snackbar(
        'Login Failed',
        'Please try again with password',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isBiometricLoginInProgress.value = false;
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    print('🔓 Toggling password visibility from $_isPasswordVisible to ${!_isPasswordVisible.value}');
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  // Toggle remember me
  void toggleRememberMe(bool? value) {
    _rememberMe.value = value ?? false;
    print('📌 Remember me toggled: ${_rememberMe.value}');
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
    // Clear previous errors FIRST
    clearErrors();

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
      print('✅ Saved phone for remember me: $formattedPhone');
    } else {
      await _sharedPrefs.remove('saved_phone');
      print('✅ Removed saved phone');
    }

    // Perform login with formatted phone
    final success = await _authController.login(
      formattedPhone,
      passwordController.text,
    );

    if (success) {
      print('✅ Login successful!');

      // After successful login, save credentials for biometric if enabled
      final biometricEnabled = await _sharedPrefs.getBool('biometric_enabled');
      if (biometricEnabled == true) {
        await _authController.saveCredentialsForBiometric(formattedPhone, passwordController.text);
        print('✅ Saved credentials for biometric login');
      }

      if (biometricEnabled == true) {
        // Save the actual password for biometric login
        await _sharedPrefs.setString('biometric_phone', formattedPhone);
        await _sharedPrefs.setString('biometric_password', passwordController.text);
        await _authController.saveCredentialsForBiometric(formattedPhone, passwordController.text);
        print('✅ Updated biometric credentials with current password');
      }
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

  void _dismissKeyboard() {
    phoneFocusNode.unfocus();
    passwordFocusNode.unfocus();
    if (Get.context != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  // Clear focus
  void unfocusFields() {
    phoneFocusNode.unfocus();
    passwordFocusNode.unfocus();
  }

  @override
  void onClose() {
    if (Get.context != null) {
      FocusScope.of(Get.context!).unfocus();
    }
    phoneFocusNode.unfocus();
    passwordFocusNode.unfocus();
    phoneController.dispose();
    passwordController.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }
}