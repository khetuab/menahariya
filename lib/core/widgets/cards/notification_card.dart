// lib/core/widgets/cards/notification_card.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';

class NotificationCard extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    Key? key,
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    required this.isRead,
    required this.onTap,
    this.onMarkRead,
    this.onDelete,
  }) : super(key: key);

  IconData _getTypeIcon() {
    switch (type.toLowerCase()) {
      case 'booking':
        return Icons.confirmation_number_rounded;
      case 'payment':
        return Icons.payments_rounded;
      case 'trip':
        return Icons.directions_bus_rounded;
      case 'cargo':
        return Icons.inventory_2_rounded;
      case 'reminder':
        return Icons.alarm_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type.toLowerCase()) {
      case 'booking':
        return isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen;
      case 'payment':
        return isDark ? AppColors.successLight : AppColors.success;
      case 'trip':
        return isDark ? AppColors.warningLight : AppColors.warning;
      case 'cargo':
        return isDark ? AppColors.infoLight : AppColors.info;
      case 'reminder':
        return isDark ? AppColors.secondaryOrangeLight : AppColors.secondaryOrange;
      case 'promo':
        return isDark ? AppColors.secondaryPurpleLight : AppColors.secondaryPurple;
      default:
        return isDark ? AppColors.grey500 : AppColors.grey600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = _getTypeColor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin12),
        decoration: BoxDecoration(
          color: isRead
              ? (isDark ? AppColors.surfaceDark : AppColors.white)
              : (isDark ? AppColors.grey800 : AppColors.grey50),
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          border: Border.all(
            color: isRead
                ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                : typeColor.withOpacity(0.3),
          ),
        ),
        child: Stack(
          children: [
            // Unread indicator
            if (!isRead)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimens.radius12),
                      bottomLeft: Radius.circular(AppDimens.radius12),
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(AppDimens.padding10),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: typeColor,
                      size: AppDimens.iconSize24,
                    ),
                  ),
                  const SizedBox(width: AppDimens.margin12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: isRead ? AppFonts.regular : AppFonts.semiBold,
                                ),
                              ),
                            ),
                            if (onMarkRead != null && !isRead)
                              IconButton(
                                icon: const Icon(Icons.mark_email_read_rounded, size: 18),
                                onPressed: onMarkRead,
                                color: typeColor,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.margin4),

                        // Body
                        Text(
                          body,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimens.margin8),

                        // Timestamp
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: AppDimens.iconSize12,
                              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                            ),
                            const SizedBox(width: AppDimens.margin4),
                            Text(
                              DateFormatter.forNotification(timestamp),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Delete button
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: onDelete,
                      color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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