// lib/modules/admin/views/admin_payments_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
import '../controllers/admin_payment_controller.dart';

class AdminPaymentsView extends GetView<AdminPaymentController> {
  const AdminPaymentsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AdminDrawer(currentIndex: 6),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Payments'),
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
            onPressed: controller.refreshPayments,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.payments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPayments,
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
              // Payments List Sliver
              SliverPadding(
                padding: const EdgeInsets.all(AppDimens.padding16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index == controller.payments.length && controller.hasMorePages) {
                        return _buildLoadMoreIndicator();
                      }
                      if (index >= controller.payments.length) {
                        return const SizedBox();
                      }
                      final payment = controller.payments[index];
                      return _buildPaymentCard(context, payment);
                    },
                    childCount: controller.payments.length + (controller.hasMorePages ? 1 : 0),
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
          _buildStatCard(context, 'Total', controller.totalPayments.toString(), Colors.blue, Icons.payments_rounded),
          const SizedBox(width: AppDimens.margin12),
          _buildStatCard(context, 'Completed', controller.completedPayments.toString(), Colors.green, Icons.check_circle_rounded),
          const SizedBox(width: AppDimens.margin12),
          _buildStatCard(context, 'Pending', controller.pendingPayments.toString(), Colors.orange, Icons.pending_rounded),
          const SizedBox(width: AppDimens.margin12),
          _buildStatCard(context, 'Failed', controller.failedPayments.toString(), Colors.red, Icons.error_rounded),
          const SizedBox(width: AppDimens.margin12),
          _buildStatCard(context, 'Refunded', controller.refundedPayments.toString(), Colors.purple, Icons.payment),
          const SizedBox(width: AppDimens.margin12),
          _buildStatCard(context, 'Amount', 'ETB ${controller.totalAmount.toStringAsFixed(0)}', Colors.teal, Icons.attach_money_rounded),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 110,
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
            padding: const EdgeInsets.all(AppDimens.padding6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radius8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
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
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search by transaction ID or reference...',
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
            if (controller.methodFilter.isNotEmpty && controller.methodFilter != 'all')
              _buildFilterChip(
                label: 'Method: ${_getMethodDisplayName(controller.methodFilter)}',
                onClear: () => controller.setMethodFilter(''),
              ),
            if (controller.statusFilter.isNotEmpty && controller.statusFilter != 'all')
              _buildFilterChip(
                label: 'Status: ${_capitalize(controller.statusFilter)}',
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

  Widget _buildPaymentCard(BuildContext context, dynamic payment) {
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
        onTap: () => _showPaymentDetailsDialog(payment),
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
                          'Payment #${payment.id.substring(0, 8).toUpperCase()}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: AppFonts.semiBold,
                          ),
                        ),
                        const SizedBox(height: AppDimens.margin2),
                        Text(
                          _getMethodDisplayName(payment.method),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  AdminStatusBadge(status: payment.status),
                ],
              ),
              const SizedBox(height: AppDimens.margin12),
              // Amount and Date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          'ETB ${payment.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: AppFonts.bold,
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Date',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        _formatDate(payment.createdAt),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
              if (payment.transactionId != null) ...[
                const SizedBox(height: AppDimens.margin8),
                Row(
                  children: [
                    Icon(Icons.receipt_rounded, size: 14, color: isDark ? AppColors.textHintDark : AppColors.textHintLight),
                    const SizedBox(width: AppDimens.margin4),
                    Expanded(
                      child: Text(
                        'TX: ${payment.transactionId}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppDimens.margin12),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (payment.status == 'completed')
                    IconButton(
                      icon: const Icon(Icons.payment, color: Colors.orange),
                      onPressed: () => _showRefundDialog(payment),
                      tooltip: 'Refund',
                    ),
                  IconButton(
                    icon: const Icon(Icons.visibility_rounded),
                    onPressed: () => _showPaymentDetailsDialog(payment),
                    tooltip: 'View Details',
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
                      'Filter Payments',
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
                // Payment Method Filter
                Text(
                  'Payment Method',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin12),
                Wrap(
                  spacing: AppDimens.margin8,
                  runSpacing: AppDimens.margin8,
                  children: controller.availableMethods.map((method) {
                    return AdminFilterChip(
                      label: method == 'all' ? 'All' : _getMethodDisplayName(method),
                      value: method,
                      selectedValue: controller.methodFilter,
                      onSelected: (value) => controller.setMethodFilter(value),
                    );
                  }).toList(),
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
                      label: status == 'all' ? 'All' : _capitalize(status),
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

  void _showPaymentDetailsDialog(dynamic payment) async {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    await controller.getPaymentDetails(payment.id);
    final fullPayment = controller.selectedPayment;
    final booking = controller.selectedBooking;
    if (fullPayment == null) return;

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
                      'Payment Details',
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
                // Payment Info
                _buildDetailSection(
                  title: 'Payment Information',
                  children: [
                    _buildDetailRow('Payment ID', fullPayment.id),
                    _buildDetailRow('Amount', 'ETB ${fullPayment.amount.toStringAsFixed(2)}'),
                    _buildDetailRow('Method', _getMethodDisplayName(fullPayment.method)),
                    _buildDetailRow('Status', fullPayment.status),
                    _buildDetailRow('Date', _formatDateTime(fullPayment.createdAt)),
                    if (fullPayment.completedAt != null)
                      _buildDetailRow('Completed', _formatDateTime(fullPayment.completedAt!)),
                    if (fullPayment.transactionId != null)
                      _buildDetailRow('Transaction ID', fullPayment.transactionId!),
                    if (fullPayment.reference != null)
                      _buildDetailRow('Reference', fullPayment.reference!),
                    if (fullPayment.failureReason != null)
                      _buildDetailRow('Failure Reason', fullPayment.failureReason!),
                  ],
                ),
                // Booking Info
                if (booking != null) ...[
                  const SizedBox(height: AppDimens.margin16),
                  _buildDetailSection(
                    title: 'Booking Information',
                    children: [
                      _buildDetailRow('Booking ID', booking.id),
                      _buildDetailRow('Passenger', booking.passengerNames),
                      _buildDetailRow('Seats', booking.seatNumbers.join(', ')),
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

  void _showRefundDialog(dynamic payment) {
    final theme = Get.context!.theme;
    final amountController = TextEditingController(text: payment.amount.toString());
    final reasonController = TextEditingController();

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
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
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: AppFonts.bold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin16),
                Text('Refund payment of ETB ${payment.amount.toStringAsFixed(2)}'),
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
                          final success = await controller.processRefund(
                            payment.id,
                            double.tryParse(amountController.text) ?? payment.amount,
                            reasonController.text,
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
    return (controller.methodFilter.isNotEmpty && controller.methodFilter != 'all') ||
        (controller.statusFilter.isNotEmpty && controller.statusFilter != 'all') ||
        controller.dateFilter != null;
  }

  String _getMethodDisplayName(String method) {
    switch (method) {
      case 'telebirr': return 'Telebirr';
      case 'cbe_birr': return 'CBE Birr';
      case 'card': return 'Card Payment';
      case 'wallet': return 'Wallet Balance';
      case 'cash': return 'Cash';
      default: return method;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm:ss').format(dateTime);
  }
}