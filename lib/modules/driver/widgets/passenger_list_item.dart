// lib/modules/driver/widgets/passenger_list_item.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/data/models/passenger/passenger_model.dart';

class PassengerListItem extends StatelessWidget {
  final PassengerModel passenger;
  final VoidCallback onTap;
  final VoidCallback? onCheckIn;
  final bool showCheckInButton;
  final bool compact;

  const PassengerListItem({
    Key? key,
    required this.passenger,
    required this.onTap,
    this.onCheckIn,
    this.showCheckInButton = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactItem(context);
    }
    return _buildFullItem(context);
  }

  Widget _buildFullItem(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.margin8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding12),
          child: Row(
            children: [
              // Avatar with status indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getAvatarColor(passenger, isDark),
                    child: Text(
                      passenger.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (passenger.checkedIn)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.successLight : AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: AppDimens.margin12),

              // Passenger details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            passenger.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: AppFonts.semiBold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.padding6,
                            vertical: AppDimens.padding2,
                          ),
                          decoration: BoxDecoration(
                            color: _getSeatColor(passenger.seatNumber, isDark).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimens.radius4),
                          ),
                          child: Text(
                            'Seat ${passenger.seatNumber}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getSeatColor(passenger.seatNumber, isDark),
                              fontWeight: AppFonts.medium,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimens.margin4),

                    // Additional info
                    Row(
                      children: [
                        if (passenger.hasCargo)
                          Container(
                            margin: const EdgeInsets.only(right: AppDimens.margin8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.padding4,
                              vertical: AppDimens.padding2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.info.withOpacity(0.2) : AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimens.radius4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_rounded,
                                  size: AppDimens.iconSize12,
                                  color: isDark ? AppColors.infoLight : AppColors.info,
                                ),
                                const SizedBox(width: AppDimens.margin2),
                                Text(
                                  'Cargo',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? AppColors.infoLight : AppColors.info,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (passenger.specialAssistance)
                          Container(
                            margin: const EdgeInsets.only(right: AppDimens.margin8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.padding4,
                              vertical: AppDimens.padding2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.warning.withOpacity(0.2) : AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimens.radius4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.accessible_rounded,
                                  size: AppDimens.iconSize12,
                                  color: isDark ? AppColors.warningLight : AppColors.warning,
                                ),
                                const SizedBox(width: AppDimens.margin2),
                                Text(
                                  'Assistance',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? AppColors.warningLight : AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    if (passenger.phone != null) ...[
                      const SizedBox(height: AppDimens.margin4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: AppDimens.iconSize12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: AppDimens.margin4),
                          Text(
                            passenger.phone!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Check-in button
              if (showCheckInButton && !passenger.checkedIn)
                Container(
                  margin: const EdgeInsets.only(left: AppDimens.margin8),
                  child: ElevatedButton(
                    onPressed: onCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radius20),
                      ),
                    ),
                    child: const Text('Check In'),
                  ),
                ),

              if (passenger.checkedIn)
                Container(
                  margin: const EdgeInsets.only(left: AppDimens.margin8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.padding8,
                    vertical: AppDimens.padding4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.success.withOpacity(0.2) : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radius20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: AppDimens.iconSize14,
                        color: isDark ? AppColors.successLight : AppColors.success,
                      ),
                      const SizedBox(width: AppDimens.margin2),
                      Text(
                        'Checked In',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.successLight : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactItem(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: _getAvatarColor(passenger, isDark),
        child: Text(
          passenger.name[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        passenger.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: AppFonts.medium,
        ),
      ),
      subtitle: Text(
        'Seat ${passenger.seatNumber}${passenger.hasCargo ? ' • Has Cargo' : ''}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: passenger.checkedIn
          ? Icon(
        Icons.check_circle_rounded,
        color: isDark ? AppColors.successLight : AppColors.success,
      )
          : ElevatedButton(
        onPressed: onCheckIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          minimumSize: const Size(60, 30),
        ),
        child: const Text('Check'),
      ),
      onTap: onTap,
    );
  }

  Color _getAvatarColor(PassengerModel passenger, bool isDark) {
    if (passenger.checkedIn) {
      return isDark ? AppColors.successLight : AppColors.success;
    }
    if (passenger.hasCargo) {
      return isDark ? AppColors.infoLight : AppColors.info;
    }
    return isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen;
  }

  Color _getSeatColor(String seatNumber, bool isDark) {
    // You can implement seat color logic based on seat location
    return isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen;
  }
}

// Passenger List Header with Statistics
class PassengerListHeader extends StatelessWidget {
  final int totalCount;
  final int checkedInCount;
  final int pendingCount;
  final VoidCallback? onRefresh;

  const PassengerListHeader({
    Key? key,
    required this.totalCount,
    required this.checkedInCount,
    required this.pendingCount,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimens.radius20),
          bottomRight: Radius.circular(AppDimens.radius20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                label: 'Total',
                value: totalCount.toString(),
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
              _buildStatItem(
                context,
                label: 'Checked In',
                value: checkedInCount.toString(),
                color: isDark ? AppColors.successLight : AppColors.success,
              ),
              _buildStatItem(
                context,
                label: 'Pending',
                value: pendingCount.toString(),
                color: isDark ? AppColors.warningLight : AppColors.warning,
              ),
            ],
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: AppDimens.margin12),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh List'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                side: BorderSide(
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required String label, required String value, required Color color}) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: AppFonts.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}