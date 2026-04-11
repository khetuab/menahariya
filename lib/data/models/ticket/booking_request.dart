// lib/data/models/ticket/booking_request.dart

import 'package:menahariya/data/models/ticket/ticket_model.dart';

class BookingRequest {
  final String tripId;
  final List<String> seatNumbers;
  final List<PassengerDetail> passengers;
  final double totalAmount;
  final String? paymentMethod;
  final String? specialRequests;
  final bool useWalletBalance;
  final bool insuranceSelected;
  final List<String>? mealPreferences;

  BookingRequest({
    required this.tripId,
    required this.seatNumbers,
    required this.passengers,
    required this.totalAmount,
    this.paymentMethod,
    this.specialRequests,
    this.useWalletBalance = false,
    this.insuranceSelected = false,
    this.mealPreferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'seatNumbers': seatNumbers,
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'specialRequests': specialRequests,
      'useWalletBalance': useWalletBalance,
      'insuranceSelected': insuranceSelected,
      'mealPreferences': mealPreferences,
    };
  }
}

class PassengerDetail {
  final String? name;
  final String? phone;
  final String? email;
  final String seatNumber;

  PassengerDetail({
    this.name,
    this.phone,
    this.email,
    required this.seatNumber,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'seatNumber': seatNumber,
    };

    if (name != null && name!.isNotEmpty) json['name'] = name;
    if (phone != null && phone!.isNotEmpty) json['phone'] = phone;
    if (email != null && email!.isNotEmpty) json['email'] = email;

    return json;
  }
}

// Booking Cancellation Request
class BookingCancellationRequest {
  final String bookingId;
  final String reason;
  final List<String>? ticketIds;

  BookingCancellationRequest({
    required this.bookingId,
    required this.reason,
    this.ticketIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'reason': reason,
      'ticketIds': ticketIds,
    };
  }
}

// Booking Confirmation Response
class BookingConfirmation {
  final String bookingId;
  final List<TicketModel> tickets;
  final double totalAmount;
  final DateTime expiresAt;

  BookingConfirmation({
    required this.bookingId,
    required this.tickets,
    required this.totalAmount,
    required this.expiresAt,
  });

  factory BookingConfirmation.fromJson(Map<String, dynamic> json) {
    return BookingConfirmation(
      bookingId: json['bookingId'] ?? '',
      tickets: (json['tickets'] as List)
          .map((t) => TicketModel.fromJson(t))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      expiresAt: DateTime.parse(json['expiresAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}