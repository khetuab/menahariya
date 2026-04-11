// lib/modules/admin/widgets/admin_filter_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_fonts.dart';

class AdminFilterBar extends StatelessWidget {
  final Function(String)? onSearch;
  final VoidCallback? onFilter;
  final VoidCallback? onRefresh;
  final String searchHint;
  final List<Widget>? additionalFilters;
  final TextEditingController? searchController;
  final bool showFilterButton;
  final bool showRefreshButton;

  // Common filter properties
  final String? statusFilter;
  final DateTime? dateFilter;
  final String? paymentStatusFilter;
  final String? roleFilter;
  final String? typeFilter;

  // Callbacks for common filters
  final Function(String)? onStatusFilterChanged;
  final Function(DateTime?)? onDateFilterChanged;
  final Function(String)? onPaymentStatusFilterChanged;
  final Function(String)? onRoleFilterChanged;
  final Function(String)? onTypeFilterChanged;

  const AdminFilterBar({
    Key? key,
    this.onSearch,
    this.onFilter,
    this.onRefresh,
    this.searchHint = 'Search...',
    this.additionalFilters,
    this.searchController,
    this.showFilterButton = true,
    this.showRefreshButton = true,
    this.statusFilter,
    this.dateFilter,
    this.paymentStatusFilter,
    this.roleFilter,
    this.typeFilter,
    this.onStatusFilterChanged,
    this.onDateFilterChanged,
    this.onPaymentStatusFilterChanged,
    this.onRoleFilterChanged,
    this.onTypeFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        children: [
          // First row: Search and action buttons
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppDimens.margin12,
            runSpacing: AppDimens.margin12,
            children: [
              // Search Field
              SizedBox(
                width: 300,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: searchHint,
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.padding16,
                      vertical: AppDimens.padding12,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ),

              // Additional Filters
              if (additionalFilters != null) ...[
                ...additionalFilters!,
              ],

              // Filter Button
              if (showFilterButton && onFilter != null)
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey100,
                    borderRadius: BorderRadius.circular(AppDimens.radius8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list_rounded, size: 20),
                    onPressed: onFilter,
                    tooltip: 'Filter',
                  ),
                ),

              // Refresh Button
              if (showRefreshButton && onRefresh != null)
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey100,
                    borderRadius: BorderRadius.circular(AppDimens.radius8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    onPressed: onRefresh,
                    tooltip: 'Refresh',
                  ),
                ),
            ],
          ),

          // Second row: Active filter chips
          if (_hasActiveFilters())
            Padding(
              padding: const EdgeInsets.only(top: AppDimens.margin12),
              child: Wrap(
                spacing: AppDimens.margin8,
                runSpacing: AppDimens.margin8,
                children: [
                  // Status filter chip
                  if (statusFilter != null && statusFilter!.isNotEmpty && onStatusFilterChanged != null)
                    _buildActiveFilterChip(
                      label: 'Status: ${_getStatusDisplayName(statusFilter!)}',
                      onClear: () => onStatusFilterChanged!(''),
                    ),

                  // Date filter chip
                  if (dateFilter != null && onDateFilterChanged != null)
                    _buildActiveFilterChip(
                      label: 'Date: ${DateFormat('MMM dd, yyyy').format(dateFilter!)}',
                      onClear: () => onDateFilterChanged!(null),
                    ),

                  // Payment status filter chip
                  if (paymentStatusFilter != null && paymentStatusFilter!.isNotEmpty && onPaymentStatusFilterChanged != null)
                    _buildActiveFilterChip(
                      label: 'Payment: ${_getPaymentStatusDisplayName(paymentStatusFilter!)}',
                      onClear: () => onPaymentStatusFilterChanged!(''),
                    ),

                  // Role filter chip
                  if (roleFilter != null && roleFilter!.isNotEmpty && onRoleFilterChanged != null)
                    _buildActiveFilterChip(
                      label: 'Role: ${_getRoleDisplayName(roleFilter!)}',
                      onClear: () => onRoleFilterChanged!(''),
                    ),

                  // Type filter chip
                  if (typeFilter != null && typeFilter!.isNotEmpty && onTypeFilterChanged != null)
                    _buildActiveFilterChip(
                      label: 'Type: ${typeFilter!}',
                      onClear: () => onTypeFilterChanged!(''),
                    ),

                  // Clear all button
                  _buildClearAllChip(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onClear,
  }) {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding8,
        vertical: AppDimens.padding4,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(
          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: AppDimens.margin4),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearAllChip() {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _clearAllFilters,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding8,
          vertical: AppDimens.padding4,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.error.withOpacity(0.2) : AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimens.radius16),
          border: Border.all(
            color: isDark ? AppColors.errorLight : AppColors.error,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.clear_all_rounded,
              size: 14,
              color: isDark ? AppColors.errorLight : AppColors.error,
            ),
            const SizedBox(width: AppDimens.margin4),
            Text(
              'Clear All',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.errorLight : AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return (statusFilter != null && statusFilter!.isNotEmpty) ||
        dateFilter != null ||
        (paymentStatusFilter != null && paymentStatusFilter!.isNotEmpty) ||
        (roleFilter != null && roleFilter!.isNotEmpty) ||
        (typeFilter != null && typeFilter!.isNotEmpty);
  }

  void _clearAllFilters() {
    if (onStatusFilterChanged != null && statusFilter != null && statusFilter!.isNotEmpty) {
      onStatusFilterChanged!('');
    }
    if (onDateFilterChanged != null && dateFilter != null) {
      onDateFilterChanged!(null);
    }
    if (onPaymentStatusFilterChanged != null && paymentStatusFilter != null && paymentStatusFilter!.isNotEmpty) {
      onPaymentStatusFilterChanged!('');
    }
    if (onRoleFilterChanged != null && roleFilter != null && roleFilter!.isNotEmpty) {
      onRoleFilterChanged!('');
    }
    if (onTypeFilterChanged != null && typeFilter != null && typeFilter!.isNotEmpty) {
      onTypeFilterChanged!('');
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled': return 'Scheduled';
      case 'in_progress': return 'In Progress';
      case 'departed': return 'Departed';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      case 'delayed': return 'Delayed';
      default: return status;
    }
  }

  String _getPaymentStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'paid': return 'Paid';
      case 'completed': return 'Completed';
      case 'failed': return 'Failed';
      case 'refunded': return 'Refunded';
      default: return status;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'passenger': return 'Passenger';
      case 'driver': return 'Driver';
      case 'admin': return 'Admin';
      case 'ticketing_staff': return 'Ticketing Staff';
      case 'cargo_staff': return 'Cargo Staff';
      default: return role;
    }
  }
}

// Status Filter Chip Widget (for the additionalFilters)
class StatusFilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String? selectedValue;
  final Function(String) onSelected;
  final Color? color;

  const StatusFilterChip({
    Key? key,
    required this.label,
    required this.value,
    this.selectedValue,
    required this.onSelected,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = selectedValue == value;
    final chipColor = color ?? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          fontSize: 13,
          fontWeight: isSelected ? AppFonts.medium : AppFonts.regular,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      backgroundColor: isDark ? AppColors.grey800 : AppColors.grey100,
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius20),
        side: BorderSide(
          color: isSelected ? chipColor : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding12,
        vertical: AppDimens.padding8,
      ),
    );
  }
}