// lib/modules/driver/widgets/validation_success_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';

class ValidationSuccessWidget extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onConfirm;
  final VoidCallback? onReject;
  final VoidCallback? onScanAnother;

  const ValidationSuccessWidget({
    Key? key,
    required this.ticket,
    required this.onConfirm,
    this.onReject,
    this.onScanAnother,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success animation placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.success.withOpacity(0.2) : AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: isDark ? AppColors.successLight : AppColors.success,
              size: 48,
            ),
          ),

          const SizedBox(height: AppDimens.margin16),

          Text(
            'Ticket Validated!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDark ? AppColors.successLight : AppColors.success,
              fontWeight: AppFonts.bold,
            ),
          ),

          const SizedBox(height: AppDimens.margin8),

          Text(
            'Passenger information verified',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),

          const SizedBox(height: AppDimens.margin24),

          // Passenger info card
          Container(
            padding: const EdgeInsets.all(AppDimens.padding16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : AppColors.grey50,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
              border: Border.all(
                color: isDark ? AppColors.successLight : AppColors.success,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      child: Text(
                        ticket.passengerName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.passengerName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: AppFonts.semiBold,
                            ),
                          ),
                          Text(
                            'Seat ${ticket.seatNumber}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimens.margin12),

                const Divider(),

                const SizedBox(height: AppDimens.margin8),

                // Ticket details
                _buildDetailRow(
                  context,
                  icon: Icons.route_rounded,
                  label: 'Route',
                  value: '${ticket.origin} → ${ticket.destination}',
                ),

                const SizedBox(height: AppDimens.margin8),

                _buildDetailRow(
                  context,
                  icon: Icons.access_time_rounded,
                  label: 'Departure',
                  value: _formatDateTime(ticket.departureTime),
                ),

                if (ticket.hasCargo) ...[
                  const SizedBox(height: AppDimens.margin8),
                  _buildDetailRow(
                    context,
                    icon: Icons.inventory_2_rounded,
                    label: 'Cargo',
                    value: 'Has cargo items',
                    highlight: true,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppDimens.margin24),

          // Action buttons
          Row(
            children: [
              if (onReject != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.errorLight : AppColors.error,
                      side: BorderSide(
                        color: isDark ? AppColors.errorLight : AppColors.error,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              if (onReject != null) const SizedBox(width: AppDimens.margin12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.successLight : AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
                  ),
                  child: const Text('Confirm Check-in'),
                ),
              ),
            ],
          ),

          if (onScanAnother != null) ...[
            const SizedBox(height: AppDimens.margin12),
            TextButton(
              onPressed: onScanAnother,
              child: Text(
                'Scan Another Ticket',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        bool highlight = false,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: AppDimens.iconSize16,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: AppDimens.margin8),
        Text(
          '$label:',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(width: AppDimens.margin4),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? AppFonts.bold : AppFonts.regular,
              color: highlight
                  ? (isDark ? AppColors.successLight : AppColors.success)
                  : null,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Validation Error Widget
class ValidationErrorWidget extends StatelessWidget {
  final String message;
  final String? ticketCode;
  final VoidCallback onRetry;
  final VoidCallback? onManualEntry;

  const ValidationErrorWidget({
    Key? key,
    required this.message,
    this.ticketCode,
    required this.onRetry,
    this.onManualEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.error.withOpacity(0.2) : AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cancel_rounded,
              color: isDark ? AppColors.errorLight : AppColors.error,
              size: 48,
            ),
          ),

          const SizedBox(height: AppDimens.margin16),

          Text(
            'Validation Failed',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDark ? AppColors.errorLight : AppColors.error,
              fontWeight: AppFonts.bold,
            ),
          ),

          const SizedBox(height: AppDimens.margin8),

          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          if (ticketCode != null) ...[
            const SizedBox(height: AppDimens.margin16),
            Container(
              padding: const EdgeInsets.all(AppDimens.padding12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : AppColors.grey50,
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
              child: Text(
                ticketCode!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],

          const SizedBox(height: AppDimens.margin24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Try Again'),
                ),
              ),
              if (onManualEntry != null) ...[
                const SizedBox(width: AppDimens.margin12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onManualEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                    child: const Text('Manual Entry'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}