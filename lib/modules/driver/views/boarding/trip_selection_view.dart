import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/cards/trip_card.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/driver/controllers/boarding_controller.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';

class TripSelectionView extends GetView<BoardingController> {
  const TripSelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Trip for Boarding'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: Obx(() {
        if (controller.isLoadingTrips && controller.availableTrips.isEmpty) {
          return _buildLoadingShimmer();
        }

        if (controller.availableTrips.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.loadAvailableTrips,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimens.padding16),
            itemCount: controller.availableTrips.length,
            itemBuilder: (context, index) {
              final trip = controller.availableTrips[index];
              final isCurrentTrip = controller.currentTripId == trip.id;
              return _buildTripCard(context, trip, isCurrentTrip);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTripCard(BuildContext context, TripModel trip, bool isCurrentTrip) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.margin12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        side: BorderSide(
          color: isCurrentTrip
              ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isCurrentTrip ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => controller.selectTripForBoarding(trip),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${trip.origin} → ${trip.destination}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: AppFonts.semiBold,
                              ),
                            ),
                            if (isCurrentTrip) ...[
                              const SizedBox(width: AppDimens.margin8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimens.padding8,
                                  vertical: AppDimens.padding4,
                                ),
                                decoration: BoxDecoration(
                                  color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(AppDimens.radius20),
                                ),
                                child: Text(
                                  'Current',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
                      horizontal: AppDimens.padding12,
                      vertical: AppDimens.padding6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(trip.status, isDark).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radius20),
                    ),
                    child: Text(
                      _getStatusText(trip.status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(trip.status, isDark),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: AppDimens.margin4),
                  Text(
                    _formatDate(trip.departureTime),
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
                    _formatTime(trip.departureTime),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin12),
              Row(
                children: [
                  Icon(
                    Icons.chair_rounded,
                    size: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: AppDimens.margin4),
                  Text(
                    '${trip.availableSeats}/${trip.totalSeats} seats available',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => controller.selectTripForBoarding(trip),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radius8),
                        ),
                      ),
                      child: const Text('Start Boarding'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.padding16),
      itemCount: 3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.margin12),
        child: ShimmerLoading(
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
          ),
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
            Icons.directions_bus_rounded,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            'No Trips Available',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            'You don\'t have any upcoming trips for boarding',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}