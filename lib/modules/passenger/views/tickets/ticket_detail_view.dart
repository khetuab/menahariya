// lib/modules/passenger/views/tickets/ticket_detail_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/widgets/qr/qr_generator.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';
import 'package:menahariya/modules/passenger/controllers/ticket_controller.dart';

class TicketDetailView extends GetView<PassengerTicketController> {
  const TicketDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get ticketId from arguments and load ticket details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String ticketId = Get.arguments['ticketId'];
      if (ticketId.isNotEmpty && controller.selectedTicket == null) {
        controller.getTicketDetails(ticketId);
      }
    });

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final ticket = controller.selectedTicket;
        if (ticket == null) {
          return _buildErrorState();
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
                      child: Center(
                        child: TicketQRWidget(
                          ticketId: ticket.id,
                          ticketData: ticket.qrCode ?? ticket.id,
                          showDetails: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () => controller.shareTicket(ticket),
                ),
                IconButton(
                  icon: const Icon(Icons.file_download_rounded),
                  onPressed: () => controller.downloadTicket(ticket),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(AppDimens.padding16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Ticket Status
                  Container(
                    padding: const EdgeInsets.all(AppDimens.padding12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ticket.status, isDark).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                      border: Border.all(
                        color: _getStatusColor(ticket.status, isDark),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(ticket.status),
                          color: _getStatusColor(ticket.status, isDark),
                        ),
                        const SizedBox(width: AppDimens.margin12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ticket Status',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                ticket.status.toUpperCase(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: _getStatusColor(ticket.status, isDark),
                                  fontWeight: AppFonts.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.margin20),

                  // Journey Details
                  _buildSectionTitle(context, 'Journey Details'),
                  const SizedBox(height: AppDimens.margin12),
                  _buildInfoRow(context, 'Route', '${ticket.origin} → ${ticket.destination}'),
                  _buildInfoRow(context, 'Departure', DateFormatter.forTicket(ticket.departureTime)),
                  _buildInfoRow(context, 'Bus Type', ticket.busType),
                  _buildInfoRow(context, 'Seat Number', ticket.seatNumber),

                  const SizedBox(height: AppDimens.margin20),

                  // Passenger Details
                  _buildSectionTitle(context, 'Passenger Details'),
                  const SizedBox(height: AppDimens.margin12),
                  _buildInfoRow(context, 'Name', ticket.passengerName),
                  _buildInfoRow(context, 'Phone', ticket.passengerPhone),
                  if (ticket.passengerEmail != null)
                    _buildInfoRow(context, 'Email', ticket.passengerEmail!),

                  const SizedBox(height: AppDimens.margin20),

                  // Payment Details
                  _buildSectionTitle(context, 'Payment Details'),
                  const SizedBox(height: AppDimens.margin12),
                  _buildInfoRow(context, 'Ticket Price', CurrencyFormatter.format(ticket.price)),
                  if (ticket.insuranceFee != null)
                    _buildInfoRow(context, 'Insurance', CurrencyFormatter.format(ticket.insuranceFee!)),
                  if (ticket.serviceFee != null)
                    _buildInfoRow(context, 'Service Fee', CurrencyFormatter.format(ticket.serviceFee!)),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    'Total Paid',
                    CurrencyFormatter.format(ticket.totalAmount),
                    isTotal: true,
                  ),

                  const SizedBox(height: AppDimens.margin20),

                  // Actions
                  if (ticket.status == 'confirmed' || ticket.status == 'paid')
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            text: 'Cancel Ticket',
                            onPressed: () => _showCancelDialog(ticket.id),
                            textColor: AppColors.error,
                            borderColor: AppColors.error,
                          ),
                        ),
                        const SizedBox(width: AppDimens.margin12),
                        Expanded(
                          child: PrimaryButton(
                            text: 'Show QR',
                            onPressed: () => Get.toNamed(
                              '/passenger/ticket/${ticket.id}/qr',
                              arguments: {'ticket': ticket},
                            ),
                            icon: Icons.qr_code_scanner_rounded,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: AppDimens.margin32),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: AppFonts.semiBold,
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              fontWeight: AppFonts.bold,
            )
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64),
          const SizedBox(height: AppDimens.margin16),
          const Text('Ticket not found'),
          const SizedBox(height: AppDimens.margin24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        return isDark ? AppColors.successLight : AppColors.success;
      case 'pending':
        return isDark ? AppColors.warningLight : AppColors.warning;
      case 'cancelled':
        return isDark ? AppColors.errorLight : AppColors.error;
      case 'used':
        return isDark ? AppColors.infoLight : AppColors.info;
      default:
        return isDark ? AppColors.grey500 : AppColors.grey600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.pending_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'used':
        return Icons.done_all_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  void _showCancelDialog(String ticketId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Ticket'),
        content: const Text('Are you sure you want to cancel this ticket?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.cancelTicket(ticketId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}