// lib/modules/auth/views/reset_password_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/modules/auth/controllers/reset_password_controller.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../../core/widgets/loading/progress_indicator.dart';
import '../widgets/auth_header.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LoadingOverlay(
      isLoading: AuthController.instance.isLoading || controller.isLoading,
      message: 'Resetting password...',
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
                            Icons.password_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: AppDimens.margin16),
                        Text(
                          'Reset Password',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimens.margin8),
                        Text(
                          'Enter your new password',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.margin40),

                  // OTP Field
                  CustomTextField(
                    label: 'Verification Code',
                    controller: controller.otpController,
                    focusNode: controller.otpFocusNode,
                    onChanged: controller.validateOtp,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.pin_rounded,
                    errorText: controller.otpError,
                    maxLength: 6,
                  ),

                  const SizedBox(height: AppDimens.margin16),

                  // New Password
                  CustomTextField(
                    label: 'New Password',
                    controller: controller.newPasswordController,
                    focusNode: controller.newPasswordFocusNode,
                    obscureText: !controller.isPasswordVisible,
                    onChanged: controller.validateNewPassword,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.lock_rounded,
                    suffixIcon: controller.isPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    onSuffixTap: controller.togglePasswordVisibility,
                    errorText: controller.newPasswordError,
                  ),

                  // Password Strength Indicator
                  Obx(() => PasswordStrengthIndicator(
                    strength: controller.passwordStrength,
                    strengthColor: controller.getPasswordStrengthColor(),
                    strengthText: controller.getPasswordStrengthText(),
                  )),

                  const SizedBox(height: AppDimens.margin16),

                  // Confirm Password
                  CustomTextField(
                    label: 'Confirm Password',
                    controller: controller.confirmPasswordController,
                    focusNode: controller.confirmPasswordFocusNode,
                    obscureText: !controller.isConfirmPasswordVisible,
                    onChanged: controller.validateConfirmPassword,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_rounded,
                    suffixIcon: controller.isConfirmPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    onSuffixTap: controller.toggleConfirmPasswordVisibility,
                    errorText: controller.confirmPasswordError,
                  ),

                  const SizedBox(height: AppDimens.margin32),

                  // Reset Button
                  Obx(() => PrimaryButton(
                    text: 'Reset Password',
                    onPressed: controller.isFormValid ? controller.handleReset : null,
                    isDisabled: !controller.isFormValid,
                    icon: Icons.check_circle_rounded,
                  )),

                  const SizedBox(height: AppDimens.margin16),

                  // Resend Code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive code? ',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Obx(() => TextButton(
                        onPressed: controller.canResend ? controller.resendOtp : null,
                        child: Text(
                          controller.canResend
                              ? 'Resend'
                              : 'Resend in ${controller.timerSeconds}s',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: controller.canResend
                                ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                                : (isDark ? AppColors.textHintDark : AppColors.textHintLight),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                    ],
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