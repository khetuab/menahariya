// lib/modules/passenger/controllers/profile_controller.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/core/services/storage/local_storage.dart';
import 'package:menahariya/core/theme/theme_controller.dart';
import 'package:menahariya/data/models/user/user_model.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';
import 'package:menahariya/core/utils/validators/auth_validator.dart';
import 'package:menahariya/core/utils/permissions/permission_handler.dart';
import 'package:menahariya/modules/passenger/views/support/about_view.dart';
import 'package:menahariya/modules/passenger/views/support/help_support_view.dart';
import 'package:menahariya/modules/passenger/views/support/privacy_security_view.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/services/storage/shared_prefs.dart';

class PassengerProfileController extends GetxController {
  static PassengerProfileController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorage _secureStorage = SecureStorage();
  final LocalStorage _localStorage = LocalStorage();
  final AuthController _authController = AuthController.instance;
  final ThemeController _themeController = ThemeController.to;

  // User data
  //late final UserModel user;

  final _user = Rxn<UserModel>();
  UserModel get user => _user.value!;

  // Form controllers for edit profile
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController cityController;

  // Password change controllers
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  // Focus nodes
  late final FocusNode nameFocusNode;
  late final FocusNode emailFocusNode;
  late final FocusNode currentPasswordFocusNode;
  late final FocusNode newPasswordFocusNode;
  late final FocusNode confirmPasswordFocusNode;

  // Observables
  final _isLoading = false.obs;
  final _isSaving = false.obs;
  final _isUploading = false.obs;
  final _profileImage = Rxn<File>();
  final _profileImageUrl = Rxn<String>();
  final _isEditing = false.obs;
  final _isChangingPassword = false.obs;
  final _currentPasswordVisible = false.obs;
  final _newPasswordVisible = false.obs;
  final _confirmPasswordVisible = false.obs;

  // Error observables
  final _nameError = Rxn<String>();
  final _emailError = Rxn<String>();
  final _phoneError = Rxn<String>();
  final _currentPasswordError = Rxn<String>();
  final _newPasswordError = Rxn<String>();
  final _confirmPasswordError = Rxn<String>();

  // Preferences
  final _notificationsEnabled = true.obs;
  final _darkMode = false.obs;
  final _language = 'en'.obs;
  final _saveHistory = true.obs;
  final _autoDownloadTickets = false.obs;
  final _receivePromotions = true.obs;

  final SharedPrefs _sharedPrefs = SharedPrefs();
  // Statistics
  final _totalTrips = 0.obs;
  final _totalCargo = 0.obs;
  final _memberSince = Rxn<DateTime>();
  final _loyaltyPoints = 0.obs;
  final _loyaltyTier = Rxn<String>();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  bool get isUploading => _isUploading.value;
  File? get profileImage => _profileImage.value;
  String? get profileImageUrl => _profileImageUrl.value;
  bool get isEditing => _isEditing.value;
  bool get isChangingPassword => _isChangingPassword.value;

  // Password visibility
  bool get currentPasswordVisible => _currentPasswordVisible.value;
  bool get newPasswordVisible => _newPasswordVisible.value;
  bool get confirmPasswordVisible => _confirmPasswordVisible.value;

  // Error getters
  String? get nameError => _nameError.value;
  String? get emailError => _emailError.value;
  String? get phoneError => _phoneError.value;
  String? get currentPasswordError => _currentPasswordError.value;
  String? get newPasswordError => _newPasswordError.value;
  String? get confirmPasswordError => _confirmPasswordError.value;

  // Preferences
  bool get notificationsEnabled => _notificationsEnabled.value;
  bool get darkMode => _darkMode.value;
  String get language => _language.value;
  bool get saveHistory => _saveHistory.value;
  bool get autoDownloadTickets => _autoDownloadTickets.value;
  bool get receivePromotions => _receivePromotions.value;

  // Statistics
  int get totalTrips => _totalTrips.value;
  int get totalCargo => _totalCargo.value;
  DateTime? get memberSince => _memberSince.value;
  int get loyaltyPoints => _loyaltyPoints.value;
  String? get loyaltyTier => _loyaltyTier.value;

