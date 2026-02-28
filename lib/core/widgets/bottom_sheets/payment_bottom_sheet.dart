// lib/core/widgets/bottom_sheets/payment_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';

import '../../services/payment/payment_service.dart';

class PaymentBottomSheet extends StatelessWidget {
  final double amount;
  final String bookingId;
  final String? description;
  final List<PaymentMethod> availableMethods;
  final Function(PaymentMethod) onPaymentSelected;
  final VoidCallback? onClose;

  const PaymentBottomSheet({
    Key? key,
    required this.amount,
    required this.bookingId,
    this.description,
    required this.availableMethods,
    required this.onPaymentSelected,
    this.onClose,
  }) : super(key: key);

  static Future<void> show({
    required double amount,
    required String bookingId,
    String? description,
    required List<PaymentMethod> methods,
    required Function(PaymentMethod) onSelected,
  }) {
    return Get.bottomSheet(
      PaymentBottomSheet(
        amount: amount,
        bookingId: bookingId,
        description: description,
        availableMethods: methods,
        onPaymentSelected: onSelected,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radius20),
          topRight: Radius.circular(AppDimens.radius20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppDimens.margin8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey700 : AppColors.grey300,
              borderRadius: BorderRadius.circular(AppDimens.radius2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Row(
              children: [
                Icon(
                  Icons.payments_rounded,
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  size: AppDimens.iconSize28,
                ),
                const SizedBox(width: AppDimens.margin12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete Payment',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: AppFonts.semiBold,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: AppDimens.margin4),
                        Text(
                          description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClose ?? () => Get.back(),
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ],
            ),
          ),

          // Amount
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.padding20,
              vertical: AppDimens.padding16,
            ),
            margin: const EdgeInsets.symmetric(horizontal: AppDimens.padding20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
                  isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight,
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(amount),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppDimens.padding8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.margin20),

          // Payment Methods
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Payment Method',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppFonts.medium,
                  ),
                ),
                const SizedBox(height: AppDimens.margin12),
                ...availableMethods.map((method) => _buildPaymentMethod(
                  context,
                  method,
                )),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.margin20),

          // Security Note
          Container(
            padding: const EdgeInsets.all(AppDimens.padding16),
            margin: const EdgeInsets.all(AppDimens.padding20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : AppColors.grey50,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  color: isDark ? AppColors.successLight : AppColors.success,
                  size: AppDimens.iconSize20,
                ),
                const SizedBox(width: AppDimens.margin8),
                Expanded(
                  child: Text(
                    'Your payment information is secure and encrypted',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context, PaymentMethod method) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.margin8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: ListTile(
        onTap: () => onPaymentSelected(method),
        leading: Container(
          padding: const EdgeInsets.all(AppDimens.padding8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
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
        title: Text(
          method.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: AppFonts.medium,
          ),
        ),
        subtitle: method.minAmount != null
            ? Text(
          'Min: ${CurrencyFormatter.format(method.minAmount!)}',
          style: theme.textTheme.bodySmall,
        )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}