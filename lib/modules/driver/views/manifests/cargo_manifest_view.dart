// lib/modules/driver/views/manifests/cargo_manifest_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/modules/driver/controllers/cargo_list_controller.dart';

class CargoManifestView extends StatelessWidget {
  const CargoManifestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tripId = Get.parameters['tripId'];
    if (tripId == null || tripId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Invalid trip ID')),
      );
    }

    final controller = Get.put(CargoListController(), tag: tripId);
    controller.setTripId(tripId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargo Manifest'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.refreshList(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.cargoList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.cargoList.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            // Summary Stats
            Container(
              padding: const EdgeInsets.all(AppDimens.padding12),
              color: isDark ? AppColors.grey800 : AppColors.grey50,
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      title: 'Total Items',
                      value: controller.totalCount.toString(),
                      icon: Icons.inventory_2_rounded,
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: AppDimens.margin8),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      title: 'Total Weight',
                      value: '${controller.totalWeight.toStringAsFixed(1)} kg',
                      icon: Icons.monitor_weight_rounded,
                      color: isDark ? AppColors.infoLight : AppColors.info,
                    ),
                  ),
                  const SizedBox(width: AppDimens.margin8),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      title: 'Total Value',
                      value: CurrencyFormatter.format(controller.totalValue, useShortSymbol: true),
                      icon: Icons.attach_money_rounded,
                      color: isDark ? AppColors.successLight : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16, vertical: AppDimens.padding8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: CargoFilter.values.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppDimens.padding8),
                      child: FilterChip(
                        label: Text(filter.displayName),
                        selected: controller.selectedFilter == filter,
                        onSelected: (_) => controller.setFilter(filter),
                        selectedColor: isDark
                            ? AppColors.primaryGreen.withOpacity(0.3)
                            : AppColors.primaryGreen.withOpacity(0.1),
                        checkmarkColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search cargo...',
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

            // Cargo List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshList,
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  itemCount: controller.cargoList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin8),
                  itemBuilder: (context, index) {
                    final cargo = controller.cargoList[index];
                    return Card(
                      child: InkWell(
                        onTap: () => controller.selectCargo(cargo.id),
                        borderRadius: BorderRadius.circular(AppDimens.radius8),
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimens.padding12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppDimens.padding6),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.grey700 : AppColors.grey100,
                                      borderRadius: BorderRadius.circular(AppDimens.radius4),
                                    ),
                                    child: Icon(
                                      cargo.isFragile ? Icons.warning_amber_rounded : Icons.inventory_2_rounded,
                                      color: cargo.isFragile
                                          ? (isDark ? AppColors.warningLight : AppColors.warning)
                                          : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimens.margin8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tracking: ${cargo.trackingCode}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontFamily: 'monospace',
                                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                          ),
                                        ),
                                        Text(
                                          cargo.receiverName,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            fontWeight: AppFonts.semiBold,
                                          ),
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
                                      color: _getStatusColor(cargo.status, isDark).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppDimens.radius4),
                                    ),
                                    child: Text(
                                      cargo.status.toUpperCase(),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: _getStatusColor(cargo.status, isDark),
                                        fontWeight: AppFonts.medium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimens.margin8),
                              Row(
                                children: [
                                  Icon(Icons.location_on_rounded, size: 14, color: theme.hintColor),
                                  const SizedBox(width: AppDimens.margin4),
                                  Expanded(
                                    child: Text(
                                      cargo.destination,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimens.margin4),
                              Row(
                                children: [
                                  Icon(Icons.monitor_weight_rounded, size: 14, color: theme.hintColor),
                                  const SizedBox(width: AppDimens.margin4),
                                  Text(
                                    '${cargo.weight} kg',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: AppDimens.margin12),
                                  if (cargo.declaredValue != null) ...[
                                    Icon(Icons.attach_money_rounded, size: 14, color: theme.hintColor),
                                    const SizedBox(width: AppDimens.margin4),
                                    Text(
                                      CurrencyFormatter.format(cargo.declaredValue!, useShortSymbol: true),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ],
                              ),
                              if (cargo.status == 'registered')
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => controller.markCargoLoaded(cargo.id),
                                    child: const Text('Mark as Loaded'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: AppDimens.margin2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: AppFonts.bold,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status) {
      case 'registered':
        return isDark ? AppColors.infoLight : AppColors.info;
      case 'loaded':
        return isDark ? AppColors.successLight : AppColors.success;
      case 'in_transit':
        return isDark ? AppColors.warningLight : AppColors.warning;
      case 'delivered':
        return isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen;
      case 'cancelled':
        return isDark ? AppColors.errorLight : AppColors.error;
      default:
        return isDark ? AppColors.grey500 : AppColors.grey600;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            'No Cargo Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            'No cargo has been registered for this trip yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}