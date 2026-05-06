import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';

import '../../../modules/passenger/controllers/support_controller.dart';

class ReplyBubble extends StatelessWidget {
  final ReplyModel reply;
  final bool isOwnMessage;

  const ReplyBubble({
    Key? key,
    required this.reply,
    required this.isOwnMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Sender name
            Padding(
              padding: const EdgeInsets.only(
                left: AppDimens.margin12,
                right: AppDimens.margin12,
                bottom: AppDimens.margin4,
              ),
              child: Text(
                reply.isAdmin ? 'Admin' : (reply.user?.fullName ?? 'You'),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: reply.isAdmin
                      ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                      : (isDark ? Colors.blue.shade300 : Colors.blue.shade700),
                ),
              ),
            ),
            // Message bubble
            Container(
              padding: const EdgeInsets.all(AppDimens.padding12),
              decoration: BoxDecoration(
                color: isOwnMessage
                    ? (isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight)
                    : (isDark ? AppColors.grey800 : Colors.grey.shade100),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppDimens.radius12),
                  topRight: const Radius.circular(AppDimens.radius12),
                  bottomLeft: Radius.circular(isOwnMessage ? AppDimens.radius12 : AppDimens.radius4),
                  bottomRight: Radius.circular(isOwnMessage ? AppDimens.radius4 : AppDimens.radius12),
                ),
              ),
              child: Text(
                reply.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isOwnMessage
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            // Timestamp
            Padding(
              padding: const EdgeInsets.only(
                left: AppDimens.margin12,
                right: AppDimens.margin12,
                top: AppDimens.margin4,
              ),
              child: Text(
                DateFormat('hh:mm a, MMM dd').format(reply.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}