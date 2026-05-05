// lib/core/widgets/cards/cargo_card.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/core/utils/helpers/number_helper.dart';

class CargoCard extends StatelessWidget {
  final String trackingId;
  final String destination;
  final double weight;
  final double fee;
  final String status;
  final DateTime registeredDate;
  final VoidCallback onTap;
  final VoidCallback? onTrack;
  final VoidCallback? onReceipt;
  final bool showActions;

  const CargoCard({
    Key? key,
    required this.trackingId,
    required this.destination,
    required this.weight,
    required this.fee,
    required this.status,
    required this.registeredDate,
    required this.onTap,
    this.onTrack,
    this.onReceipt,
    this.showActions = true,
  }) : super(key: key);

  Color _getStatusColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status.toLowerCase()) {
      case 'registered':
        return isDark ? AppColors.infoLight : AppColors.info;
      case 'loaded':
      case 'in_transit':
        return isDark ? AppColors.warningLight : AppColors.warning;
      case 'delivered':
        return isDark ? AppColors.successLight : AppColors.success;
      case 'cancelled':
        return isDark ? AppColors.errorLight : AppColors.error;
      default:
        return isDark ? AppColors.grey500 : AppColors.grey600;
    }
  }

  String _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'registered':
        return '📦';
      case 'loaded':
        return '🚚';
      case 'in_transit':
        return '🚛';
      case 'delivered':
        return '✅';
      case 'cancelled':
        return '❌';
      default:
        return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            // Header with Tracking ID
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimens.padding8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                    child: Text(
                      _getStatusIcon(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: AppDimens.margin12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tracking ID',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          trackingId.toUpperCase(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: AppFonts.medium,
                            letterSpacing: 1,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.margin8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.padding8,
                      vertical: AppDimens.padding4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radius20),
                    ),
                    child: Text(
                      status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Cargo Details - Using Wrap for responsive layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: AppDimens.margin8,
                runSpacing: AppDimens.margin12,
                children: [
                  // Destination
                  SizedBox(
                    width: 100,
                    child: _buildDetailItem(
                      context,
                      icon: Icons.location_on_rounded,
                      label: 'Destination',
                      value: destination,
                    ),
                  ),
                  // Weight
                  SizedBox(
                    width: 80,
                    child: _buildDetailItem(
                      context,
                      icon: Icons.monitor_weight_rounded,
                      label: 'Weight',
                      value: NumberHelper.formatWeight(weight),
                    ),
                  ),
                  // Fee
                  SizedBox(
                    width: 80,
                    child: _buildDetailItem(
                      context,
                      icon: Icons.payments_rounded,
                      label: 'Fee',
                      value: CurrencyFormatter.forCargoFee(fee),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.margin12),

            // Footer
            Container(
              padding: const EdgeInsets.all(AppDimens.padding12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: AppDimens.iconSize14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: AppDimens.margin4),
                  Expanded(
                    child: Text(
                      'Registered ${DateFormatter.toRelative(registeredDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (showActions) ...[
                    if (onTrack != null)
                      TextButton(
                        onPressed: onTrack,
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('Track'),
                      ),
                    if (onReceipt != null)
                      TextButton(
                        onPressed: onReceipt,
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('Receipt'),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppDimens.iconSize16,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        const SizedBox(height: AppDimens.margin4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: AppFonts.medium,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}