// lib/modules/passenger/views/search/search_results_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/cards/trip_card.dart';
import 'package:menahariya/core/widgets/bottom_sheets/filter_bottom_sheet.dart' as bottomsheet;
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/passenger/controllers/search_controller.dart' as search;

import '../../../../core/utils/formatters/date_formatter.dart';

class SearchResultsView extends GetView<search.PassengerSearchController> {
  const SearchResultsView({Key? key}) : super(key: key);

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
              '${controller.fromController.text} → ${controller.toController.text}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
            Text(
              DateFormatter.toDisplayDate(controller.selectedDate!),
              style: theme.textTheme.bodySmall,
            ),
          ],
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.searchTrips,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.searchResults.isEmpty) {
          return _buildLoadingShimmer();
        }

        if (controller.searchResults.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: controller.searchTrips,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppDimens.padding16),
            itemCount: controller.searchResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin12),
            itemBuilder: (context, index) {
              final trip = controller.searchResults[index];
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
                  '/passenger/trip/${trip.id}',
                  arguments: {'tripId': trip.id},
                ),
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
            Icons.search_off_rounded,
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
            'Try adjusting your search filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppDimens.margin24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Modify Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Show filters bottom sheet using the correct FilterOptions type
  Future<void> _showFilters() async {
    final result = await Get.bottomSheet<bottomsheet.FilterOptions>(
      bottomsheet.FilterBottomSheet(
        // Use the same FilterOptions type as the bottom sheet
        initialOptions: controller.appliedFilters as bottomsheet.FilterOptions,
        onApply: (filters) => controller.applyFilters(filters as search.FilterOptions ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}