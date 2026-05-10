// lib/modules/passenger/views/payment/payment_detail_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/modules/passenger/controllers/payment_controller.dart';

class PassengerPaymentDetailView extends GetView<PassengerPaymentController> {
  const PassengerPaymentDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final paymentId = Get.parameters['id'] ?? Get.arguments?['paymentId'] ?? Get.arguments?['id'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (paymentId != null) {
        //controller.fetchPaymentDetails(paymentId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.receipt_rounded),
        //     onPressed: () => controller.downloadReceipt(),
        //     tooltip: 'Download Receipt',
        //   ),
        // ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.payment == null) {
          return _buildLoadingShimmer();
        }

        if (controller.payment == null) {
          return _buildErrorState(context);
        }

        final payment = controller.payment;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Status
              _buildPaymentStatus(context, payment),

              const SizedBox(height: AppDimens.margin16),

              // Payment Summary
              _buildPaymentSummary(context, payment),

              const SizedBox(height: AppDimens.margin16),

              // Payment Method
              _buildPaymentMethod(context, payment),

              const SizedBox(height: AppDimens.margin16),

              // Transaction Details
              _buildTransactionDetails(context, payment),

              const SizedBox(height: AppDimens.margin24),

              // Action Buttons
              _buildActionButtons(context, payment),

              const SizedBox(height: AppDimens.margin16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPaymentStatus(BuildContext context, dynamic payment) {
    final theme = Theme.of(context);
    final isSuccess = payment.status?.toLowerCase() == 'success' ||
        payment.status?.toLowerCase() == 'completed';
    final isPending = payment.status?.toLowerCase() == 'pending';

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String statusText;

    if (isSuccess) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
      icon = Icons.check_circle_rounded;
      statusText = 'Payment Successful';
    } else if (isPending) {
      backgroundColor = Colors.orange;
      textColor = Colors.white;
      icon = Icons.pending_rounded;
      statusText = 'Payment Pending';
    } else {
      backgroundColor = Colors.red;
      textColor = Colors.white;
      icon = Icons.error_rounded;
      statusText = 'Payment Failed';
    }

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 32),
          const SizedBox(width: AppDimens.margin12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: AppFonts.bold,
                  ),
                ),
                Text(
                  'Transaction ID: ${payment.transactionId ?? payment.id.substring(0, 12)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context, dynamic payment) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_rounded,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
              const SizedBox(width: AppDimens.margin12),
              Text(
                'Payment Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.margin16),
          _buildSummaryRow(
            context,
            label: 'Amount Paid',
            value: '${payment.currency ?? 'ETB'} ${payment.amount?.toString() ?? '0'}',
            isTotal: true,
          ),
          const Divider(height: AppDimens.margin16),
          _buildSummaryRow(
            context,
            label: 'Payment Date',
            value: _formatDateTime(payment.createdAt),
          ),
          const SizedBox(height: AppDimens.margin8),
          _buildSummaryRow(
            context,
            label: 'Payment For',
            value: payment.description ?? payment.itemName ?? 'Ticket Purchase',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context, dynamic payment) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData methodIcon;
    String methodName;

    switch (payment.method?.toLowerCase()) {
      case 'credit_card':
      case 'card':
        methodIcon = Icons.credit_card_rounded;
        methodName = 'Credit Card';
        break;
      case 'mobile_money':
      case 'momo':
        methodIcon = Icons.phone_android_rounded;
        methodName = 'Mobile Money';
        break;
      case 'bank_transfer':
        methodIcon = Icons.account_balance_rounded;
        methodName = 'Bank Transfer';
        break;
      case 'cash':
        methodIcon = Icons.money_rounded;
        methodName = 'Cash';
        break;
      default:
        methodIcon = Icons.payment_rounded;
        methodName = payment.method ?? 'Other';
    }

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radius8),
            ),
            child: Icon(methodIcon, color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
          ),
          const SizedBox(width: AppDimens.margin12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Method',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  methodName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: AppFonts.medium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(BuildContext context, dynamic payment) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
              const SizedBox(width: AppDimens.margin12),
              Text(
                'Transaction Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.margin16),
          _buildDetailRow(
            context,
            label: 'Transaction ID',
            value: payment.transactionId ?? payment.id,
          ),
          const SizedBox(height: AppDimens.margin8),
          _buildDetailRow(
            context,
            label: 'Reference Number',
            value: payment.referenceNumber ?? payment.reference ?? 'N/A',
          ),
          const SizedBox(height: AppDimens.margin8),
          if (payment.cardLast4 != null)
            _buildDetailRow(
              context,
              label: 'Card Details',
              value: '**** **** **** ${payment.cardLast4}',
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, {
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? theme.primaryColor : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic payment) {
    final isSuccess = payment.status?.toLowerCase() == 'success' ||
        payment.status?.toLowerCase() == 'completed';

    return Column(
      children: [
        if (isSuccess)
          PrimaryButton(
            text: 'View Ticket',
            onPressed: () => _viewTicket(payment),
            icon: Icons.confirmation_number_rounded,
          ),
        const SizedBox(height: AppDimens.margin12),
        OutlinedButton.icon(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Go Back'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  void _viewTicket(dynamic payment) {
    final ticketId = payment.ticketId ?? payment.metadata?['ticketId'];
    if (ticketId != null) {
      Get.toNamed('/passenger/ticket/$ticketId');
    } else {
      Get.back();
    }
  }

  Widget _buildLoadingShimmer() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            'Failed to load payment details',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimens.margin24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}