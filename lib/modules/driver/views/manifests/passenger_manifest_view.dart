import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/modules/driver/controllers/passenger_list_controller.dart';

class PassengerManifestView extends StatelessWidget {
  const PassengerManifestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get tripId from URL parameter
    final tripId = Get.parameters['tripId'];
    if (tripId == null || tripId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Invalid trip ID')),
      );
    }

    // Create a new controller instance (unique tag = tripId)
    final controller = Get.put(PassengerListController(), tag: tripId);
    controller.setTripId(tripId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Manifest'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.refreshList(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.passengers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.passengers.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            // Stats Summary
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.padding16,
                vertical: AppDimens.padding12,
              ),
              color: isDark ? AppColors.grey800 : AppColors.grey50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    label: 'Total',
                    value: controller.totalCount.toString(),
                    color: isDark
                        ? AppColors.primaryGreenLight
                        : AppColors.primaryGreen,
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
              ),
            ),

            // Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding16,
                  vertical: AppDimens.padding8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
                ),
              ),
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

            // Passenger List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshList,
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  itemCount: controller.passengers.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimens.margin8),
                  itemBuilder: (context, index) {
                    final passenger = controller.passengers[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 4.0),
                        leading: CircleAvatar(
                          backgroundColor: passenger.checkedIn
                              ? (isDark
                                  ? AppColors.successLight
                                  : AppColors.success)
                              : (isDark
                                  ? AppColors.warningLight
                                  : AppColors.warning),
                          child: Text(passenger.name.isNotEmpty
                              ? passenger.name[0]
                              : '?'),
                        ),
                        title: Text(passenger.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Seat: ${passenger.seatNumber}'),
                            Text(
                                'Ticket: ${passenger.ticketNumber.substring(0, 8)}...'),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: passenger.checkedIn
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.padding8,
                                    vertical: AppDimens.padding4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.success.withOpacity(0.2)
                                        : AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppDimens.radius4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Checked In',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: isDark
                                            ? AppColors.successLight
                                            : AppColors.success,
                                        fontWeight: AppFonts.medium,
                                      ),
                                    ),
                                  ),
                                ) : ElevatedButton(
                                  onPressed: () => controller
                                      .markPassengerCheckedIn(passenger.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? AppColors.primaryGreenLight
                                        : AppColors.primaryGreen,
                                    minimumSize: const Size(80, 36),
                                  ),
                                  child: const Text('Check In'),
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

  Widget _buildStatItem(BuildContext context,
      {required String label, required String value, required Color color}) {
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
            'No passengers have booked this trip yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
