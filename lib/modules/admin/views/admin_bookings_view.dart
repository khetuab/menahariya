// lib/modules/admin/views/admin_bookings_view.dart

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
import '../controllers/admin_booking_controller.dart';

class AdminBookingsView extends GetView<AdminBookingController> {
  const AdminBookingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AdminDrawer(currentIndex: 2),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Bookings'),
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
            onPressed: controller.refreshBookings,
            tooltip: 'Refresh ',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.bookings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshBookings,
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
              // Bookings List Sliver
              SliverPadding(
                padding: const EdgeInsets.all(AppDimens.padding16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index == controller.bookings.length && controller.hasMorePages) {
                        return _buildLoadMoreIndicator();
                      }
                      if (index >= controller.bookings.length) {
                        return const SizedBox();
                      }
                      final booking = controller.bookings[index];
                      return _buildBookingCard(context, booking);
                    },
                    childCount: controller.bookings.length + (controller.hasMorePages ? 1 : 0),
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

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      margin: const EdgeInsets.all(AppDimens.margin16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        children: [
          _buildStatItem(context, 'Total', controller.totalBookings.toString(), Colors.blue),
          _buildVerticalDivider(isDark),
          _buildStatItem(context, 'Confirmed', controller.confirmedBookings.toString(), Colors.green),
          _buildVerticalDivider(isDark),
          _buildStatItem(context, 'Pending', controller.pendingBookings.toString(), Colors.orange),
          _buildVerticalDivider(isDark),
          _buildStatItem(context, 'Revenue', 'ETB ${controller.totalRevenue.toStringAsFixed(0)}', Colors.teal),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search by booking ID, passenger, or phone...',
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
    );
  }

