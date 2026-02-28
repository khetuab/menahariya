// lib/data/models/ticket/ticket_model.dart

import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/data/models/user/user_model.dart';

class TicketModel {
  final String id;
  final String bookingId;
  final String tripId;
  final TripModel? trip;
  final String passengerId;
  final UserModel? passenger;
  final String passengerName;
  final String passengerPhone;
  final String? passengerEmail;
  final String seatNumber;
  final double price;
  final double? insuranceFee;
  final double? serviceFee;
  final double totalAmount;
  final String paymentStatus;
  final String ticketStatus;
  final String? qrCode;
  final DateTime issuedAt;
  final DateTime departureTime;
  final DateTime? validatedAt;
  final String? validatedBy;
  final bool hasCargo;
  final String? cargoId;
  final Map<String, dynamic>? metadata;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  // Trip details (denormalized for quick access)
  final String origin;
  final String destination;
  final String busType;

  TicketModel({
    required this.id,
    required this.bookingId,
    required this.tripId,
    this.trip,
    required this.passengerId,
    this.passenger,
    required this.passengerName,
    required this.passengerPhone,
    this.passengerEmail,
    required this.seatNumber,
    required this.price,
    this.insuranceFee,
    this.serviceFee,
    required this.totalAmount,
    required this.paymentStatus,
    required this.ticketStatus,
    this.qrCode,
    required this.issuedAt,
    required this.departureTime,
    this.validatedAt,
    this.validatedBy,
    this.hasCargo = false,
    this.cargoId,
    this.metadata,
    this.cancelledAt,
    this.cancellationReason,
    required this.origin,
    required this.destination,
    required this.busType,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['_id'] ?? json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      tripId: json['tripId'] ?? json['trip']?['_id'] ?? '',
      trip: json['trip'] != null ? TripModel.fromJson(json['trip']) : null,
      passengerId: json['passengerId'] ?? json['passenger']?['_id'] ?? '',
      passenger: json['passenger'] != null ? UserModel.fromJson(json['passenger']) : null,
      passengerName: json['passengerName'] ?? json['passenger']?['fullName'] ?? '',
      passengerPhone: json['passengerPhone'] ?? json['passenger']?['phone'] ?? '',
      passengerEmail: json['passengerEmail'] ?? json['passenger']?['email'],
      seatNumber: json['seatNumber'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      insuranceFee: json['insuranceFee']?.toDouble(),
      serviceFee: json['serviceFee']?.toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'pending',
      ticketStatus: json['ticketStatus'] ?? 'issued',
      qrCode: json['qrCode'],
      issuedAt: DateTime.parse(json['issuedAt'] ?? DateTime.now().toIso8601String()),
      departureTime: DateTime.parse(json['departureTime'] ?? DateTime.now().toIso8601String()),
      validatedAt: json['validatedAt'] != null ? DateTime.parse(json['validatedAt']) : null,
      validatedBy: json['validatedBy'],
      hasCargo: json['hasCargo'] ?? false,
      cargoId: json['cargoId'],
      metadata: json['metadata'],
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      cancellationReason: json['cancellationReason'],
      origin: json['origin'] ?? json['trip']?['route']?['origin'] ?? '',
      destination: json['destination'] ?? json['trip']?['route']?['destination'] ?? '',
      busType: json['busType'] ?? json['trip']?['vehicle']?['type'] ?? 'Standard',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'tripId': tripId,
      'passengerId': passengerId,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'passengerEmail': passengerEmail,
      'seatNumber': seatNumber,
      'price': price,
      'insuranceFee': insuranceFee,
      'serviceFee': serviceFee,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'ticketStatus': ticketStatus,
      'qrCode': qrCode,
      'issuedAt': issuedAt.toIso8601String(),
      'departureTime': departureTime.toIso8601String(),
      'hasCargo': hasCargo,
      'cargoId': cargoId,
      'metadata': metadata,
      'origin': origin,
      'destination': destination,
      'busType': busType,
    };
  }

  // Copy with method
  TicketModel copyWith({
    String? ticketStatus,
    DateTime? validatedAt,
    String? validatedBy,
    String? paymentStatus,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return TicketModel(
      id: id,
      bookingId: bookingId,
      tripId: tripId,
      trip: trip,
      passengerId: passengerId,
      passenger: passenger,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      passengerEmail: passengerEmail,
      seatNumber: seatNumber,
      price: price,
      insuranceFee: insuranceFee,
      serviceFee: serviceFee,
      totalAmount: totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      ticketStatus: ticketStatus ?? this.ticketStatus,
      qrCode: qrCode,
      issuedAt: issuedAt,
      departureTime: departureTime,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
      hasCargo: hasCargo,
      cargoId: cargoId,
      metadata: metadata,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      origin: origin,
      destination: destination,
      busType: busType,
    );
  }

  // Helper getters
  bool get isValid => ticketStatus == 'issued' || ticketStatus == 'paid';
  bool get isUsed => ticketStatus == 'used';
  bool get isCancelled => ticketStatus == 'cancelled';
  String get status => ticketStatus;
  bool get isRefundable {
    if (isCancelled || isUsed) return false;
    final now = DateTime.now();
    final hoursUntilDeparture = departureTime.difference(now).inHours;
    return hoursUntilDeparture > 2; // Refundable up to 2 hours before
  }
}

// Ticket Validation Result
class TicketValidationResult {
  final bool isValid;
  final String message;
  final TicketModel? ticket;
  final DateTime timestamp;

  TicketValidationResult({
    required this.isValid,
    required this.message,
    this.ticket,
    required this.timestamp,
  });

  factory TicketValidationResult.fromJson(Map<String, dynamic> json) {
    return TicketValidationResult(
      isValid: json['valid'] ?? false,
      message: json['message'] ?? '',
      ticket: json['ticket'] != null ? TicketModel.fromJson(json['ticket']) : null,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}