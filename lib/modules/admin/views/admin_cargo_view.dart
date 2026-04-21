// lib/modules/admin/views/admin_cargo_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
import '../controllers/admin_cargo_controller.dart';

class AdminCargoView extends GetView<AdminCargoController> {
  const AdminCargoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AdminDrawer(currentIndex: 4),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Cargo Management'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshCargo,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.cargoList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.cargoList.isEmpty && !controller.isLoading) {
          return AdminEmptyState(
            title: 'No Cargo Found',
            message: 'No cargo shipments found',
            icon: Icons.inventory_2_rounded,
            onAction: controller.refreshCargo,
            actionText: 'Refresh',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshCargo,
          child: CustomScrollView(
            slivers: [
              // Stats Sliver
              SliverToBoxAdapter(
                child: _buildStatsRow(context),
              ),
              // Search Bar Sliver
              SliverToBoxAdapter(
                child: _buildSearchBar(context),
              ),
              // Active Filters Sliver
              SliverToBoxAdapter(
                child: _buildActiveFilters(context),
              ),
              // Cargo List Sliver
              SliverPadding(
                padding: const EdgeInsets.all(AppDimens.padding16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index == controller.cargoList.length && controller.hasMorePages) {
                        return _buildLoadMoreIndicator();
                      }
                      if (index >= controller.cargoList.length) {
                        return const SizedBox();
                      }
                      final cargo = controller.cargoList[index];
                      return _buildCargoCard(context, cargo);
                    },
                    childCount: controller.cargoList.length + (controller.hasMorePages ? 1 : 0),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppDimens.padding16),
      child: Row(
        children: [
          _buildStatCard(context, 'Total', controller.totalCargo.toString(), Colors.blue, Icons.inventory_2_rounded),
          const SizedBox(width: AppDimens.margin12),
          _buildStatCard(context, 'Registered', controller.registeredCargo.toString(), Colors.orange, Icons.pending_rounded),
          const SizedBox(width: AppDimens.margin12),
          _buildStatCard(context, 'Loaded', controller.loadedCargo.toString(), Colors.purple, Icons.check_circle_rounded),
          const SizedBox(width: AppDimens.margin12),
          _buildStatCard(context, 'In Transit', controller.inTransitCargo.toString(), Colors.cyan, Icons.directions_bus_rounded),
          const SizedBox(width: AppDimens.margin12),
          _buildStatCard(context, 'Delivered', controller.deliveredCargo.toString(), Colors.green, Icons.check_circle_rounded),
          const SizedBox(width: AppDimens.margin12),
          _buildStatCard(context, 'Revenue', 'ETB ${controller.statsRevenue.toStringAsFixed(0)}', Colors.teal, Icons.attach_money_rounded),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 120,
      padding: const EdgeInsets.all(AppDimens.padding12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.padding8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radius8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: AppFonts.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimens.margin2),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by tracking code, sender, or receiver...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () => controller.searchController.clear(),
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
          Container(
            width: 155,
            child: DropdownButtonFormField<String>(
              value: controller.statusFilter.isEmpty ? null : controller.statusFilter,
              decoration: InputDecoration(
                hintText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.padding12, vertical: AppDimens.padding8),
              ),
              items: controller.availableStatuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status == 'all' ? 'All' : status.capitalize ?? status),
                );
              }).toList(),
              onChanged: (value) => controller.setStatusFilter(value ?? ''),
            ),
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
            if (controller.statusFilter.isNotEmpty && controller.statusFilter != 'all')
              _buildFilterChip(
                label: 'Status: ${controller.statusFilter.capitalize ?? controller.statusFilter}',
                onClear: () => controller.setStatusFilter(''),
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

  Widget _buildCargoCard(BuildContext context, dynamic cargo) {
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
      child: InkWell(
        onTap: () => _showCargoDetailsDialog(cargo),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cargo.trackingCode,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: AppFonts.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: AppDimens.margin2),
                        Text(
                          cargo.cargoType,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  AdminStatusBadge(status: cargo.status),
                ],
              ),
              const SizedBox(height: AppDimens.margin12),
              // Route
              Row(
                children: [
                  Icon(Icons.route_rounded, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(width: AppDimens.margin8),
                  Expanded(
                    child: Text(
                      '${cargo.origin} → ${cargo.destination}',
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin8),
              // Sender & Receiver
              Row(
                children: [
                  Icon(Icons.person_rounded, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(width: AppDimens.margin8),
                  Expanded(
                    child: Text(
                      '${cargo.senderName} → ${cargo.receiverName}',
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin8),
              // Weight and Date
              Row(
                children: [
                  Icon(Icons.monitor_weight_rounded, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(width: AppDimens.margin8),
                  Text(
                    '${cargo.weight} kg',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today_rounded, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(width: AppDimens.margin4),
                  Text(
                    _formatDate(cargo.registeredDate),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin12),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fee',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        'ETB ${cargo.fee.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppFonts.bold,
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (cargo.status != 'delivered' && cargo.status != 'cancelled')
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Colors.orange),
                          onPressed: () => _showUpdateStatusDialog(cargo),
                          tooltip: 'Update Status',
                        ),
                      IconButton(
                        icon: const Icon(Icons.print_rounded, color: Colors.teal),
                        onPressed: () => _showReceiptDialog(cargo),
                        tooltip: 'Print Receipt',
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility_rounded),
                        onPressed: () => _showCargoDetailsDialog(cargo),
                        tooltip: 'View Details',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                      'Filter Cargo',
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
                  children: controller.availableStatuses.map((status) {
                    return AdminFilterChip(
                      label: status == 'all' ? 'All' : (status.capitalize ?? status),
                      value: status,
                      selectedValue: controller.statusFilter,
                      onSelected: (value) => controller.setStatusFilter(value),
                    );
                  }).toList(),
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

  void _showCargoDetailsDialog(dynamic cargo) async {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    await controller.getCargoDetails(cargo.id);
    final fullCargo = controller.selectedCargo;
    if (fullCargo == null) return;

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
                      'Cargo Details',
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
                // Tracking Info
                _buildDetailSection(
                  title: 'Tracking Information',
                  children: [
                    _buildDetailRow('Tracking Code', fullCargo.trackingCode),
                    _buildDetailRow('Registered Date', _formatDateTime(fullCargo.registeredDate)),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Sender & Receiver
                _buildDetailSection(
                  title: 'Sender Information',
                  children: [
                    _buildDetailRow('Name', fullCargo.senderName),
                    _buildDetailRow('Phone', fullCargo.senderPhone),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                _buildDetailSection(
                  title: 'Receiver Information',
                  children: [
                    _buildDetailRow('Name', fullCargo.receiverName),
                    _buildDetailRow('Phone', fullCargo.receiverPhone),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Cargo Info
                _buildDetailSection(
                  title: 'Cargo Information',
                  children: [
                    _buildDetailRow('Type', fullCargo.cargoType),
                    _buildDetailRow('Weight', '${fullCargo.weight} kg'),
                    if (fullCargo.dimensions != null && fullCargo.dimensions!.isNotEmpty)
                      _buildDetailRow('Dimensions', fullCargo.dimensions!),
                    if (fullCargo.description != null && fullCargo.description!.isNotEmpty)
                      _buildDetailRow('Description', fullCargo.description!),
                    _buildDetailRow('Fee', 'ETB ${fullCargo.fee.toStringAsFixed(2)}'),
                    if (fullCargo.isFragile || fullCargo.isPerishable || fullCargo.needsRefrigeration)
                      _buildDetailRow('Special Handling',
                        '${fullCargo.isFragile ? "Fragile " : ""}'
                            '${fullCargo.isPerishable ? "Perishable " : ""}'
                            '${fullCargo.needsRefrigeration ? "Refrigerated" : ""}'.trim(),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Trip Info
                _buildDetailSection(
                  title: 'Trip Information',
                  children: [
                    _buildDetailRow('Route', '${fullCargo.origin} → ${fullCargo.destination}'),
                    _buildDetailRow('Departure', _formatDateTime(fullCargo.departureTime)),
                    if (fullCargo.location != null && fullCargo.location!.isNotEmpty)
                      _buildDetailRow('Current Location', fullCargo.location!),
                  ],
                ),
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

  void _showUpdateStatusDialog(dynamic cargo) {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    controller.statusController.text = cargo.status;
    controller.locationController.text = cargo.location ?? '';
    controller.notesController.text = cargo.notes ?? '';

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
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
                  'Update Cargo Status',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: AppFonts.bold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin16),
                DropdownButtonFormField<String>(
                  value: controller.statusController.text,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'registered', child: Text('Registered')),
                    DropdownMenuItem(value: 'loaded', child: Text('Loaded')),
                    DropdownMenuItem(value: 'in_transit', child: Text('In Transit')),
                    DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (value) => controller.statusController.text = value ?? '',
                ),
                const SizedBox(height: AppDimens.margin16),
                CustomTextField(
                  label: 'Location',
                  controller: controller.locationController,
                  hint: 'Current location of cargo',
                ),
                const SizedBox(height: AppDimens.margin16),
                CustomTextField(
                  label: 'Notes',
                  controller: controller.notesController,
                  hint: 'Additional notes',
                  maxLines: 3,
                ),
                const SizedBox(height: AppDimens.margin24),
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
                        text: 'Update',
                        onPressed: () async {
                          Get.back();
                          final success = await controller.updateCargoStatus(
                            cargo.id,
                            controller.statusController.text,
                            location: controller.locationController.text,
                            notes: controller.notesController.text,
                          );
                          if (success) {
                            Get.snackbar('Success', 'Cargo status updated');
                          }
                        },
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

  void _showReceiptDialog(dynamic cargo) {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius16),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.padding24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_rounded, size: 48, color: Colors.green),
              const SizedBox(height: AppDimens.margin16),
              Text(
                'Cargo Receipt',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppFonts.bold,
                ),
              ),
              const SizedBox(height: AppDimens.margin24),
              _buildReceiptRow('Tracking Code', cargo.trackingCode),
              _buildReceiptRow('Sender', cargo.senderName),
              _buildReceiptRow('Receiver', cargo.receiverName),
              _buildReceiptRow('Cargo Type', cargo.cargoType),
              _buildReceiptRow('Weight', '${cargo.weight} kg'),
              _buildReceiptRow('Route', '${cargo.origin} → ${cargo.destination}'),
              const Divider(height: AppDimens.margin24),
              _buildReceiptRow('Total Fee', 'ETB ${cargo.fee.toStringAsFixed(2)}', isBold: true),
              const SizedBox(height: AppDimens.margin24),
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
                      text: 'Print',
                      onPressed: () {
                        Get.back();
                        Get.snackbar('Print', 'Receipt sent to printer');
                      },
                      icon: Icons.print_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            width: 110,
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

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    final theme = Get.context!.theme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isBold ? null : theme.textTheme.bodySmall?.color,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? AppFonts.bold : AppFonts.medium,
              color: isBold ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return (controller.statusFilter.isNotEmpty && controller.statusFilter != 'all') ||
        controller.dateFilter != null;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
}