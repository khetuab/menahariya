import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/driver/controllers/trip_history_controller.dart';
import 'package:menahariya/modules/driver/views/trip/trip_history_card.dart';

import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../data/models/trip/trip_model.dart';

class DriverTripHistoryView extends GetView<DriverTripHistoryController> {
  const DriverTripHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshTrips,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Row
          _buildStatsRow(context),

          // Search Bar
          _buildSearchBar(context),

          // Status Filters
          _buildStatusFilters(context),

          // Trips List
          Expanded(
            child: Obx(() {
              if (controller.isLoading && controller.trips.isEmpty) {
                return _buildLoadingShimmer();
              }

              if (controller.trips.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshTrips,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  itemCount: controller.trips.length + (controller.hasMorePages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.trips.length && controller.hasMorePages) {
                      return _buildLoadMoreIndicator();
                    }
                    final trip = controller.trips[index];
                    return TripHistoryCard(
                      trip: trip,
                      onTap: () {
                        if (trip.status == 'scheduled') {
                          // Pass tripId as argument
                          Get.toNamed('/driver/trip/${trip.id}', arguments: {'tripId': trip.id});
                        } else {
                          _showTripDetailsDialog(context, trip);
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      margin: const EdgeInsets.all(AppDimens.margin16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.grey.shade200,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            context,
            label: 'Total Trips',
            value: '${controller.totalTrips}',
            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          _buildStatItem(
            context,
            label: 'Completed',
            value: '${controller.completedTrips}',
            color: isDark ? AppColors.successLight : AppColors.success,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          _buildStatItem(
            context,
            label: 'Cancelled',
            value: '${controller.cancelledTrips}',
            color: isDark ? AppColors.errorLight : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: AppFonts.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimens.margin2),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
      child: TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search by route...',
          prefixIcon: const Icon(Icons.search_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.padding16,
            vertical: AppDimens.padding12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16, vertical: AppDimens.padding12),
      child: Obx(() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.statusOptions.map((status) {
            final isSelected = controller.selectedStatus == status;
            return Padding(
              padding: const EdgeInsets.only(right: AppDimens.margin8),
              child: FilterChip(
                label: Text(status.toUpperCase().replaceFirst('_', ' ')),
                selected: isSelected,
                onSelected: (_) => controller.setStatusFilter(status),
                selectedColor: isDark
                    ? AppColors.primaryGreen.withOpacity(0.3)
                    : AppColors.primaryGreen.withOpacity(0.1),
                checkmarkColor: isDark
                    ? AppColors.primaryGreenLight
                    : AppColors.primaryGreen,
                backgroundColor: isDark ? AppColors.grey800 : Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
            );
          }).toList(),
        ),
      )),
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

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(AppDimens.padding16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
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
            Icons.history_rounded,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            'No Trip History',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            'Your completed and past trips will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showTripDetailsDialog(BuildContext context, TripModel trip) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius16),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.padding20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Trip Details',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin16),
              _buildDetailRow('Route', '${trip.origin} → ${trip.destination}'),
              const SizedBox(height: AppDimens.margin8),
              _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(trip.departureTime)),
              const SizedBox(height: AppDimens.margin8),
              _buildDetailRow('Time', DateFormat('HH:mm').format(trip.departureTime)),
              const SizedBox(height: AppDimens.margin8),
              _buildDetailRow('Status', trip.status.toUpperCase()),
              const SizedBox(height: AppDimens.margin8),
              _buildDetailRow('Trip ID', trip.id.substring(0, 8).toUpperCase()),
              const SizedBox(height: AppDimens.margin24),
              PrimaryButton(
                text: 'Close',
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Get.context!.theme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppFonts.medium,
            ),
          ),
        ),
      ],
    );
  }
}