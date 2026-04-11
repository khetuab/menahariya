// lib/modules/admin/widgets/admin_status_badge.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_fonts.dart';

class AdminStatusBadge extends StatelessWidget {
  final String status;
  final bool isActive;

  const AdminStatusBadge({
    Key? key,
    required this.status,
    this.isActive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding8,
        vertical: AppDimens.padding4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: AppFonts.medium,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    final lowerStatus = status.toLowerCase();

    switch (lowerStatus) {
      case 'confirmed':
      case 'paid':
      case 'completed':
      case 'delivered':
      case 'active':
        return Colors.green;

      case 'pending':
      case 'processing':
      case 'registered':
        return Colors.orange;

      case 'cancelled':
      case 'failed':
      case 'inactive':
        return Colors.red;

      case 'in_transit':
        return Colors.cyan;

      case 'loaded':
        return Colors.purple;

      case 'scheduled':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }
}