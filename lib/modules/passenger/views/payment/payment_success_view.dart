// lib/modules/passenger/views/payment/payment_success_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/modules/passenger/controllers/payment_controller.dart';

class PaymentSuccessView extends GetView<PassengerPaymentController> {
  const PaymentSuccessView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Animation (you can add Lottie here)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.success, AppColors.successLight],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: AppDimens.shadowBlurLarge,
                      spreadRadius: AppDimens.shadowSpreadSmall,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),

              const SizedBox(height: AppDimens.margin32),

              // Success Message
              Text(
                'Payment Successful!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppFonts.bold,
                ),
              ),

              const SizedBox(height: AppDimens.margin8),

              Text(
                'Your booking has been confirmed',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: AppDimens.margin32),

              // Payment Details
              Container(
                padding: const EdgeInsets.all(AppDimens.padding20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppDimens.radius16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Amount Paid'),
                        Text(
                          controller.formattedAmount,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.margin12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment Method'),
                        Text(
                          controller.selectedMethod?.name ?? '',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: AppFonts.medium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.margin12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Transaction ID'),
                        Text(
                          controller.payment?.transactionId ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.margin12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date & Time'),
                        Text(
                          DateTime.now().toString().substring(0, 16),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.margin32),

              // Action Buttons
              PrimaryButton(
                text: 'View My Tickets',
                onPressed: () => Get.offAllNamed('/passenger/tickets'),
                icon: Icons.confirmation_number_rounded,
              ),

              const SizedBox(height: AppDimens.margin12),

              SecondaryButton(
                text: 'Back to Home',
                onPressed: () => Get.offAllNamed('/passenger/dashboard'),
                icon: Icons.home_rounded,
              ),

              const SizedBox(height: AppDimens.margin12),

              TextButton(
                onPressed: () {
                  // Download receipt
                },
                child: const Text('Download Receipt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}