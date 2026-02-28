// lib/modules/driver/widgets/trip_summary_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';

class TripSummaryCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;
  final VoidCallback? onStartTrip;
  final VoidCallback? onViewDetails;
  final bool showActions;
  final bool compact;

  const TripSummaryCard({
    Key? key,
    required this.trip,
    required this.onTap,
    this.onStartTrip,
    this.onViewDetails,
    this.showActions = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactCard(context);
    }
    return _buildFullCard(context);
  }

  Widget _buildFullCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin12),
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with status
            Container(
              padding: const EdgeInsets.all(AppDimens.padding12),
              decoration: BoxDecoration(
                color: _getStatusColor(trip.status, isDark).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.radius16),
                  topRight: Radius.circular(AppDimens.radius16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(trip.status),
                    color: _getStatusColor(trip.status, isDark),
                    size: AppDimens.iconSize20,
                  ),
                  const SizedBox(width: AppDimens.margin8),
                  Expanded(
                    child: Text(
                      trip.status.toUpperCase(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _getStatusColor(trip.status, isDark),
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.padding8,
                      vertical: AppDimens.padding4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey800 : AppColors.white,
                      borderRadius: BorderRadius.circular(AppDimens.radius20),
                    ),
                    child: Text(
                      'ID: ${trip.id.substring(0, 6)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            // Route information
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding16),
              child: Row(
                children: [
                  // Origin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FROM',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          trip.origin,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: AppFonts.semiBold,
                          ),
                        ),
                        Text(
                          DateFormatter.toTime(trip.departureTime),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Container(
                    padding: const EdgeInsets.all(AppDimens.padding8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                  ),

                  // Destination
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TO',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          trip.destination,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: AppFonts.semiBold,
                          ),
                        ),
                        Text(
                          DateFormatter.toTime(trip.arrivalTime),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
              child: Row(
                children: [
                  _buildStatItem(
                    context,
                    icon: Icons.people_rounded,
                    label: 'Passengers',
                    value: '${trip.passengerCount ?? 0}',
                  ),
                  const SizedBox(width: AppDimens.margin16),
                  _buildStatItem(
                    context,
                    icon: Icons.inventory_2_rounded,
                    label: 'Cargo',
                    value: '${trip.cargoCount ?? 0}',
                  ),
                  const Spacer(),
                  _buildStatItem(
                    context,
                    icon: Icons.access_time_rounded,
                    label: 'Duration',
                    value: DateFormatter.getDuration(
                      trip.arrivalTime.difference(trip.departureTime),
                    ),
                  ),
                ],
              ),
            ),

            if (showActions) ...[
              const SizedBox(height: AppDimens.margin16),

              // Actions
              Container(
                padding: const EdgeInsets.all(AppDimens.padding12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewDetails ?? onTap,
                        icon: const Icon(Icons.visibility_rounded),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          side: BorderSide(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onStartTrip ?? onTap,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start Trip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
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

  Widget _buildCompactCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin8),
        padding: const EdgeInsets.all(AppDimens.padding12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(trip.status, isDark),
                borderRadius: BorderRadius.circular(AppDimens.radius2),
              ),
            ),
            const SizedBox(width: AppDimens.margin12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${trip.origin} → ${trip.destination}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: AppFonts.semiBold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.padding6,
                          vertical: AppDimens.padding2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(trip.status, isDark).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimens.radius4),
                        ),
                        child: Text(
                          trip.status,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(trip.status, isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.margin4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: AppDimens.iconSize12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: AppDimens.margin4),
                      Text(
                        DateFormatter.toTime(trip.departureTime),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: AppDimens.margin12),
                      Icon(
                        Icons.people_rounded,
                        size: AppDimens.iconSize12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: AppDimens.margin4),
                      Text(
                        '${trip.passengerCount ?? 0}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required IconData icon, required String label, required String value}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: AppDimens.iconSize16,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: AppDimens.margin4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: AppFonts.medium,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return isDark ? AppColors.infoLight : AppColors.info;
      case 'departed':
      case 'in_progress':
        return isDark ? AppColors.warningLight : AppColors.warning;
      case 'completed':
        return isDark ? AppColors.successLight : AppColors.success;
      case 'cancelled':
        return isDark ? AppColors.errorLight : AppColors.error;
      case 'delayed':
        return isDark ? AppColors.secondaryOrangeLight : AppColors.secondaryOrange;
      default:
        return isDark ? AppColors.grey500 : AppColors.grey600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Icons.schedule_rounded;
      case 'departed':
      case 'in_progress':
        return Icons.departure_board_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'delayed':
        return Icons.timer_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}

// Trip Countdown Widget
class TripCountdownWidget extends StatelessWidget {
  final DateTime departureTime;
  final VoidCallback? onExpired;

  const TripCountdownWidget({
    Key? key,
    required this.departureTime,
    this.onExpired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final difference = departureTime.difference(now);

    if (difference.isNegative) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onExpired?.call();
      });
      return const SizedBox();
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
            isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_rounded,
            color: Colors.white,
          ),
          const SizedBox(width: AppDimens.margin12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time until departure',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  '${hours}h ${minutes}m',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}