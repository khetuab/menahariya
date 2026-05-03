// lib/modules/admin/controllers/admin_profile_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../config/environment/env_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/services/storage/secure_storage.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/admin_models.dart';

class AdminProfileController extends GetxController {
  static AdminProfileController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorage _secureStorage = SecureStorage();
  final AuthController _authController = Get.find<AuthController>();

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
  }

  void _initializeControllers() {
    fullNameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  Future<void> fetchProfile() async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get('/admin/profile');
      if (response != null && response['data'] != null) {
        final profileData = response['data'];
        _profile.value = AdminProfile.fromJson(profileData);
        _populateForm();

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
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
      AppSnackbar.show('Error', 'Failed to load profile');
    } finally {
      _isLoading.value = false;
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