  // Computed getters
  String get displayName => _user.value?.fullName ?? '';
  String get displayPhone => _user.value?.phone ?? '';
  String get displayEmail => _user.value?.email ?? 'Not provided';
  String get displayAddress => addressController.text.isEmpty ? 'Not set' : addressController.text;
  String get memberSinceText {
    if (_memberSince.value == null) return 'Unknown';
    final years = DateTime.now().difference(_memberSince.value!).inDays ~/ 365;
    return '$years year${years != 1 ? 's' : ''} ago';
  }

  bool get canSaveProfile {
    return nameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        _nameError.value == null &&
        _emailError.value == null &&
        _phoneError.value == null;
  }

  bool get canChangePassword {
    return currentPasswordController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        _currentPasswordError.value == null &&
        _newPasswordError.value == null &&
        _confirmPasswordError.value == null;
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _initializeControllers();
    _loadPreferences();
    _loadStatistics();
    _loadStatisticsFromUserData();
    _loadBiometricState();
    _load2FAState();
    PermissionHandler.debugPermissions();
  }


  Future<void> _loadBiometricState() async {
    try {
      final biometricEnabled = await _sharedPrefs.getBool('biometric_enabled');
      print('🔐 Loading biometric state from SharedPrefs: $biometricEnabled');
      _isBiometricEnabled.value = biometricEnabled ?? false;
    } catch (e) {
      print('❌ Error loading biometric state: $e');
      _isBiometricEnabled.value = false;
    }
  }

  void _loadStatisticsFromUserData() async {
    // Statistics already loaded from user data
    // Optionally refresh from server if needed
    try {
      final response = await _apiClient.get('/users/me');
      if (response != null && response['data'] != null) {
        final userData = response['data'];
        _totalTrips.value = userData['totalTrips'] ?? _totalTrips.value;
        // Cargo might not be in the response yet
        _loyaltyPoints.value = userData['loyaltyPoints'] ?? _loyaltyPoints.value;
        _loyaltyTier.value = userData['loyaltyTier'] ?? _loyaltyTier.value;
        print('✅ Statistics refreshed from /users/me');
      }
    } catch (e) {
      print('⚠️ Could not refresh statistics: $e');
    }
  }

  // In PassengerProfileController, replace the _loadStatistics method:

  final _isBiometricEnabled = false.obs;
  bool get isBiometricEnabled => _isBiometricEnabled.value;

  // Update the biometric methods in profile_controller.dart:

  // In profile_controller.dart, update toggleBiometricLogin:

