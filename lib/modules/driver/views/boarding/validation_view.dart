// lib/modules/driver/views/boarding/validation_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/modules/driver/controllers/validation_controller.dart';

class ValidationView extends GetView<ValidationController> {
  const ValidationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Validation'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => _showHistory(context),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            onPressed: controller.clearHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner Area
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(AppDimens.radius12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.padding16,
                          vertical: AppDimens.padding8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(AppDimens.radius20),
                        ),
                        child: Text(
                          'Scan QR Code',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Manual Entry
          Container(
            padding: const EdgeInsets.all(AppDimens.padding16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimens.radius20),
                topRight: Radius.circular(AppDimens.radius20),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter ticket code manually',
                    prefixIcon: const Icon(Icons.confirmation_number_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                    ),
                    suffixIcon: Obx(() {
                      if (controller.isValidating) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return IconButton(
                        icon: const Icon(Icons.send_rounded),
                        onPressed: () {
                          // Get the text from TextField
                        },
                      );
                    }),
                  ),
                  onSubmitted: controller.validateTicket,
                ),
                const SizedBox(height: AppDimens.margin16),

                // Validation Result
                Obx(() {
                  final result = controller.lastValidation;
                  if (result == null) return const SizedBox();

                  return Container(
                    padding: const EdgeInsets.all(AppDimens.padding16),
                    decoration: BoxDecoration(
                      color: result.isValid
                          ? (isDark ? AppColors.success.withOpacity(0.2) : AppColors.success.withOpacity(0.1))
                          : (isDark ? AppColors.error.withOpacity(0.2) : AppColors.error.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                      border: Border.all(
                        color: result.isValid
                            ? (isDark ? AppColors.successLight : AppColors.success)
                            : (isDark ? AppColors.errorLight : AppColors.error),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          result.isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: result.isValid
                              ? (isDark ? AppColors.successLight : AppColors.success)
                              : (isDark ? AppColors.errorLight : AppColors.error),
                          size: 32,
                        ),
                        const SizedBox(width: AppDimens.margin12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.isValid ? 'Valid Ticket' : 'Invalid Ticket',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: result.isValid
                                      ? (isDark ? AppColors.successLight : AppColors.success)
                                      : (isDark ? AppColors.errorLight : AppColors.error),
                                  fontWeight: AppFonts.bold,
                                ),
                              ),
                              Text(
                                result.message,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: AppDimens.margin16),

                // Stats
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      context,
                      label: 'Valid',
                      value: controller.getValidCount().toString(),
                      color: isDark ? AppColors.successLight : AppColors.success,
                    ),
                    _buildStatItem(
                      context,
                      label: 'Invalid',
                      value: controller.getInvalidCount().toString(),
                      color: isDark ? AppColors.errorLight : AppColors.error,
                    ),
                    _buildStatItem(
                      context,
                      label: 'Total',
                      value: controller.validationHistory.length.toString(),
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required String label, required String value, required Color color}) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: AppFonts.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  void _showHistory(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        height: 400,
        padding: const EdgeInsets.all(AppDimens.padding16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimens.radius20),
            topRight: Radius.circular(AppDimens.radius20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Validation History',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
            const SizedBox(height: AppDimens.margin16),
            Expanded(
              child: Obx(() {
                if (controller.validationHistory.isEmpty) {
                  return Center(
                    child: Text(
                      'No validation history',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: controller.validationHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin8),
                  itemBuilder: (context, index) {
                    final item = controller.validationHistory[index];
                    return ListTile(
                      leading: Icon(
                        item.isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: item.isValid
                            ? (isDark ? AppColors.successLight : AppColors.success)
                            : (isDark ? AppColors.errorLight : AppColors.error),
                      ),
                      title: Text(
                        item.ticketCode,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                      subtitle: Text(item.message),
                      trailing: Text(
                        '${item.timestamp.hour}:${item.timestamp.minute}',
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}