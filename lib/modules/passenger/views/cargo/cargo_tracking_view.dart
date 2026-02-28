// lib/modules/passenger/views/cargo/cargo_tracking_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/modules/passenger/controllers/cargo_controller.dart';

import '../../../../data/models/cargo/cargo_model.dart';

class CargoTrackingView extends GetView<PassengerCargoController> {
  const CargoTrackingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Cargo'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.padding16),
        child: Column(
          children: [
            // Tracking Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.padding16),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Tracking Code',
                      controller: TextEditingController(),
                      prefixIcon: Icons.qr_code_scanner_rounded,
                      hint: 'Enter tracking code',
                      onSubmitted: (value) => controller.trackCargo(value),
                    ),
                    const SizedBox(height: AppDimens.margin16),
                    PrimaryButton(
                      text: 'Track Cargo',
                      onPressed: () {
                        // Implement tracking
                      },
                      icon: Icons.track_changes_rounded,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimens.margin24),

            // Tracking Result
            Obx(() {
              final cargo = controller.selectedCargo;
              if (cargo == null) {
                return _buildEmptyState(context);
              }

              return Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Status Timeline
                      _buildTimeline(context, cargo),

                      const SizedBox(height: AppDimens.margin20),

                      // Cargo Details
                      _buildCargoDetails(context, cargo),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_rounded,
              size: 80,
              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
            ),
            const SizedBox(height: AppDimens.margin16),
            Text(
              'Enter tracking code',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimens.margin8),
            Text(
              'Enter your cargo tracking code to check status',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, CargoModel cargo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final steps = [
      {'status': 'Registered', 'date': cargo.registeredDate, 'completed': true},
      {'status': 'Loaded', 'date': cargo.loadedDate, 'completed': cargo.loadedDate != null},
      {'status': 'In Transit', 'date': cargo.inTransitDate, 'completed': cargo.inTransitDate != null},
      {'status': 'Delivered', 'date': cargo.deliveredDate, 'completed': cargo.deliveredDate != null},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tracking Status',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
            const SizedBox(height: AppDimens.margin16),

            ...List.generate(steps.length, (index) {
              final step = steps[index];
              final isCompleted = step['completed'] as bool;
              final isLast = index == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? (isDark ? AppColors.successLight : AppColors.success)
                              : (isDark ? AppColors.grey700 : AppColors.grey300),
                          shape: BoxShape.circle,
                        ),
                        child: isCompleted
                            ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: isCompleted
                              ? (isDark ? AppColors.successLight : AppColors.success)
                              : (isDark ? AppColors.grey700 : AppColors.grey300),
                        ),
                    ],
                  ),
                  const SizedBox(width: AppDimens.margin12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['status'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isCompleted ? AppFonts.semiBold : AppFonts.regular,
                            color: isCompleted
                                ? (isDark ? AppColors.successLight : AppColors.success)
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                        if (step['date'] != null)
                          Text(
                            (step['date'] as DateTime).toString().substring(0, 16),
                            style: theme.textTheme.bodySmall,
                          ),
                        if (!isLast) const SizedBox(height: AppDimens.margin12),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCargoDetails(BuildContext context, CargoModel cargo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cargo Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
            const SizedBox(height: AppDimens.margin16),

            _buildDetailRow(context, 'Tracking Code', cargo.trackingCode),
            _buildDetailRow(context, 'Status', cargo.status),
            _buildDetailRow(context, 'Destination', cargo.destination),
            _buildDetailRow(context, 'Weight', '${cargo.weight} kg'),
            _buildDetailRow(context, 'Fee', CurrencyFormatter.format(cargo.fee)),
            if (cargo.description != null)
              _buildDetailRow(context, 'Description', cargo.description!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppFonts.medium,
            ),
          ),
        ],
      ),
    );
  }
}