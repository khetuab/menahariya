// lib/data/models/ticket/seat_model.dart

class SeatModel {
  final String id;
  final String tripId;
  final String number;
  final String row;
  final int column;
  final String status; // available, locked, booked, selected
  final double? price;
  final String? passengerId;
  final String? passengerName;
  final DateTime? lockedUntil;
  final bool isWindow;
  final bool isAisle;
  final bool isExit;
  final Map<String, dynamic>? features;
  final DateTime? bookedAt;

  SeatModel({
    required this.id,
    required this.tripId,
    required this.number,
    required this.row,
    required this.column,
    required this.status,
    this.price,
    this.passengerId,
    this.passengerName,
    this.lockedUntil,
    this.isWindow = false,
    this.isAisle = false,
    this.isExit = false,
    this.features,
    this.bookedAt,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      id: json['_id'] ?? json['id'] ?? '',
      tripId: json['tripId'] ?? '',
      number: json['number'] ?? '',
      row: json['row'] ?? '',
      column: json['column'] ?? 0,
      status: json['status'] ?? 'available',
      price: json['price']?.toDouble(),
      passengerId: json['passengerId'],
      passengerName: json['passengerName'],
      lockedUntil: json['lockedUntil'] != null
          ? DateTime.parse(json['lockedUntil'])
          : null,
      isWindow: json['isWindow'] ?? false,
      isAisle: json['isAisle'] ?? false,
      isExit: json['isExit'] ?? false,
      features: json['features'],
      bookedAt: json['bookedAt'] != null
          ? DateTime.parse(json['bookedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'number': number,
      'row': row,
      'column': column,
      'status': status,
      'price': price,
      'passengerId': passengerId,
      'passengerName': passengerName,
      'lockedUntil': lockedUntil?.toIso8601String(),
      'isWindow': isWindow,
      'isAisle': isAisle,
      'isExit': isExit,
      'features': features,
      'bookedAt': bookedAt?.toIso8601String(),
    };
  }

  // Copy with method
  SeatModel copyWith({
    String? status,
    String? passengerId,
    String? passengerName,
    DateTime? lockedUntil,
    DateTime? bookedAt,
  }) {
    return SeatModel(
      id: id,
      tripId: tripId,
      number: number,
      row: row,
      column: column,
      status: status ?? this.status,
      price: price,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      isWindow: isWindow,
      isAisle: isAisle,
      isExit: isExit,
      features: features,
      bookedAt: bookedAt ?? this.bookedAt,
    );
  }

  // Helper getters
  bool get isAvailable => status == 'available';
  bool get isLocked => status == 'locked';
  bool get isBooked => status == 'booked';
  bool get isSelected => status == 'selected';
}

// Seat Layout Configuration
class SeatLayoutConfig {
  final int rows;
  final int columns;
  final Map<String, dynamic> layout;
  final List<String> windowSeats;
  final List<String> aisleSeats;
  final List<String> exitSeats;

  SeatLayoutConfig({
    required this.rows,
    required this.columns,
    required this.layout,
    required this.windowSeats,
    required this.aisleSeats,
    required this.exitSeats,
  });

  factory SeatLayoutConfig.fromJson(Map<String, dynamic> json) {
    return SeatLayoutConfig(
      rows: json['rows'] ?? 0,
      columns: json['columns'] ?? 0,
      layout: json['layout'] ?? {},
      windowSeats: List<String>.from(json['windowSeats'] ?? []),
      aisleSeats: List<String>.from(json['aisleSeats'] ?? []),
      exitSeats: List<String>.from(json['exitSeats'] ?? []),
    );
  }
}

// Seat Lock Request
class SeatLockRequest {
  final String tripId;
  final List<String> seatNumbers;
  final int durationMinutes;

  SeatLockRequest({
    required this.tripId,
    required this.seatNumbers,
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'seatNumbers': seatNumbers,
      'duration': durationMinutes,
    };
  }
}