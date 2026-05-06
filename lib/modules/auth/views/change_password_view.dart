import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/utils/validators/auth_validator.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

class ChangePasswordView extends GetView<AuthController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final isCurrentPasswordVisible = false.obs;
    final isNewPasswordVisible = false.obs;
    final isConfirmPasswordVisible = false.obs;

    final isLoading = false.obs;
    final isFormValid = false.obs;

    final currentPasswordError = RxnString();
    final newPasswordError = RxnString();
    final confirmPasswordError = RxnString();

    void updateFormValidity() {
      isFormValid.value =
          currentPasswordController.text.trim().isNotEmpty &&
              newPasswordController.text.trim().isNotEmpty &&
              confirmPasswordController.text.trim().isNotEmpty &&
              currentPasswordError.value == null &&
              newPasswordError.value == null &&
              confirmPasswordError.value == null;
    }

    void validateCurrentPassword(String value) {
      currentPasswordError.value =
      value.trim().isEmpty
          ? 'Current password is required'
          : null;

      updateFormValidity();
    }

    void validateNewPassword(String value) {
      newPasswordError.value =
          AuthValidator.validatePassword(value);

      if (confirmPasswordController.text.isNotEmpty) {
        confirmPasswordError.value =
            AuthValidator.validateConfirmPassword(
              value,
              confirmPasswordController.text,
            );
      }

      updateFormValidity();
    }

    void validateConfirmPassword(String value) {
      confirmPasswordError.value =
          AuthValidator.validateConfirmPassword(
            newPasswordController.text,
            value,
          );

      updateFormValidity();
    }

    Future<void> changePassword() async {
      validateCurrentPassword(
        currentPasswordController.text,
      );

      validateNewPassword(
        newPasswordController.text,
      );

      validateConfirmPassword(
        confirmPasswordController.text,
      );

      if (!isFormValid.value) return;

      isLoading.value = true;

      final success = await controller.changePassword(
        currentPassword:
        currentPasswordController.text.trim(),
        newPassword:
        newPasswordController.text.trim(),
      );

      isLoading.value = false;

      if (success) {
        Get.back();

        Get.snackbar(
          'Success',
          'Password changed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to change password. Check your current password.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor:
        isDark
            ? AppColors.surfaceDark
            : AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(AppDimens.padding24),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: AppDimens.margin16,
              ),

              // Current Password
              Obx(
                    () => CustomTextField(
                  label: 'Current Password',
                  controller:
                  currentPasswordController,
                  obscureText:
                  !isCurrentPasswordVisible
                      .value,
                  onChanged:
                  validateCurrentPassword,
                  prefixIcon:
                  Icons.lock_rounded,
                  suffixIcon:
                  isCurrentPasswordVisible
                      .value
                      ? Icons
                      .visibility_off_rounded
                      : Icons
                      .visibility_rounded,
                  onSuffixTap: () =>
                      isCurrentPasswordVisible
                          .toggle(),
                  errorText:
                  currentPasswordError
                      .value,
                ),
              ),

              const SizedBox(
                height: AppDimens.margin16,
              ),

              // New Password
              Obx(
                    () => CustomTextField(
                  label: 'New Password',
                  controller:
                  newPasswordController,
                  obscureText:
                  !isNewPasswordVisible.value,
                  onChanged:
                  validateNewPassword,
                  prefixIcon:
                  Icons.lock_outline_rounded,
                  suffixIcon:
                  isNewPasswordVisible.value
                      ? Icons
                      .visibility_off_rounded
                      : Icons
                      .visibility_rounded,
                  onSuffixTap: () =>
                      isNewPasswordVisible
                          .toggle(),
                  errorText:
                  newPasswordError.value,
                  helperText:
                  'Password must be at least 6 characters',
                ),
              ),

              const SizedBox(
                height: AppDimens.margin16,
              ),

              // Confirm Password
              Obx(
                    () => CustomTextField(
                  label:
                  'Confirm New Password',
                  controller:
                  confirmPasswordController,
                  obscureText:
                  !isConfirmPasswordVisible
                      .value,
                  onChanged:
                  validateConfirmPassword,
                  prefixIcon:
                  Icons.lock_outline_rounded,
                  suffixIcon:
                  isConfirmPasswordVisible
                      .value
                      ? Icons
                      .visibility_off_rounded
                      : Icons
                      .visibility_rounded,
                  onSuffixTap: () =>
                      isConfirmPasswordVisible
                          .toggle(),
                  errorText:
                  confirmPasswordError
                      .value,
                ),
              ),

              const SizedBox(
                height: AppDimens.margin32,
              ),

              // Change Password Button
              Obx(
                    () => PrimaryButton(
                  text: 'Change Password',
                  onPressed:
                  (!isLoading.value &&
                      isFormValid.value)
                      ? changePassword
                      : null,
                  isLoading: isLoading.value,
                  icon: Icons.save_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}