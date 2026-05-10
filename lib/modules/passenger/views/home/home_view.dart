// lib/modules/passenger/views/home/home_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/cards/trip_card.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/passenger/controllers/home_controller.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/promotion/promotion_banner_row.dart';
import '../../controllers/notification_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authController = AuthController.instance;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'greeting',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            Text(
              authController.currentUser?.fullName.split(' ').first ?? 'User',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Obx(() {
                  final count = Get.find<PassengerNotificationController>().unreadCount;
                  if (count > 0) {
                    return Positioned(
                      right: 0,
                      top: 0,
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
                          count > 9 ? '9+' : '$count',
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
            onPressed: () => Get.toNamed('/passenger/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshHome,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PromotionBannerRow(),
              const SizedBox(height: AppDimens.margin24),
              // Quick Actions Grid
              _buildQuickActions(context),

              const SizedBox(height: AppDimens.margin24),

              // Popular Routes Section
              _buildPopularRoutes(context),

              const SizedBox(height: AppDimens.margin24),

              // Featured Trips Section
              _buildFeaturedTrips(context),

              const SizedBox(height: AppDimens.margin24),

              // Recent Searches
              _buildRecentSearches(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);

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
        Obx(() => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: AppDimens.gridSpacingMedium,
            mainAxisSpacing: AppDimens.gridSpacingMedium,
          ),
          itemCount: controller.quickActions.length,
          itemBuilder: (context, index) {
            final action = controller.quickActions[index];
            return _buildQuickActionCard(context, action);
          },
        )),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, QuickAction action) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Get.toNamed(action.route),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.padding8),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action.icon,
                color: action.color,
                size: AppDimens.iconSize24,
              ),
            ),
            const SizedBox(height: AppDimens.margin8),
            Text(
              action.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: AppFonts.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularRoutes(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Routes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/passenger/search'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.margin12),
        Obx(() {
          if (controller.isLoading) {
            return _buildPopularRoutesShimmer();
          }
          if (controller.popularRoutes.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.route_rounded,
              message: 'No popular routes found',
            );
          }
          return SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.popularRoutes.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppDimens.margin12),
              itemBuilder: (context, index) {
                final route = controller.popularRoutes[index];
                return Container(
                  width: 120,
                  padding: const EdgeInsets.all(AppDimens.padding12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.route_rounded,
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      ),
                      const SizedBox(height: AppDimens.margin4),
                      Text(
                        route.origin,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                      ),
                      Text(
                        route.destination,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: AppFonts.medium,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFeaturedTrips(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Trips',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: AppDimens.margin12),
        Obx(() {
          if (controller.isLoading) {
            return _buildFeaturedTripsShimmer();
          }
          if (controller.featuredTrips.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.directions_bus_rounded,
              message: 'No featured trips available',
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.featuredTrips.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin12),
            itemBuilder: (context, index) {
              final trip = controller.featuredTrips[index];
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
                  AppRoutes.passengerTripDetail,  // ✅ Use the constant
                  arguments: {'tripId': trip.id},
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
            if (controller.recentSearches.isNotEmpty)
              TextButton(
                onPressed: controller.clearRecentSearches,
                child: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 50),
        Obx(() {
          if (controller.recentSearches.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.search_rounded,
              message: 'No recent searches',
              compact: true,
            );
          }
          return Wrap(
            spacing: AppDimens.margin8,
            runSpacing: AppDimens.margin8,
            children: controller.recentSearches.map((search) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding12,
                  vertical: AppDimens.padding6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey100,
                  borderRadius: BorderRadius.circular(AppDimens.radius20),
                ),
                child: Text(
                  search,
                  style: theme.textTheme.bodySmall,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPopularRoutesShimmer() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.margin12),
        itemBuilder: (_, __) => ShimmerLoading(
          child: Container(
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedTripsShimmer() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin12),
      itemBuilder: (_, __) => ShimmerLoading(
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, {
        required IconData icon,
        required String message,
        bool compact = false,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (compact) {
      return Center(
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding32),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
            ),
          ),
        ],
      ),
    );
  }
}