import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

class TwoFactorVerifyView extends GetView<AuthController> {
  const TwoFactorVerifyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tempToken = Get.arguments['tempToken'] as String;
    final userId = Get.arguments['userId'] as String;
    final phone = Get.arguments['phone'] as String?;

    final pinController = TextEditingController();
    final isLoading = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).viewInsets.bottom -
                  16,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.padding24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security_rounded,
                      size: 40,
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: AppDimens.margin24),
                  // Title
                  Text(
                    'Verification Required',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: AppFonts.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.margin8),
                  // Subtitle
                  Text(
                    'Enter the 6-digit code from your authenticator app',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (phone != null) ...[
                    const SizedBox(height: AppDimens.margin4),
                    Text(
                      phone,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppDimens.margin32),
                  // PIN Input
                  Pinput(
                    controller: pinController,
                    length: 6,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    obscureText: false,
                    pinAnimationType: PinAnimationType.fade,
                    defaultPinTheme: PinTheme(
                      width: 50,
                      height: 50,
                      textStyle: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey800 : AppColors.grey50,
                        borderRadius: BorderRadius.circular(AppDimens.radius12),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 50,
                      height: 50,
                      textStyle: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey800 : AppColors.grey50,
                        borderRadius: BorderRadius.circular(AppDimens.radius12),
                        border: Border.all(
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 50,
                      height: 50,
                      textStyle: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey800 : AppColors.grey50,
                        borderRadius: BorderRadius.circular(AppDimens.radius12),
                        border: Border.all(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                    ),
                    onCompleted: (pin) async {
                      isLoading.value = true;
                      final success = await controller.verify2FACode(pin, tempToken, userId);
                      isLoading.value = false;

                      if (!success) {
                        pinController.clear();
                        Get.snackbar(
                          'Invalid Code',
                          'The verification code you entered is incorrect',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppDimens.margin24),
                  // Verify Button
                  Obx(() => PrimaryButton(
                    text: 'Verify',
                    onPressed: isLoading.value ? null : () async {
                      if (pinController.text.length == 6) {
                        isLoading.value = true;
                        final success = await controller.verify2FACode(
                          pinController.text,
                          tempToken,
                          userId,
                        );
                        isLoading.value = false;

                        if (!success) {
                          pinController.clear();
                          Get.snackbar(
                            'Invalid Code',
                            'The verification code you entered is incorrect',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      } else {
                        Get.snackbar(
                          'Invalid Code',
                          'Please enter the 6-digit verification code',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    isLoading: isLoading.value,
                  )),
                  const SizedBox(height: AppDimens.margin16),
                  // Back to Login
                  SecondaryButton(
                    text: 'Back to Login',
                    onPressed: () => Get.offAllNamed('/auth/login'),
                    icon: Icons.arrow_back_rounded,
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