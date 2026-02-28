// lib/core/widgets/qr/qr_generator.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';

class QRGenerator extends StatelessWidget {
  final String data;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final Widget? logo;
  final VoidCallback? onTap;
  final bool showData;
  final String? label;

  const QRGenerator({
    Key? key,
    required this.data,
    this.size = AppDimens.qrCodeSize,
    this.color,
    this.backgroundColor,
    this.logo,
    this.onTap,
    this.showData = false,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.padding16),
        decoration: BoxDecoration(
          color: backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.white),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR Code
            Stack(
              alignment: Alignment.center,
              children: [
                QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: size,
                  backgroundColor: backgroundColor ?? (isDark ? AppColors.surfaceDark : Colors.white),
                  foregroundColor: color ?? (isDark ? AppColors.textPrimaryDark : Colors.black),
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  padding: const EdgeInsets.all(AppDimens.padding8),
                ),
                if (logo != null)
                  Container(
                    padding: const EdgeInsets.all(AppDimens.padding4),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? (isDark ? AppColors.surfaceDark : Colors.white),
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                    ),
                    child: logo,
                  ),
              ],
            ),

            if (showData && label != null) ...[
              const SizedBox(height: AppDimens.margin12),
              Container(
                padding: const EdgeInsets.all(AppDimens.padding8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                ),
                child: Text(
                  label!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TicketQRWidget extends StatelessWidget {
  final String ticketId;
  final String ticketData;
  final VoidCallback? onTap;
  final bool showDetails;

  const TicketQRWidget({
    Key? key,
    required this.ticketId,
    required this.ticketData,
    this.onTap,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreenDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      child: Stack(
        children: [
          // Decorative Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: TicketPatternPainter(),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.confirmation_number_rounded,
                      color: Colors.white,
                      size: AppDimens.iconSize24,
                    ),
                    const SizedBox(width: AppDimens.margin8),
                    Expanded(
                      child: Text(
                        'Boarding Pass',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: AppFonts.semiBold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimens.margin16),

                // QR Code
                QRGenerator(
                  data: ticketData,
                  size: 180,
                  backgroundColor: Colors.white,
                  logo: Container(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/images/menahariya_icon.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),

                if (showDetails) ...[
                  const SizedBox(height: AppDimens.margin16),

                  // Ticket ID
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.padding12,
                      vertical: AppDimens.padding4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimens.radius20),
                    ),
                    child: Text(
                      ticketId.toUpperCase(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: AppFonts.medium,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TicketPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + 10, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}