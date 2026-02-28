// lib/modules/auth/views/forgot_password_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/inputs/phone_field.dart';
import 'package:menahariya/modules/auth/controllers/forgot_password_controller.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';
import '../../../core/widgets/loading/progress_indicator.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LoadingOverlay(
      isLoading: AuthController.instance.isLoading || controller.isLoading,
      message: 'Sending OTP...',
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => controller.unfocusFields(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.padding24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                isDark ? AppColors.primaryGreen : AppColors.primaryGreenDark,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: AppDimens.margin16),
                        Text(
                          'Forgot Password?',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimens.margin8),
                        Text(
                          'Enter your phone number to reset your password',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.margin40),

                  // Phone Number Field
                  PhoneField(
                    controller: controller.phoneController,
                    focusNode: controller.phoneFocusNode,
                    onChanged: controller.validatePhone,
                    autoFocus: true,
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

                  const SizedBox(height: AppDimens.margin32),

                  // Submit Button
                  Obx(() => PrimaryButton(
                    text: 'Send Reset Code',
                    onPressed: controller.isFormValid ? controller.handleSubmit : null,
                    isDisabled: !controller.isFormValid,
                    icon: Icons.send_rounded,
                  )),

                  const SizedBox(height: AppDimens.margin16),

                  // Back to Login
                  Center(
                    child: TextButton(
                      onPressed: controller.goToLogin,
                      child: Text(
                        'Back to Login',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}