  Widget _buildActiveFilters(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            if (controller.paymentStatusFilter.isNotEmpty)
              _buildFilterChip(
                label: 'Payment: ${_getPaymentStatusDisplayName(controller.paymentStatusFilter)}',
                onClear: () => controller.setPaymentStatusFilter(''),
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

  Widget _buildBookingCard(BuildContext context, dynamic booking) {
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
        onTap: () => _showBookingDetailsDialog(booking),
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
                    child: Text(
                      'Booking #${booking.id.substring(0, 8).toUpperCase()}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                  ),
                  AdminStatusBadge(status: booking.bookingStatus),
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
                      '${booking.trip?.origin ?? 'N/A'} → ${booking.trip?.destination ?? 'N/A'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin8),
              // Passenger
              Row(
                children: [
                  Icon(Icons.person_rounded, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(width: AppDimens.margin8),
                  Expanded(
                    child: Text(
                      booking.passengerNames,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin8),
              // Seats and Date
              Row(
                children: [
                  Icon(Icons.chair_rounded, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(width: AppDimens.margin8),
                  Text(
                    'Seats: ${booking.seatNumbers.join(", ")}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today_rounded, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(width: AppDimens.margin4),
                  Text(
                    _formatDate(booking.bookingDate),
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
                        'Amount',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        'ETB ${booking.totalAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppFonts.bold,
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (booking.bookingStatus == 'confirmed' && booking.paymentStatus == 'paid')
                        IconButton(
                          icon: const Icon(Icons.payment, color: Colors.orange),
                          onPressed: () => _showRefundDialog(booking),
                          tooltip: 'Refund',
                        ),
                      if (booking.bookingStatus == 'pending')
                        IconButton(
                          icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                          onPressed: () => _showCancelBookingDialog(booking),
                          tooltip: 'Cancel Booking',
                        ),
                      IconButton(
                        icon: const Icon(Icons.visibility_rounded),
                        onPressed: () => _showBookingDetailsDialog(booking),
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
                      'Filter Bookings',
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
                  'Booking Status',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin12),
                Obx(
                  () => Wrap(
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
                        label: 'Pending',
                        value: 'pending',
                        selectedValue: controller.statusFilter,
                        onSelected: (value) => controller.setStatusFilter(value),
                      ),
                      AdminFilterChip(
                        label: 'Confirmed',
                        value: 'confirmed',
                        selectedValue: controller.statusFilter,
                        onSelected: (value) => controller.setStatusFilter(value),
                      ),
                      AdminFilterChip(
                        label: 'Cancelled',
                        value: 'cancelled',
                        selectedValue: controller.statusFilter,
                        onSelected: (value) => controller.setStatusFilter(value),
                      ),
                      AdminFilterChip(
                        label: 'Expired',
                        value: 'expired',
                        selectedValue: controller.statusFilter,
                        onSelected: (value) => controller.setStatusFilter(value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.margin24),
                // Payment Status Filter
                Text(
                  'Payment Status',
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
                      selectedValue: controller.paymentStatusFilter,
                      onSelected: (value) => controller.setPaymentStatusFilter(value),
                    ),
                    AdminFilterChip(
                      label: 'Paid',
                      value: 'paid',
                      selectedValue: controller.paymentStatusFilter,
                      onSelected: (value) => controller.setPaymentStatusFilter(value),
                    ),
                    AdminFilterChip(
                      label: 'Pending',
                      value: 'pending',
                      selectedValue: controller.paymentStatusFilter,
                      onSelected: (value) => controller.setPaymentStatusFilter(value),
                    ),
                    AdminFilterChip(
                      label: 'Failed',
                      value: 'failed',
                      selectedValue: controller.paymentStatusFilter,
                      onSelected: (value) => controller.setPaymentStatusFilter(value),
                    ),
                    AdminFilterChip(
                      label: 'Refunded',
                      value: 'refunded',
                      selectedValue: controller.paymentStatusFilter,
                      onSelected: (value) => controller.setPaymentStatusFilter(value),
                    ),
                  ],
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

  void _showBookingDetailsDialog(dynamic booking) async {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    await controller.getBookingDetails(booking.id);
    final fullBooking = controller.selectedBooking;
    if (fullBooking == null) return;

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
                      'Booking Details',
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
                // Booking Info
                _buildDetailSection(
                  title: 'Booking Information',
                  children: [
                    _buildDetailRow('Booking ID', fullBooking.id),
                    _buildDetailRow('Date', _formatDateTime(fullBooking.bookingDate)),
                    _buildDetailRow('Status', fullBooking.bookingStatus),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Trip Info
                _buildDetailSection(
                  title: 'Trip Information',
                  children: [
                    _buildDetailRow('Route', '${booking.trip?.origin ?? 'N/A'} → ${booking.trip?.destination ?? 'N/A'}'),
                    _buildDetailRow('Departure', fullBooking.trip?.departureTime != null ? _formatDateTime(fullBooking.trip!.departureTime) : 'N/A'),
                    _buildDetailRow('Seats', fullBooking.seatNumbers.join(', ')),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // Passenger Details
                _buildDetailSection(
                  title: 'Passenger Details',
                  children: fullBooking.passengerDetails.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.padding8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name ?? 'Unknown',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: AppFonts.medium,
                          ),
                        ),
                        Text(
                          'Seat: ${p.seatNumber} | Phone: ${p.phone ?? 'N/A'}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )).toList(),
                ),
                const SizedBox(height: AppDimens.margin16),
                // Payment Info
                _buildDetailSection(
                  title: 'Payment Information',
                  children: [
                    _buildDetailRow('Total Amount', 'ETB ${fullBooking.totalAmount.toStringAsFixed(2)}'),
                    _buildDetailRow('Payment Status', fullBooking.paymentStatus),
                    _buildDetailRow('Payment Method', fullBooking.paymentMethod ?? 'N/A'),
                    if (fullBooking.insuranceSelected)
                      _buildDetailRow('Insurance Fee', 'ETB ${fullBooking.insuranceFee?.toStringAsFixed(2) ?? '0'}'),
                  ],
                ),
                // Add this in the dialog, after Payment Information section
                const SizedBox(height: AppDimens.margin16),

// Status Update Section
                _buildDetailSection(
                  title: 'Update Status',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: fullBooking.bookingStatus,
                            decoration: const InputDecoration(
                              labelText: 'Booking Status',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('Pending',style: TextStyle(fontSize: 12),)),
                              DropdownMenuItem(value: 'confirmed', child: Text('Confirmed',style: TextStyle(fontSize: 12),)),
                              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled',style: TextStyle(fontSize: 12),)),
                            ],
                            onChanged: (newStatus) {
                              // Call update status API
                              controller.updateBookingStatus(fullBooking.id, newStatus!);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: fullBooking.paymentStatus,
                            decoration: const InputDecoration(
                              labelText: 'Payment Status',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('Pending',style: TextStyle(fontSize: 12),)),
                              DropdownMenuItem(value: 'paid', child: Text('Paid',style: TextStyle(fontSize: 12),)),
                              DropdownMenuItem(value: 'failed', child: Text('Failed',style: TextStyle(fontSize: 12),)),
                              DropdownMenuItem(value: 'refunded', child: Text('Refunded',style: TextStyle(fontSize: 12),)),
                            ],
                            onChanged: (newStatus) {
                              controller.updatePaymentStatus(fullBooking.id, newStatus!);
                            },
                          ),
                        ),
                      ],
                    ),
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

  void _showRefundDialog(dynamic booking) {
    final amountController = TextEditingController(text: booking.totalAmount.toString());
    final reasonController = TextEditingController();

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
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
                  'Process Refund',
                  style: Get.context!.textTheme.headlineSmall?.copyWith(
                    fontWeight: AppFonts.bold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin16),
                Text('Refund for booking: ${booking.id.substring(0, 8)}'),
                const SizedBox(height: AppDimens.margin16),
                CustomTextField(
                  label: 'Refund Amount',
                  controller: amountController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppDimens.margin12),
                CustomTextField(
                  label: 'Reason',
                  controller: reasonController,
                  maxLines: 2,
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
                        text: 'Process Refund',
                        onPressed: () async {
                          Get.back();
                          final success = await controller.refundBooking(
                            booking.id,
                            amount: double.tryParse(amountController.text),
                            reason: reasonController.text,
                          );
                          if (success) {
                            Get.snackbar('Success', 'Refund processed successfully');
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

  void _showCancelBookingDialog(dynamic booking) async {
    final reasonController = TextEditingController();

    final confirmed = await AdminConfirmationDialog.show(
      title: 'Cancel Booking',
      message: 'Are you sure you want to cancel this booking?',
      confirmText: 'Cancel Booking',
    );

    if (confirmed) {
      Get.dialog(
        AlertDialog(
          title: const Text('Cancellation Reason'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter reason for cancellation',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                final success = await controller.cancelBooking(booking.id, reasonController.text);
                if (success) {
                  Get.snackbar('Success', 'Booking cancelled successfully');
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      );
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

  bool _hasActiveFilters() {
    return controller.statusFilter.isNotEmpty ||
        controller.paymentStatusFilter.isNotEmpty ||
        controller.dateFilter != null;
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'cancelled': return 'Cancelled';
      case 'expired': return 'Expired';
      default: return status;
    }
  }

  String _getPaymentStatusDisplayName(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'paid': return 'Paid';
      case 'failed': return 'Failed';
      case 'refunded': return 'Refunded';
      default: return status;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
}