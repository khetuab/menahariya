// lib/modules/driver/views/trips/trip_detail_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';
import 'package:menahariya/modules/driver/controllers/trip_detail_controller.dart';

class DriverTripDetailView extends GetView<DriverTripDetailController> {
  const DriverTripDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshTripDetails,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.trip == null) {
          return _buildLoadingShimmer();
        }

        if (controller.trip == null) {
          return _buildErrorState(context);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Header
              _buildTripHeader(context),

              const SizedBox(height: AppDimens.margin20),

              // Boarding Progress
              _buildBoardingProgress(context),

              const SizedBox(height: AppDimens.margin20),

              // Quick Actions
              _buildQuickActions(context),

              const SizedBox(height: AppDimens.margin20),

              // Vehicle Info
              _buildVehicleInfo(context),

              const SizedBox(height: AppDimens.margin20),

              // Passenger Stats
              _buildPassengerStats(context),

              const SizedBox(height: AppDimens.margin20),

              // Cargo Summary
              _buildCargoSummary(context),

              const SizedBox(height: AppDimens.margin20),

              // Timeline
              _buildTimeline(context),

              const SizedBox(height: AppDimens.margin32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTripHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trip = controller.trip!;

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
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.origin,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    Text(
                      'Departure: ${DateFormatter.toTime(trip.departureTime)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppDimens.padding8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trip.destination,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    Text(
                      'Arrival: ${DateFormatter.toTime(trip.arrivalTime)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.margin16),
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
              'Status: ${trip.status.toUpperCase()}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: AppFonts.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardingProgress(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Boarding Progress',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              Obx(() => Text(
                '${controller.checkedInCount}/${controller.totalPassengers}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: AppFonts.bold,
                ),
              )),
            ],
          ),
          const SizedBox(height: AppDimens.margin8),
          Obx(() => ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radius4),
            child: LinearProgressIndicator(
              value: controller.boardingProgress,
              minHeight: 8,
              backgroundColor: isDark ? AppColors.grey700 : AppColors.grey300,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.successLight : AppColors.success,
              ),
            ),
          )),
          const SizedBox(height: AppDimens.margin8),
          Obx(() => Text(
            controller.boardingStatusText,
            style: theme.textTheme.bodySmall,
          )),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Expanded(
        //   child: _buildActionButton(
        //     context,
        //     icon: Icons.qr_code_scanner_rounded,
        //     label: 'Scan Tickets',
        //     color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
        //     onTap: () => Get.toNamed(
        //       '/driver/validation',
        //       arguments: {'tripId': controller.tripId},
        //     ),
        //   ),
        // ),
        // const SizedBox(width: AppDimens.margin8),
        // // For Passenger Manifest - use arguments, not URL parameter
        // // In your trip detail view

// For Passenger Manifest - use URL parameter
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.people_rounded,
            label: 'Passengers',
            color: isDark ? AppColors.infoLight : AppColors.info,
            onTap: () {
              print('🎯 Navigating to passenger manifest with tripId: ${controller.tripId}');
              Get.toNamed('/driver/passenger-manifest/${controller.tripId}');
            },
          ),
        ),

SizedBox(width: AppDimens.padding12,),
// For Cargo Manifest - use URL parameter
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.inventory_2_rounded,
            label: 'Cargo',
            color: isDark ? AppColors.warningLight : AppColors.warning,
            onTap: () {
              print('🎯 Navigating to cargo manifest with tripId: ${controller.tripId}');
              Get.toNamed('/driver/cargo-manifest/${controller.tripId}');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radius8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.padding8,
          horizontal: AppDimens.padding4,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimens.radius8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: AppDimens.margin2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: AppFonts.medium,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vehicle = controller.vehicle;

    if (vehicle == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Information',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.padding8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey700 : AppColors.grey200,
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                ),
                child: const Icon(Icons.directions_bus_rounded),
              ),
              const SizedBox(width: AppDimens.margin12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.plateNumber,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                    Text(
                      vehicle.model,
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
                  color: isDark ? AppColors.success.withOpacity(0.2) : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radius4),
                ),
                child: Text(
                  vehicle.status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.successLight : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerStats(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stats = controller.getPassengerStatistics();

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passenger Summary',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                label: 'Total',
                value: stats['total'].toString(),
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
              _buildStatItem(
                context,
                label: 'Checked In',
                value: stats['checkedIn'].toString(),
                color: isDark ? AppColors.successLight : AppColors.success,
              ),
              _buildStatItem(
                context,
                label: 'Pending',
                value: stats['pending'].toString(),
                color: isDark ? AppColors.warningLight : AppColors.warning,
              ),
            ],
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

  Widget _buildCargoSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cargo Summary',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(
                  '/driver/cargo-manifest/${controller.tripId}',
                  arguments: {'tripId': controller.tripId},
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.margin12),
          Obx(() {
            if (controller.cargoList.isEmpty) {
              return Text(
                'No cargo for this trip',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                ),
              );
            }
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Items:'),
                    Text('${controller.cargoList.length}'),
                  ],
                ),
                const SizedBox(height: AppDimens.margin4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Weight:'),
                    Text('${controller.cargoList.fold(0.0, (sum, c) => sum + c.weight)} kg'),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Timeline',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin16),
          _buildTimelineItem(
            context,
            title: 'Departure',
            time: controller.trip?.departureTime,
            isCompleted: DateTime.now().isAfter(controller.trip?.departureTime ?? DateTime.now()),
          ),
          _buildTimelineItem(
            context,
            title: 'Arrival',
            time: controller.trip?.arrivalTime,
            isCompleted: DateTime.now().isAfter(controller.trip?.arrivalTime ?? DateTime.now()),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, {required String title, DateTime? time, required bool isCompleted}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isCompleted
                  ? (isDark ? AppColors.successLight : AppColors.success)
                  : (isDark ? AppColors.grey600 : AppColors.grey400),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimens.margin12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isCompleted ? AppFonts.semiBold : AppFonts.regular,
                  ),
                ),
                if (time != null)
                  Text(
                    DateFormatter.toTime(time),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ShimmerLoading(
      child: ListView(
        padding: const EdgeInsets.all(AppDimens.padding16),
        children: [
          Container(height: 120, color: Colors.white),
          const SizedBox(height: AppDimens.margin16),
          Container(height: 80, color: Colors.white),
          const SizedBox(height: AppDimens.margin16),
          Container(height: 150, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64),
          const SizedBox(height: AppDimens.margin16),
          const Text('Failed to load trip details'),
          const SizedBox(height: AppDimens.margin24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}