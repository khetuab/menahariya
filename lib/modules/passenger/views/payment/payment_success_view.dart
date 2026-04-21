import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/data/models/booking/booking_model.dart';
import 'package:menahariya/data/models/payment/payment_model.dart';

import '../../../../core/services/payment/payment_service.dart';

class PaymentSuccessView extends StatefulWidget {
  const PaymentSuccessView({Key? key}) : super(key: key);

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView> {
  @override
  void initState() {
    super.initState();
    // Auto‑redirect to home after 3 seconds (adjust as needed)
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) Get.offAllNamed('/passenger/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Read arguments directly – no controller!
    final args = Get.arguments;
    final amount = (args?['amount'] ?? args?['finalTotal'] ?? 0).toDouble();
    final payment = args?['payment'] as PaymentModel?;
    final selectedMethod = args?['selectedMethod'] as PaymentMethod?;

    final formattedAmount = CurrencyFormatter.format(amount);
    final paymentMethodName = selectedMethod?.name ?? payment?.method ?? 'Cash';
    final transactionId = payment?.transactionId ?? 'N/A';
    final dateTime = DateTime.now().toString().substring(0, 16);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
              ),
              const SizedBox(height: AppDimens.margin32),
              Text(
                'Payment Successful!',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: AppFonts.bold),
              ),
              const SizedBox(height: AppDimens.margin8),
              Text(
                'Your booking has been confirmed',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppDimens.margin32),
              Container(
                padding: const EdgeInsets.all(AppDimens.padding20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppDimens.radius16),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(theme, isDark, 'Amount Paid', formattedAmount, isTotal: true),
                    const SizedBox(height: AppDimens.margin12),
                    _buildInfoRow(theme, isDark, 'Payment Method', paymentMethodName),
                    const SizedBox(height: AppDimens.margin12),
                    _buildInfoRow(theme, isDark, 'Transaction ID', transactionId, isMonospace: true),
                    const SizedBox(height: AppDimens.margin12),
                    _buildInfoRow(theme, isDark, 'Date & Time', dateTime),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.margin32),
              PrimaryButton(
                text: 'View My Tickets',
                onPressed: () => Get.offAllNamed('/passenger/my-tickets'),
                icon: Icons.confirmation_number_rounded,
              ),
              const SizedBox(height: AppDimens.margin12),
              SecondaryButton(
                text: 'Back to Home',
                onPressed: () => Get.offAllNamed('/passenger/home'),
                icon: Icons.home_rounded,
              ),
              const SizedBox(height: AppDimens.margin12),
              TextButton(onPressed: () {}, child: const Text('Download Receipt')),
              const SizedBox(height: AppDimens.margin16),
              Text(
                'Redirecting to home in a few seconds...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, bool isDark, String label, String value,
      {bool isTotal = false, bool isMonospace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        // Wrap the value with Expanded to prevent overflow
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: isTotal
                ? theme.textTheme.titleLarge?.copyWith(
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              fontWeight: AppFonts.bold,
            )
                : theme.textTheme.bodyMedium?.copyWith(
              fontFamily: isMonospace ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }
}