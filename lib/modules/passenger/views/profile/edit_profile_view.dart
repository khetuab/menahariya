// lib/modules/passenger/views/profile/edit_profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/widgets/inputs/phone_field.dart';
import 'package:menahariya/modules/passenger/controllers/profile_controller.dart';

class EditProfileView extends GetView<PassengerProfileController> {
  const EditProfileView({Key? key}) : super(key: key);

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
          onPressed: ()  {
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
            children: [
              // Profile Image
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
                    controller.user.fullName[0].toUpperCase(),
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

              // Edit Form
              CustomTextField(
                label: 'Full Name',
                controller: controller.nameController,
                onChanged: controller.validateName,
                errorText: controller.nameError,
                prefixIcon: Icons.person_rounded,
              ),

              const SizedBox(height: AppDimens.margin16),

              PhoneField(
                controller: controller.phoneController,
                onChanged: controller.validatePhone,
              ),
              if (controller.phoneError != null) ...[
                const SizedBox(height: AppDimens.margin4),
                Text(
                  controller.phoneError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.errorLight : AppColors.error,
                  ),
                ),
              ],

              const SizedBox(height: AppDimens.margin16),

              CustomTextField(
                label: 'Email (Optional)',
                controller: controller.emailController,
                onChanged: controller.validateEmail,
                errorText: controller.emailError,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_rounded,
              ),

              const SizedBox(height: AppDimens.margin16),

              CustomTextField(
                label: 'Address',
                controller: controller.addressController,
                prefixIcon: Icons.location_on_rounded,
              ),

              const SizedBox(height: AppDimens.margin16),

              CustomTextField(
                label: 'City',
                controller: controller.cityController,
                prefixIcon: Icons.location_city_rounded,
              ),

              const SizedBox(height: AppDimens.margin32),

              // Save Button
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Cancel',
                      onPressed: controller.toggleEditMode,
                    ),
                  ),
                  const SizedBox(width: AppDimens.margin12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Save Changes',
                      onPressed:
                        controller.canSaveProfile
                            ? controller.saveProfile
                            : null,

                      isDisabled: !controller.canSaveProfile,
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
              'Change Profile Picture',
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
          ],
        ),
      ),
    );
  }
}