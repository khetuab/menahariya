// lib/modules/passenger/widgets/seat_layout.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';

class SeatLayout extends StatelessWidget {
  final List<Seat> seats;
  final List<String> selectedSeats;
  final Function(Seat) onSeatSelected;
  final int maxSelection;
  final bool showLegend;

  const SeatLayout({
    Key? key,
    required this.seats,
    required this.selectedSeats,
    required this.onSeatSelected,
    this.maxSelection = 10,
    this.showLegend = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        if (showLegend) ...[
          _buildLegend(context),
          const SizedBox(height: AppDimens.margin16),
        ],

        // Driver Area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.padding8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey100,
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
          child: const Center(
            child: Icon(Icons.directions_bus),
          ),
        ),

        const SizedBox(height: AppDimens.margin24),

        // Seat Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: AppDimens.gridSpacingSmall,
            mainAxisSpacing: AppDimens.gridSpacingSmall,
            childAspectRatio: 1,
          ),
          itemCount: seats.length,
          itemBuilder: (context, index) {
            final seat = seats[index];
            final isSelected = selectedSeats.contains(seat.number);

            return GestureDetector(
              onTap: seat.isAvailable ? () => onSeatSelected(seat) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: _getSeatColor(seat, isSelected, isDark),
                  borderRadius: BorderRadius.circular(AppDimens.radius4),
                  border: seat.isWindow ? Border.all(
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    width: 2,
                  ) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      seat.number,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: AppFonts.medium,
                      ),
                    ),
                    if (!seat.isAvailable)
                      const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: AppDimens.margin16),

        // Selected Count
        if (selectedSeats.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppDimens.padding8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radius8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_seat_rounded,
                  size: 16,
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
                const SizedBox(width: AppDimens.margin4),
                Text(
                  '${selectedSeats.length} of $maxSelection seats selected',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          context,
          color: isDark ? AppColors.successLight : AppColors.success,
          label: 'Available',
        ),
        _buildLegendItem(
          context,
          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          label: 'Selected',
        ),
        _buildLegendItem(
          context,
          color: isDark ? AppColors.errorLight : AppColors.error,
          label: 'Booked',
        ),
        _buildLegendItem(
          context,
          color: isDark ? AppColors.grey600 : AppColors.grey400,
          label: 'Window',
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, {required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimens.radius4),
          ),
        ),
        const SizedBox(width: AppDimens.margin4),
        Text(label),
      ],
    );
  }

  Color _getSeatColor(Seat seat, bool isSelected, bool isDark) {
    if (isSelected) {
      return isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen;
    }
    if (!seat.isAvailable) {
      return isDark ? AppColors.errorLight : AppColors.error;
    }
    return isDark ? AppColors.successLight : AppColors.success;
  }
}

class Seat {
  final String number;
  final bool isAvailable;
  final bool isWindow;
  final double? price;

  Seat({
    required this.number,
    required this.isAvailable,
    this.isWindow = false,
    this.price,
  });
}