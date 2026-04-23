// lib/modules/driver/views/profile/edit_profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/widgets/inputs/phone_field.dart';
import 'package:menahariya/modules/driver/controllers/profile_controller.dart';

class DriverEditProfileView extends GetView<DriverProfileController> {
  const DriverEditProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            controller.toggleEditMode();
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        if (controller.isSaving) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: isDark ? AppColors.grey800 : AppColors.grey200,
                      backgroundImage: controller.profileImage != null
                          ? FileImage(controller.profileImage!) as ImageProvider
                          : controller.profileImageUrl != null
                          ? NetworkImage(controller.profileImageUrl!) as ImageProvider
                          : null,
                      child: controller.profileImage == null &&
                          controller.profileImageUrl == null
                          ? Text(
                        controller.user!.fullName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 40),
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showImagePickerDialog(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.margin24),

              // Form Fields
              CustomTextField(
                label: 'Full Name',
                controller: controller.nameController,
                prefixIcon: Icons.person_rounded,
                onChanged: (_) => _validateName(),
                errorText: _getNameError(),
              ),

              const SizedBox(height: AppDimens.margin16),

              PhoneField(
                controller: controller.phoneController,
                onChanged: (_) => _validatePhone(),
              ),

              const SizedBox(height: AppDimens.margin16),

              CustomTextField(
                label: 'Email (Optional)',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_rounded,
                onChanged: (_) => _validateEmail(),
                errorText: _getEmailError(),
              ),

              const SizedBox(height: AppDimens.margin16),

              CustomTextField(
                label: 'License Number',
                controller: controller.licenseNumberController,
                prefixIcon: Icons.badge_rounded,
                onChanged: (_) => _validateLicense(),
                errorText: _getLicenseError(),
              ),

              const SizedBox(height: AppDimens.margin16),

              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: 'License Expiry Date',
                    controller: controller.licenseExpiryController,
                    prefixIcon: Icons.calendar_today_rounded,
                    hint: 'YYYY-MM-DD',
                    onChanged: (_) => _validateLicenseExpiry(),
                    errorText: _getLicenseExpiryError(),
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.margin32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Cancel',
                      onPressed: () {
                        controller.toggleEditMode();
                        Get.back();
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimens.margin12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Save Changes',
                      onPressed: _canSave() ? controller.saveProfile : null,
                      isDisabled: !_canSave(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showImagePickerDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimens.padding20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimens.radius20),
            topRight: Radius.circular(AppDimens.radius20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimens.margin20),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                controller.pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                controller.pickImageFromGallery();
              },
            ),
            if (controller.profileImageUrl != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  _removeProfileImage();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _removeProfileImage() async {
    // Implement remove profile image functionality
    Get.snackbar(
      'Remove Photo',
      'Profile photo removal feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.licenseExpiryController.text =
      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _validateLicenseExpiry();
    }
  }

  // Validation methods
  String? _getNameError() {
    if (controller.nameController.text.isEmpty) {
      return 'Full name is required';
    }
    if (controller.nameController.text.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _getPhoneError() {
    final phone = controller.phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) {
      return 'Phone number is required';
    }
    if (phone.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _getEmailError() {
    final email = controller.emailController.text;
    if (email.isEmpty) return null;
    if (!GetUtils.isEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _getLicenseError() {
    if (controller.licenseNumberController.text.isEmpty) {
      return 'License number is required for drivers';
    }
    if (controller.licenseNumberController.text.length < 5) {
      return 'Please enter a valid license number';
    }
    return null;
  }

  String? _getLicenseExpiryError() {
    if (controller.licenseExpiryController.text.isEmpty) {
      return 'License expiry date is required';
    }
    return null;
  }

  bool _canSave() {
    return _getNameError() == null &&
        _getPhoneError() == null &&
        _getEmailError() == null &&
        _getLicenseError() == null &&
        _getLicenseExpiryError() == null &&
        controller.nameController.text.isNotEmpty &&
        controller.phoneController.text.isNotEmpty;
  }

  void _validateName() {
    // Trigger rebuild for error display
    controller.update();
  }

  void _validatePhone() {
    controller.update();
  }

  void _validateEmail() {
    controller.update();
  }

  void _validateLicense() {
    controller.update();
  }

  void _validateLicenseExpiry() {
    controller.update();
  }
}