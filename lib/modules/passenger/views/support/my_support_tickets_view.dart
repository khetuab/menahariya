import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/modules/passenger/controllers/support_controller.dart';
import 'package:menahariya/data/models/common/support_ticket_model.dart';
import 'package:menahariya/modules/passenger/views/support/ticket_detail_view.dart';
import 'package:menahariya/modules/passenger/views/support/ticket_detail_view_user.dart';

class MySupportTicketsView extends GetView<SupportController> {
  const MySupportTicketsView({Key? key}) : super(key: key);

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
            onPressed: controller.fetchMyTickets,
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
          onRefresh: controller.fetchMyTickets,
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

          Get.to(()=>TicketDetailViewUser(),arguments:  {'ticket': ticket} );
        },
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                ticket.message,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasResponse) ...[
                const SizedBox(height: AppDimens.margin12),
                Container(
                  padding: const EdgeInsets.all(AppDimens.padding12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey50,
                    borderRadius: BorderRadius.circular(AppDimens.radius8),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.support_agent_rounded,
                        size: 16,
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      ),
                      const SizedBox(width: AppDimens.margin8),
                      Expanded(
                        child: Text(
                          'Admin responded: ${ticket.adminResponse}',
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isResolved)
                        Icon(
                          Icons.circle_rounded,
                          size: 8,
                          color: Colors.orange,
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppDimens.margin12),
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
                    Text(
                      'Awaiting your response',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent_rounded,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            'No Support Tickets',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            'Your support requests will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppDimens.margin24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.message_rounded),
            label: const Text('Contact Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}