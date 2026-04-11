// lib/modules/passenger/views/tickets/my_tickets_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/cards/ticket_card.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/passenger/controllers/ticket_controller.dart';

import '../../../../core/routes/app_routes.dart';

class MyTicketsView extends GetView<PassengerTicketController> {
  const MyTicketsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Tickets'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Past'),
              Tab(text: 'All'),
            ],
            labelColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            indicatorColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          ),
        ),
        body: TabBarView(
          children: [
            // Active Tickets Tab
            _buildTicketList(context, 'active'),
            // Past Tickets Tab
            _buildTicketList(context, 'past'),
            // All Tickets Tab
            _buildTicketList(context, 'all'),
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
        onRefresh: controller.refreshTickets,
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          children: _getTicketsForType(type),
        ),
      );
    });
  }

  List<Widget> _getTicketsForType(String type) {
    final List<Widget> ticketWidgets = [];

    switch (type) {
      case 'active':
        if (controller.activeTickets.isEmpty) {
          return [_buildEmptyState('No active tickets')];
        }
        ticketWidgets.addAll(controller.activeTickets.map((ticket) => TicketCard(
          ticketId: ticket.id,
          origin: ticket.origin,
          destination: ticket.destination,
          departureTime: ticket.departureTime,
          seatNumber: ticket.seatNumber,
          price: ticket.price,
          status: ticket.status,
          // In MyTicketsView, update the onTap:

          onTap: () => Get.toNamed(
            '/passenger/ticket-detail/${ticket.id}',
            arguments: {'ticketId': ticket.id},
          ),
          showActions: true,
        )));
        break;

      case 'past':
        if (controller.pastTickets.isEmpty) {
          return [_buildEmptyState('No past tickets')];
        }
        ticketWidgets.addAll(controller.pastTickets.map((ticket) => TicketCard(
          ticketId: ticket.id,
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
        )));
        break;

      case 'all':
      default:
        if (controller.tickets.isEmpty) {
          return [_buildEmptyState('No tickets found')];
        }
        ticketWidgets.addAll(controller.tickets.map((ticket) => TicketCard(
          ticketId: ticket.id,
          origin: ticket.origin,
          destination: ticket.destination,
          departureTime: ticket.departureTime,
          seatNumber: ticket.seatNumber,
          price: ticket.price,
          status: ticket.status,
          onTap: () => Get.toNamed(
            AppRoutes.passengerTicketDetail,  // Use the constant, not a string with ID
            arguments: {'ticketId': ticket.id},  // Pass ID as argument
          ),
          showActions: ticket.status == 'confirmed' || ticket.status == 'pending',
        )));
        break;
    }

    // Add spacing between tickets
    final List<Widget> result = [];
    for (int i = 0; i < ticketWidgets.length; i++) {
      result.add(ticketWidgets[i]);
      if (i < ticketWidgets.length - 1) {
        result.add(const SizedBox(height: AppDimens.margin12));
      }
    }

    return result;
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

  // In MyTicketsView, update the _buildEmptyState method:

  Widget _buildEmptyState(String message) {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_rounded,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            'Book your first trip to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppDimens.margin24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/passenger/tickets/select-trip'), // Changed this line
            icon: const Icon(Icons.search_rounded),
            label: const Text('Search Trips'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}