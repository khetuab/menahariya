// lib/core/widgets/cards/ticket_card.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';

class TicketCard extends StatelessWidget {
  final String ticketId;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final String seatNumber;
  final double price;
  final String status;
  final VoidCallback onTap;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final bool showActions;
  final bool isForBoarding;

  const TicketCard({
    Key? key,
    required this.ticketId,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.seatNumber,
    required this.price,
    required this.status,
    required this.onTap,
    this.onShare,
    this.onDownload,
    this.showActions = true,
    this.isForBoarding = false,
  }) : super(key: key);

  Color _getStatusColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        return isDark ? AppColors.successLight : AppColors.success;
      case 'pending':
      case 'reserved':
        return isDark ? AppColors.warningLight : AppColors.warning;
      case 'cancelled':
      case 'expired':
        return isDark ? AppColors.errorLight : AppColors.error;
      case 'used':
        return isDark ? AppColors.infoLight : AppColors.info;
      default:
        return isDark ? AppColors.grey500 : AppColors.grey600;
    }
  }

  String _getStatusText() {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        return 'Confirmed';
      case 'pending':
      case 'reserved':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      case 'used':
        return 'Used';
      case 'expired':
        return 'Expired';
      default:
        return status;
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
        margin: const EdgeInsets.only(bottom: AppDimens.margin16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.transparent : AppColors.grey200.withOpacity(0.5),
              blurRadius: AppDimens.shadowBlurSmall,
              spreadRadius: AppDimens.shadowSpreadNone,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with Ticket ID
            Container(
              padding: const EdgeInsets.all(AppDimens.padding16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : AppColors.grey50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.radius16),
                  topRight: Radius.circular(AppDimens.radius16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.confirmation_number_rounded,
                    size: AppDimens.iconSize20,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: AppDimens.margin8),
                  Text(
                    'Ticket #${ticketId.substring(0, 8).toUpperCase()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                  const Spacer(),
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
                      _getStatusText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Ticket Content
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding16),
              child: Row(
                children: [
                  // Left decorative border with dots
                  Container(
                    width: 2,
                    height: 80,
                    margin: const EdgeInsets.only(right: AppDimens.margin16),
                    child: CustomPaint(
                      painter: DottedLinePainter(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                  ),

                  // Ticket Details
                  Expanded(
                    child: Column(
                      children: [
                        // Route
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    origin,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  Text(
                                    destination,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: AppFonts.semiBold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.padding12,
                                vertical: AppDimens.padding6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimens.radius20),
                              ),
                              child: Text(
                                seatNumber,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                  fontWeight: AppFonts.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimens.margin16),

                        // Time and Price
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: AppDimens.iconSize16,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: AppDimens.margin4),
                            Text(
                              DateFormatter.forTicket(departureTime),
                              style: theme.textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            Text(
                              CurrencyFormatter.forTicketPrice(price),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                fontWeight: AppFonts.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // QR Code Preview (if for boarding)
            if (isForBoarding) ...[
              Container(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              Container(
                padding: const EdgeInsets.all(AppDimens.padding12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey800 : AppColors.grey100,
                        borderRadius: BorderRadius.circular(AppDimens.radius8),
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin8),
                    Text(
                      'Tap to show QR code',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            if (showActions) ...[
              Container(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.padding12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (onShare != null)
                      _buildActionButton(
                        context,
                        icon: Icons.share_rounded,
                        label: 'Share',
                        onTap: onShare!,
                      ),
                    if (onDownload != null)
                      _buildActionButton(
                        context,
                        icon: Icons.download_rounded,
                        label: 'Download',
                        onTap: onDownload!,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding16,
          vertical: AppDimens.padding8,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey800 : AppColors.grey50,
          borderRadius: BorderRadius.circular(AppDimens.radius20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimens.iconSize16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            const SizedBox(width: AppDimens.margin4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4;
    const dashSpace = 4;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}