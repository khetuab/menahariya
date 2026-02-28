// lib/modules/passenger/views/cargo/cargo_receipt_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/data/models/cargo/cargo_model.dart';

class CargoReceiptView extends StatelessWidget {
  const CargoReceiptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cargo = Get.arguments['cargo'] as CargoModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargo Receipt'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              // Share receipt
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download_rounded),
            onPressed: () {
              // Download receipt
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.padding16),
        child: Column(
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.successLight.withOpacity(0.2) : AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: isDark ? AppColors.successLight : AppColors.success,
                size: 40,
              ),
            ),

            const SizedBox(height: AppDimens.margin16),

            Text(
              'Cargo Registered Successfully!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: AppFonts.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimens.margin8),

            Text(
              'Your cargo has been registered and is ready for shipment',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimens.margin32),

            // Receipt Card
            Container(
              padding: const EdgeInsets.all(AppDimens.padding20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.white,
                borderRadius: BorderRadius.circular(AppDimens.radius16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.transparent : AppColors.grey200.withOpacity(0.5),
                    blurRadius: AppDimens.shadowBlurSmall,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARGO RECEIPT',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: AppFonts.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              '#${cargo.trackingCode}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: AppFonts.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(AppDimens.padding8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimens.radius8),
                        ),
                        child: Text(
                          cargo.status.toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: AppDimens.margin32),

                  // Sender Details
                  _buildReceiptSection(
                    context,
                    title: 'Sender',
                    icon: Icons.person_rounded,
                    details: {
                      'Name': cargo.senderName,
                      'Phone': cargo.senderPhone,
                    },
                  ),

                  const SizedBox(height: AppDimens.margin16),

                  // Receiver Details
                  _buildReceiptSection(
                    context,
                    title: 'Receiver',
                    icon: Icons.person_rounded,
                    details: {
                      'Name': cargo.receiverName,
                      'Phone': cargo.receiverPhone,
                    },
                  ),

                  const SizedBox(height: AppDimens.margin16),

                  // Cargo Details
                  _buildReceiptSection(
                    context,
                    title: 'Cargo Details',
                    icon: Icons.inventory_2_rounded,
                    details: {
                      'Type': cargo.cargoType,
                      'Weight': '${cargo.weight} kg',
                      if (cargo.dimensions != null) 'Dimensions': cargo.dimensions!,
                      if (cargo.isFragile) 'Fragile': 'Yes',
                      if (cargo.isPerishable) 'Perishable': 'Yes',
                      if (cargo.needsRefrigeration) 'Refrigerated': 'Yes',
                    },
                  ),

                  const SizedBox(height: AppDimens.margin16),

                  // Trip Details
                  _buildReceiptSection(
                    context,
                    title: 'Trip Details',
                    icon: Icons.directions_bus_rounded,
                    details: {
                      'Route': '${cargo.origin} → ${cargo.destination}',
                      'Departure': cargo.departureTime.toString().substring(0, 16),
                    },
                  ),

                  const Divider(height: AppDimens.margin32),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Fee',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(cargo.fee),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.margin16),

                  // Date
                  Text(
                    'Issued: ${DateTime.now().toString().substring(0, 16)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.margin32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Track Cargo',
                    onPressed: () {
                      Get.toNamed(
                        '/passenger/cargo/track',
                        arguments: {'trackingCode': cargo.trackingCode},
                      );
                    },
                    icon: Icons.track_changes_rounded,
                  ),
                ),
                const SizedBox(width: AppDimens.margin12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Done',
                    onPressed: () => Get.offAllNamed('/passenger/dashboard'),
                    icon: Icons.home_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Map<String, String> details,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            const SizedBox(width: AppDimens.margin4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.margin8),
        ...details.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.padding4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: theme.textTheme.bodySmall,
              ),
              Text(
                entry.value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: AppFonts.medium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}