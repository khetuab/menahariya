// lib/modules/driver/views/dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/cards/trip_card.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/core/utils/app_snackbar.dart';
import 'package:menahariya/modules/driver/controllers/dashboard_controller.dart';
import 'package:menahariya/modules/driver/views/boarding/boarding_management_view.dart';
import 'package:menahariya/modules/driver/views/boarding/validation_view.dart';
import 'package:menahariya/modules/driver/views/profile/profile_view.dart';

import '../trips/assigned_trips_view.dart';

class DriverDashboardView extends GetView<DriverDashboardController> {
  const DriverDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${controller.driverName}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
            Text(
              'Driver',
              style: theme.textTheme.bodySmall,
            ),
          ],
        )),
        actions: [
          // Online/Offline Toggle
          Obx(() => Switch(
            value: controller.isOnline,
            onChanged: controller.updateDriverStatus,
            activeColor: isDark ? AppColors.successLight : AppColors.success,
            inactiveThumbColor: isDark ? AppColors.errorLight : AppColors.error,
          )),
          const SizedBox(width: AppDimens.margin8),
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_rounded),
                onPressed: () => Get.toNamed('/driver/notifications'),
              ),
              Obx(() {
                if (controller.notificationsCount > 0) {
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        controller.notificationsCount > 9
                            ? '9+'
                            : '${controller.notificationsCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              }),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.currentIndex == 0) {
          return _buildLoadingShimmer();
        }

        // Show different screens based on selected tab
        return IndexedStack(
          index: controller.currentIndex,
          children: const [
            // Index 0: Dashboard (current view)
            _DashboardContent(),

            // Index 1: Trips
            AssignedTripsView(),

            // Index 2: Boarding
            BoardingManagementView(),

            // Index 3: Validate
            ValidationView(),

            // Index 4: Profile
            DriverProfileView(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex,
        onTap: controller.changeTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        selectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: AppFonts.medium,
        ),
        unselectedLabelStyle: theme.textTheme.bodySmall,
        items: List.generate(5, (index) {
          return BottomNavigationBarItem(
            icon: Icon(controller.screenIcons[index]),
            label: controller.screenTitles[index],
          );
        }),
      )),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.padding16),
      children: [
        ShimmerLoading(
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.margin16),
        ShimmerLoading(
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.margin16),
        ShimmerLoading(
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
          ),
        ),
      ],
    );
  }
}

// Extract dashboard content to a separate widget for cleaner code
class _DashboardContent extends GetView<DriverDashboardController> {
  const _DashboardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: controller.refreshDashboard,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.padding16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Grid
            _buildStatsGrid(context),

            const SizedBox(height: AppDimens.margin24),

            // Current Trip Section
            if (controller.currentTrip != null)
              _buildCurrentTrip(context),

            const SizedBox(height: AppDimens.margin24),

            // Upcoming Trips
            _buildUpcomingTrips(context),

            const SizedBox(height: AppDimens.margin24),

            // Quick Actions
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppDimens.gridSpacingMedium,
      mainAxisSpacing: AppDimens.gridSpacingMedium,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          icon: Icons.route_rounded,
          label: "Today's Trips",
          value: '${controller.todayTrips}',
          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
        ),
        _buildStatCard(
          context,
          icon: Icons.check_circle_rounded,
          label: 'Completed',
          value: '${controller.completedTrips}',
          color: isDark ? AppColors.successLight : AppColors.success,
        ),
        _buildStatCard(
          context,
          icon: Icons.people_rounded,
          label: 'Passengers',
          value: '${controller.totalPassengers}',
          color: isDark ? AppColors.infoLight : AppColors.info,
        ),
        _buildStatCard(
          context,
          icon: Icons.inventory_2_rounded,
          label: 'Cargo Items',
          value: '${controller.totalCargo}',
          color: isDark ? AppColors.warningLight : AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
      }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppDimens.margin4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTrip(BuildContext context) {
    final theme = Theme.of(context);
    final trip = controller.currentTrip!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Trip',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: AppDimens.margin12),
        TripCard(
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
        ),
      ],
    );
  }

  Widget _buildUpcomingTrips(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Trips',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
            TextButton(
              onPressed: () => controller.changeTab(1),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.margin12),
        Obx(() {
          if (controller.upcomingTrips.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(AppDimens.padding32),
              child: Center(
                child: Text(
                  'No upcoming trips',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.upcomingTrips.length > 3
                ? 3
                : controller.upcomingTrips.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin12),
            itemBuilder: (context, index) {
              final trip = controller.upcomingTrips[index];
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
          );
        }),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: AppDimens.margin12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan Ticket',
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                onTap: () {
                  controller.changeTab(3); // Switch to validation tab
                },
              ),
            ),
            const SizedBox(width: AppDimens.margin12),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.assignment_rounded,
                label: 'Boarding',
                color: isDark ? AppColors.infoLight : AppColors.info,
                onTap: () {
                  if (controller.currentTrip != null) {
                    Get.toNamed(
                      '/driver/boarding/${controller.currentTrip!.id}',
                      arguments: {'tripId': controller.currentTrip!.id},
                    );
                  } else {
                    AppSnackbar.show(
                      'No Active Trip',
                      'You don\'t have an active trip to manage boarding',
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.margin12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.warning_rounded,
                label: 'Report Issue',
                color: isDark ? AppColors.warningLight : AppColors.warning,
                onTap: () {
                  if (controller.currentTrip != null) {
                    Get.toNamed(
                      '/driver/incident/report',
                      arguments: {'tripId': controller.currentTrip!.id},
                    );
                  } else {
                    Get.toNamed('/driver/incident/report');
                  }
                },
              ),
            ),
            const SizedBox(width: AppDimens.margin12),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.update_rounded,
                label: 'Update Status',
                color: isDark ? AppColors.successLight : AppColors.success,
                onTap: () {
                  if (controller.currentTrip != null) {
                    Get.toNamed(
                      '/driver/trip/${controller.currentTrip!.id}/status',
                      arguments: {'tripId': controller.currentTrip!.id},
                    );
                  }
                },
              ),
            ),
          ],
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
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radius8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.padding12,
          horizontal: AppDimens.padding8,
        ),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimens.radius8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: AppDimens.margin4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: AppFonts.medium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}