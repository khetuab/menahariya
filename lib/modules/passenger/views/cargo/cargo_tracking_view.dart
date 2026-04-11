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

    // Get tracking code from arguments if provided
    final String? initialCode = Get.arguments?['trackingCode'];

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
                      controller: controller.trackingCodeController,
                      prefixIcon: Icons.qr_code_scanner_rounded,
                      hint: 'Enter tracking code',
                      onSubmitted: (value) => controller.trackCargo(value),
                      initialValue: initialCode, // Pre-fill if provided
                    ),
                    const SizedBox(height: AppDimens.margin16),
                    Obx(() => PrimaryButton(
                      text: controller.isLoading ? 'Tracking...' : 'Track Cargo',
                      onPressed: controller.isLoading
                          ? null
                          : () => controller.trackCargo(controller.trackingCodeController.text),
                      icon: Icons.track_changes_rounded,
                      isLoading: controller.isLoading,
                    )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimens.margin24),

            // Tracking Result
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final cargo = controller.selectedCargo;
                if (cargo == null) {
                  return _buildEmptyState(context);
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Status Timeline
                      _buildTimeline(context, cargo),

                      const SizedBox(height: AppDimens.margin20),

                      // Cargo Details
                      _buildCargoDetails(context, cargo),

                      const SizedBox(height: AppDimens.margin20),

                      // Sender & Receiver Info
                      _buildContactInfo(context, cargo),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
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
                        width: 24,
                        height: 24,
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
                          size: 16,
                        )
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 50,
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
                            _formatDate(step['date'] as DateTime),
                            style: theme.textTheme.bodySmall,
                          ),
                        if (step['status'] == 'In Transit' && cargo.location != null && cargo.isInTransit)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '📍 ${cargo.location}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                              ),
                            ),
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
            Row(
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
                const SizedBox(width: AppDimens.margin8),
                Text(
                  'Cargo Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.margin16),

            _buildDetailRow(context, 'Tracking Code', cargo.trackingCode),
            _buildDetailRow(context, 'Status', cargo.statusText),
            _buildDetailRow(context, 'Type', cargo.cargoType),
            _buildDetailRow(context, 'Weight', '${cargo.weight} kg'),
            if (cargo.dimensions != null && cargo.dimensions!.isNotEmpty)
              _buildDetailRow(context, 'Dimensions', cargo.dimensions!),
            _buildDetailRow(context, 'Fee', CurrencyFormatter.format(cargo.fee)),
            if (cargo.description != null && cargo.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  cargo.description!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, CargoModel cargo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
                const SizedBox(width: AppDimens.margin8),
                Text(
                  'Contact Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.margin16),

            Container(
              padding: const EdgeInsets.all(AppDimens.padding12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : AppColors.grey50,
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sender',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cargo.senderName,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: AppFonts.medium,
                              ),
                            ),
                            Text(
                              cargo.senderPhone,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Receiver',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cargo.receiverName,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: AppFonts.medium,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            Text(
                              cargo.receiverPhone,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.right,
                            ),
                          ],
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
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}