// lib/modules/admin/controllers/admin_profile_controller.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../config/environment/env_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/services/storage/secure_storage.dart';
import '../../../core/utils/permissions/permission_handler.dart';
import '../../../data/models/user/user_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/admin_models.dart';

class AdminProfileController extends GetxController {
  static AdminProfileController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorage _secureStorage = SecureStorage();
  final AuthController _authController = Get.find<AuthController>();
  final SharedPrefs _sharedPrefs = SharedPrefs();

  // Get base URL without /api suffix
  String get _baseUrl {
    final base = EnvConfig.instance.apiBaseUrl;
    return base.replaceAll('/api', '');
  }

  // Observables
  final _isLoading = false.obs;
  final _isSaving = false.obs;
  final _isUploadingImage = false.obs;
  final _profile = Rxn<AdminProfile>();
  final _activityLogs = <ActivityLog>[].obs;
  final _user = Rxn<UserModel>();
  UserModel get user => _user.value!;

  // Form controllers
  late final TextEditingController fullNameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  // Profile image - store FULL URL
  final _profileImage = Rxn<File>();
  final _profileImageUrl = ''.obs;
  final _imageUploadProgress = 0.0.obs;
  final _isBiometricEnabled = false.obs;
  final _is2FAEnabled = false.obs;
  final _2FAMethod = 'authenticator'.obs;
  final _2FASecret = ''.obs;
  final _backupCodes = <String>[].obs;

// Add these getters
  bool get isBiometricEnabled => _isBiometricEnabled.value;
  bool get is2FAEnabled => _is2FAEnabled.value;
  String get twoFAMethod => _2FAMethod.value;
  List<String> get backupCodes => _backupCodes;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  bool get isUploadingImage => _isUploadingImage.value;
  AdminProfile? get profile => _profile.value;
  List<ActivityLog> get activityLogs => _activityLogs;
  File? get profileImage => _profileImage.value;
  String get profileImageUrl => _profileImageUrl.value;
  double get imageUploadProgress => _imageUploadProgress.value;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchProfile();
    fetchActivityLogs();
    _loadUserData();
    _loadBiometricState();
    _load2FAState();
  }

  void _initializeControllers() {
    fullNameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  void _loadUserData() {
    final currentUser = _authController.currentUser;
    if (currentUser != null) {
      _user.value = currentUser;
      print('✅ Admin user data loaded: ${currentUser.fullName}');
    } else {
      print('⚠️ No user data available in AuthController');
    }
  }

  // Add this method to load biometric state
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

// Add this method to load 2FA state
  Future<void> _load2FAState() async {
    try {
      final twoFactorEnabled = await _sharedPrefs.getBool('2fa_enabled');
      print('🔐 Loading 2FA state from SharedPrefs: $twoFactorEnabled');
      _is2FAEnabled.value = twoFactorEnabled ?? false;
    } catch (e) {
      print('❌ Error loading 2FA state: $e');
      _is2FAEnabled.value = false;
    }
  }
  Future<void> fetchProfile() async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get('/admin/profile');
      if (response != null && response['data'] != null) {
        final profileData = response['data'];
        _profile.value = AdminProfile.fromJson(profileData);
        _populateForm();

        // ALSO LOAD USER DATA FROM AUTH CONTROLLER
        _user.value = _authController.currentUser;

        // Update auth controller if needed
        final currentUser = _authController.currentUser;
        if (currentUser != null && _profile.value != null) {
          final updatedUser = currentUser.copyWith(
            fullName: _profile.value!.fullName,
            phone: _profile.value!.phone,
            email: _profile.value!.email,
            profileImage: _profile.value!.profileImage,
          );
          await _secureStorage.writeObject('user', updatedUser.toJson());
          // Update the local user as well
          _user.value = updatedUser;
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
      AppSnackbar.show('Error', 'Failed to load profile');
    } finally {
      _isLoading.value = false;
    }
  }


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
  void _populateForm() {
    final profile = _profile.value;
    if (profile == null) return;

    fullNameController.text = profile.fullName;
    phoneController.text = profile.phone;
    emailController.text = profile.email;

    // Store FULL URL for image (without /api prefix)
    if (profile.profileImage != null && profile.profileImage!.isNotEmpty) {
      final staticBaseUrl = EnvConfig.instance.apiBaseUrl.replaceAll('/api', '');
      final cleanPath = profile.profileImage!.startsWith('/')
          ? profile.profileImage!
          : '/${profile.profileImage!}';
      _profileImageUrl.value = '$staticBaseUrl$cleanPath';
    } else {
      _profileImageUrl.value = '';
    }
  }

  Future<void> fetchActivityLogs() async {
    try {
      final response = await _apiClient.get('/admin/activity-logs');
      if (response != null && response['data'] != null) {
        final List<dynamic> logs = response['data'];
        _activityLogs.value = logs.map((l) => ActivityLog.fromJson(l)).toList();
      }
    } catch (e) {
      print('Error fetching activity logs: $e');
    }
  }

  Future<void> updateProfile() async {
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();

    if (fullName.isEmpty || phone.isEmpty) {
      AppSnackbar.show('Error', 'Please fill all required fields');
      return;
    }

    if (phone.length < 10) {
      AppSnackbar.show('Error', 'Please enter a valid phone number');
      return;
    }

    if (email.isNotEmpty && !email.contains('@')) {
      AppSnackbar.show('Error', 'Please enter a valid email address');
      return;
    }

    try {
      _isSaving.value = true;

      final updateData = {
        'fullName': fullName,
        'phone': phone,
        'email': email,
      };

      final response = await _apiClient.put(
        '/admin/profile',
        data: updateData,
      );

      if (response != null && response['success'] == true) {
        await fetchProfile();

        if (_authController.currentUser != null && _profile.value != null) {
          final updatedUser = _authController.currentUser!.copyWith(
            fullName: _profile.value!.fullName,
            phone: _profile.value!.phone,
            email: _profile.value!.email,
            profileImage: _profile.value!.profileImage,
          );
          await _secureStorage.writeObject(
            AppConstants.prefKeyUser,
            updatedUser.toJson(),
          );
          await AuthController.instance.updateUser(updatedUser);
        }

        AppSnackbar.show('Success', 'Profile updated successfully');
        Get.back();
      } else {
        AppSnackbar.show('Error', response?['message'] ?? 'Failed to update profile!');
      }
    } catch (e) {
      print('Error updating profile: $e');
      AppSnackbar.show('Error', 'Failed to update profile');
    } finally {
      _isSaving.value = false;
    }
  }

  Future<void> uploadProfileImage() async {
    final imageFile = _profileImage.value;
    if (imageFile == null) {
      AppSnackbar.show('Error', 'No image selected');
      return;
    }

    try {
      _isUploadingImage.value = true;
      _imageUploadProgress.value = 0.0;

      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      print('📤 Uploading profile image: ${imageFile.path}');

      final response = await _apiClient.post(
        '/admin/profile/upload-image',
        data: formData,
      );

      print('📥 Upload response: $response');

      if (response == null) {
        throw Exception('No response from server');
      }

      final success = response['success'] as bool? ?? false;

      if (success) {
        final data = response['data'];
        if (data != null && data is Map<String, dynamic>) {
          final relativeImageUrl = data['imageUrl'] as String?;

          if (relativeImageUrl != null && relativeImageUrl.isNotEmpty) {
            // Store FULL URL
            final fullImageUrl = '$_baseUrl$relativeImageUrl';
            _profileImageUrl.value = fullImageUrl;
            _profileImage.value = null;

            // Update the stored user data
            final currentUser = _authController.currentUser;
            if (currentUser != null) {
              final updatedUser = currentUser.copyWith(
                profileImage: relativeImageUrl,
              );
              await _secureStorage.writeObject('user', updatedUser.toJson());
            }

            // Refresh profile data
            await fetchProfile();

            AppSnackbar.show('Success', 'Profile image updated successfully');
            return;
          }
        }
        throw Exception('Invalid response format');
      } else {
        final message = response['message'] as String? ?? 'Failed to upload image';
        throw Exception(message);
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
      AppSnackbar.show('Error', 'Failed to upload image: ${e.toString()}');
    } finally {
      _isUploadingImage.value = false;
      _imageUploadProgress.value = 0.0;
    }
  }

  Future<void> removeProfileImage() async {
    try {
      _isSaving.value = true;

      final response = await _apiClient.delete('/admin/profile/image');

      if (response != null && response['success'] == true) {
        _profileImageUrl.value = '';
        _profileImage.value = null;

        if (_authController.currentUser != null) {
          final updatedUser = _authController.currentUser!.copyWith(
            profileImage: null,
          );
          await _secureStorage.writeObject('user', updatedUser.toJson());
        }

        await fetchProfile();
        AppSnackbar.show('Success', 'Profile image removed successfully');
      }
    } catch (e) {
      print('Error removing image: $e');
      AppSnackbar.show('Error', 'Failed to remove image');
    } finally {
      _isSaving.value = false;
    }
  }

  Future<void> changePassword() async {
    final currentPass = currentPasswordController.text;
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      AppSnackbar.show('Error', 'Please fill all password fields');
      return;
    }

    if (newPass != confirmPass) {
      AppSnackbar.show('Error', 'New passwords do not match');
      return;
    }

    if (newPass.length < 6) {
      AppSnackbar.show('Error', 'Password must be at least 6 characters');
      return;
    }

    if (currentPass == newPass) {
      AppSnackbar.show('Error', 'New password must be different from current password');
      return;
    }

    try {
      _isSaving.value = true;

      final response = await _apiClient.post(
        '/admin/profile/change-password',
        data: {
          'currentPassword': currentPass,
          'newPassword': newPass,
        },
      );

      if (response != null && response['success'] == true) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        AppSnackbar.show('Success', 'Password changed successfully');
        Get.back();
      } else {
        AppSnackbar.show('Error', response?['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      print('Error changing password: $e');
      AppSnackbar.show('Error', 'Failed to change password');
    } finally {
      _isSaving.value = false;
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (image != null) {
        _profileImage.value = File(image.path);
        await uploadProfileImage();
      }
    } catch (e) {
      print('Error picking image: $e');
      AppSnackbar.show('Error', 'Failed to pick image!');
    }
  }

  Future<void> takeProfilePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (image != null) {
        _profileImage.value = File(image.path);
        await uploadProfileImage();
      }
    } catch (e) {
      print('Error taking photo: $e');
      AppSnackbar.show('Error', 'Failed to take photo');
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}