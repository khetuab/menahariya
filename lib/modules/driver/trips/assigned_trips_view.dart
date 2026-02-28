// lib/modules/driver/views/trips/assigned_trips_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/cards/trip_card.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/driver/controllers/assigned_trips_controller.dart';

class AssignedTripsView extends GetView<AssignedTripsController> {
  const AssignedTripsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(AppDimens.padding12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search trips...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.padding16,
                      vertical: AppDimens.padding12,
                    ),
                  ),
                  onChanged: controller.setSearchQuery,
                ),
              ),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(
                  left: AppDimens.padding16,
                  right: AppDimens.padding16,
                  bottom: AppDimens.padding12,
                ),
                child: Obx(() => Row(
                  children: TripFilter.values.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppDimens.padding8),
                      child: FilterChip(
                        label: Text(filter.displayName),
                        selected: controller.currentFilter == filter,
                        onSelected: (_) => controller.setFilter(filter),
                        selectedColor: isDark
                            ? AppColors.primaryGreen.withOpacity(0.3)
                            : AppColors.primaryGreen.withOpacity(0.1),
                        checkmarkColor: isDark
                            ? AppColors.primaryGreenLight
                            : AppColors.primaryGreen,
                      ),
                    );
                  }).toList(),
                )),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading && controller.assignedTrips.isEmpty) {
          return _buildLoadingShimmer();
        }

        if (controller.assignedTrips.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshTrips,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppDimens.padding16),
            itemCount: controller.assignedTrips.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin12),
            itemBuilder: (context, index) {
              final trip = controller.assignedTrips[index];
              return TripCard(
                id: trip.id,
                origin: trip.origin,
                destination: trip.destination,
                departureTime: trip.departureTime,
                arrivalTime: trip.arrivalTime,
                price: trip.price,
                availableSeats: trip.availableSeats,
                busType: trip.busType,
                onTap: () => Get.toNamed(
                  '/driver/trip/${trip.id}',
                  arguments: {'tripId': trip.id},
                ),
                showFavorite: false,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.padding16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin12),
      itemBuilder: (_, __) => ShimmerLoading(
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
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
            Icons.route_rounded,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            'No Trips Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            'You don\'t have any assigned trips',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}