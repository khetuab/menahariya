// lib/modules/admin/widgets/admin_activity_tile.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../models/admin_models.dart';

class AdminActivityTile extends StatelessWidget {
  final AuditLogEntry activity;

  const AdminActivityTile({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getActivityColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radius8),
            ),
            child: Icon(
              _getActivityIcon(),
              color: _getActivityColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimens.margin12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.action,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppFonts.medium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // const SizedBox(height: AppDimens.margin2),
                // Text(
                //   _getActivityDescription(),
                //   style: theme.textTheme.bodySmall,
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                // ),
              ],
            ),
          ),

          // Time
          Text(
            _formatTime(activity.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon() {
    switch (activity.action.toLowerCase()) {
      case 'create':
      case 'added':
        return Icons.add_circle_rounded;
      case 'update':
      case 'edited':
        return Icons.edit_rounded;
      case 'delete':
      case 'deleted':
        return Icons.delete_rounded;
      case 'login':
        return Icons.login_rounded;
      case 'logout':
        return Icons.logout_rounded;
      case 'payment':
        return Icons.payments_rounded;
      case 'booking':
        return Icons.confirmation_number_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getActivityColor() {
    switch (activity.action.toLowerCase()) {
      case 'create':
      case 'added':
        return Colors.green;
      case 'update':
      case 'edited':
        return Colors.orange;
      case 'delete':
      case 'deleted':
        return Colors.red;
      case 'login':
        return Colors.blue;
      case 'logout':
        return Colors.purple;
      case 'payment':
        return Colors.teal;
      case 'booking':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _getActivityDescription() {
    if (activity.entityType.isNotEmpty && activity.entityId != null) {
      final shortId = activity.entityId!.length > 8
          ? '${activity.entityId!.substring(0, 8)}...'
          : activity.entityId!;
      return '${activity.entityType} $shortId by ${activity.userName}';
    }
    return 'by ${activity.userName}';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd').format(time);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}