// lib/data/models/booking/booking_model.dart

import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String tripId;
  final TripModel? trip;
  final List<String> seatNumbers;
  final List<TicketModel>? tickets;
  final double totalAmount;
  final String paymentStatus;
  final String bookingStatus;
  final DateTime bookingDate;
  final DateTime? expiryDate;
  final Map<String, dynamic>? passengerDetails;
  final bool insuranceSelected;
  final List<String>? mealPreferences;
  final String? specialRequests;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final Map<String, dynamic>? metadata;

  BookingModel({
    required this.id,
    required this.userId,
    required this.tripId,
    this.trip,
    required this.seatNumbers,
    this.tickets,
    required this.totalAmount,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.bookingDate,
    this.expiryDate,
    this.passengerDetails,
    this.insuranceSelected = false,
    this.mealPreferences,
    this.specialRequests,
    this.cancelledAt,
    this.cancellationReason,
    this.metadata,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      tripId: json['tripId'] ?? json['trip']?['_id'] ?? '',
      trip: json['trip'] != null ? TripModel.fromJson(json['trip']) : null,
      seatNumbers: List<String>.from(json['seatNumbers'] ?? []),
      tickets: json['tickets'] != null
          ? (json['tickets'] as List)
          .map((t) => TicketModel.fromJson(t))
          .toList()
          : null,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'pending',
      bookingStatus: json['bookingStatus'] ?? 'pending',
      bookingDate: DateTime.parse(json['bookingDate'] ?? DateTime.now().toIso8601String()),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      passengerDetails: json['passengerDetails'],
      insuranceSelected: json['insuranceSelected'] ?? false,
      mealPreferences: json['mealPreferences'] != null
          ? List<String>.from(json['mealPreferences'])
          : null,
      specialRequests: json['specialRequests'],
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      cancellationReason: json['cancellationReason'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tripId': tripId,
      'seatNumbers': seatNumbers,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'bookingStatus': bookingStatus,
      'bookingDate': bookingDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'passengerDetails': passengerDetails,
      'insuranceSelected': insuranceSelected,
      'mealPreferences': mealPreferences,
      'specialRequests': specialRequests,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'metadata': metadata,
    };
  }

  // Helper getters
  bool get isPending => bookingStatus == 'pending';
  bool get isConfirmed => bookingStatus == 'confirmed';
  bool get isCancelled => bookingStatus == 'cancelled';
  bool get isExpired => bookingStatus == 'expired';

  bool get isPaid => paymentStatus == 'paid' || paymentStatus == 'completed';
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentFailed => paymentStatus == 'failed';
}