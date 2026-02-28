// lib/modules/auth/views/login_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_strings.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/widgets/inputs/phone_field.dart';
import 'package:menahariya/modules/auth/controllers/login_controller.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';
import 'package:menahariya/modules/auth/widgets/auth_header.dart';

import '../../../core/widgets/loading/progress_indicator.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LoadingOverlay(
      isLoading: AuthController.instance.isLoading,
      message: 'Logging in...',
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => controller.unfocusFields(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.padding24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with logo
                  const AuthHeader(
                    title: 'Welcome Back!',
                    subtitle: 'Login to continue your journey',
                  ),

                  const SizedBox(height: AppDimens.margin32),

                  // Form
                  Form(
                    child: Column(
                      children: [
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

                        const SizedBox(height: AppDimens.margin16),

                        // Password Field
                        CustomTextField(
                          label: AppStrings.password,
                          controller: controller.passwordController,
                          focusNode: controller.passwordFocusNode,
                          obscureText: !controller.isPasswordVisible,
                          onChanged: controller.validatePassword,
                          onSubmitted: (_) => controller.handleLogin(),
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.lock_rounded,
                          suffixIcon: controller.isPasswordVisible
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          onSuffixTap: controller.togglePasswordVisibility,
                          errorText: controller.passwordError,
                        ),

                        const SizedBox(height: AppDimens.margin8),

                        // Remember Me & Forgot Password
                        Row(
                          children: [
                            // Remember Me
                            Row(
                              children: [
                                Obx(() => Checkbox(
                                  value: controller.rememberMe,
                                  onChanged: controller.toggleRememberMe,
                                  activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                )),
                                Text(
                                  'Remember Me',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Forgot Password
                            TextButton(
                              onPressed: controller.goToForgotPassword,
                              child: Text(
                                'Forgot Password?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimens.margin32),

                        // Login Button
                        Obx(() => PrimaryButton(
                          text: 'Login',
                          onPressed: controller.isFormValid ? controller.handleLogin : null,
                          isDisabled: !controller.isFormValid,
                          icon: Icons.login_rounded,
                        )),

                        const SizedBox(height: AppDimens.margin16),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: theme.textTheme.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: controller.goToRegister,
                              child: Text(
                                'Sign Up',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimens.margin32),

                        // Or divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
                              child: Text(
                                'OR',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimens.margin24),

                        // Demo Login Buttons (for testing)
                        if (GetPlatform.isAndroid || GetPlatform.isIOS) ...[
                          SecondaryButton(
                            text: 'Continue as Guest',
                            onPressed: () {
                              // Implement guest login
                            },
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: AppDimens.margin12),
                          OutlinedButton.icon(
                            onPressed: () {
                              // Demo login - passenger
                              controller.phoneController.text = '0912345678';
                              controller.passwordController.text = 'Pass@123';
                              controller.handleLogin();
                            },
                            icon: Icon(
                              Icons.supervised_user_circle_rounded,
                              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            ),
                            label: Text(
                              'Demo Passenger',
                              style: TextStyle(
                                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                              ),
                              minimumSize: const Size(double.infinity, AppDimens.buttonHeightLarge),
                            ),
                          ),
                          const SizedBox(height: AppDimens.margin8),
                          OutlinedButton.icon(
                            onPressed: () {
                              // Demo login - driver
                              controller.phoneController.text = '0987654321';
                              controller.passwordController.text = 'Driver@123';
                              controller.handleLogin();
                            },
                            icon: Icon(
                              Icons.drive_eta_rounded,
                              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            ),
                            label: Text(
                              'Demo Driver',
                              style: TextStyle(
                                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                              ),
                              minimumSize: const Size(double.infinity, AppDimens.buttonHeightLarge),
                            ),
                          ),
                        ],
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