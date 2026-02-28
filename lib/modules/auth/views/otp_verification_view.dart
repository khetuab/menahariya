// lib/modules/auth/views/otp_verification_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/modules/auth/controllers/otp_controller.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../../core/widgets/loading/progress_indicator.dart';

class OtpVerificationView extends GetView<OtpController> {
  const OtpVerificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LoadingOverlay(
      isLoading: AuthController.instance.isLoading || controller.isVerifying,
      message: 'Verifying OTP...',
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.padding24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  onPressed: () => Get.back(),
                ),

                const SizedBox(height: AppDimens.margin20),

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
                          Icons.smartphone_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: AppDimens.margin16),
                      Text(
                        'Verify Phone Number',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimens.margin8),
                      Text(
                        'We\'ve sent a verification code to',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: AppDimens.margin4),
                      Text(
                        controller.phone,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.margin40),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    AppConstants.otpLength,
                        (index) => SizedBox(
                      width: 50,
                      height: 60,
                      child: TextFormField(
                        controller: controller.otpControllers[index],
                        focusNode: controller.otpFocusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radius12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radius12),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < AppConstants.otpLength - 1) {
                            controller.otpFocusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            controller.otpFocusNodes[index - 1].requestFocus();
                          }
                        },
                        onEditingComplete: () {
                          if (index == AppConstants.otpLength - 1) {
                            controller.verifyOtp();
                          }
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimens.margin32),

                // Verify Button
                Obx(() => PrimaryButton(
                  text: 'Verify',
                  onPressed: controller.isOtpComplete ? controller.verifyOtp : null,
                  isDisabled: !controller.isOtpComplete,
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

                const SizedBox(height: AppDimens.margin24),

                // Change Phone Number
                Center(
                  child: TextButton(
                    onPressed: controller.changePhoneNumber,
                    child: Text(
                      'Change Phone Number',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}