  Future<void> toggleBiometricLogin(bool value) async {
    print('🔐 Toggle biometric login called with value: $value');

    if (value) {
      // Check if user is logged in
      if (_user.value == null) {
        print('❌ No user logged in, cannot enable biometrics');
        Get.snackbar('Please Login First', 'Login with password to enable biometrics');
        return;
      }

      // Check if device supports biometrics
      final isAvailable = await PermissionHandler.checkBiometricSupport();
      print('🔐 Device biometric support: $isAvailable');

      if (!isAvailable) {
        Get.snackbar(
          'Not Available',
          'Biometric authentication is not available on this device',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // FIRST: Ask for password to confirm and save it
      final password = await _showPasswordDialog();
      if (password == null || password.isEmpty) {
        print('❌ No password provided, cancelling biometric enable');
        Get.snackbar('Password Required', 'Please enter your password to enable biometrics');
        _isBiometricEnabled.value = false;
        return;
      }

      // Get available biometric types
      final availableTypes = await PermissionHandler.getAvailableBiometrics();
      final typeNames = availableTypes.map((t) =>
          PermissionHandler.getBiometricTypeName(t)).join(' or ');

      // Authenticate to enable
      final isAuthenticated = await PermissionHandler.authenticateWithBiometrics(
        reason: 'Enable ${typeNames.isEmpty ? 'biometric' : typeNames} login for faster access to your account',
      );

      print('🔐 Authentication result: $isAuthenticated');

      if (isAuthenticated) {
        // Save to SharedPrefs with the actual password
        await _sharedPrefs.setString('biometric_phone', _user.value!.phone);
        await _sharedPrefs.setString('biometric_password', password);  // Save actual password!
        await _sharedPrefs.setBool('biometric_enabled', true);

        // Also update AuthController
        await _authController.saveCredentialsForBiometric(_user.value!.phone, password);

        _isBiometricEnabled.value = true;
        print('✅ Biometric login ENABLED - phone: ${_user.value!.phone}, password saved');

        Get.snackbar(
          'Success',
          'Biometric login enabled. Next time you login, you can use biometrics.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        _isBiometricEnabled.value = false;
        print('❌ Biometric login NOT enabled - authentication failed');
      }
    } else {
      // Disable biometric login
      print('🔐 Disabling biometric login...');

      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Disable Biometric Login'),
          content: const Text('Are you sure you want to disable biometric login?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Disable'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        // Clear from SharedPrefs
        await _sharedPrefs.remove('biometric_phone');
        await _sharedPrefs.remove('biometric_password');
        await _sharedPrefs.setBool('biometric_enabled', false);

        // Clear from SecureStorage
        await _secureStorage.delete('saved_credentials');
        await _secureStorage.delete('saved_phone');

        _isBiometricEnabled.value = false;
        print('✅ Biometric login DISABLED');

        Get.snackbar(
          'Disabled',
          'Biometric login disabled',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Revert the switch
        _isBiometricEnabled.value = true;
        print('⚠️ User cancelled biometric disable');
      }
    }
  }

// Add this helper method to show password dialog with validation
  Future<String?> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    final isPasswordVisible = false.obs;
    final isLoading = false.obs;
    final errorMessage = ''.obs;

    return await Get.dialog<String>(
      AlertDialog(
        title: const Text('Confirm Password'),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible.value,
              decoration: InputDecoration(
                labelText: 'Enter your password',
                border: const OutlineInputBorder(),
                errorText: errorMessage.value.isEmpty ? null : errorMessage.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => isPasswordVisible.toggle(),
                ),
              ),
            ),
            if (isLoading.value)
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: CircularProgressIndicator(),
              ),
          ],
        )),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value
                ? null
                : () async {
              final password = passwordController.text.trim();
              if (password.isEmpty) {
                errorMessage.value = 'Please enter your password';
                return;
              }

              isLoading.value = true;
              errorMessage.value = '';

              // Verify password with backend
              final isValid = await _verifyPassword(password);

              isLoading.value = false;

              if (isValid) {
                Get.back(result: password);
              } else {
                errorMessage.value = 'Incorrect password. Please try again.';
                passwordController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Confirm'),
          )),
        ],
      ),
      barrierDismissible: false,
    );
  }

// Add this helper method to verify password with backend
  Future<bool> _verifyPassword(String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify-password',
        data: {'password': password},
      );
      return response != null && response['valid'] == true;
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }

// Add a method to authenticate when the app starts (if biometric login is enabled)
  Future<bool> authenticateWithBiometricsOnStartup() async {
    if (_isBiometricEnabled.value) {
      final isAuthenticated = await PermissionHandler.authenticateWithBiometrics(
        reason: 'Authenticate to access your account',
      );
      return isAuthenticated;
    }
    return true;
  }



  final _profileVisibility = 'public'.obs; // 'public', 'private', 'contacts_only'
  String get profileVisibility => _profileVisibility.value;

  Future<void> updateProfileVisibility(String visibility) async {
    try {
      await _apiClient.patch('/users/profile/visibility', data: {
        'visibility': visibility,
      });
      _profileVisibility.value = visibility;
      await _secureStorage.write('profile_visibility', visibility);
      Get.snackbar('Success', 'Profile visibility updated');
    } catch (e) {
      print('Error updating profile visibility: $e');
    }
  }

  final _locationSharingEnabled = true.obs;
  final _locationAccuracy = 'precise'.obs; // 'precise', 'approximate'
  bool get locationSharingEnabled => _locationSharingEnabled.value;
  String get locationAccuracy => _locationAccuracy.value;

  Future<void> toggleLocationSharing(bool value) async {
    _locationSharingEnabled.value = value;
    await _secureStorage.writeBool('location_sharing', value);

    if (value) {
      await PermissionHandler.requestLocationPermission();
    }
  }

  Future<void> updateLocationAccuracy(String accuracy) async {
    _locationAccuracy.value = accuracy;
    await _secureStorage.write('location_accuracy', accuracy);
  }

