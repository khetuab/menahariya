// lib/modules/passenger/controllers/profile_controller.dart

import 'dart:io';
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

class PassengerProfileController extends GetxController {
  static PassengerProfileController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorage _secureStorage = SecureStorage();
  final LocalStorage _localStorage = LocalStorage();
  final AuthController _authController = AuthController.instance;
  final ThemeController _themeController = ThemeController.to;

  // User data
  late final UserModel user;

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
  String get displayName => user.fullName;
  String get displayPhone => user.phone;
  String get displayEmail => user.email ?? 'Not provided';
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
  }

  void _loadUserData() {
    user = _authController.currentUser!;
    _profileImageUrl.value = user.profileImage;
    _memberSince.value = user.createdAt;
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

  Future<void> _loadStatistics() async {
    try {
      final response = await _apiClient.get('/user/statistics');
      if (response != null && response['data'] != null) {
        _totalTrips.value = response['data']['totalTrips'] ?? 0;
        _totalCargo.value = response['data']['totalCargo'] ?? 0;
        _loyaltyPoints.value = response['data']['loyaltyPoints'] ?? 0;
        _loyaltyTier.value = response['data']['loyaltyTier'] ?? 'Bronze';
      }
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  // ============== Profile Image Methods ==============

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

  Future<void> pickImageFromGallery() async {
    final granted = await PermissionHandler.requestStoragePermission();
    if (!granted) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        _profileImage.value = File(pickedFile.path);
        await _uploadProfileImage();
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage.value == null) return;

    try {
      _isUploading.value = true;

      final response = await _apiClient.uploadFile(
        ApiEndpoints.usersUpdateAvatar,
        _profileImage.value!.path,
      );

      if (response != null && response['data'] != null) {
        _profileImageUrl.value = response['data']['url'];

        // Update user in auth controller
        await _authController.updateProfile({
          'profileImage': _profileImageUrl.value,
        });

        Get.snackbar(
          'Success',
          'Profile picture updated',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      Get.snackbar(
        'Error',
        'Failed to upload image',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isUploading.value = false;
    }
  }

  // ============== Profile Edit Methods ==============

  void toggleEditMode() {
    if (_isEditing.value) {
      // Cancel editing - revert changes
      nameController.text = user.fullName;
      emailController.text = user.email ?? '';
      phoneController.text = user.phone;
      addressController.text = user.address ?? '';
      cityController.text = user.city ?? '';
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
        // Update local user data
        user = _authController.currentUser!;
        _isEditing.value = false;

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
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
    Get.toNamed('/support');
  }

  void viewFAQs() {
    Get.toNamed('/faqs');
  }

  void viewTermsAndConditions() {
    Get.toNamed('/terms');
  }

  void viewPrivacyPolicy() {
    Get.toNamed('/privacy');
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