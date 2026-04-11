// lib/modules/admin/views/admin_routes_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_dialogs.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_empty_state.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_sidebar.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_status_badge.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/inputs/custom_textfield.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/admin_route_controller.dart';

class AdminRoutesView extends GetView<AdminRouteController> {
  const AdminRoutesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AdminDrawer(currentIndex: 7),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Routes'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showRouteDialog(isEdit: false),
            tooltip: 'Add Route',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshRoutes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.routes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.routes.isEmpty && !controller.isLoading) {
          return AdminEmptyState(
            title: 'No Routes',
            message: 'No bus routes have been added yet',
            icon: Icons.map_rounded,
            onAction: () => _showRouteDialog(isEdit: false),
            actionText: 'Add First Route',
          );
        }

        return Column(
          children: [
            // Search Bar
            _buildSearchBar(context),
            // Stats Row
            _buildStatsRow(context),
            // Routes List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshRoutes,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  itemCount: controller.routes.length,
                  itemBuilder: (context, index) {
                    final route = controller.routes[index];
                    return _buildRouteCard(context, route);
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
      child: TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search by route name, origin, or destination...',
          hintStyle: const TextStyle(fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
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
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.margin16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        children: [
          _buildStatItem(context, 'Total', controller.totalRoutes.toString(), Colors.blue),
          _buildVerticalDivider(isDark),
          _buildStatItem(context, 'Active', controller.activeRoutes.toString(), Colors.green),
          _buildVerticalDivider(isDark),
          _buildStatItem(context, 'Inactive', controller.inactiveRoutes.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
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
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 30,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

  Widget _buildRouteCard(BuildContext context, dynamic route) {
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
                  child: Text(
                    route.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: AppFonts.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AdminStatusBadge(status: route.isActive ? 'Active' : 'Inactive'),
              ],
            ),
            const SizedBox(height: AppDimens.margin12),
            // Route
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimens.padding8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey100,
                    borderRadius: BorderRadius.circular(AppDimens.radius8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        route.origin,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: AppFonts.medium,
                        ),
                      ),
                      const SizedBox(width: AppDimens.margin8),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                      const SizedBox(width: AppDimens.margin8),
                      Text(
                        route.destination,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: AppFonts.medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.margin12),
            // Details
            Row(
              children: [
                _buildInfoChip(Icons.straighten_rounded, '${route.distance} km'),
                const SizedBox(width: AppDimens.margin8),
                _buildInfoChip(Icons.timer_rounded, _formatDuration(route.duration)),
                const SizedBox(width: AppDimens.margin8),
                _buildInfoChip(Icons.attach_money_rounded, 'ETB ${route.basePrice.toStringAsFixed(0)}'),
              ],
            ),
            // Stops - FIXED VERSION
            if (route.stops != null && route.stops!.isNotEmpty) ...[
              const SizedBox(height: AppDimens.margin12),
              Wrap(
                spacing: AppDimens.margin8,
                runSpacing: AppDimens.margin8,
                children: List.generate(route.stops!.length, (index) {
                  final stop = route.stops![index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding8, vertical: AppDimens.padding4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey800 : AppColors.grey100,
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                    child: Text(
                      stop,
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }),
              ),
            ],
            const SizedBox(height: AppDimens.margin12),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.orange),
                  onPressed: () => _showRouteDialog(isEdit: true, route: route),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: Icon(
                    route.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                    color: route.isActive ? Colors.red : Colors.green,
                  ),
                  onPressed: () => _showToggleStatusDialog(route),
                  tooltip: route.isActive ? 'Deactivate' : 'Activate',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                  onPressed: () => _showDeleteDialog(route.id, route.name),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Add this helper method if not already present
  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes > 0) {
        return '${hours}h ${remainingMinutes}m';
      }
      return '${hours}h';
    }
    return '${minutes}m';
  }

  Widget _buildInfoChip(IconData icon, String label) {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding8, vertical: AppDimens.padding4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          const SizedBox(width: AppDimens.margin4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  void _showRouteDialog({required bool isEdit, dynamic route}) {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    if (isEdit && route != null) {
      controller.startEdit(route);
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
                      isEdit ? 'Edit Route' : 'Add New Route',
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
                // Route Name
                CustomTextField(
                  label: 'Route Name',
                  controller: controller.nameController,
                  hint: 'e.g., Addis Ababa - Jimma',
                ),
                const SizedBox(height: AppDimens.margin16),
                // Origin and Destination
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Origin',
                        controller: controller.originController,
                        hint: 'Starting city',
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Destination',
                        controller: controller.destinationController,
                        hint: 'Ending city',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Distance and Duration
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Distance (km)',
                        controller: controller.distanceController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Duration (minutes)',
                        controller: controller.durationController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Base Price
                CustomTextField(
                  label: 'Base Price (ETB)',
                  controller: controller.basePriceController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppDimens.margin16),
                // Stops
                CustomTextField(
                  label: 'Stops',
                  controller: controller.stopsController,
                  hint: 'Enter stops separated by commas',
                  maxLines: 2,
                ),
                const SizedBox(height: AppDimens.margin24),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Cancel',
                        onPressed: () {
                          controller.cancelEdit();
                          Get.back();
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: PrimaryButton(
                        text: isEdit ? 'Update Route' : 'Create Route',
                        onPressed: () async {
                          bool success;
                          if (isEdit && route != null) {
                            success = await controller.updateRoute(route.id);
                          } else {
                            success = await controller.createRoute();
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

  void _showToggleStatusDialog(dynamic route) async {
    final confirmed = await AdminConfirmationDialog.show(
      title: route.isActive ? 'Deactivate Route' : 'Activate Route',
      message: 'Are you sure you want to ${route.isActive ? 'deactivate' : 'activate'} "${route.name}"?',
      confirmText: route.isActive ? 'Deactivate' : 'Activate',
      confirmColor: route.isActive ? Colors.red : Colors.green,
    );

    if (confirmed) {
      await controller.toggleRouteStatus(route.id, !route.isActive);
    }
  }

  void _showDeleteDialog(String routeId, String routeName) async {
    final confirmed = await AdminConfirmationDialog.show(
      title: 'Delete Route',
      message: 'Are you sure you want to delete "$routeName"? This action cannot be undone.',
      confirmText: 'Delete',
    );

    if (confirmed) {
      await controller.deleteRoute(routeId);
    }
  }
}