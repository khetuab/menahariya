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
  late Map<String, List<SeatData>> _seatsByRow;

  @override
  void initState() {
    super.initState();
    _selectedSeats = widget.initiallySelectedSeats ?? [];
    _buildSeatMap();
  }

  void _buildSeatMap() {
    _seatsByRow = {};

    for (var seat in widget.seats) {
      _seatMap[seat.id] = seat;

      // Group seats by row
      if (!_seatsByRow.containsKey(seat.row)) {
        _seatsByRow[seat.row] = [];
      }
      _seatsByRow[seat.row]!.add(seat);
    }

    // Sort seats in each row by column
    _seatsByRow.forEach((row, seats) {
      seats.sort((a, b) => a.column.compareTo(b.column));
    });

    print('🎯 SeatMap initialized with ${widget.seats.length} seats');
    print('📊 Rows found: ${_seatsByRow.keys.length}');
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

    print('🎯 Building SeatMap with ${_seatsByRow.length} rows');

    if (widget.seats.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.event_seat_rounded,
              size: 48,
              color: isDark ? AppColors.grey600 : AppColors.grey400,
            ),
            const SizedBox(height: AppDimens.margin8),
            Text(
              'No seats available',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

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

    // Get sorted row keys
    final sortedRows = _seatsByRow.keys.toList()..sort();

    print('📊 Building ${sortedRows.length} rows');

    // Determine max columns for consistent spacing
    int maxColumns = 4; // Default
    if (widget.seats.isNotEmpty) {
      maxColumns = widget.seats.map((s) => s.column).reduce((a, b) => a > b ? a : b);
    }

    for (var rowName in sortedRows) {
      final rowSeats = _seatsByRow[rowName]!;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.padding8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildSeatsInRow(rowName, rowSeats, maxColumns),
          ),
        ),
      );

      // Add row label on the side
      rows.add(
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Row(
            children: [
              Container(
                width: 20,
                alignment: Alignment.centerLeft,
                child: Text(
                  rowName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  List<Widget> _buildSeatsInRow(String rowName, List<SeatData> rowSeats, int totalColumns) {
    final List<Widget> seats = [];

    // Create a map of column -> seat for quick lookup
    final Map<int, SeatData> columnSeatMap = {};
    for (var seat in rowSeats) {
      columnSeatMap[seat.column] = seat;
    }

    // Build seats for all columns
    for (int col = 1; col <= totalColumns; col++) {
      final seat = columnSeatMap[col];

      if (seat != null) {
        // Add aisle spacing for middle columns
        final bool isAisle = col == 2 || col == 3;

        seats.add(
          Padding(
            padding: EdgeInsets.only(
              right: isAisle ? AppDimens.seatAisleWidth : AppDimens.padding4,
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
        // Empty space for missing seat (shouldn't happen with proper data)
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
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      row: json['row']?.toString() ?? '',
      column: json['column'] is int ? json['column'] : int.tryParse(json['column']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'available',
      price: json['price'] != null ? (json['price'] is int ? (json['price'] as int).toDouble() : json['price']?.toDouble()) : null,
      passengerName: json['passengerName']?.toString(),
      isAvailable: json['status'] == 'available',
      isWindow: json['isWindow'] ?? false,
      isAisle: json['isAisle'] ?? false,
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }
}