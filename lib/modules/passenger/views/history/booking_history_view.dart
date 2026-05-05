// lib/modules/passenger/views/history/booking_history_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/cards/ticket_card.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/passenger/controllers/history_controller.dart';

import '../../../../data/models/ticket/ticket_model.dart';

class BookingHistoryView extends GetView<PassengerHistoryController> {
  const BookingHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Reset filters and load tickets when view is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset status filter to empty (show all tickets)
      controller.resetStatusFilter();
      // Load tickets
      controller.loadTickets(refresh: true);
    });

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
        body: Obx(() {
          if (controller.isLoading && controller.tickets.isEmpty) {
            return _buildLoadingShimmer();
          }

          return TabBarView(
            children: [
              // Upcoming Tab
              _buildTicketList(context, 'upcoming'),
              // Completed Tab
              _buildTicketList(context, 'completed'),
              // Cancelled Tab
              _buildTicketList(context, 'cancelled'),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTicketList(BuildContext context, String type) {
    final tickets = _getFilteredTicketsForType(type);

    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadTickets(refresh: true);
      },
      child: tickets.isEmpty
          ? _buildEmptyState(context, type)
          : ListView.builder(
        padding: const EdgeInsets.all(AppDimens.padding16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.margin12),
            child: TicketCard(
              ticketId: ticket.id ?? ticket.bookingId,
              origin: ticket.origin,
              destination: ticket.destination,
              departureTime: ticket.departureTime,
              seatNumber: ticket.seatNumber,
              price: ticket.price,
              status: ticket.status,
              onTap: () => Get.toNamed(
                '/passenger/ticket-detail/${ticket.id}',
                arguments: {'ticketId': ticket.id},
              ),
              showActions: false,
            ),
          );
        },
      ),
    );
  }

  List<TicketModel> _getFilteredTicketsForType(String type) {
    final allTickets = controller.tickets;

    print('📊 Filtering for type: $type');
    print('📊 Total tickets available: ${allTickets.length}');

    if (allTickets.isEmpty) {
      return [];
    }

    switch (type) {
      case 'upcoming':
      // Upcoming: status is 'issued' and departure time is in the future
        return allTickets.where((t) {
          final isIssued = t.status == 'issued';
          final isFutureDate = t.departureTime.isAfter(DateTime.now());
          return isIssued && isFutureDate;
        }).toList();

      case 'completed':
      // Completed: status is 'issued' but departure time is in the past
      // Or status is 'used', 'completed', 'delivered'
        return allTickets.where((t) {
          final isPastDate = t.departureTime.isBefore(DateTime.now());
          final isCompletedStatus = t.status == 'used' ||
              t.status == 'completed' ||
              t.status == 'delivered';
          return (isPastDate && t.status == 'issued') || isCompletedStatus;
        }).toList();

      case 'cancelled':
      // Cancelled: status is 'cancelled' or 'refunded'
        return allTickets.where((t) {
          return t.status == 'cancelled' || t.status == 'refunded';
        }).toList();

      default:
        return allTickets;
    }
  }

  Widget _buildEmptyState(BuildContext context, String type) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String title = '';
    String message = '';
    IconData icon = Icons.history_rounded;

    switch (type) {
      case 'upcoming':
        title = 'No Upcoming Trips';
        message = 'You don\'t have any upcoming trips';
        icon = Icons.calendar_today_rounded;
        break;
      case 'completed':
        title = 'No Completed Trips';
        message = 'Your completed trips will appear here';
        icon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        title = 'No Cancelled Trips';
        message = 'Cancelled trips will appear here';
        icon = Icons.cancel_rounded;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.padding16),
      itemCount: 3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.margin12),
        child: ShimmerLoading(
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
          ),
        ),
      ),
    );
  }
}