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
import 'package:permission_handler/permission_handler.dart' as perm;

import '../../../core/utils/app_snackbar.dart';

class DriverProfileController extends GetxController {
  static DriverProfileController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorage _secureStorage = SecureStorage();
  final AuthController _authController = AuthController.instance;
  final ThemeController _themeController = ThemeController.to;

  // User data - make it observable and nullable initially
  final _user = Rxn<UserModel>();
  UserModel? get user => _user.value;

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
  final _driverStatus = true.obs;
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
    _initializeControllers();
    _loadUserData(); // This will set _user.value
    _loadDriverStats();
    _loadPreferences();
  }

  void _loadUserData() {
    final currentUser = _authController.currentUser;
    if (currentUser != null) {
      _user.value = currentUser;
      _profileImageUrl.value = currentUser.profileImage;
      _driverSince.value = currentUser.createdAt;

      // Update controllers after user is loaded
      nameController.text = currentUser.fullName;
      emailController.text = currentUser.email ?? '';
      phoneController.text = currentUser.phone;
      licenseNumberController.text = currentUser.licenseNumber ?? '';
      licenseExpiryController.text = currentUser.licenseExpiry?.toString().substring(0, 10) ?? '';
    }
  }

  void _initializeControllers() {
    // Initialize with empty values first, will be updated when user loads
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    licenseNumberController = TextEditingController();
    licenseExpiryController = TextEditingController();
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
    final status = await perm.Permission.camera.request();

    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        _showOpenSettingsDialog('Camera permission is permanently denied. Please enable it from app settings.');
      } else {
        AppSnackbar.show('Permission Required', 'Camera permission is needed to take photos');
      }
      return;
    }

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
      AppSnackbar.show('Error', 'Failed to capture image');
    }
  }

  Future<void> pickImageFromGallery() async {
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

  Future<void> saveProfile() async {
    if (user == null) {
      AppSnackbar.show('Error', 'User data not loaded');
      return;
    }

    if (nameController.text.trim().isEmpty) {
      AppSnackbar.show('Error', 'Full name is required');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      AppSnackbar.show('Error', 'Phone number is required');
      return;
    }

    final cleanPhone = phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length < 10) {
      AppSnackbar.show('Error', 'Please enter a valid phone number');
      return;
    }

    final email = emailController.text.trim();
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      AppSnackbar.show('Error', 'Please enter a valid email address');
      return;
    }

    if (licenseNumberController.text.trim().isEmpty) {
      AppSnackbar.show('Error', 'License number is required');
      return;
    }

    if (licenseExpiryController.text.trim().isEmpty) {
      AppSnackbar.show('Error', 'License expiry date is required');
      return;
    }

    try {
      _isSaving.value = true;

      final updates = {
        'fullName': nameController.text.trim(),
        'phone': cleanPhone,
        if (email.isNotEmpty) 'email': email,
        'licenseNumber': licenseNumberController.text.trim(),
        'licenseExpiry': licenseExpiryController.text.trim(),
      };

      final success = await _authController.updateProfile(updates);

      if (success) {
        final updatedUser = _authController.currentUser;
        if (updatedUser != null) {
          _user.value = updatedUser;
          _profileImageUrl.value = updatedUser.profileImage;

          nameController.text = updatedUser.fullName;
          emailController.text = updatedUser.email ?? '';
          phoneController.text = updatedUser.phone;
          licenseNumberController.text = updatedUser.licenseNumber ?? '';
          licenseExpiryController.text =
              updatedUser.licenseExpiry?.toString().substring(0, 10) ?? '';
        }

        _isEditing.value = false;
        AppSnackbar.show('Success', 'Profile updated successfully');
        Get.back();
      } else {
        AppSnackbar.show('Error', 'Failed to update profile');
      }
    } catch (e) {
      print('Error saving profile: $e');
      AppSnackbar.show('Error', 'Failed to update profile. Please try again.');
    } finally {
      _isSaving.value = false;
    }
  }

  void toggleEditMode() {
    if (user == null) return;

    if (_isEditing.value) {
      // Cancel editing - revert changes
      nameController.text = user!.fullName;
      emailController.text = user!.email ?? '';
      phoneController.text = user!.phone;
      licenseNumberController.text = user!.licenseNumber ?? '';
      licenseExpiryController.text = user!.licenseExpiry?.toString().substring(0, 10) ?? '';
    }
    _isEditing.value = !_isEditing.value;
  }

  void _showOpenSettingsDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              perm.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage.value == null) return;

    try {
      _isUploading.value = true;

      final response = await _apiClient.uploadFile(
        ApiEndpoints.usersUpdateAvatar,
        _profileImage.value!.path,
        fieldName: 'avatar',
      );

      print('📥 Upload response: $response');

      if (response != null && response['data'] != null) {
        String? imageUrl;

        if (response['data']['url'] != null) {
          imageUrl = response['data']['url'];
        } else if (response['data']['imageUrl'] != null) {
          imageUrl = response['data']['imageUrl'];
        } else if (response['data']['profileImage'] != null) {
          imageUrl = response['data']['profileImage'];
        } else if (response['data']['avatar'] != null) {
          imageUrl = response['data']['avatar'];
        }

        if (imageUrl != null) {
          _profileImageUrl.value = imageUrl;

          await _authController.updateProfile({
            'profileImage': imageUrl,
          });

          // Update local user
          if (_user.value != null) {
            _user.value = _user.value!.copyWith(profileImage: imageUrl);
          }

          AppSnackbar.show('Success', 'Profile picture updated');
        } else {
          throw Exception('No URL found in response: ${response['data']}');
        }
      } else {
        throw Exception('Invalid response: $response');
      }
    } catch (e) {
      print('Error uploading image: $e');
      AppSnackbar.show('Error', 'Failed to upload image: ${e.toString().split('\n')[0]}');
    } finally {
      _isUploading.value = false;
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