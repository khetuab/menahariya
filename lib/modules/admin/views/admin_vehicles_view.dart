// lib/modules/admin/views/admin_vehicles_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_dialogs.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_empty_state.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_filter_chip.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_sidebar.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_status_badge.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/inputs/custom_textfield.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/admin_vehicle_controller.dart';

class AdminVehiclesView extends GetView<AdminVehicleController> {
  const AdminVehiclesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AdminDrawer(currentIndex: 8),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Vehicles'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showVehicleDialog(isEdit: false,context: context),
            tooltip: 'Add Vehicle',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshVehicles,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.vehicles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.vehicles.isEmpty && !controller.isLoading) {
          return AdminEmptyState(
            title: 'No Vehicles',
            message: 'No vehicles have been added to the fleet yet',
            icon: Icons.local_shipping_rounded,
            onAction: () => _showVehicleDialog(isEdit: false,context: context),
            actionText: 'Add First Vehicle',
          );
        }

        return Column(
          children: [
            // Search and Filter Bar
            _buildSearchBar(context),
            // Stats Row
            _buildStatsRow(context),
            // Active Filters
            Obx(() => _buildActiveFilters(context)),
            // Vehicles List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshVehicles,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  itemCount: controller.vehicles.length + (controller.hasMorePages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.vehicles.length && controller.hasMorePages) {
                      return _buildLoadMoreIndicator();
                    }
                    if (index >= controller.vehicles.length) {
                      return const SizedBox();
                    }
                    final vehicle = controller.vehicles[index];
                    return _buildVehicleCard(context, vehicle);
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
                hintText: 'Search by plate number or model...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.isNotEmpty) {
                    return GestureDetector(
                      onTap: () => controller.searchController.clear(),
                      child: const Icon(Icons.clear_rounded, size: 18),
                    );
                  }
                  return const SizedBox.shrink();
                }),
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
          _buildStatChip('Total', controller.totalVehicles.toString(), Colors.blue),
          const SizedBox(width: AppDimens.margin8),
          _buildStatChip('Active', controller.activeVehicles.toString(), Colors.green),
          const SizedBox(width: AppDimens.margin8),
          _buildStatChip('Maintenance', controller.maintenanceVehicles.toString(), Colors.orange),
          const SizedBox(width: AppDimens.margin8),
          _buildStatChip('Inactive', controller.inactiveVehicles.toString(), Colors.red),
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
            if (controller.typeFilter.isNotEmpty)
              _buildFilterChip(
                label: 'Type: ${controller.typeFilter}',
                onClear: () => controller.setTypeFilter(''),
              ),
            if (controller.statusFilter.isNotEmpty)
              _buildFilterChip(
                label: 'Status: ${_capitalize(controller.statusFilter)}',
                onClear: () => controller.setStatusFilter(''),
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

  Widget _buildVehicleCard(BuildContext context, dynamic vehicle) {
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
                        vehicle.plateNumber,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppFonts.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: AppDimens.margin2),
                      Text(
                        vehicle.model,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                AdminStatusBadge(status: vehicle.status),
              ],
            ),
            const SizedBox(height: AppDimens.margin12),
            // Type and Capacity
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    icon: Icons.category_rounded,
                    label: 'Type',
                    value: vehicle.type,
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    icon: Icons.chair_rounded,
                    label: 'Capacity',
                    value: '${vehicle.capacity} seats',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.margin8),
            // Cargo Capacity and Driver
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    icon: Icons.inventory_2_rounded,
                    label: 'Cargo Capacity',
                    value: '${vehicle.cargoCapacity?.toStringAsFixed(0) ?? 0} kg',
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    icon: Icons.person_rounded,
                    label: 'Driver',
                    value: vehicle.driver?.fullName?.split(' ').first ??
                        (vehicle.driverId != null ? 'Assigned' : 'Not Assigned'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.margin8),
            // Maintenance Dates
            if (vehicle.nextMaintenance != null)
              Row(
                children: [
                  Icon(Icons.build_rounded, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(width: AppDimens.margin4),
                  Text(
                    'Next maintenance: ${_formatDate(vehicle.nextMaintenance!)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            // Amenities - Using List.generate for better type safety
            if (vehicle.amenities.isNotEmpty) ...[
              const SizedBox(height: AppDimens.margin8),
              Wrap(
                spacing: AppDimens.margin8,
                runSpacing: AppDimens.margin4,
                children: List.generate(
                  vehicle.amenities.length > 3 ? 3 : vehicle.amenities.length,
                      (index) {
                    final amenity = vehicle.amenities[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding8, vertical: AppDimens.padding4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey800 : AppColors.grey100,
                        borderRadius: BorderRadius.circular(AppDimens.radius12),
                      ),
                      child: Text(
                        amenity,
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
              if (vehicle.amenities.length > 3)
                Text(
                  '+${vehicle.amenities.length - 3} more',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                  ),
                ),

            ],
            const SizedBox(height: AppDimens.margin12),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_rounded, color: Colors.blue),
                  onPressed: () => _showVehicleDetailsDialog(vehicle),
                  tooltip: 'View Details',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.orange),
                  onPressed: () => _showVehicleDialog(isEdit: true, vehicle: vehicle, context: context),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                  onPressed: () => _showDeleteDialog(vehicle),
                  tooltip: 'Delete',
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
                      'Filter Vehicles',
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
                // Type Filter
                Text(
                  'Vehicle Type',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin12),
                Obx(() => Wrap(
                    spacing: AppDimens.margin8,
                    runSpacing: AppDimens.margin8,
                    children: [
                      AdminFilterChip(
                        label: 'All',
                        value: '',
                        selectedValue: controller.typeFilter,
                        onSelected: (value) => controller.setTypeFilter(value),
                      ),
                      ...controller.vehicleTypes.map((type) {
                        return AdminFilterChip(
                          label: type,
                          value: type,
                          selectedValue: controller.typeFilter,
                          onSelected: (value) => controller.setTypeFilter(value),
                        );
                      }).toList(), // ✅ Add .toList() here
                    ],
                  ),
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
                Obx( ()=> Wrap(
                    spacing: AppDimens.margin8,
                    runSpacing: AppDimens.margin8,
                    children: [
                      AdminFilterChip(
                        label: 'All',
                        value: '',
                        selectedValue: controller.statusFilter,
                        onSelected: (value) => controller.setStatusFilter(value),
                      ),
                      ...controller.vehicleStatuses.map((status) {
                        return AdminFilterChip(
                          label: _capitalize(status),
                          value: status,
                          selectedValue: controller.statusFilter,
                          onSelected: (value) => controller.setStatusFilter(value),
                        );
                      }).toList(), // ✅ Add .toList() here
                    ],
                  ),
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

  void _showVehicleDialog({required bool isEdit, dynamic vehicle,BuildContext? context} ) {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    if (isEdit && vehicle != null) {
      controller.startEdit(vehicle);
    } else {
      controller.clearForm();
    }

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
                      isEdit ? 'Edit Vehicle' : 'Add New Vehicle',
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
                // Plate Number and Model
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Plate Number',
                        controller: controller.plateNumberController,
                        hint: 'e.g., AA-1234-ET',
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Model',
                        controller: controller.modelController,
                        hint: 'e.g., Toyota Coaster',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Type and Capacity
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: controller.vehicleTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) => controller.setType(value ?? 'Standard'),
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Seat Capacity',
                        controller: controller.capacityController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Cargo Capacity
                CustomTextField(
                  label: 'Cargo Capacity (kg)',
                  controller: controller.cargoCapacityController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppDimens.margin16),
                // Driver Assignment
                DropdownButtonFormField<String>(
                  value: controller.driverIdController.text.isEmpty ? null : controller.driverIdController.text,
                  decoration: const InputDecoration(
                    labelText: 'Assign Driver',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...controller.drivers.map((driver) {
                      return DropdownMenuItem(
                        value: driver.id,
                        child: Text('${driver.fullName} - ${driver.phone}'),
                      );
                    }).toList(), // ✅ Add .toList() here
                  ],
                  onChanged: (value) => controller.driverIdController.text = value ?? '',
                ),
                const SizedBox(height: AppDimens.margin16),
                // Maintenance Dates
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context!, isLastMaintenance: true),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            label: 'Last Maintenance',
                            controller: controller.lastMaintenanceController,
                            hint: 'YYYY-MM-DD',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context!, isLastMaintenance: false),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            label: 'Next Maintenance',
                            controller: controller.nextMaintenanceController,
                            hint: 'YYYY-MM-DD',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Status
                DropdownButtonFormField<String>(
                  value: controller.selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: controller.vehicleStatuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_capitalize(status)),
                    );
                  }).toList(),
                  onChanged: (value) => controller.setStatus(value ?? 'active'),
                ),
                const SizedBox(height: AppDimens.margin16),
                // Amenities
                CustomTextField(
                  label: 'Amenities',
                  controller: controller.amenitiesController,
                  hint: 'Enter amenities separated by commas (e.g., WiFi, AC, USB)',
                  maxLines: 2,
                ),
                const SizedBox(height: AppDimens.margin24),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Cancel',
                        onPressed: () {
                          if (isEdit) {
                            controller.cancelEdit();
                          }
                          Get.back();
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: PrimaryButton(
                        text: isEdit ? 'Update Vehicle' : 'Create Vehicle',
                        onPressed: () async {
                          bool success;
                          if (isEdit && vehicle != null) {
                            success = await controller.updateVehicle(vehicle.id);
                          } else {
                            success = await controller.createVehicle();
                          }
                          if (success) {
                            Get.back();
                          }
                        },
                        isLoading: controller.isSaving,
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

  void _showVehicleDetailsDialog(dynamic vehicle) async {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    await controller.getVehicleDetails(vehicle.id);
    final fullVehicle = controller.selectedVehicle;
    if (fullVehicle == null) return;

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
                      'Vehicle Details',
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
                // Basic Information
                _buildDetailSection(
                  title: 'Basic Information',
                  children: [
                    _buildDetailRow('Plate Number', fullVehicle.plateNumber),
                    _buildDetailRow('Model', fullVehicle.model),
                    _buildDetailRow('Type', fullVehicle.type),
                    _buildDetailRow('Status', fullVehicle.status),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Capacity Information
                _buildDetailSection(
                  title: 'Capacity',
                  children: [
                    _buildDetailRow('Seat Capacity', '${fullVehicle.capacity} seats'),
                    _buildDetailRow('Cargo Capacity', '${fullVehicle.cargoCapacity?.toStringAsFixed(0) ?? 0} kg'),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Maintenance Information
                _buildDetailSection(
                  title: 'Maintenance',
                  children: [
                    _buildDetailRow('Last Maintenance', fullVehicle.lastMaintenance != null ? _formatDate(fullVehicle.lastMaintenance!) : 'Not recorded'),
                    _buildDetailRow('Next Maintenance', fullVehicle.nextMaintenance != null ? _formatDate(fullVehicle.nextMaintenance!) : 'Not scheduled'),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Assignment
                _buildDetailSection(
                  title: 'Assignment',
                  children: [
                    _buildDetailRow('Assigned Driver', fullVehicle.driver?.fullName ?? 'Not Assigned '),
                    _buildDetailRow('Driver Phone', fullVehicle.driver?.phone ?? 'N/A'),
                  ],
                ),
                if (fullVehicle.amenities.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.margin16),
                  _buildDetailSection(
                    title: 'Amenities',
                    children: [
                      Wrap(
                        spacing: AppDimens.margin8,
                        runSpacing: AppDimens.margin8,
                        children: fullVehicle.amenities.map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding8, vertical: AppDimens.padding4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.grey800 : AppColors.grey100,
                              borderRadius: BorderRadius.circular(AppDimens.radius12),
                            ),
                            child: Text(amenity, style: theme.textTheme.bodySmall),
                          );
                        }).toList(),
                      ),
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

  void _showDeleteDialog(dynamic vehicle) async {
    final confirmed = await AdminConfirmationDialog.show(
      title: 'Delete Vehicle',
      message: 'Are you sure you want to delete vehicle "${vehicle.plateNumber}"? This action cannot be undone.',
      confirmText: 'Delete',
    );

    if (confirmed) {
      await controller.deleteVehicle(vehicle.id);
    }
  }

  Future<void> _selectDate(BuildContext context, {required bool isLastMaintenance}) async {
    final initialDate = isLastMaintenance
        ? (controller.lastMaintenanceController.text.isNotEmpty
        ? DateTime.tryParse(controller.lastMaintenanceController.text)
        : DateTime.now().subtract(const Duration(days: 30)))
        : (controller.nextMaintenanceController.text.isNotEmpty
        ? DateTime.tryParse(controller.nextMaintenanceController.text)
        : DateTime.now().add(const Duration(days: 30)));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? (isLastMaintenance ? DateTime.now().subtract(const Duration(days: 30)) : DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryGreenLight
                  : AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      if (isLastMaintenance) {
        controller.lastMaintenanceController.text = _formatDate(date);
      } else {
        controller.nextMaintenanceController.text = _formatDate(date);
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
            width: 120,
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
    return controller.typeFilter.isNotEmpty || controller.statusFilter.isNotEmpty;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}