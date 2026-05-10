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
import 'driver_state_controller.dart';

class DriverProfileController extends GetxController {
  static DriverProfileController get instance => Get.find();
  final DriverStateController _driverStateController = Get.find<DriverStateController>();

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

  // Availability Settings
  final _workingHours = <String, WorkingHours>{}.obs;
  final _customWorkingHours = <String, WorkingHours>{}.obs;
  final _restDays = <String, bool>{}.obs;
  final _preferredTripTypes = <String, bool>{}.obs;
  final _isAvailabilitySaving = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  bool get isUploading => _isUploading.value;
  File? get profileImage => _profileImage.value;
  String? get profileImageUrl => _profileImageUrl.value;
  bool get isEditing => _isEditing.value;
  bool get isOnline => _driverStateController.isOnline.value;

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
  bool get isAvailabilitySaving => _isAvailabilitySaving.value;

  // Availability Getters
  Map<String, WorkingHours> get workingHours => _workingHours;
  Map<String, WorkingHours> get customWorkingHours => _customWorkingHours;
  Map<String, bool> get restDays => _restDays;
  Map<String, bool> get preferredTripTypes => _preferredTripTypes;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadUserData();
    _loadDriverStats();
    _loadPreferences();
    loadAvailabilitySettings();
  }

  void _loadUserData() {
    final currentUser = _authController.currentUser;
    if (currentUser != null) {
      _user.value = currentUser;
      _profileImageUrl.value = currentUser.profileImage;
      _driverSince.value = currentUser.createdAt;

      nameController.text = currentUser.fullName;
      emailController.text = currentUser.email ?? '';
      phoneController.text = currentUser.phone;
      licenseNumberController.text = currentUser.licenseNumber ?? '';
      licenseExpiryController.text = currentUser.licenseExpiry?.toString().substring(0, 10) ?? '';
    }
  }

  void _initializeControllers() {
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

  Future<void> toggleDriverStatus(bool value) async {
    await _driverStateController.updateDriverStatus(value);
    // Refresh availability settings after status change
    await loadAvailabilitySettings();
  }
  Future<void> loadAvailabilitySettings() async {
    _isLoading.value = true;
    try {
      final response = await _apiClient.get('/driver/availability-settings');
      if (response != null && response['data'] != null) {
        final data = response['data'];

        // Load working hours
        if (data['workingHours'] != null) {
          final hours = data['workingHours'] as Map<String, dynamic>;
          hours.forEach((day, schedule) {
            if (schedule['isCustom'] == true) {
              _customWorkingHours[day] = WorkingHours.fromJson(schedule);
            } else {
              _workingHours[day] = WorkingHours.fromJson(schedule);
            }
          });
        } else {
          // Set default working hours
          _setDefaultWorkingHours();
        }

        // Load rest days
        if (data['restDays'] != null) {
          _restDays.addAll((data['restDays'] as Map).map((key, value) => MapEntry(key, value as bool)));
        } else {
          _setDefaultRestDays();
        }

        // Load preferred trip types
        if (data['preferredTripTypes'] != null) {
          _preferredTripTypes.addAll((data['preferredTripTypes'] as Map).map((key, value) => MapEntry(key, value as bool)));
        } else {
          _setDefaultTripTypes();
        }

        // Load driver status
        if (data['isOnline'] != null) {
          _driverStatus.value = data['isOnline'] as bool;
        }

        // Load auto-accept setting
        if (data['autoAcceptTrips'] != null) {
          _autoAcceptTrips.value = data['autoAcceptTrips'] as bool;
        }

        // Load max trip distance
        if (data['maxTripDistance'] != null) {
          _maxTripDistance.value = data['maxTripDistance'] as int;
        }
      } else {
        _setDefaultWorkingHours();
        _setDefaultRestDays();
        _setDefaultTripTypes();
      }
    } catch (e) {
      print('Error loading availability settings: $e');
      _setDefaultWorkingHours();
      _setDefaultRestDays();
      _setDefaultTripTypes();
    } finally {
      _isLoading.value = false;
    }
  }

  void _setDefaultWorkingHours() {
    _workingHours.clear();
    _workingHours['Monday - Friday'] = WorkingHours(
      startTime: '08:00',
      endTime: '18:00',
      isClosed: false,
    );
    _workingHours['Saturday'] = WorkingHours(
      startTime: '09:00',
      endTime: '16:00',
      isClosed: false,
    );
    _workingHours['Sunday'] = WorkingHours(
      startTime: '00:00',
      endTime: '00:00',
      isClosed: true,
    );
  }

  void _setDefaultRestDays() {
    _restDays.clear();
    _restDays['Monday'] = false;
    _restDays['Tuesday'] = false;
    _restDays['Wednesday'] = false;
    _restDays['Thursday'] = false;
    _restDays['Friday'] = false;
    _restDays['Saturday'] = false;
    _restDays['Sunday'] = false;
  }

  void _setDefaultTripTypes() {
    _preferredTripTypes.clear();
    _preferredTripTypes['Standard'] = true;
    _preferredTripTypes['Executive'] = false;
    _preferredTripTypes['VIP'] = true;
    _preferredTripTypes['Luxury'] = false;
    _preferredTripTypes['Night trips'] = true;
    _preferredTripTypes['Long distance'] = false;
  }

  // Working Hours Methods
  void updateWorkingHours(String day, String startTime, String endTime) {
    if (_workingHours.containsKey(day)) {
      _workingHours[day] = WorkingHours(
        startTime: startTime,
        endTime: endTime,
        isClosed: false,
      );
    } else if (_customWorkingHours.containsKey(day)) {
      _customWorkingHours[day] = WorkingHours(
        startTime: startTime,
        endTime: endTime,
        isClosed: false,
        isCustom: true,
      );
    }
  }

  void addCustomWorkingHours(String day, String startTime, String endTime) {
    // Remove from regular working hours if exists
    _workingHours.remove(day);

    _customWorkingHours[day] = WorkingHours(
      startTime: startTime,
      endTime: endTime,
      isClosed: false,
      isCustom: true,
    );
  }

  void removeCustomWorkingHours(String day) {
    _customWorkingHours.remove(day);
    // Optionally restore default
    if (day == 'Monday - Friday' || day == 'Saturday' || day == 'Sunday') {
      if (day == 'Monday - Friday') {
        _workingHours[day] = WorkingHours(startTime: '08:00', endTime: '18:00');
      } else if (day == 'Saturday') {
        _workingHours[day] = WorkingHours(startTime: '09:00', endTime: '16:00');
      } else if (day == 'Sunday') {
        _workingHours[day] = WorkingHours(startTime: '00:00', endTime: '00:00', isClosed: true);
      }
    }
  }

  void updateRestDay(String day, bool isRestDay) {
    _restDays[day] = isRestDay;
  }

  void updateTripPreference(String type, bool isSelected) {
    _preferredTripTypes[type] = isSelected;
  }

  Future<bool> saveAvailabilitySettings() async {
    _isAvailabilitySaving.value = true;

    try {
      final Map<String, dynamic> workingHoursMap = {};

      _workingHours.forEach((day, hours) {
        workingHoursMap[day] = {
          'startTime': hours.startTime,
          'endTime': hours.endTime,
          'isClosed': hours.isClosed,
          'isCustom': false,
        };
      });

      _customWorkingHours.forEach((day, hours) {
        workingHoursMap[day] = {
          'startTime': hours.startTime,
          'endTime': hours.endTime,
          'isClosed': hours.isClosed,
          'isCustom': true,
        };
      });

      final data = {
        'workingHours': workingHoursMap,
        'restDays': Map.from(_restDays),
        'preferredTripTypes': Map.from(_preferredTripTypes),
        'autoAcceptTrips': _autoAcceptTrips.value,
        'maxTripDistance': _maxTripDistance.value,
      };

      final response = await _apiClient.post(
        '/driver/availability-settings',
        data: data,
      );

      if (response != null && response['success'] == true) {
        // Refresh centralized state
        await _driverStateController.refreshStatus();

        AppSnackbar.show('Success', 'Availability settings saved successfully');
        return true;
      } else {
        AppSnackbar.show('Error', response?['message'] ?? 'Failed to save settings');
        return false;
      }
    } catch (e) {
      print('Error saving availability settings: $e');
      AppSnackbar.show('Error', 'Failed to save settings. Please try again.');
      return false;
    } finally {
      _isAvailabilitySaving.value = false;
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
        _profileImage.value = File(pickedFile.path);
        await _uploadProfileImage();
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
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

// Working Hours Model
class WorkingHours {
  final String startTime;
  final String endTime;
  final bool isClosed;
  final bool isCustom;

  WorkingHours({
    required this.startTime,
    required this.endTime,
    this.isClosed = false,
    this.isCustom = false,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      startTime: json['startTime'] ?? '00:00',
      endTime: json['endTime'] ?? '00:00',
      isClosed: json['isClosed'] ?? false,
      isCustom: json['isCustom'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isClosed': isClosed,
      'isCustom': isCustom,
    };
  }
}