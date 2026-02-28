// lib/modules/driver/views/status/update_trip_status_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/modules/driver/controllers/trip_status_controller.dart';

class UpdateTripStatusView extends GetView<TripStatusController> {
  const UpdateTripStatusView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Trip Status'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Status Card
              _buildCurrentStatusCard(context),

              const SizedBox(height: AppDimens.margin24),

              // Available Status Updates
              Text(
                'Update Status To:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              const SizedBox(height: AppDimens.margin12),

              ...controller.availableStatuses.map((status) {
                return _buildStatusOption(context, status);
              }),

              const SizedBox(height: AppDimens.margin24),

              // Report Delay Section
              if (controller.currentStatus == 'scheduled' ||
                  controller.currentStatus == 'in_transit')
                _buildDelaySection(context),

              const SizedBox(height: AppDimens.margin24),

              // Status History
              _buildStatusHistory(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
            isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Status',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppDimens.margin4),
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.currentStatus.toUpperCase(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding12,
                  vertical: AppDimens.padding6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimens.radius20),
                ),
                child: Text(
                  'For ${controller.getTimeInCurrentStatus().inHours}h',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(BuildContext context, String status) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color getStatusColor() {
      switch (status) {
        case 'departed':
          return isDark ? AppColors.infoLight : AppColors.info;
        case 'in_transit':
          return isDark ? AppColors.warningLight : AppColors.warning;
        case 'completed':
          return isDark ? AppColors.successLight : AppColors.success;
        case 'delayed':
          return isDark ? AppColors.secondaryOrangeLight : AppColors.secondaryOrange;
        case 'cancelled':
          return isDark ? AppColors.errorLight : AppColors.error;
        default:
          return isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.margin8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppDimens.padding8),
          decoration: BoxDecoration(
            color: getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
          child: Icon(
            _getStatusIcon(status),
            color: getStatusColor(),
          ),
        ),
        title: Text(
          status.toUpperCase(),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: AppFonts.semiBold,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_rounded,
          color: getStatusColor(),
        ),
        onTap: () => _showConfirmationDialog(context, status),
      ),
    );
  }

  Widget _buildDelaySection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    int delayMinutes = 30;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_rounded,
                color: isDark ? AppColors.warningLight : AppColors.warning,
              ),
              const SizedBox(width: AppDimens.margin8),
              Text(
                'Report Delay',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.margin16),
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  Text(
                    'Delay: $delayMinutes minutes',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Slider(
                    value: delayMinutes.toDouble(),
                    min: 15,
                    max: 180,
                    divisions: 11,
                    activeColor: isDark ? AppColors.warningLight : AppColors.warning,
                    onChanged: (value) {
                      setState(() {
                        delayMinutes = value.round();
                      });
                    },
                  ),
                  const SizedBox(height: AppDimens.margin12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Reason for delay',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radius8),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppDimens.margin16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Report delay
                        controller.reportDelay(delayMinutes, '');
                      },
                      icon: const Icon(Icons.warning_rounded),
                      label: const Text('Report Delay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.warningLight : AppColors.warning,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHistory(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status History',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: AppDimens.margin12),
        Obx(() {
          if (controller.statusHistory.isEmpty) {
            return Center(
              child: Text(
                'No status history available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.statusHistory.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin8),
            itemBuilder: (context, index) {
              final update = controller.statusHistory[index];
              return Container(
                padding: const EdgeInsets.all(AppDimens.padding12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getStatusColor(update.toStatus, isDark),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${update.fromStatus} → ${update.toStatus}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: AppFonts.medium,
                            ),
                          ),
                          if (update.reason != null)
                            Text(
                              update.reason!,
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${update.timestamp.hour}:${update.timestamp.minute}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'departed':
        return Icons.departure_board_rounded;
      case 'in_transit':
        return Icons.route_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'delayed':
        return Icons.timer_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status) {
      case 'scheduled':
        return isDark ? AppColors.infoLight : AppColors.info;
      case 'departed':
        return isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen;
      case 'in_transit':
        return isDark ? AppColors.warningLight : AppColors.warning;
      case 'completed':
        return isDark ? AppColors.successLight : AppColors.success;
      case 'delayed':
        return isDark ? AppColors.secondaryOrangeLight : AppColors.secondaryOrange;
      case 'cancelled':
        return isDark ? AppColors.errorLight : AppColors.error;
      default:
        return isDark ? AppColors.grey500 : AppColors.grey600;
    }
  }

  void _showConfirmationDialog(BuildContext context, String newStatus) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Status Update'),
        content: Text('Are you sure you want to update status to "$newStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateStatus(newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}