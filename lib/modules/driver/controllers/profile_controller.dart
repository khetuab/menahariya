// lib/modules/driver/controllers/profile_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/core/theme/theme_controller.dart';
import 'package:menahariya/core/utils/permissions/permission_handler.dart';
import 'package:menahariya/core/utils/validators/auth_validator.dart';
import 'package:menahariya/data/models/user/user_model.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../../core/utils/app_snackbar.dart';

class DriverProfileController extends GetxController {
  static DriverProfileController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorage _secureStorage = SecureStorage();
  final AuthController _authController = AuthController.instance;
  final ThemeController _themeController = ThemeController.to;

  // User data
  late final UserModel user;

  // Form controllers
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController licenseNumberController;
  late final TextEditingController licenseExpiryController;

  // Observables
  final _isLoading = false.obs;
  final _isSaving = false.obs;
  final _isUploading = false.obs;
  final _profileImage = Rxn<File>();
  final _profileImageUrl = Rxn<String>();
  final _isEditing = false.obs;
  final _driverStatus = true.obs; // online/offline
  final _totalTrips = 0.obs;
  final _totalDistance = 0.obs;
  final _rating = 0.0.obs;
  final _totalReviews = 0.obs;
  final _driverSince = Rxn<DateTime>();

  // Preferences
  final _notificationsEnabled = true.obs;
  final _darkMode = false.obs;
  final _language = 'en'.obs;
  final _autoAcceptTrips = false.obs;
  final _maxTripDistance = 100.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  bool get isUploading => _isUploading.value;
  File? get profileImage => _profileImage.value;
  String? get profileImageUrl => _profileImageUrl.value;
  bool get isEditing => _isEditing.value;
  bool get isOnline => _driverStatus.value;

  // Statistics
  int get totalTrips => _totalTrips.value;
  int get totalDistance => _totalDistance.value;
  double get rating => _rating.value;
  int get totalReviews => _totalReviews.value;
  DateTime? get driverSince => _driverSince.value;

  // Preferences
  bool get notificationsEnabled => _notificationsEnabled.value;
  bool get darkMode => _darkMode.value;
  String get language => _language.value;
  bool get autoAcceptTrips => _autoAcceptTrips.value;
  int get maxTripDistance => _maxTripDistance.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _initializeControllers();
    _loadDriverStats();
    _loadPreferences();
  }

  void _loadUserData() {
    user = _authController.currentUser!;
    _profileImageUrl.value = user.profileImage;
    _driverSince.value = user.createdAt;
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: user.fullName);
    emailController = TextEditingController(text: user.email ?? '');
    phoneController = TextEditingController(text: user.phone);
    licenseNumberController = TextEditingController(text: user.licenseNumber ?? '');
    licenseExpiryController = TextEditingController(
      text: user.licenseExpiry?.toString().substring(0, 10) ?? '',
    );
  }

  Future<void> _loadDriverStats() async {
    try {
      final response = await _apiClient.get('/driver/stats');
      if (response != null && response['data'] != null) {
        _totalTrips.value = response['data']['totalTrips'] ?? 0;
        _totalDistance.value = response['data']['totalDistance'] ?? 0;
        _rating.value = (response['data']['rating'] ?? 0.0).toDouble();
        _totalReviews.value = response['data']['totalReviews'] ?? 0;
      }
    } catch (e) {
      print('Error loading driver stats: $e');
    }
  }

  Future<void> _loadPreferences() async {
    try {
      _darkMode.value = _themeController.isDarkMode;
      _language.value = await _secureStorage.read(AppConstants.prefKeyLanguage) ?? 'en';
      _notificationsEnabled.value = await _secureStorage.readBoolOrDefault('driver_notifications', true);
      _autoAcceptTrips.value = await _secureStorage.readBoolOrDefault('auto_accept_trips', false);
      _maxTripDistance.value = await _secureStorage.readIntOrDefault('max_trip_distance', 100);
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
      AppSnackbar.show(
        'Error',
        'Failed to capture image',
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
      AppSnackbar.show(
        'Error',
        'Failed to pick image',
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

        await _authController.updateProfile({
          'profileImage': _profileImageUrl.value,
        });

        AppSnackbar.show(
          'Success',
          'Profile picture updated',
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      AppSnackbar.show(
        'Error',
        'Failed to upload image',
      );
    } finally {
      _isUploading.value = false;
    }
  }

  void toggleEditMode() {
    if (_isEditing.value) {
      // Cancel editing
      nameController.text = user.fullName;
      emailController.text = user.email ?? '';
      phoneController.text = user.phone;
      licenseNumberController.text = user.licenseNumber ?? '';
      licenseExpiryController.text = user.licenseExpiry?.toString().substring(0, 10) ?? '';
    }
    _isEditing.value = !_isEditing.value;
  }

  Future<void> saveProfile() async {
    try {
      _isSaving.value = true;

      final updates = {
        'fullName': nameController.text,
        'email': emailController.text.isEmpty ? null : emailController.text,
        'phone': phoneController.text,
        'licenseNumber': licenseNumberController.text.isEmpty ? null : licenseNumberController.text,
        'licenseExpiry': licenseExpiryController.text.isEmpty ? null : licenseExpiryController.text,
      };

      final success = await _authController.updateProfile(updates);

      if (success) {
        user = _authController.currentUser!;
        _isEditing.value = false;

        AppSnackbar.show(
          'Success',
          'Profile updated successfully',
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      AppSnackbar.show(
        'Error',
        'Failed to update profile',
      );
    } finally {
      _isSaving.value = false;
    }
  }

  void toggleDriverStatus(bool value) async {
    try {
      await _apiClient.post(
        '/driver/update-status',
        data: {'status': value ? 'online' : 'offline'},
      );

      _driverStatus.value = value;
    } catch (e) {
      print('Error toggling driver status: $e');
    }
  }

  void toggleNotifications(bool value) async {
    _notificationsEnabled.value = value;
    await _secureStorage.writeBool('driver_notifications', value);
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

  void toggleAutoAcceptTrips(bool value) async {
    _autoAcceptTrips.value = value;
    await _secureStorage.writeBool('auto_accept_trips', value);
  }

  void setMaxTripDistance(int distance) async {
    _maxTripDistance.value = distance;
    await _secureStorage.writeInt('max_trip_distance', distance);
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _authController.logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    licenseNumberController.dispose();
    licenseExpiryController.dispose();
    super.onClose();
  }
}