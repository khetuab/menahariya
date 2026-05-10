// lib/modules/driver/views/support/driver_my_tickets_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/modules/driver/controllers/driver_support_controller.dart';
import 'package:menahariya/data/models/common/support_ticket_model.dart';
import 'package:menahariya/modules/driver/views/support/driver_ticket_detail_view.dart';

class DriverMyTicketsView extends GetView<DriverSupportController> {
  const DriverMyTicketsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Support Tickets'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.fetchMyTickets(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.myTickets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myTickets.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchMyTickets(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimens.padding16),
            itemCount: controller.myTickets.length,
            itemBuilder: (context, index) {
              final ticket = controller.myTickets[index];
              return _buildTicketCard(context, ticket);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTicketCard(BuildContext context, SupportTicketModel ticket) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasResponse = ticket.adminResponse != null && ticket.adminResponse!.isNotEmpty;
    final isResolved = ticket.status == 'resolved' || ticket.status == 'closed';

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
        onTap: () {
          print('📋 Ticket tapped: ${ticket.id}');
          Get.to(
                () => const DriverTicketDetailView(),
            arguments: {'ticket': ticket},
            transition: Transition.rightToLeft,
          );
        },
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Subject and Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.subject,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.padding8,
                      vertical: AppDimens.padding4,
                    ),
                    decoration: BoxDecoration(
                      color: ticket.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radius20),
                    ),
                    child: Text(
                      ticket.statusDisplay,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ticket.statusColor,
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin8),

              // Message Preview
              Text(
                ticket.message,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimens.margin8),

              // Admin Response Preview (if any)
              if (hasResponse) ...[
                const SizedBox(height: AppDimens.margin4),
                Container(
                  padding: const EdgeInsets.all(AppDimens.padding8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey50,
                    borderRadius: BorderRadius.circular(AppDimens.radius8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.headset_mic_outlined,
                        size: 14,
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      ),
                      const SizedBox(width: AppDimens.margin4),
                      Expanded(
                        child: Text(
                          'Admin: ${ticket.adminResponse}',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppDimens.margin12),

              // Footer Row with Date and Status Indicator
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: AppDimens.margin4),
                  Text(
                    _formatDate(ticket.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (hasResponse && !isResolved)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.padding8,
                        vertical: AppDimens.padding2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimens.radius12),
                      ),
                      child: Text(
                        'Awaiting response',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  if (ticket.status == 'pending')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.padding8,
                        vertical: AppDimens.padding2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimens.radius12),
                      ),
                      child: Text(
                        'Pending',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                          fontSize: 10,
                        ),
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.padding24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                size: 50,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: AppDimens.margin24),

            // Title
            Text(
              'No Support Tickets',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
            const SizedBox(height: AppDimens.margin8),

            // Subtitle
            Text(
              'Your support requests will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.margin16),

            // Hint Text
            Text(
              'Go to Help & Support to create a ticket',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
              ),
            ),
            const SizedBox(height: AppDimens.margin32),

            // Action Button
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.message_rounded),
              label: const Text('Contact Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding24,
                  vertical: AppDimens.padding12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}