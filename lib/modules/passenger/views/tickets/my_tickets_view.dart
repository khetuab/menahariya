// lib/modules/passenger/views/tickets/my_tickets_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/cards/ticket_card.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/passenger/controllers/ticket_controller.dart';

class MyTicketsView extends GetView<PassengerTicketController> {
  const MyTicketsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        bottom: TabBar(
          controller: TabController(length: 3, vsync: Scaffold.of(context)),
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
      body: Obx(() {
        if (controller.isLoading && controller.tickets.isEmpty) {
          return _buildLoadingShimmer();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshTickets,
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.padding16),
            children: [
              // Active Tickets
              if (controller.activeTickets.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.padding8),
                  child: Text(
                    'Active Tickets',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppFonts.semiBold,
                    ),
                  ),
                ),
                ...controller.activeTickets.map((ticket) => TicketCard(
                  ticketId: ticket.id,
                  origin: ticket.origin,
                  destination: ticket.destination,
                  departureTime: ticket.departureTime,
                  seatNumber: ticket.seatNumber,
                  price: ticket.price,
                  status: ticket.status,
                  onTap: () => Get.toNamed(
                    '/passenger/ticket/${ticket.id}',
                    arguments: {'ticketId': ticket.id},
                  ),
                  showActions: true,
                )),
                const SizedBox(height: AppDimens.margin16),
              ],

              // Past Tickets
              if (controller.pastTickets.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.padding8),
                  child: Text(
                    'Past Tickets',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppFonts.semiBold,
                    ),
                  ),
                ),
                ...controller.pastTickets.take(5).map((ticket) => TicketCard(
                  ticketId: ticket.id,
                  origin: ticket.origin,
                  destination: ticket.destination,
                  departureTime: ticket.departureTime,
                  seatNumber: ticket.seatNumber,
                  price: ticket.price,
                  status: ticket.status,
                  onTap: () => Get.toNamed(
                    '/passenger/ticket/${ticket.id}',
                    arguments: {'ticketId': ticket.id},
                  ),
                  showActions: false,
                )),
              ],

              if (controller.tickets.isEmpty)
                _buildEmptyState(context),
            ],
          ),
        );
      }),
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
            Icons.confirmation_number_rounded,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            'No Tickets Found',
            style: theme.textTheme.headlineSmall?.copyWith(
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
            onPressed: () => Get.toNamed('/passenger/search'),
            icon: const Icon(Icons.search_rounded),
            label: const Text('Search Trips'),
          ),
        ],
      ),
    );
  }
}