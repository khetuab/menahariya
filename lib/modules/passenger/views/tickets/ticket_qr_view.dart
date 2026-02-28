// lib/modules/passenger/views/tickets/ticket_qr_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/qr/qr_generator.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';

class TicketQRView extends StatelessWidget {
  const TicketQRView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ticket = Get.arguments['ticket'] as TicketModel;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Title
              Text(
                'Boarding Pass',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppFonts.bold,
                ),
              ),

              const SizedBox(height: AppDimens.margin8),

              Text(
                'Scan QR code at the gate',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: AppDimens.margin40),

              // QR Code
              Center(
                child: TicketQRWidget(
                  ticketId: ticket.id,
                  ticketData: ticket.qrCode ?? ticket.id,
                  showDetails: true,
                ),
              ),

              const SizedBox(height: AppDimens.margin32),

              // Ticket Info
              Container(
                padding: const EdgeInsets.all(AppDimens.padding20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppDimens.radius16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${ticket.origin} → ${ticket.destination}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimens.margin8),
                    Text(
                      'Seat ${ticket.seatNumber}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.margin24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(AppDimens.padding16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_rounded,
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: Text(
                        'Present this QR code at the boarding gate for validation',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Brightness Hint
              Text(
                'Increase screen brightness for better scanning',
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
}