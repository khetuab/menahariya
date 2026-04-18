// lib/modules/driver/views/manifests/passenger_manifest_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/driver/controllers/passenger_list_controller.dart';

class PassengerManifestView extends GetView<PassengerListController> {
  const PassengerManifestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Manifest'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Content (moved from AppBar.bottom)
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stats Summary
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.padding16,
                    vertical: AppDimens.padding8,
                  ),
                  child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        label: 'Total',
                        value: controller.totalCount.toString(),
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      ),
                      _buildStatItem(
                        context,
                        label: 'Checked In',
                        value: controller.checkedInCount.toString(),
                        color: isDark ? AppColors.successLight : AppColors.success,
                      ),
                      _buildStatItem(
                        context,
                        label: 'Pending',
                        value: controller.pendingCount.toString(),
                        color: isDark ? AppColors.warningLight : AppColors.warning,
                      ),
                    ],
                  )),
                ),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(
                    left: AppDimens.padding16,
                    right: AppDimens.padding16,
                    bottom: AppDimens.padding8,
                  ),
                  child: Obx(() => Row(
                    children: PassengerFilter.values.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppDimens.padding8),
                        child: FilterChip(
                          label: Text(filter.displayName),
                          selected: controller.selectedFilter == filter,
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
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(AppDimens.padding12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search passengers...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radius8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.padding12,
                        vertical: AppDimens.padding8,
                      ),
                      isDense: true,
                    ),
                    onChanged: controller.setSearchQuery,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          // Passenger List
          Expanded(
            child: Obx(() {
              if (controller.isLoading && controller.passengers.isEmpty) {
                return _buildLoadingShimmer();
              }

              if (controller.passengers.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshList,
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  itemCount: controller.passengers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin8),
                  itemBuilder: (context, index) {
                    final passenger = controller.passengers[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: passenger.checkedIn
                              ? (isDark ? AppColors.successLight : AppColors.success)
                              : (isDark ? AppColors.warningLight : AppColors.warning),
                          child: Text(passenger.name[0]),
                        ),
                        title: Text(passenger.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Seat: ${passenger.seatNumber}'),
                            if (passenger.hasCargo)
                              Container(
                                margin: const EdgeInsets.only(top: AppDimens.margin4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimens.padding6,
                                  vertical: AppDimens.padding2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.info.withOpacity(0.2) : AppColors.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppDimens.radius4),
                                ),
                                child: Text(
                                  'Has Cargo',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? AppColors.infoLight : AppColors.info,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.padding8,
                            vertical: AppDimens.padding4,
                          ),
                          decoration: BoxDecoration(
                            color: passenger.checkedIn
                                ? (isDark ? AppColors.success.withOpacity(0.2) : AppColors.success.withOpacity(0.1))
                                : (isDark ? AppColors.warning.withOpacity(0.2) : AppColors.warning.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(AppDimens.radius4),
                          ),
                          child: Text(
                            passenger.checkedIn ? 'Checked In' : 'Pending',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: passenger.checkedIn
                                  ? (isDark ? AppColors.successLight : AppColors.success)
                                  : (isDark ? AppColors.warningLight : AppColors.warning),
                              fontWeight: AppFonts.medium,
                            ),
                          ),
                        ),
                        onTap: () => controller.selectPassenger(passenger.id),
                      ),
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

  Widget _buildLoadingShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.padding16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin8),
      itemBuilder: (_, __) => ShimmerLoading(
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radius8),
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
            Icons.people_outline_rounded,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            'No Passengers Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            'The passenger list is empty',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}