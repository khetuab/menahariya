// lib/modules/passenger/widgets/price_summary.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';

class PriceSummary extends StatelessWidget {
  final double subtotal;
  final double? insurance;
  final double? discount;
  final double? walletDeduction;
  final double total;
  final bool showBreakdown;

  const PriceSummary({
    Key? key,
    required this.subtotal,
    this.insurance,
    this.discount,
    this.walletDeduction,
    required this.total,
    this.showBreakdown = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          if (showBreakdown) ...[
            _buildRow(context, 'Subtotal', CurrencyFormatter.format(subtotal)),
            if (insurance != null)
              _buildRow(context, 'Insurance', CurrencyFormatter.format(insurance!)),
            if (discount != null)
              _buildRow(context, 'Discount', '-${CurrencyFormatter.format(discount!)}'),
            if (walletDeduction != null)
              _buildRow(context, 'Wallet', '-${CurrencyFormatter.format(walletDeduction!)}'),
            const Divider(height: AppDimens.margin24),
          ],
          _buildRow(
            context,
            'Total',
            CurrencyFormatter.format(total),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String amount, {bool isTotal = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
              fontWeight: AppFonts.semiBold,
            )
                : theme.textTheme.bodyMedium,
          ),
          Text(
            amount,
            style: isTotal
                ? theme.textTheme.titleLarge?.copyWith(
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              fontWeight: AppFonts.bold,
            )
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}