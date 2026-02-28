// lib/modules/passenger/views/payment/payment_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/modules/passenger/controllers/payment_controller.dart';

import '../../../../core/services/payment/payment_service.dart';

class PaymentView extends GetView<PassengerPaymentController> {
  const PaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: controller.cancelPayment,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timer
              Container(
                padding: const EdgeInsets.all(AppDimens.padding16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      color: controller.countdownSeconds < 60
                          ? AppColors.error
                          : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complete payment within',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            controller.countdownText,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: controller.countdownSeconds < 60
                                  ? AppColors.error
                                  : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                              fontWeight: AppFonts.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      controller.formattedAmount,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.margin24),

              // Payment Methods
              Text(
                'Select Payment Method',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              const SizedBox(height: AppDimens.margin12),

              Obx(() => Column(
                children: controller.paymentMethods.map((method) {
                  return _buildPaymentMethodCard(context, method);
                }).toList(),
              )),

              const SizedBox(height: AppDimens.margin24),

              // Payment Form (based on selected method)
              Obx(() {
                if (controller.selectedMethod == null) return const SizedBox();

                switch (controller.selectedMethod!.code) {
                  case 'telebirr':
                  case 'cbe_birr':
                    return _buildMobileMoneyForm(context);
                  case 'card':
                    return _buildCardForm(context);
                  case 'wallet':
                    return _buildWalletPayment(context);
                  default:
                    return const SizedBox();
                }
              }),

              const SizedBox(height: AppDimens.margin24),

              // Pay Button
              Obx(() => PrimaryButton(
                text: 'Pay ${controller.formattedAmount}',
                onPressed: controller.initiatePayment,
                isDisabled: controller.isProcessing,
                isLoading: controller.isProcessing,
                icon: Icons.lock_rounded,
              )),

              const SizedBox(height: AppDimens.margin12),

              // Security Note
              Center(
                child: Text(
                  '🔒 Secured by SSL Encryption',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, PaymentMethod method) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = controller.selectedMethod?.code == method.code;

    return GestureDetector(
      onTap: () => controller.selectPaymentMethod(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin8),
        padding: const EdgeInsets.all(AppDimens.padding12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey800 : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.padding8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey700 : AppColors.grey100,
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
              child: method.icon != null
                  ? Image.asset(
                method.icon!,
                width: 24,
                height: 24,
              )
                  : Icon(
                Icons.payment_rounded,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: AppDimens.margin12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (method.minAmount != null)
                    Text(
                      'Min: ${CurrencyFormatter.format(method.minAmount!)}',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Radio(
              value: method.code,
              groupValue: controller.selectedMethod?.code,
              onChanged: (value) => controller.selectPaymentMethod(method),
              activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileMoneyForm(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Money Number',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: AppFonts.medium,
          ),
        ),
        const SizedBox(height: AppDimens.margin8),
        CustomTextField(
          controller: controller.mobileMoneyPhoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_rounded,
          hint: 'Enter your mobile money number',
          label: 'Money number',
        ),
      ],
    );
  }

  Widget _buildCardForm(BuildContext context) {
    return Column(
      children: [
        // Card Number
        CustomTextField(
          controller: controller.cardNumberController,
          label: 'Card Number',
          keyboardType: TextInputType.number,
          onChanged: (_) => controller.formatCardNumber(controller.cardNumberController.text),
          prefixIcon: Icons.credit_card_rounded,
          hint: '1234 5678 9012 3456',
          maxLength: 19,
        ),
        const SizedBox(height: AppDimens.margin12),

        // Card Holder Name
        CustomTextField(
          controller: controller.cardNameController,
          label: 'Card Holder Name',
          prefixIcon: Icons.person_rounded,
          hint: 'Name on card',
        ),
        const SizedBox(height: AppDimens.margin12),

        // Expiry and CVV
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller.cardExpiryController,
                label: 'Expiry',
                onChanged: (_) => controller.formatExpiry(controller.cardExpiryController.text),
                prefixIcon: Icons.calendar_today_rounded,
                hint: 'MM/YY',
                maxLength: 5,
              ),
            ),
            const SizedBox(width: AppDimens.margin12),
            Expanded(
              child: CustomTextField(
                controller: controller.cardCvvController,
                label: 'CVV',
                onChanged: (_) => controller.formatCvv(controller.cardCvvController.text),
                prefixIcon: Icons.lock_rounded,
                hint: '123',
                maxLength: 3,
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletPayment(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
              const SizedBox(width: AppDimens.margin12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Balance',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      CurrencyFormatter.format(controller.amount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}