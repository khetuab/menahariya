// lib/modules/passenger/views/tickets/ticket_trip_select_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/modules/passenger/controllers/ticket_controller.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';

import '../../../../core/routes/app_routes.dart';

class TicketTripSelectView extends GetView<PassengerTicketController> {
  const TicketTripSelectView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Trip'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Obx(() {
          if (controller.isLoadingTrips) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Search Bar - Fixed at top with scroll
              Container(
                padding: const EdgeInsets.all(AppDimens.padding16),
                child: _buildSearchBar(context),
              ),

              // Trips List - Scrollable
              Expanded(
                child: controller.availableTrips.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
                  itemCount: controller.availableTrips.length,
                  itemBuilder: (context, index) {
                    final trip = controller.availableTrips[index];
                    return _buildTripCard(context, trip);
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Origin Field with Suggestions
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                ),
                child: TextField(
                  controller: TextEditingController(text: controller.origin.value),
                  focusNode: controller.originFocusNode,
                  onChanged: (value) {
                    controller.origin.value = value;
                    controller.getPlaceSuggestions(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'From',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppDimens.padding12),
                    prefixIcon: Icon(
                      Icons.fmd_good_rounded,
                      size: 18,
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => controller.destinationFocusNode.requestFocus(),
                ),
              ),

              // Origin Suggestions - Limited height with scroll
              Obx(() {
                if (controller.placeSuggestions.isEmpty || !controller.originFocusNode.hasFocus) {
                  return const SizedBox();
                }
                return Container(
                  margin: const EdgeInsets.only(top: AppDimens.margin4),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimens.radius8),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.placeSuggestions.length,
                    itemBuilder: (context, index) {
                      final place = controller.placeSuggestions[index];
                      return ListTile(
                        leading: Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        ),
                        title: Text(
                          place.name,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: place.city != null
                            ? Text(
                          place.city!,
                          style: theme.textTheme.bodySmall,
                        )
                            : null,
                        onTap: () {
                          controller.origin.value = place.name;
                          controller.originFocusNode.unfocus();
                          controller.placeSuggestions.clear();
                          Future.delayed(const Duration(milliseconds: 100), () {
                            controller.destinationFocusNode.requestFocus();
                          });
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: AppDimens.margin8),

          // Swap Button
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(
                Icons.swap_vert_rounded,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
              onPressed: () {
                controller.swapLocations();
              },
              tooltip: 'Swap locations',
            ),
          ),

          const SizedBox(height: AppDimens.margin8),

          // Destination Field with Suggestions
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                ),
                child: TextField(
                  controller: TextEditingController(text: controller.destination.value),
                  focusNode: controller.destinationFocusNode,
                  onChanged: (value) {
                    controller.destination.value = value;
                    controller.getPlaceSuggestions(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'To',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppDimens.padding12),
                    prefixIcon: Icon(
                      Icons.fmd_bad_rounded,
                      size: 18,
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
              ),

              // Destination Suggestions - Limited height with scroll
              Obx(() {
                if (controller.placeSuggestions.isEmpty || !controller.destinationFocusNode.hasFocus) {
                  return const SizedBox();
                }
                return Container(
                  margin: const EdgeInsets.only(top: AppDimens.margin4),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimens.radius8),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.placeSuggestions.length,
                    itemBuilder: (context, index) {
                      final place = controller.placeSuggestions[index];
                      return ListTile(
                        leading: Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        ),
                        title: Text(
                          place.name,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: place.city != null
                            ? Text(
                          place.city!,
                          style: theme.textTheme.bodySmall,
                        )
                            : null,
                        onTap: () {
                          controller.destination.value = place.name;
                          controller.destinationFocusNode.unfocus();
                          controller.placeSuggestions.clear();
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: AppDimens.margin12),

          // Date and Search Button
          Row(
            children: [
              // Date Picker
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimens.padding12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey800 : AppColors.grey50,
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        ),
                        const SizedBox(width: AppDimens.margin8),
                        Expanded(
                          child: Obx(() => Text(
                            controller.selectedDate.value == null
                                ? 'Select Date'
                                : DateFormatter.toDisplayDate(controller.selectedDate.value!),
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.margin12),

              // Search Button
              SizedBox(
                width: 100,
                height: 48,
                child: PrimaryButton(
                  text: 'Search',
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    controller.searchTripsForTicket();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripModel trip) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimens.margin12),
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route
          Row(
            children: [
              // Origin
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.origin,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormatter.toTime(trip.departureTime),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              const SizedBox(width: AppDimens.margin8),
              Icon(
                Icons.arrow_forward_rounded,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: AppDimens.margin8),

              // Destination
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trip.destination,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      DateFormatter.toTime(trip.arrivalTime),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimens.margin12),

          // Trip Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Available Seats
              Row(
                children: [
                  Icon(
                    Icons.event_seat_rounded,
                    size: 16,
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${trip.availableSeats} seats',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),

              // Price
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding8,
                  vertical: AppDimens.padding4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                ),
                child: Text(
                  CurrencyFormatter.format(trip.price),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppFonts.bold,
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimens.margin16),

          // Select Button
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: 'Select This Trip',
                onPressed: () {
                  print('🔘 Select trip button pressed for: ${trip.origin} → ${trip.destination}');
                  // Navigate directly to trip detail
                  Get.offNamed(
                    AppRoutes.passengerMyTickets,
                    arguments: {'tripId': trip.id},
                  );
                },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.padding16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: isDark ? AppColors.grey600 : AppColors.grey400,
            ),
            const SizedBox(height: AppDimens.margin16),
            Text(
              'No Trips Found',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimens.margin8),
            Text(
              'Try adjusting your search criteria',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryGreenLight
                  : AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectedDate.value = picked;
    }
  }
}