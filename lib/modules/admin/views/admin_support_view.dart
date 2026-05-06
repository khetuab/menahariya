import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/modules/admin/controllers/admin_support_controller.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_status_badge.dart';
import 'package:menahariya/data/models/common/support_ticket_model.dart';

import '../../passenger/views/support/ticket_detail_view.dart';

class AdminSupportView extends GetView<AdminSupportController> {
  const AdminSupportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    print('🔧 AdminSupportView built - current route: ${Get.currentRoute}');

    return WillPopScope(
      onWillPop: () async {
        print('🔙 Back button pressed in AdminSupportView');
        Get.back();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Support Tickets'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              print('🔙 Back button pressed');
              Get.back();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                print('🔄 Refreshing tickets');
                controller.refreshTickets();
              },
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildStatsRow(context),
            _buildSearchAndFilters(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading && controller.tickets.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.tickets.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    print('🔄 Pull to refresh');
                    await controller.refreshTickets();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimens.padding16),
                    itemCount: controller.tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = controller.tickets[index];
                      return _buildTicketCard(context, ticket);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      margin: const EdgeInsets.all(AppDimens.margin16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.grey.shade200,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(context, label: 'Pending', count: controller.pendingCount, color: Colors.orange),
          Container(width: 1, height: 30, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          _buildStatItem(context, label: 'In Progress', count: controller.inProgressCount, color: Colors.blue),
          Container(width: 1, height: 30, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          _buildStatItem(context, label: 'Resolved', count: controller.resolvedCount, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required String label, required int count, required Color color}) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: AppFonts.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimens.margin2),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
      child: Column(
        children: [
          TextField(
            onChanged: (query) {
              print('🔍 Searching: $query');
              controller.setSearchQuery(query);
            },
            decoration: InputDecoration(
              hintText: 'Search by name, email, or subject...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radius12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16, vertical: AppDimens.padding12),
            ),
          ),
          const SizedBox(height: AppDimens.margin12),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.statusOptions.map((status) {
                final isSelected = controller.selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimens.margin8),
                  child: FilterChip(
                    label: Text(status.toUpperCase().replaceFirst('_', ' ')),
                    selected: isSelected,
                    onSelected: (_) {
                      print('📊 Filter changed to: $status');
                      controller.setStatusFilter(status);
                    },
                    selectedColor: isDark
                        ? AppColors.primaryGreen.withOpacity(0.3)
                        : AppColors.primaryGreen.withOpacity(0.1),
                    checkmarkColor: isDark
                        ? AppColors.primaryGreenLight
                        : AppColors.primaryGreen,
                    backgroundColor: isDark ? AppColors.grey800 : Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
          const SizedBox(height: AppDimens.margin8),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, SupportTicketModel ticket) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.margin12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: InkWell(
        onTap: () {
          print('📋 Ticket tapped: ${ticket.id}');

          Get.to(()=>AdminTicketDetailView(),arguments:  {'ticket': ticket} );
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.subject,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppFonts.semiBold),
                        ),
                        const SizedBox(height: AppDimens.margin4),
                        Text('From: ${ticket.name}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  AdminStatusBadge(status: ticket.status),
                ],
              ),
              const SizedBox(height: AppDimens.margin12),
              Text(
                ticket.message,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimens.margin12),
              Row(
                children: [
                  Icon(Icons.email_rounded, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(width: AppDimens.margin4),
                  Expanded(child: Text(ticket.email, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: AppDimens.margin8),
                  Icon(Icons.access_time_rounded, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  const SizedBox(width: AppDimens.margin4),
                  Text(_formatDate(ticket.createdAt), style: theme.textTheme.bodySmall),
                ],
              ),
              // Show reply indicator if there are replies
              if (ticket.hasReplies) ...[
                const SizedBox(height: AppDimens.margin8),
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 12,
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                    const SizedBox(width: AppDimens.margin4),
                    Text(
                      'Has replies',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 80, child: Text(label, style: Get.context!.textTheme.bodySmall)),
        Expanded(child: Text(value, style: Get.context!.textTheme.bodyMedium)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent_rounded, size: 80, color: isDark ? AppColors.textHintDark : AppColors.textHintLight),
          const SizedBox(height: AppDimens.margin16),
          Text('No Support Tickets', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: AppFonts.semiBold)),
          const SizedBox(height: AppDimens.margin8),
          Text('Support tickets from users will appear here', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}