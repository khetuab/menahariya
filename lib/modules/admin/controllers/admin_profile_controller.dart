// lib/modules/admin/controllers/admin_profile_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../models/admin_models.dart';

class AdminProfileController extends GetxController {
  static AdminProfileController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Observables
  final _isLoading = false.obs;
  final _isSaving = false.obs;
  final _profile = Rxn<AdminProfile>();
  final _activityLogs = <ActivityLog>[].obs;

  // Form controllers
  late final TextEditingController fullNameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  // Profile image
  final _profileImage = Rxn<File>();
  final _profileImageUrl = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  AdminProfile? get profile => _profile.value;
  List<ActivityLog> get activityLogs => _activityLogs;
  File? get profileImage => _profileImage.value;
  String get profileImageUrl => _profileImageUrl.value;

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
        _profile.value = AdminProfile.fromJson(response['data']);
        _populateForm();
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
    _profileImageUrl.value = profile.profileImage ?? '';
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
    if (fullNameController.text.isEmpty || phoneController.text.isEmpty) {
      AppSnackbar.show('Error', 'Please fill all required fields');
      return;
    }

    try {
      _isSaving.value = true;

      // Create FormData for multipart request
      final formData = FormData.fromMap({
        'fullName': fullNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
      });

      // Add image file if selected
      if (_profileImage.value != null) {
        final file = _profileImage.value!;
        final fileExtension = file.path.split('.').last;
        final mimeType = _getMimeType(fileExtension);

        formData.files.add(
          MapEntry(
            'profileImage',
            await MultipartFile.fromFile(
              file.path,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.$fileExtension',
              contentType: DioMediaType.parse(mimeType),
            ),
          ),
        );
      }

      final response = await _apiClient.post(
        '/admin/profile/update',
        data: formData,
      );

      if (response != null && response['success'] == true) {
        await fetchProfile();
        AppSnackbar.show('Success', 'Profile updated successfully');
        Get.back();
      }
    } catch (e) {
      print('Error updating profile: $e');
      AppSnackbar.show('Error', 'Failed to update profile');
    } finally {
      _isSaving.value = false;
    }
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> changePassword() async {
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      AppSnackbar.show('Error', 'Please enter new password');
      return;
    }

    if (newPass != confirmPass) {
      AppSnackbar.show('Error', 'Passwords do not match');
      return;
    }

    if (newPass.length < 6) {
      AppSnackbar.show('Error', 'Password must be at least 6 characters');
      return;
    }

    try {
      _isSaving.value = true;

      final response = await _apiClient.post(
        '/admin/profile/change-password',
        data: {
          'currentPassword': currentPasswordController.text,
          'newPassword': newPass,
        },
      );

      if (response != null && response['success'] == true) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        AppSnackbar.show('Success', 'Password changed successfully');
        Get.back();
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
      }
    } catch (e) {
      print('Error picking image: $e');
      AppSnackbar.show('Error', 'Failed to pick image');
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
      }
    } catch (e) {
      print('Error taking photo: $e');
      AppSnackbar.show('Error', 'Failed to take photo');
    }
  }

  void removeProfileImage() {
    _profileImage.value = null;
    _profileImageUrl.value = '';
  }

  String formatDate(DateTime date) {
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