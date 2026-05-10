import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';

class TripHistoryCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const TripHistoryCard({
    Key? key,
    required this.trip,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(trip.status, isDark);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.margin12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${trip.origin} → ${trip.destination}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: AppFonts.semiBold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimens.margin4),
                        Text(
                          'Trip ID: ${trip.id.substring(0, 8).toUpperCase()}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
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
                      _getStatusText(trip.status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin12),
              // Date and Time
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: AppDimens.margin4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(trip.departureTime),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: AppDimens.margin16),
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: AppDimens.margin4),
                  Text(
                    DateFormat('HH:mm').format(trip.departureTime),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin8),
              // Stats
              Row(
                children: [
                  _buildStatChip(
                    context,
                    icon: Icons.chair_rounded,
                    label: '${trip.availableSeats}/${trip.totalSeats} seats',
                  ),
                  const SizedBox(width: AppDimens.margin8),
                  _buildStatChip(
                    context,
                    icon: Icons.attach_money_rounded,
                    label: 'ETB ${trip.price.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding8,
        vertical: AppDimens.padding4,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: AppDimens.margin4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status) {
      case 'scheduled':
        return isDark ? AppColors.infoLight : AppColors.info;
      case 'in_progress':
        return isDark ? AppColors.warningLight : AppColors.warning;
      case 'completed':
        return isDark ? AppColors.successLight : AppColors.success;
      case 'cancelled':
        return isDark ? AppColors.errorLight : AppColors.error;
      default:
        return isDark ? AppColors.grey400 : AppColors.grey600;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}