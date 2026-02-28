// lib/modules/passenger/views/history/cargo_history_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/cards/cargo_card.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/passenger/controllers/history_controller.dart';

class CargoHistoryView extends GetView<PassengerHistoryController> {
  const CargoHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargo History'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // Show search
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.cargoList.isEmpty) {
          return _buildLoadingShimmer();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.padding16),
            children: [
              // Stats Card
              _buildStatsCard(context),

              const SizedBox(height: AppDimens.margin20),

              // Filters
              _buildFilters(context),

              const SizedBox(height: AppDimens.margin16),

              // Cargo List
              if (controller.filteredCargo.isEmpty)
                _buildEmptyState(context)
              else
                ...controller.filteredCargo.map((cargo) => CargoCard(
                  trackingId: cargo.trackingCode,
                  destination: cargo.destination,
                  weight: cargo.weight,
                  fee: cargo.fee,
                  status: cargo.status,
                  registeredDate: cargo.registeredDate,
                  onTap: () => Get.toNamed(
                    '/passenger/cargo/${cargo.id}',
                    arguments: {'cargoId': cargo.id},
                  ),
                  onTrack: () => Get.toNamed(
                    '/passenger/cargo/track',
                    arguments: {'trackingCode': cargo.trackingCode},
                  ),
                  onReceipt: () => Get.toNamed(
                    '/passenger/cargo/receipt',
                    arguments: {'cargo': cargo},
                  ),
                )),

              // Load More
              if (controller.cargoHasMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimens.padding16),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: controller.loadMoreCargo,
                      child: const Text('Load More'),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Shipments',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  '${controller.totalCargo}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total Spent',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'ETB ${controller.totalSpent.toStringAsFixed(0)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
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

  Widget _buildFilters(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(context, 'All', 'all'),
          const SizedBox(width: AppDimens.margin8),
          _buildFilterChip(context, 'In Transit', 'in_transit'),
          const SizedBox(width: AppDimens.margin8),
          _buildFilterChip(context, 'Delivered', 'delivered'),
          const SizedBox(width: AppDimens.margin8),
          _buildFilterChip(context, 'Cancelled', 'cancelled'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String value) {
    final isSelected = controller.statusFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        controller.setStatusFilter(selected ? value : 'all');
      },
      selectedColor: isSelected
          ? (Theme.of(context).brightness == Brightness.dark
          ? AppColors.primaryGreen.withOpacity(0.3)
          : AppColors.primaryGreen.withOpacity(0.1))
          : null,
      checkmarkColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.primaryGreenLight
          : AppColors.primaryGreen,
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.padding16),
      itemCount: 3,
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_rounded,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            'No Cargo History',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            'Your cargo shipment history will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}