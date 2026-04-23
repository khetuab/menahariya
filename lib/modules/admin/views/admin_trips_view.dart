// lib/modules/admin/views/admin_trips_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_dialogs.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_filter_chip.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_sidebar.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_status_badge.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/inputs/custom_textfield.dart';
import '../controllers/admin_trip_controller.dart';

class AdminTripsView extends GetView<AdminTripController> {
  const AdminTripsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AdminDrawer(currentIndex: 1),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Trips'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateTripDialog(context),
            tooltip: 'Add Trip',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshTrips,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.trips.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Search and Filter Bar
            _buildSearchBar(context),
            // Stats Row
            _buildStatsRow(context),
            // Active Filters
            _buildActiveFilters(context),
            // Trips List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshTrips,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  itemCount: controller.trips.length + (controller.hasMorePages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.trips.length && controller.hasMorePages) {
                      return _buildLoadMoreIndicator();
                    }
                    if (index >= controller.trips.length) {
                      return const SizedBox();
                    }
                    final trip = controller.trips[index];
                    return _buildTripCard(context, trip);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by route, origin, or destination...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                    ? GestureDetector(
                  onTap: () => controller.searchController.clear(),
                  child: const Icon(Icons.clear_rounded, size: 18),
                )
                    : const SizedBox.shrink()),
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
          ),
          const SizedBox(width: AppDimens.margin8),
          GestureDetector(
            onTap: () => _showFilterBottomSheet(context),
            child: Container(
              padding: const EdgeInsets.all(AppDimens.padding12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : AppColors.grey100,
                borderRadius: BorderRadius.circular(AppDimens.radius12),
              ),
              child: Icon(
                Icons.filter_list_rounded,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
      child: Row(
        children: [
          _buildStatChip('Total', controller.totalTrips.toString(), Colors.blue),
          const SizedBox(width: AppDimens.margin8),
          _buildStatChip('Scheduled', controller.scheduledTrips.toString(), Colors.green),
          const SizedBox(width: AppDimens.margin8),
          _buildStatChip('In Progress', controller.inProgressTrips.toString(), Colors.orange),
          const SizedBox(width: AppDimens.margin8),
          _buildStatChip('Completed', controller.completedTrips.toString(), Colors.teal),
          const SizedBox(width: AppDimens.margin8),
          _buildStatChip('Cancelled', controller.cancelledTrips.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding12, vertical: AppDimens.padding6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radius20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.bold,
              color: color,
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

  Widget _buildActiveFilters(BuildContext context) {
    if (!_hasActiveFilters()) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16, vertical: AppDimens.padding8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (controller.statusFilter.isNotEmpty)
              _buildFilterChip(
                label: 'Status: ${_getStatusDisplayName(controller.statusFilter)}',
                onClear: () => controller.setStatusFilter(''),
              ),
            if (controller.routeFilter != null && controller.routeFilter!.isNotEmpty)
              _buildFilterChip(
                label: 'Route: ${controller.routeFilter}',
                onClear: () => controller.setRouteFilter(null),
              ),
            if (controller.dateFilter != null)
              _buildFilterChip(
                label: 'Date: ${DateFormat('MMM dd, yyyy').format(controller.dateFilter!)}',
                onClear: () => controller.setDateFilter(null),
              ),
            _buildFilterChip(
              label: 'Clear All',
              onClear: controller.clearFilters,
              isClearAll: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onClear,
    bool isClearAll = false,
  }) {
    final isDark = Get.context!.theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(right: AppDimens.margin8),
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding8, vertical: AppDimens.padding4),
      decoration: BoxDecoration(
        color: isClearAll
            ? (isDark ? AppColors.error.withOpacity(0.2) : AppColors.error.withOpacity(0.1))
            : (isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(
          color: isClearAll
              ? (isDark ? AppColors.errorLight : AppColors.error)
              : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isClearAll
                  ? (isDark ? AppColors.errorLight : AppColors.error)
                  : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: AppDimens.margin4),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: isClearAll
                  ? (isDark ? AppColors.errorLight : AppColors.error)
                  : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, dynamic trip) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.margin12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip.origin} → ${trip.destination}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppFonts.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimens.margin2),
                      Text(
                        'ID: ${trip.id.substring(0, 8).toUpperCase()}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                AdminStatusBadge(status: trip.status),
              ],
            ),
            const SizedBox(height: AppDimens.margin12),
            // Date and Time
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    icon: Icons.calendar_today_rounded,
                    label: 'Departure',
                    value: DateFormat('MMM dd, yyyy').format(trip.departureTime),
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    icon: Icons.access_time_rounded,
                    label: 'Time',
                    value: DateFormat('HH:mm').format(trip.departureTime),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.margin8),
            // Price and Seats
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    icon: Icons.attach_money_rounded,
                    label: 'Price',
                    value: 'ETB ${trip.price.toStringAsFixed(0)}',
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    icon: Icons.chair_rounded,
                    label: 'Seats',
                    value: '${trip.availableSeats}/${trip.totalSeats} available',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.margin8),
            // Vehicle and Driver
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    icon: Icons.directions_bus_rounded,
                    label: 'Vehicle',
                    // Use vehicle object if available, fallback to vehicleId
                    value: trip.vehicle?.plateNumber ?? 'N/A',
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    icon: Icons.person_rounded,
                    label: 'Driver',
                    // Use driver object if available, fallback to driverId
                    value: trip.driver?.fullName?.split(' ').first ?? 'Not Assigned',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.margin12),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_rounded, color: Colors.blue),
                  onPressed: () => _showTripDetailsDialog(trip),
                  tooltip: 'View Details',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.orange),
                  onPressed: () => _showEditTripDialog(trip),
                  tooltip: 'Edit',
                ),
                if (trip.status == 'scheduled')
                  IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                    onPressed: () => _showCancelTripDialog(trip),
                    tooltip: 'Cancel Trip',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        const SizedBox(width: AppDimens.margin4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: AppFonts.medium)),
            ],
          ),
        ),
      ],
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

  void _showFilterBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Trips',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin24),
                // Status Filter
                Text(
                  'Status',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin12),
                Wrap(
                  spacing: AppDimens.margin8,
                  runSpacing: AppDimens.margin8,
                  children: [
                    AdminFilterChip(
                      label: 'All',
                      value: '',
                      selectedValue: controller.statusFilter,
                      onSelected: (value) => controller.setStatusFilter(value),
                    ),
                    AdminFilterChip(
                      label: 'Scheduled',
                      value: 'scheduled',
                      selectedValue: controller.statusFilter,
                      onSelected: (value) => controller.setStatusFilter(value),
                    ),
                    AdminFilterChip(
                      label: 'In Progress',
                      value: 'in_progress',
                      selectedValue: controller.statusFilter,
                      onSelected: (value) => controller.setStatusFilter(value),
                    ),
                    AdminFilterChip(
                      label: 'Completed',
                      value: 'completed',
                      selectedValue: controller.statusFilter,
                      onSelected: (value) => controller.setStatusFilter(value),
                    ),
                    AdminFilterChip(
                      label: 'Cancelled',
                      value: 'cancelled',
                      selectedValue: controller.statusFilter,
                      onSelected: (value) => controller.setStatusFilter(value),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin24),
                // Route Filter
                Text(
                  'Route',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin12),
                DropdownButtonFormField<String>(
                  value: controller.routeFilter,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Routes')),
                    ...controller.routes.map((route) {
                      return DropdownMenuItem(
                        value: route.id,
                        child: Text(route.name),
                      );
                    }),
                  ],
                  onChanged: (value) => controller.setRouteFilter(value),
                ),
                const SizedBox(height: AppDimens.margin24),
                // Date Filter
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(
                    controller.dateFilter != null
                        ? DateFormat('yyyy-MM-dd').format(controller.dateFilter!)
                        : 'Select date',
                  ),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: controller.dateFilter ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2026),
                    );
                    if (date != null) {
                      controller.setDateFilter(date);
                      Get.back();
                    }
                  },
                ),
                const SizedBox(height: AppDimens.margin24),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Reset',
                        onPressed: () {
                          controller.clearFilters();
                          Get.back();
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Apply',
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateTripDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Reset form
    controller.routeIdController.clear();
    controller.vehicleIdController.clear();
    controller.driverIdController.clear();
    controller.departureTimeController.clear();
    controller.arrivalTimeController.clear();
    controller.priceController.clear();
    controller.notesController.clear();

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Trip',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: AppFonts.bold,
                        fontSize: 22,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey800 : AppColors.grey100,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin24),

                // Route Selection
                _buildFormField(
                  label: 'Route',
                  child: DropdownButtonFormField<String>(
                    decoration: _buildInputDecoration('Select route', Icons.route_rounded),
                    items: controller.routes.map((route) {
                      return DropdownMenuItem(
                        value: route.id,
                        child: Text(
                          '${route.origin} → ${route.destination}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => controller.routeIdController.text = value ?? '',
                  ),
                ),

                const SizedBox(height: AppDimens.margin16),

                // Vehicle Selection
                _buildFormField(
                  label: 'Vehicle',
                  child: DropdownButtonFormField<String>(
                    decoration: _buildInputDecoration('Select vehicle', Icons.directions_bus_rounded),
                    items: controller.vehicles.map((vehicle) {
                      return DropdownMenuItem(
                        value: vehicle.id,
                        child: Text(
                          '${vehicle.plateNumber} - ${vehicle.model}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => controller.vehicleIdController.text = value ?? '',
                  ),
                ),

                const SizedBox(height: AppDimens.margin16),

                // Driver Selection with refresh
                _buildFormField(
                  label: 'Driver',
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          if (controller.drivers.isEmpty) {
                            return DropdownButtonFormField<String>(
                              decoration: _buildInputDecoration('No drivers available', Icons.person_rounded),
                              value: null,
                              items: const [
                                DropdownMenuItem(value: null, child: Text('No drivers available'))
                              ],
                              onChanged: null,
                            );
                          }
                          return DropdownButtonFormField<String>(
                            decoration: _buildInputDecoration('Select driver', Icons.person_rounded),
                            value: controller.driverIdController.text.isEmpty ? null : controller.driverIdController.text,
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Select Driver')),
                              ...controller.drivers.map((driver) {
                                return DropdownMenuItem(
                                  value: driver.id,
                                  child: Text(
                                    driver.fullName ?? 'Unknown Driver',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              controller.driverIdController.text = value ?? '';
                            },
                          );
                        }),
                      ),
                      const SizedBox(width: AppDimens.margin8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.grey800 : AppColors.grey100,
                          borderRadius: BorderRadius.circular(AppDimens.radius12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.refresh_rounded, size: 20, color: AppColors.primaryGreen),
                          onPressed: () async {
                            await controller.fetchDropdownData();
                            Get.snackbar(
                              'Refreshed',
                              'Drivers list refreshed',
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 1),
                              backgroundColor: isDark ? AppColors.grey800 : Colors.white,
                              colorText: isDark ? Colors.white : Colors.black,
                            );
                          },
                          tooltip: 'Refresh Drivers',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.margin16),

                // Departure Time
                _buildFormField(
                  label: 'Departure Time',
                  child: GestureDetector(
                    onTap: () => _selectDateTime(context, isDeparture: true),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: controller.departureTimeController,
                        style: const TextStyle(fontSize: 14),
                        decoration: _buildInputDecoration('Select date and time', Icons.calendar_today_rounded),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimens.margin16),

                // Arrival Time
                _buildFormField(
                  label: 'Arrival Time',
                  child: GestureDetector(
                    onTap: () => _selectDateTime(context, isDeparture: false),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: controller.arrivalTimeController,
                        style: const TextStyle(fontSize: 14),
                        decoration: _buildInputDecoration('Select date and time', Icons.calendar_today_rounded),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimens.margin16),

                // Price
                _buildFormField(
                  label: 'Price',
                  child: CustomTextField(
                    controller: controller.priceController,
                    hint: 'Enter price in ETB',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money_rounded,
                    label: 'Price',
                  ),
                ),

                const SizedBox(height: AppDimens.margin16),

                // Notes
                _buildFormField(
                  label: 'Notes (Optional)',
                  child: CustomTextField(
                    controller: controller.notesController,
                    hint: 'Any additional information...',
                    maxLines: 2,
                    prefixIcon: Icons.note_rounded,
                    label: 'Notes',
                  ),
                ),

                const SizedBox(height: AppDimens.margin24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Cancel',
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Create Trip',
                        onPressed: () async {
                          // Validate
                          if (controller.routeIdController.text.isEmpty) {
                            Get.snackbar('Error', 'Please select a route',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }
                          if (controller.vehicleIdController.text.isEmpty) {
                            Get.snackbar('Error', 'Please select a vehicle',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }
                          if (controller.driverIdController.text.isEmpty) {
                            Get.snackbar('Error', 'Please select a driver',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }
                          if (controller.departureTimeController.text.isEmpty) {
                            Get.snackbar('Error', 'Please select departure time',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }
                          if (controller.arrivalTimeController.text.isEmpty) {
                            Get.snackbar('Error', 'Please select arrival time',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }
                          if (controller.priceController.text.isEmpty) {
                            Get.snackbar('Error', 'Please enter price',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }

                          final success = await controller.createTrip({
                            'routeId': controller.routeIdController.text,
                            'vehicleId': controller.vehicleIdController.text,
                            'driverId': controller.driverIdController.text,
                            'departureTime': controller.departureTimeController.text,
                            'arrivalTime': controller.arrivalTimeController.text,
                            'price': double.tryParse(controller.priceController.text) ?? 0,
                            'totalSeats': controller.vehicles.firstWhere(
                                  (v) => v.id == controller.vehicleIdController.text,
                              orElse: () => controller.vehicles.first,
                            ).capacity,
                            'notes': controller.notesController.text.isEmpty ? null : controller.notesController.text,
                          });
                          if (success) Get.back();
                        },
                        isLoading: controller.isLoading,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimens.margin8),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Helper method to build form field with label
  Widget _buildFormField({
    required String label,
    required Widget child,
  }) {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppDimens.margin6),
        child,
      ],
    );
  }

// Helper method to build input decoration
  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.textHintDark : AppColors.textHintLight),
      prefixIcon: Icon(icon, size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        borderSide: BorderSide(
          color: AppColors.primaryGreen,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding16,
        vertical: AppDimens.padding14,
      ),
      filled: true,
      fillColor: isDark ? AppColors.grey800 : AppColors.grey50,
    );
  }

  void _showTripDetailsDialog(dynamic trip) async {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    await controller.getTripDetails(trip.id);
    final fullTrip = controller.selectedTrip;
    if (fullTrip == null) return;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trip Details',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                _buildDetailSection(
                  title: 'Trip Information',
                  children: [
                    _buildDetailRow('Trip ID', fullTrip.id),
                    _buildDetailRow('Route', '${fullTrip.origin} → ${fullTrip.destination}'),
                    _buildDetailRow('Status', fullTrip.status),
                    _buildDetailRow('Price', 'ETB ${fullTrip.price.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                _buildDetailSection(
                  title: 'Schedule',
                  children: [
                    _buildDetailRow('Departure', _formatDateTime(fullTrip.departureTime)),
                    _buildDetailRow('Arrival', _formatDateTime(fullTrip.arrivalTime)),
                    _buildDetailRow('Duration', fullTrip.duration.inHours > 0
                        ? '${fullTrip.duration.inHours}h ${fullTrip.duration.inMinutes % 60}m'
                        : '${fullTrip.duration.inMinutes}m'),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                _buildDetailSection(
                  title: 'Capacity',
                  children: [
                    _buildDetailRow('Seats', '${fullTrip.availableSeats}/${fullTrip.totalSeats}'),
                    _buildDetailRow('Cargo Capacity', '${fullTrip.cargoCapacity?.toStringAsFixed(0) ?? 0} kg'),
                    _buildDetailRow('Current Cargo', '${fullTrip.currentCargoWeight?.toStringAsFixed(0) ?? 0} kg'),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                _buildDetailSection(
                  title: 'Assignment',
                  children: [
                    _buildDetailRow('Vehicle', fullTrip.vehicle?.plateNumber ?? 'N/A'),
                    _buildDetailRow('Driver', fullTrip.driver?.fullName ?? 'Not Assigned'),
                  ],
                ),
                if (fullTrip.notes != null && fullTrip.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.margin16),
                  _buildDetailSection(
                    title: 'Notes',
                    children: [
                      Text(fullTrip.notes!, style: Get.context!.textTheme.bodyMedium),
                    ],
                  ),
                ],
                const SizedBox(height: AppDimens.margin24),
                PrimaryButton(
                  text: 'Close',
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditTripDialog(dynamic trip) async {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    // Pre-fill controllers
    controller.routeIdController.text = trip.routeId;
    controller.vehicleIdController.text = trip.vehicleId;
    controller.driverIdController.text = trip.driverId;
    controller.departureTimeController.text = _formatDateTime(trip.departureTime);
    controller.arrivalTimeController.text = _formatDateTime(trip.arrivalTime);
    controller.priceController.text = trip.price.toString();
    controller.notesController.text = trip.notes ?? '';

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Trip',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: AppFonts.bold,
                        fontSize: 22,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey800 : AppColors.grey100,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin24),

                // Route Selection (read-only in edit)
                _buildFormField(
                  label: 'Route',
                  child: DropdownButtonFormField<String>(
                    value: controller.routeIdController.text,
                    decoration: _buildInputDecoration('Select route', Icons.route_rounded),
                    items: controller.routes.map((route) {
                      return DropdownMenuItem(
                        value: route.id,
                        child: Text(
                          '${route.origin} → ${route.destination}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => controller.routeIdController.text = value ?? '',
                  ),
                ),

                const SizedBox(height: AppDimens.margin16),

                // Vehicle Selection
                _buildFormField(
                  label: 'Vehicle',
                  child: DropdownButtonFormField<String>(
                    value: controller.vehicleIdController.text,
                    decoration: _buildInputDecoration('Select vehicle', Icons.directions_bus_rounded),
                    items: controller.vehicles.map((vehicle) {
                      return DropdownMenuItem(
                        value: vehicle.id,
                        child: Text(
                          '${vehicle.plateNumber} - ${vehicle.model}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => controller.vehicleIdController.text = value ?? '',
                  ),
                ),

                const SizedBox(height: AppDimens.margin16),

                // Driver Selection
                _buildFormField(
                  label: 'Driver',
                  child: Obx(() {
                    if (controller.drivers.isEmpty) {
                      return DropdownButtonFormField<String>(
                        decoration: _buildInputDecoration('No drivers available', Icons.person_rounded),
                        value: null,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('No drivers available'))
                        ],
                        onChanged: null,
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: controller.driverIdController.text.isEmpty ? null : controller.driverIdController.text,
                      decoration: _buildInputDecoration('Select driver', Icons.person_rounded),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Select Driver')),
                        ...controller.drivers.map((driver) {
                          return DropdownMenuItem(
                            value: driver.id,
                            child: Text(
                              driver.fullName ?? 'Unknown Driver',
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        controller.driverIdController.text = value ?? '';
                      },
                    );
                  }),
                ),

                const SizedBox(height: AppDimens.margin16),

                // Departure Time
                _buildFormField(
                  label: 'Departure Time',
                  child: GestureDetector(
                    onTap: () => _selectDateTime(Get.context!, isDeparture: true),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: controller.departureTimeController,
                        style: const TextStyle(fontSize: 14),
                        decoration: _buildInputDecoration('Select date and time', Icons.calendar_today_rounded),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimens.margin16),

                // Arrival Time
                _buildFormField(
                  label: 'Arrival Time',
                  child: GestureDetector(
                    onTap: () => _selectDateTime(Get.context!, isDeparture: false),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: controller.arrivalTimeController,
                        style: const TextStyle(fontSize: 14),
                        decoration: _buildInputDecoration('Select date and time', Icons.calendar_today_rounded),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimens.margin16),

                // Price
                _buildFormField(
                  label: 'Price',
                  child: CustomTextField(
                    controller: controller.priceController,
                    hint: 'Enter price in ETB',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money_rounded,
                    label: 'Price',
                  ),
                ),

                const SizedBox(height: AppDimens.margin16),

                // Notes
                _buildFormField(
                  label: 'Notes (Optional)',
                  child: CustomTextField(
                    controller: controller.notesController,
                    hint: 'Any additional information...',
                    maxLines: 2,
                    prefixIcon: Icons.note_rounded,
                    label: 'Notes',
                  ),
                ),

                const SizedBox(height: AppDimens.margin24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Cancel',
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Update Trip',
                        onPressed: () async {
                          // Validate
                          if (controller.routeIdController.text.isEmpty) {
                            Get.snackbar('Error', 'Please select a route',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }
                          if (controller.vehicleIdController.text.isEmpty) {
                            Get.snackbar('Error', 'Please select a vehicle',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }
                          if (controller.driverIdController.text.isEmpty) {
                            Get.snackbar('Error', 'Please select a driver',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }
                          if (controller.departureTimeController.text.isEmpty) {
                            Get.snackbar('Error', 'Please select departure time',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }
                          if (controller.arrivalTimeController.text.isEmpty) {
                            Get.snackbar('Error', 'Please select arrival time',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }
                          if (controller.priceController.text.isEmpty) {
                            Get.snackbar('Error', 'Please enter price',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }

                          final success = await controller.updateTrip(trip.id, {
                            'routeId': controller.routeIdController.text,
                            'vehicleId': controller.vehicleIdController.text,
                            'driverId': controller.driverIdController.text,
                            'departureTime': controller.departureTimeController.text,
                            'arrivalTime': controller.arrivalTimeController.text,
                            'price': double.tryParse(controller.priceController.text) ?? 0,
                            'notes': controller.notesController.text.isEmpty ? null : controller.notesController.text,
                          });
                          if (success) Get.back();
                        },
                        isLoading: controller.isLoading,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimens.margin8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelTripDialog(dynamic trip) async {
    final reasonController = TextEditingController();

    final confirmed = await AdminConfirmationDialog.show(
      title: 'Cancel Trip',
      message: 'Are you sure you want to cancel the trip from ${trip.origin} to ${trip.destination}?',
      confirmText: 'Cancel',
    );

    if (confirmed) {
      Get.bottomSheet(
        Container(
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.padding20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cancellation Reason',
                    style: Get.context!.textTheme.headlineSmall?.copyWith(
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimens.margin16),
                  CustomTextField(
                    label: 'Reason',
                    controller: reasonController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppDimens.margin24),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Back',
                          onPressed: () => Get.back(),
                        ),
                      ),
                      const SizedBox(width: AppDimens.margin12),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Confirm Cancellation',
                          onPressed: () async {
                            Get.back();
                            final success = await controller.cancelTrip(trip.id, reasonController.text);
                            if (success) {
                              Get.snackbar('Success', 'Trip cancelled successfully');
                            }
                          },
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _selectDateTime(BuildContext context, {required bool isDeparture}) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year, date.month, date.day,
          time.hour, time.minute,
        );
        if (isDeparture) {
          controller.departureTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
        } else {
          controller.arrivalTimeController.text = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
        }
      }
    }
  }

  Widget _buildDetailSection({required String title, required List<Widget> children}) {
    final theme = Get.context!.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: AppDimens.margin8),
        Container(
          padding: const EdgeInsets.all(AppDimens.padding12),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Get.context!.theme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
      ),
    );
  }

  bool _hasActiveFilters() {
    return controller.statusFilter.isNotEmpty ||
        controller.routeFilter != null ||
        controller.dateFilter != null;
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'scheduled': return 'Scheduled';
      case 'in_progress': return 'In Progress';
      case 'departed': return 'Departed';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      case 'delayed': return 'Delayed';
      default: return status;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
}