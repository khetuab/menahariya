// lib/modules/passenger/views/booking/seat_selection_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/seat/seat_map.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/modules/passenger/controllers/trip_detail_controller.dart';

class SeatSelectionView extends GetView<PassengerTripDetailController> {
  const SeatSelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Seats'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Bus Layout Info
            Container(
              padding: const EdgeInsets.all(AppDimens.padding16),
              color: isDark ? AppColors.grey800 : AppColors.grey50,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.trip?.origin} → ${controller.trip?.destination}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: AppFonts.semiBold,
                          ),
                        ),
                        Text(
                          'Available: ${controller.availableSeatsCount} seats',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.successLight : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.padding8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                    ),
                    child: Text(
                      CurrencyFormatter.format(controller.trip?.price ?? 0),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Seat Map
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.padding16),
                child: SeatMap(
                  tripId: controller.tripId,
                  seatLayout: controller.seatLayout,
                  seats: controller.seats.map((seat) => SeatData(
                    id: seat.id,
                    number: seat.number,
                    status: seat.status,
                    row: seat.row,
                    column: seat.column,
                    isAvailable: seat.isAvailable,
                  )).toList(),
                  onSeatSelected: (seatData) {
                    // Find corresponding SeatModel and call your existing toggle function
                    final seatModel = controller.seats.firstWhere((s) => s.id == seatData.id);
                    controller.toggleSeatSelection(seatModel);
                  },
                  maxSelection: controller.trip?.maxSeatsPerBooking ?? 10,
                  showLegend: true,
                ),
              ),
            ),

            // Selected Seats Summary
            Obx(() {
              if (controller.selectedSeats.isEmpty) return const SizedBox();

              return Container(
                padding: const EdgeInsets.all(AppDimens.padding16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.transparent : AppColors.grey200.withOpacity(0.5),
                      blurRadius: AppDimens.shadowBlurMedium,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Selected Seats: ${controller.selectedSeats.map((s) => s.number).join(', ')}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          controller.formattedTotalPrice,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.margin12),
                    PrimaryButton(
                      text: 'Continue to Booking',
                      onPressed: controller.proceedToBooking,
                      icon: Icons.arrow_forward_rounded,
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}