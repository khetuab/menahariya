// lib/core/widgets/seat/seat_item.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/seat/seat_map.dart';

class SeatItem extends StatelessWidget {
  final SeatData seat;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;

  const SeatItem({
    Key? key,
    required this.seat,
    required this.isSelected,
    required this.onTap,
    this.size = AppDimens.seatSize,
  }) : super(key: key);

  Color _getSeatColor(BuildContext context) {
    if (isSelected) return AppColors.seatSelected;

    switch (seat.status.toLowerCase()) {
      case 'available':
        return AppColors.seatAvailable;
      case 'booked':
      case 'paid':
      case 'used':
        return AppColors.seatBooked;
      case 'locked':
      case 'reserved':
        return AppColors.seatLocked;
      case 'disabled':
        return AppColors.seatDisabled;
      default:
        return Theme.of(context).brightness == Brightness.dark
            ? AppColors.grey700
            : AppColors.grey300;
    }
  }

  IconData _getSeatIcon() {
    if (seat.isWindow) return Icons.chair_alt_rounded;
    if (seat.isAisle) return Icons.event_seat_rounded;
    return Icons.event_seat_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final seatColor = _getSeatColor(context);
    final isAvailable = seat.status.toLowerCase() == 'available';

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: AnimatedContainer(
        duration: AppDimens.animationFast,
        width: size,
        height: size,
        margin: const EdgeInsets.all(2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Seat Background
            Container(
              decoration: BoxDecoration(
                color: seatColor.withOpacity(isAvailable ? 1 : 0.8),
                borderRadius: BorderRadius.circular(AppDimens.radius8),
                border: isSelected
                    ? Border.all(
                  color: AppColors.white,
                  width: 2,
                )
                    : null,
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: seatColor.withOpacity(0.5),
                    blurRadius: AppDimens.shadowBlurSmall,
                    spreadRadius: AppDimens.shadowSpreadSmall,
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  _getSeatIcon(),
                  size: size * 0.5,
                  color: Colors.white.withOpacity(isAvailable ? 1 : 0.7),
                ),
              ),
            ),

            // Seat Number
            if (isAvailable)
              Positioned(
                bottom: 2,
                child: Text(
                  seat.number,
                  style: TextStyle(
                    fontSize: size * 0.2,
                    color: Colors.white,
                    fontWeight: AppFonts.medium,
                  ),
                ),
              ),

            // Lock Icon for locked seats
            if (seat.status.toLowerCase() == 'locked')
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.lock_rounded,
                  size: size * 0.25,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),

            // Booked Indicator
            if (seat.status.toLowerCase() == 'booked' && seat.passengerName != null)
              Positioned(
                top: 2,
                left: 2,
                child: Icon(
                  Icons.person_rounded,
                  size: size * 0.2,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}