// lib/core/widgets/seat/seat_map.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/seat/seat_item.dart';

class SeatMap extends StatefulWidget {
  final String tripId;
  final Map<String, dynamic> seatLayout;
  final List<SeatData> seats;
  final Function(SeatData) onSeatSelected;
  final int maxSelection;
  final List<String>? initiallySelectedSeats;
  final bool showLegend;
  final double seatSize;
  final double spacing;

  const SeatMap({
    Key? key,
    required this.tripId,
    required this.seatLayout,
    required this.seats,
    required this.onSeatSelected,
    this.maxSelection = 1,
    this.initiallySelectedSeats,
    this.showLegend = true,
    this.seatSize = AppDimens.seatSize,
    this.spacing = AppDimens.seatSpacing,
  }) : super(key: key);

  @override
  State<SeatMap> createState() => _SeatMapState();
}

class _SeatMapState extends State<SeatMap> {
  late List<String> _selectedSeats;
  final Map<String, SeatData> _seatMap = {};

  @override
  void initState() {
    super.initState();
    _selectedSeats = widget.initiallySelectedSeats ?? [];
    _buildSeatMap();
  }

  void _buildSeatMap() {
    for (var seat in widget.seats) {
      _seatMap[seat.id] = seat;
    }
  }

  void _handleSeatTap(SeatData seat) {
    if (!seat.isAvailable) return;

    setState(() {
      if (_selectedSeats.contains(seat.id)) {
        _selectedSeats.remove(seat.id);
      } else {
        if (_selectedSeats.length < widget.maxSelection) {
          _selectedSeats.add(seat.id);
        }
      }
    });

    widget.onSeatSelected(seat);
  }

  bool _isSeatSelected(String seatId) => _selectedSeats.contains(seatId);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        if (widget.showLegend) _buildLegend(context),
        const SizedBox(height: AppDimens.margin16),

        // Driver Section
        _buildDriverSection(context),

        const SizedBox(height: AppDimens.margin24),

        // Seat Grid
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          padding: const EdgeInsets.all(AppDimens.padding20),
          child: Column(
            children: _buildSeatRows(),
          ),
        ),

        const SizedBox(height: AppDimens.margin16),

        // Selection Info
        if (_selectedSeats.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppDimens.padding12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_seat_rounded,
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
                const SizedBox(width: AppDimens.margin8),
                Text(
                  '${_selectedSeats.length} seat${_selectedSeats.length > 1 ? 's' : ''} selected',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    fontWeight: AppFonts.medium,
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

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            context,
            color: AppColors.seatAvailable,
            label: 'Available',
          ),
          _buildLegendItem(
            context,
            color: AppColors.seatSelected,
            label: 'Selected',
          ),
          _buildLegendItem(
            context,
            color: AppColors.seatBooked,
            label: 'Booked',
          ),
          _buildLegendItem(
            context,
            color: AppColors.seatLocked,
            label: 'Locked',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, {required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: AppDimens.seatLegendSize,
          height: AppDimens.seatLegendSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimens.radius4),
          ),
        ),
        const SizedBox(width: AppDimens.margin4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDriverSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding24,
        vertical: AppDimens.padding12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimens.radius30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            size: AppDimens.iconSize24,
          ),
          const SizedBox(width: AppDimens.margin8),
          Text(
            'DRIVER',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppFonts.semiBold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSeatRows() {
    final List<Widget> rows = [];
    final layout = widget.seatLayout;

    for (var row in layout['rows'] as List) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.padding8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildSeatsInRow(row),
          ),
        ),
      );
    }

    return rows;
  }

  List<Widget> _buildSeatsInRow(Map<String, dynamic> rowData) {
    final List<Widget> seats = [];
    final rowName = rowData['row'];
    final seatsInRow = rowData['seats'] as List;

    for (var seatData in seatsInRow) {
      final seatNumber = seatData['number'];
      final seatId = '$rowName$seatNumber';
      final seat = _seatMap[seatId];

      if (seat != null) {
        seats.add(
          Padding(
            padding: EdgeInsets.only(
              right: seatData['aisle'] == true ? AppDimens.seatAisleWidth : AppDimens.padding4,
            ),
            child: SeatItem(
              seat: seat,
              isSelected: _isSeatSelected(seat.id),
              onTap: () => _handleSeatTap(seat),
              size: widget.seatSize,
            ),
          ),
        );
      } else {
        // Empty space for layout
        seats.add(
          SizedBox(
            width: widget.seatSize,
            height: widget.seatSize,
          ),
        );
      }
    }

    return seats;
  }
}

class SeatData {
  final String id;
  final String number;
  final String row;
  final int column;
  final String status;
  final double? price;
  final String? passengerName;
  final bool isAvailable;
  final bool isWindow;
  final bool isAisle;
  final Map<String, dynamic>? metadata;

  SeatData({
    required this.id,
    required this.number,
    required this.row,
    required this.column,
    required this.status,
    this.price,
    this.passengerName,
    required this.isAvailable,
    this.isWindow = false,
    this.isAisle = false,
    this.metadata,
  });

  factory SeatData.fromJson(Map<String, dynamic> json) {
    return SeatData(
      id: json['id'],
      number: json['number'],
      row: json['row'],
      column: json['column'],
      status: json['status'],
      price: json['price']?.toDouble(),
      passengerName: json['passengerName'],
      isAvailable: json['isAvailable'] ?? false,
      isWindow: json['isWindow'] ?? false,
      isAisle: json['isAisle'] ?? false,
      metadata: json['metadata'],
    );
  }
}