// lib/core/widgets/cards/trip_card.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/core/widgets/buttons/icon_button_widget.dart';

class TripCard extends StatelessWidget {
  final String id;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final int availableSeats;
  final String busType;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final String? driverName;
  final bool showFavorite;
  final bool isSelected;

  const TripCard({
    Key? key,
    required this.id,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.availableSeats,
    required this.busType,
    required this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.driverName,
    this.showFavorite = true,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final duration = arrivalTime.difference(departureTime);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1))
              : (isDark ? AppColors.surfaceDark : AppColors.white),
          borderRadius: BorderRadius.circular(AppDimens.radius16),
          border: isSelected
              ? Border.all(color: AppColors.primaryGreen, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.transparent : AppColors.grey200.withOpacity(0.5),
              blurRadius: AppDimens.shadowBlurSmall,
              spreadRadius: AppDimens.shadowSpreadNone,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding16),
              child: Row(
                children: [
                  // Bus Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.padding8,
                      vertical: AppDimens.padding4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radius20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_bus_rounded,
                          size: AppDimens.iconSize14,
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        ),
                        const SizedBox(width: AppDimens.margin4),
                        Text(
                          busType,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            fontWeight: AppFonts.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (showFavorite)
                    FavoriteButton(
                      isFavorite: isFavorite,
                      onFavoriteChanged: (_) => onFavorite?.call(),
                    ),
                ],
              ),
            ),

            // Trip Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
              child: Row(
                children: [
                  // Time & Location Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormatter.toTime(departureTime),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimens.margin4),
                        Text(
                          origin,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duration Line
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${duration.inHours}h ${duration.inMinutes.remainder(60)}m',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: AppDimens.margin4),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                              ),
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrival Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormatter.toTime(arrivalTime),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimens.margin4),
                        Text(
                          destination,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Driver Info (if available)
            if (driverName != null) ...[
              const SizedBox(height: AppDimens.margin12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: AppDimens.iconSize16,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: AppDimens.margin4),
                    Text(
                      'Driver: $driverName',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppDimens.margin12),

            // Footer
            Container(
              padding: const EdgeInsets.all(AppDimens.padding16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.forTicketPrice(price),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Available Seats
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.padding12,
                      vertical: AppDimens.padding6,
                    ),
                    decoration: BoxDecoration(
                      color: availableSeats > 0
                          ? (isDark ? AppColors.success.withOpacity(0.2) : AppColors.success.withOpacity(0.1))
                          : (isDark ? AppColors.error.withOpacity(0.2) : AppColors.error.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(AppDimens.radius20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_seat_rounded,
                          size: AppDimens.iconSize14,
                          color: availableSeats > 0 ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: AppDimens.margin4),
                        Text(
                          availableSeats > 0 ? '$availableSeats seats' : 'Full',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: availableSeats > 0 ? AppColors.success : AppColors.error,
                            fontWeight: AppFonts.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}