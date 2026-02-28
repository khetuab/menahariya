// lib/modules/auth/views/register_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_strings.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/widgets/inputs/phone_field.dart';
import 'package:menahariya/modules/auth/controllers/register_controller.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';
import 'package:menahariya/modules/auth/widgets/auth_header.dart';

import '../../../core/widgets/loading/progress_indicator.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LoadingOverlay(
      isLoading: AuthController.instance.isLoading,
      message: 'Creating account...',
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => controller.unfocusFields(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.padding24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const AuthHeader(
                    title: 'Create Account',
                    subtitle: 'Sign up to get started',
                  ),

                  const SizedBox(height: AppDimens.margin32),

                  // Form
                  Form(
                    child: Column(
                      children: [
                        // Full Name
                        CustomTextField(
                          label: 'Full Name',
                          controller: controller.fullNameController,
                          focusNode: controller.fullNameFocusNode,
                          onChanged: controller.validateFullName,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.person_rounded,
                          errorText: controller.fullNameError,
                        ),

                        const SizedBox(height: AppDimens.margin16),

                        // Phone Number
                        PhoneField(
                          controller: controller.phoneController,
                          focusNode: controller.phoneFocusNode,
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

                        // Email (optional)
                        CustomTextField(
                          label: 'Email (Optional)',
                          controller: controller.emailController,
                          focusNode: controller.emailFocusNode,
                          onChanged: controller.validateEmail,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_rounded,
                          errorText: controller.emailError,
                        ),

                        const SizedBox(height: AppDimens.margin16),

                        // Password
                        CustomTextField(
                          label: AppStrings.password,
                          controller: controller.passwordController,
                          focusNode: controller.passwordFocusNode,
                          obscureText: !controller.isPasswordVisible,
                          onChanged: controller.validatePassword,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.lock_rounded,
                          suffixIcon: controller.isPasswordVisible
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          onSuffixTap: controller.togglePasswordVisibility,
                          errorText: controller.passwordError,
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

                        const SizedBox(height: AppDimens.margin24),

                        // Terms and Conditions
                        Row(
                          children: [
                            Obx(() => Checkbox(
                              value: controller.agreeToTerms,
                              onChanged: controller.toggleTermsAgreement,
                              activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            )),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.toggleTermsAgreement(!controller.agreeToTerms),
                                child: RichText(
                                  text: TextSpan(
                                    style: theme.textTheme.bodyMedium,
                                    children: [
                                      const TextSpan(
                                        text: 'I agree to the ',
                                      ),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: null, // Add tap recognizer
                                      ),
                                      const TextSpan(
                                        text: ' and ',
                                      ),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: null, // Add tap recognizer
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (controller.termsError != null) ...[
                          const SizedBox(height: AppDimens.margin4),
                          Text(
                            controller.termsError!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.errorLight : AppColors.error,
                            ),
                          ),
                        ],

                        const SizedBox(height: AppDimens.margin32),

                        // Register Button
                        Obx(() => PrimaryButton(
                          text: 'Create Account',
                          onPressed: controller.isFormValid ? controller.handleRegister : null,
                          isDisabled: !controller.isFormValid,
                          icon: Icons.app_registration_rounded,
                        )),

                        const SizedBox(height: AppDimens.margin16),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: theme.textTheme.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: controller.goToLogin,
                              child: Text(
                                'Login',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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