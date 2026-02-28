// lib/modules/passenger/views/trip/trip_detail_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/seat/seat_map.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';
import 'package:menahariya/modules/passenger/controllers/trip_detail_controller.dart';

class TripDetailView extends GetView<PassengerTripDetailController> {
  const TripDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading && controller.trip == null) {
          return _buildLoadingShimmer();
        }

        if (controller.trip == null) {
          return _buildErrorState(context);
        }

        return CustomScrollView(
          slivers: [
            // App Bar with image
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              stretch: true,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Bus Image
                    Image.network(
                      controller.busImages.isNotEmpty
                          ? controller.busImages.first
                          : 'https://via.placeholder.com/800x400',
                      fit: BoxFit.cover,
                    ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Favorite Button
                Obx(() => IconButton(
                      icon: Icon(
                        controller.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color:
                            controller.isFavorite ? AppColors.primaryRed : null,
                      ),
                      onPressed: controller.toggleFavorite,
                    )),
                // Share Button
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () {}, // Implement share
                ),
              ],
            ),

            // Trip Info
            SliverPadding(
              padding: const EdgeInsets.all(AppDimens.padding16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Route
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.trip!.origin,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: AppFonts.bold,
                              ),
                            ),
                            Text(
                              'Departure: ${DateFormatter.toTime(controller.trip!.departureTime)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(AppDimens.padding8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.grey800 : AppColors.grey100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_bus_rounded),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              controller.trip!.destination,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: AppFonts.bold,
                              ),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              'Arrival: ${DateFormatter.toTime(controller.trip!.arrivalTime)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.margin16),

                  // Duration & Price
                  Container(
                    padding: const EdgeInsets.all(AppDimens.padding16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey800 : AppColors.grey50,
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Duration',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              DateFormatter.formatTripDuration(
                                controller.trip!.departureTime,
                                controller.trip!.arrivalTime,
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: AppFonts.semiBold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Price per seat',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              CurrencyFormatter.format(controller.trip!.price),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDark
                                    ? AppColors.primaryGreenLight
                                    : AppColors.primaryGreen,
                                fontWeight: AppFonts.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.margin16),

                  // Amenities
                  if (controller.amenities.isNotEmpty) ...[
                    Text(
                      'Amenities',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                    const SizedBox(height: AppDimens.margin12),
                    Wrap(
                      spacing: AppDimens.margin8,
                      runSpacing: AppDimens.margin8,
                      children: controller.amenities.map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.padding12,
                            vertical: AppDimens.padding6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppColors.grey800 : AppColors.grey100,
                            borderRadius:
                                BorderRadius.circular(AppDimens.radius20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                amenity.icon,
                                size: 16,
                                color: isDark
                                    ? AppColors.primaryGreenLight
                                    : AppColors.primaryGreen,
                              ),
                              const SizedBox(width: AppDimens.margin4),
                              Text(
                                amenity.name,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppDimens.margin16),
                  ],

                  // Seat Selection Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Seats',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppFonts.semiBold,
                        ),
                      ),
                      Obx(() => Text(
                            '${controller.availableSeatsCount} seats available',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.primaryGreenLight
                                  : AppColors.primaryGreen,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: AppDimens.margin12),

                  // Seat Map
                  SeatMap(
                    tripId: controller.tripId,
                    seatLayout: controller.seatLayout,
                    seats: controller.seats
                        .map((seat) => SeatData(
                              id: seat.id,
                              number: seat.number,
                              status: seat.status,
                              row: seat.row,
                              column: seat.column,
                              isAvailable: seat.isAvailable,
                            ))
                        .toList(),
                    onSeatSelected: (seatData) {
                      // Find the corresponding SeatModel and call your existing toggle function
                      final seatModel = controller.seats
                          .firstWhere((s) => s.id == seatData.id);
                      controller.toggleSeatSelection(seatModel);
                    },
                    maxSelection: controller.trip?.maxSeatsPerBooking ?? 10,
                  ),

                  const SizedBox(height: AppDimens.margin24),

                  // Reviews Section
                  if (controller.reviews.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reviews',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: AppFonts.semiBold,
                          ),
                        ),
                        TextButton(
                          onPressed: controller.viewAllReviews,
                          child: Text('View All (${controller.totalReviews})'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.margin12),
                    _buildReviewCard(context, controller.reviews.first),
                  ],

                  const SizedBox(
                      height: AppDimens.margin80), // Space for bottom button
                ]),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.selectedSeats.isEmpty) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(AppDimens.padding16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.white,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.transparent
                    : AppColors.grey200.withOpacity(0.5),
                blurRadius: AppDimens.shadowBlurMedium,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${controller.selectedSeats.length} Seat${controller.selectedSeats.length > 1 ? 's' : ''} Selected',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        controller.formattedTotalPrice,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: isDark
                              ? AppColors.primaryGreenLight
                              : AppColors.primaryGreen,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  text: 'Continue',
                  onPressed: controller.proceedToBooking,
                  width: 150,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoadingShimmer() {
    return ShimmerLoading(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: ColoredBox(color: Colors.white),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppDimens.padding16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(height: 60, color: Colors.white),
                const SizedBox(height: AppDimens.margin16),
                Container(height: 80, color: Colors.white),
                const SizedBox(height: AppDimens.margin16),
                Container(height: 40, color: Colors.white),
                const SizedBox(height: AppDimens.margin16),
                Container(height: 200, color: Colors.white),
              ]),
            ),
          ),
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
          Text(
            'Failed to load trip details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimens.margin24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: review.userImage != null
                    ? NetworkImage(review.userImage!)
                    : null,
                child:
                    review.userImage == null ? Text(review.userName[0]) : null,
              ),
              const SizedBox(width: AppDimens.margin12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.primaryYellow,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: AppDimens.margin4),
                        Text(
                          DateFormatter.forNotification(review.date),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            review.comment,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
