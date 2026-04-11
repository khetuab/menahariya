// lib/modules/passenger/views/history/booking_history_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/cards/ticket_card.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/passenger/controllers/history_controller.dart';

class BookingHistoryView extends GetView<PassengerHistoryController> {
  const BookingHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking History'),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Upcoming Tab
            _buildTicketList(context, 'upcoming'),
            // Completed Tab
            _buildTicketList(context, 'completed'),
            // Cancelled Tab
            _buildTicketList(context, 'cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketList(BuildContext context, String type) {
    return Obx(() {
      if (controller.isLoading && controller.tickets.isEmpty) {
        return _buildLoadingShimmer();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          children: [
            // Date Range Filter
            _buildDateFilter(context),

            const SizedBox(height: AppDimens.margin16),

            // Stats Summary
            _buildStatsSummary(context),

            const SizedBox(height: AppDimens.margin16),

            // Tickets List
            if (_getFilteredTicketsForType(type).isEmpty)
              _buildEmptyState(context)
            else
              ..._getFilteredTicketsForType(type).map((ticket) => TicketCard(
                ticketId: ticket.id,
                origin: ticket.origin,
                destination: ticket.destination,
                departureTime: ticket.departureTime,
                seatNumber: ticket.seatNumber,
                price: ticket.price,
                status: ticket.status,
                onTap: () => Get.toNamed('/passenger/ticket/${ticket.id}'),
                showActions: false,
              )),

            // Load More
            if (controller.ticketsHasMore)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.padding16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: controller.loadMoreTickets,
                    child: const Text('Load More'),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  List<dynamic> _getFilteredTicketsForType(String type) {
    // Filter based on tab type
    switch (type) {
      case 'upcoming':
        return controller.filteredTickets.where((t) =>
        t.status == 'confirmed' || t.status == 'paid' || t.status == 'pending'
        ).toList();
      case 'completed':
        return controller.filteredTickets.where((t) =>
        t.status == 'used' || t.status == 'completed'
        ).toList();
      case 'cancelled':
        return controller.filteredTickets.where((t) =>
        t.status == 'cancelled'
        ).toList();
      default:
        return controller.filteredTickets;
    }
  }

  Widget _buildDateFilter(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 16,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: AppDimens.margin8),
          Expanded(
            child: Obx(() {
              if (controller.dateRange == null) {
                return Text(
                  'Select Date Range',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                  ),
                );
              }
              return Text(
                '${controller.dateRange!.start.toString().substring(0, 10)} - ${controller.dateRange!.end.toString().substring(0, 10)}',
                style: theme.textTheme.bodyMedium,
              );
            }),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (value) {
              if (value == 'clear') {
                controller.clearDateRange();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Filter'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
            isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${controller.totalTrips}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: AppFonts.bold,
                  ),
                ),
                Text(
                  'Total Trips',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  controller.mostFrequentRoute ?? 'N/A',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: AppFonts.semiBold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Most Visited',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.padding16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin12),
      itemBuilder: (_, __) => ShimmerLoading(
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
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
            Icons.history_rounded,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            'No Booking History',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            'Your booking history will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}