// ============== Clear History Methods ==============

  Future<void> clearSearchHistory() async {
    try {
      await _apiClient.delete('/users/history/search');
      Get.snackbar('Success', 'Search history cleared');
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  Future<void> clearBrowseHistory() async {
    try {
      await _apiClient.delete('/users/history/browse');
      Get.snackbar('Success', 'Browse history cleared');
    } catch (e) {
      print('Error clearing browse history: $e');
    }
  }

// ============== Download Data Methods ==============

  Future<void> requestDataDownload() async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post('/users/data/export');

      if (response != null && response['success'] == true) {
        Get.snackbar(
          'Request Sent',
          'We\'ll email you when your data is ready',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('Error requesting data download: $e');
      Get.snackbar('Error', 'Failed to request data download');
    } finally {
      _isLoading.value = false;
    }
  }

// ============== Delete Account Methods ==============

  Future<void> deleteAccount(String password) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.delete('/users/account', data: {
        'password': password,
      });

      if (response != null && response['success'] == true) {
        await _authController.logout();
        Get.offAllNamed('/auth/login');
        Get.snackbar('Account Deleted', 'Your account has been permanently deleted');
      }
    } catch (e) {
      print('Error deleting account: $e');
      Get.snackbar('Error', 'Failed to delete account. Please check your password.');
    } finally {
      _isLoading.value = false;
    }
  }
  final _is2FAEnabled = false.obs;
  final _2FAMethod = 'authenticator'.obs; // 'authenticator', 'sms', 'email'
  final _2FASecret = ''.obs;
  final _backupCodes = <String>[].obs;

  bool get is2FAEnabled => _is2FAEnabled.value;
  String get twoFAMethod => _2FAMethod.value;
  List<String> get backupCodes => _backupCodes;

  // Update the setupTwoFactorAuth method

  Future<void> _load2FAState() async {
    try {
      final twoFactorEnabled = await _sharedPrefs.getBool('2fa_enabled');
      print('🔐 Loading 2FA state from SharedPrefs: $twoFactorEnabled');
      _is2FAEnabled.value = twoFactorEnabled ?? false;

      // Also load from user data if available
      if (_user.value != null && _user.value!.twoFactorEnabled != null) {
        final user2FAEnabled = _user.value!.twoFactorEnabled;
        if (user2FAEnabled != _is2FAEnabled.value) {
          _is2FAEnabled.value = user2FAEnabled!;
          await _sharedPrefs.setBool('2fa_enabled', user2FAEnabled);
        }
      }
    } catch (e) {
      print('❌ Error loading 2FA state: $e');
      _is2FAEnabled.value = false;
    }
  }
  Future<void> setupTwoFactorAuth() async {
    try {
      _isLoading.value = true;
      print('🔐 Setting up 2FA...');

      // Get setup data from server
      final response = await _apiClient.post('/auth/2fa/setup');

      print('📦 2FA Setup Response received');

      if (response != null && response['data'] != null) {
        final data = response['data'];
        _2FASecret.value = data['secret'] ?? '';
        _backupCodes.value = List<String>.from(data['backupCodes'] ?? []);

        final otpauthUrl = data['otpauthUrl'] ?? '';
        String? qrCodeBase64 = data['qrCode'];

        final codeController = TextEditingController();

        // Show QR code dialog
        Get.dialog(
          AlertDialog(
            title: const Text('Setup Two-Factor Authentication'),
            content: SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Scan this QR code with your authenticator app:',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Display QR code if available
                    if (qrCodeBase64 != null && qrCodeBase64.isNotEmpty)
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.memory(
                          base64Decode(qrCodeBase64.replaceFirst('data:image/png;base64,', '')),
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      )
                    else if (_2FASecret.value.isNotEmpty)
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code, size: 80),
                              const SizedBox(height: 8),
                              Text(
                                'Secret Key:',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              Text(
                                _2FASecret.value,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Enter 6-digit code',
                        border: OutlineInputBorder(),
                        hintText: '000000',
                        helperText: 'Enter the code from your authenticator app',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '⚠️ Save these backup codes!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Use these codes if you lose access to your authenticator app:',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: _backupCodes.map((code) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                code,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  codeController.dispose();
                  Get.back();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final code = codeController.text.trim();
                  if (code.length != 6) {
                    Get.snackbar('Error', 'Please enter a valid 6-digit code');
                    return;
                  }
                  Get.back();
                  await _verifyAndEnable2FA(code);
                  codeController.dispose();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Verify & Enable'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print('❌ Error setting up 2FA: $e');
      Get.snackbar('Error', 'Failed to setup two-factor authentication');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _verifyAndEnable2FA(String code) async {
    try {
      _isLoading.value = true;
      print('🔐 Verifying 2FA with code: $code');

      final response = await _apiClient.post('/auth/2fa/verify', data: {
        'code': code,
        'method': _2FAMethod.value,
      });

      print('📦 2FA Verify Response: $response');

      if (response != null && response['success'] == true) {
        _is2FAEnabled.value = true;

        // Save to SharedPrefs (persists across logout)
        await _sharedPrefs.setBool('2fa_enabled', true);

        // Also save to SecureStorage for backup
        await _secureStorage.writeBool('2fa_enabled', true);

        Get.snackbar(
          'Success',
          'Two-factor authentication enabled',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Error verifying 2FA: $e');
      Get.snackbar('Error', 'Invalid verification code. Please try again.');
    } finally {
      _isLoading.value = false;
    }
  }

// Update disableTwoFactorAuth:
  Future<void> disableTwoFactorAuth() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Disable 2FA'),
        content: const Text('Are you sure you want to disable two-factor authentication?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiClient.post('/auth/2fa/disable');
        _is2FAEnabled.value = false;

        // Clear from SharedPrefs
        await _sharedPrefs.setBool('2fa_enabled', false);
        await _secureStorage.writeBool('2fa_enabled', false);

        Get.snackbar('Success', 'Two-factor authentication disabled');
      } catch (e) {
        print('Error disabling 2FA: $e');
        Get.snackbar('Error', 'Failed to disable 2FA');
      }
    }
  }

  Future<void> _loadStatistics() async {
    try {
      print('📊 Loading statistics...');

      // Get trips count from booking history
      final tripsResponse = await _apiClient.get('/tickets/my-tickets?limit=100');
      if (tripsResponse != null && tripsResponse['data'] != null) {
        final trips = tripsResponse['data'] as List;
        _totalTrips.value = trips.length;
        print('✅ Total trips: ${_totalTrips.value}');
      }

      // Get cargo count from cargo history (using correct endpoint)
      try {
        final cargoResponse = await _apiClient.get('/cargo/history?limit=100');
        if (cargoResponse != null && cargoResponse['data'] != null) {
          final cargoData = cargoResponse['data'];
          List cargoList = [];

          if (cargoData is List) {
            cargoList = cargoData;
          } else if (cargoData['data'] is List) {
            cargoList = cargoData['data'];
          }

          _totalCargo.value = cargoList.length;
          print('✅ Total cargo: ${_totalCargo.value}');
        }
      } catch (cargoError) {
        print('⚠️ Could not load cargo count: $cargoError');
        _totalCargo.value = 0;
      }

      // Get loyalty points from user data
      if (_user.value != null) {
        _loyaltyPoints.value = _user.value!.loyaltyPoints ?? 0;
        _loyaltyTier.value = _user.value!.loyaltyTier ?? 'Bronze';
        print('✅ Loyalty: Points=${_loyaltyPoints.value}, Tier=${_loyaltyTier.value}');
      }

    } catch (e) {
      print('❌ Error loading statistics: $e');
      _totalTrips.value = 0;
      _totalCargo.value = 0;
      _loyaltyPoints.value = 254;
      _loyaltyTier.value = 'Bronze';
    }
  }

  Future<void> refreshStatistics() async {
    await _loadStatistics();
  }
  void _loadUserData() {
    _user.value = _authController.currentUser!;
    _profileImageUrl.value = user.profileImage;
    _memberSince.value = user.createdAt;

    // Load statistics from user object if available
    if (_user.value != null) {
      _loyaltyPoints.value = _user.value!.loyaltyPoints ?? 0;
      _loyaltyTier.value = _user.value!.loyaltyTier ?? 'Bronze';
      print('📊 User data loaded: Points=${_loyaltyPoints.value}, Tier=${_loyaltyTier.value}');
    }
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: user.fullName);
    emailController = TextEditingController(text: user.email ?? '');
    phoneController = TextEditingController(text: user.phone);
    addressController = TextEditingController(text: user.address ?? '');
    cityController = TextEditingController(text: user.city ?? '');

    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    nameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    currentPasswordFocusNode = FocusNode();
    newPasswordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
  }

  Future<void> _loadPreferences() async {
    try {
      _darkMode.value = _themeController.isDarkMode;
      _language.value = await _secureStorage.read(AppConstants.prefKeyLanguage) ?? 'en';
      _notificationsEnabled.value = await _secureStorage.readBoolOrDefault('notifications', true);
      _saveHistory.value = await _secureStorage.readBoolOrDefault('save_history', true);
      _autoDownloadTickets.value = await _secureStorage.readBoolOrDefault('auto_download', false);
      _receivePromotions.value = await _secureStorage.readBoolOrDefault('promotions', true);
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    final granted = await PermissionHandler.requestCameraPermission();
    if (!granted) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        _profileImage.value = File(pickedFile.path);
        await _uploadProfileImage();
      }
    } catch (e) {
      print('Error picking image from camera: $e');
      Get.snackbar(
        'Error',
        'Failed to capture image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // In your profile controller's pickImageFromGallery method:

  Future<void> pickImageFromGallery() async {
    // Use the new image picker permission method
    final granted = await PermissionHandler.requestImagePickerPermission();

    if (!granted) {
      Get.snackbar(
        'Permission Required',
        'Photos permission is needed to select images',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        print('✅ Image selected: ${pickedFile.path}');
        print('📏 File size: ${await pickedFile.length()} bytes');
        _profileImage.value = File(pickedFile.path);
        await _uploadProfileImage();
      } else {
        print('⚠️ No image selected by user');
      }
    } catch (e) {
      print('❌ Error picking image from gallery: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString().split('\n')[0]}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // In PassengerProfileController, update _uploadProfileImage:

  Future<void> _uploadProfileImage() async {
    if (_profileImage.value == null) return;


    // Check if file exists
    if (!await _profileImage.value!.exists()) {
      print('❌ File does not exist: ${_profileImage.value!.path}');
      Get.snackbar(
        'Error',
        'Image file not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    try {
      _isUploading.value = true;

      print('📤 Uploading avatar from: ${_profileImage.value!.path}');

      // Use the uploadFile method with fieldName 'avatar'
      final response = await _apiClient.uploadFile(
        ApiEndpoints.usersUpdateAvatar,
        _profileImage.value!.path,
        fieldName: 'avatar', // This will be used as the form field name
      );

      print('✅ Upload response: $response');

      if (response != null && response['data'] != null) {
        // Log the response structure for debugging
        print('📦 Response data keys: ${response['data'].keys}');

        // Get the URL from response - try different possible paths
        String? avatarUrl;

        if (response['data']['url'] != null) {
          avatarUrl = response['data']['url'];
        } else if (response['data']['avatar'] != null) {
          avatarUrl = response['data']['avatar'];
        } else if (response['data']['profileImage'] != null) {
          avatarUrl = response['data']['profileImage'];
        } else if (response['data']['image'] != null) {
          avatarUrl = response['data']['image'];
        }

        if (avatarUrl != null) {
          _profileImageUrl.value = avatarUrl;
          print('✅ Avatar URL: $avatarUrl');

          // Update user in auth controller
          await _authController.updateProfile({
            'profileImage': avatarUrl,
          });

          Get.snackbar(
            'Success',
            'Profile picture updated',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception('No URL found in response: ${response['data']}');
        }
      } else {
        throw Exception('Invalid response structure: $response');
      }
    } on DioException catch (e) {
      print('❌ Upload Dio error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');

      String errorMessage = 'Failed to upload image';
      if (e.response?.data != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Upload error: $e');
      Get.snackbar(
        'Error',
        'Failed to upload image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isUploading.value = false;
    }
  }

  // ============== Profile Edit Methods ==============

  void toggleEditMode() {
    if (_isEditing.value) {
      // Cancel editing - revert changes
      nameController.text = _user.value!.fullName;
      emailController.text = _user.value!.email ?? '';
      phoneController.text = _user.value!.phone;
      addressController.text = _user.value!.address ?? '';
      cityController.text = _user.value!.city ?? '';
      _clearEditErrors();
    }
    _isEditing.value = !_isEditing.value;
  }

  void validateName(String value) {
    _nameError.value = AuthValidator.validateFullName(value);
  }

  void validateEmail(String value) {
    _emailError.value = AuthValidator.validateEmail(value);
  }

  void validatePhone(String value) {
    _phoneError.value = AuthValidator.validatePhone(value);
  }

  void _clearEditErrors() {
    _nameError.value = null;
    _emailError.value = null;
    _phoneError.value = null;
  }

  // In PassengerProfileController, update the saveProfile method:

  Future<void> saveProfile() async {
    if (!canSaveProfile) return;

    try {
      _isSaving.value = true;

      final updates = {
        'fullName': nameController.text,
        'email': emailController.text.isEmpty ? null : emailController.text,
        'phone': phoneController.text,
        'address': addressController.text.isEmpty ? null : addressController.text,
        'city': cityController.text.isEmpty ? null : cityController.text,
      };

      final success = await _authController.updateProfile(updates);

      if (success) {
        // Update the reactive user object
        final updatedUser = _authController.currentUser;
        if (updatedUser != null) {
          _user.value = updatedUser; // This is now allowed
        }

        // Update form controllers with new data
        nameController.text = _user.value!.fullName;
        emailController.text = _user.value!.email ?? '';
        phoneController.text = _user.value!.phone;
        addressController.text = _user.value!.address ?? '';
        cityController.text = _user.value!.city ?? '';

        _isEditing.value = false;

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isSaving.value = false;
    }
  }
  // ============== Password Change Methods ==============

  void togglePasswordChange() {
    if (_isChangingPassword.value) {
      // Cancel - clear fields
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      _clearPasswordErrors();
    }
    _isChangingPassword.value = !_isChangingPassword.value;
  }

  void toggleCurrentPasswordVisibility() {
    _currentPasswordVisible.value = !_currentPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    _newPasswordVisible.value = !_newPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    _confirmPasswordVisible.value = !_confirmPasswordVisible.value;
  }

  void validateCurrentPassword(String value) {
    _currentPasswordError.value = value.isEmpty ? 'Current password is required' : null;
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

  void _clearPasswordErrors() {
    _currentPasswordError.value = null;
    _newPasswordError.value = null;
    _confirmPasswordError.value = null;
  }

  Future<void> changePassword() async {
    if (!canChangePassword) return;

    try {
      _isSaving.value = true;

      final success = await _authController.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      if (success) {
        // Clear form and exit
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        _isChangingPassword.value = false;
        _clearPasswordErrors();
      }
    } catch (e) {
      print('Error changing password: $e');
      Get.snackbar(
        'Error',
        'Failed to change password',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isSaving.value = false;
    }
  }

  // ============== Preference Methods ==============

  void toggleNotifications(bool value) async {
    _notificationsEnabled.value = value;
    await _secureStorage.writeBool('notifications', value);
  }

  void toggleDarkMode(bool value) {
    _darkMode.value = value;
    if (value) {
      _themeController.setDarkMode();
    } else {
      _themeController.setLightMode();
    }
  }

  void setLanguage(String code) async {
    _language.value = code;
    await _secureStorage.write(AppConstants.prefKeyLanguage, code);
    Get.updateLocale(Locale(code));
  }

  void toggleSaveHistory(bool value) async {
    _saveHistory.value = value;
    await _secureStorage.writeBool('save_history', value);
  }

  void toggleAutoDownload(bool value) async {
    _autoDownloadTickets.value = value;
    await _secureStorage.writeBool('auto_download', value);
  }

  void togglePromotions(bool value) async {
    _receivePromotions.value = value;
    await _secureStorage.writeBool('promotions', value);
  }

  // ============== Support Methods ==============

  void contactSupport() {
    Get.to(()=> HelpSupportView());
  }

  void viewFAQs() {
    Get.toNamed('/faqs');
  }

  void viewTermsAndConditions() {
    Get.to(()=> AboutView());
  }

  void viewPrivacyPolicy() {
    Get.to(()=> PrivacySecurityView());
  }

  void rateApp() {
    // Open store listing for rating
    // Implementation depends on platform
  }

  void shareApp() {
    // Share app link
    // Implementation depends on platform
  }

  // ============== Logout ==============

  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authController.logout();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    currentPasswordFocusNode.dispose();
    newPasswordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }
}