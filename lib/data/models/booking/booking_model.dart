// lib/data/models/booking/booking_model.dart

import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';

// Add a PassengerDetail class to properly handle passenger data
class PassengerDetail {
  final String? id;
  final String? name;
  final String? phone;
  final String? email;
  final String seatNumber;
  final Map<String, dynamic>? metadata;

  PassengerDetail({
    this.id,
    this.name,
    this.phone,
    this.email,
    required this.seatNumber,
    this.metadata,
  });

  factory PassengerDetail.fromJson(Map<String, dynamic> json) {
    return PassengerDetail(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      seatNumber: json['seatNumber']?.toString() ?? '',
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'seatNumber': seatNumber,
    };
    if (id != null) json['_id'] = id;
    if (name != null && name!.isNotEmpty) json['name'] = name;
    if (phone != null && phone!.isNotEmpty) json['phone'] = phone;
    if (email != null && email!.isNotEmpty) json['email'] = email;
    if (metadata != null) json['metadata'] = metadata;
    return json;
  }
}

class BookingModel {
  final String id;
  final String userId;
  final String tripId;
  final TripModel? trip;
  final List<String> seatNumbers;
  final List<TicketModel>? tickets;
  final List<PassengerDetail> passengerDetails; // Changed from Map to List
  final double totalAmount;
  final double? insuranceFee;
  final double? serviceFee;
  final String paymentStatus;
  final String bookingStatus;
  final DateTime bookingDate;
  final DateTime? expiryDate;
  final DateTime? paymentDeadline;
  final bool insuranceSelected;
  final List<String>? mealPreferences;
  final String? specialRequests;
  final String? paymentMethod;
  final String? transactionId;
  final String? reference;
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
    required this.passengerDetails, // Now required
    required this.totalAmount,
    this.insuranceFee,
    this.serviceFee,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.bookingDate,
    this.expiryDate,
    this.paymentDeadline,
    this.insuranceSelected = false,
    this.mealPreferences,
    this.specialRequests,
    this.paymentMethod,
    this.transactionId,
    this.reference,
    this.cancelledAt,
    this.cancellationReason,
    this.metadata,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    print('📦 Parsing BookingModel from JSON');

    // Parse passenger details - handle both List and Map formats
    List<PassengerDetail> passengers = [];

    if (json['passengerDetails'] != null) {
      if (json['passengerDetails'] is List) {
        // Handle List format (what the server returns)
        passengers = (json['passengerDetails'] as List)
            .map((p) => PassengerDetail.fromJson(p as Map<String, dynamic>))
            .toList();
        print('✅ Parsed ${passengers.length} passenger details from List');
      } else if (json['passengerDetails'] is Map) {
        // Handle Map format (old format)
        final map = json['passengerDetails'] as Map<String, dynamic>;
        // Try to extract passengers from map or create a single passenger
        if (map.containsKey('passengers') && map['passengers'] is List) {
          passengers = (map['passengers'] as List)
              .map((p) => PassengerDetail.fromJson(p as Map<String, dynamic>))
              .toList();
        } else {
          // Single passenger object
          passengers = [PassengerDetail.fromJson(map)];
        }
        print('✅ Parsed ${passengers.length} passenger details from Map');
      }
    }

    // Parse seat numbers
    List<String> seatNumbers = [];
    if (json['seatNumbers'] != null) {
      if (json['seatNumbers'] is List) {
        seatNumbers = List<String>.from(json['seatNumbers']);
      } else if (json['seatNumbers'] is String) {
        seatNumbers = [json['seatNumbers'] as String];
      }
    }

    // Parse dates safely
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      try {
        if (date is Map && date.containsKey('\$date')) {
          return DateTime.parse(date['\$date'].toString());
        }
        return DateTime.parse(date.toString());
      } catch (e) {
        print('⚠️ Error parsing date: $date - $e');
        return DateTime.now();
      }
    }

    return BookingModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? json['trip']?['_id']?.toString() ?? '',
      trip: json['trip'] != null ? TripModel.fromJson(json['trip']) : null,
      seatNumbers: seatNumbers,
      tickets: json['tickets'] != null
          ? (json['tickets'] as List)
          .map((t) => TicketModel.fromJson(t))
          .toList()
          : null,
      passengerDetails: passengers,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      insuranceFee: json['insuranceFee']?.toDouble(),
      serviceFee: json['serviceFee']?.toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'pending',
      bookingStatus: json['bookingStatus'] ?? 'pending',
      bookingDate: parseDate(json['bookingDate'] ?? json['createdAt']),
      expiryDate: json['expiryDate'] != null ? parseDate(json['expiryDate']) : null,
      paymentDeadline: json['paymentDeadline'] != null ? parseDate(json['paymentDeadline']) : null,
      insuranceSelected: json['insuranceSelected'] ?? false,
      mealPreferences: json['mealPreferences'] != null
          ? List<String>.from(json['mealPreferences'])
          : null,
      specialRequests: json['specialRequests']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      transactionId: json['transactionId']?.toString(),
      reference: json['reference']?.toString(),
      cancelledAt: json['cancelledAt'] != null ? parseDate(json['cancelledAt']) : null,
      cancellationReason: json['cancellationReason']?.toString(),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tripId': tripId,
      'seatNumbers': seatNumbers,
      'passengerDetails': passengerDetails.map((p) => p.toJson()).toList(),
      'totalAmount': totalAmount,
      'insuranceFee': insuranceFee,
      'serviceFee': serviceFee,
      'paymentStatus': paymentStatus,
      'bookingStatus': bookingStatus,
      'bookingDate': bookingDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'paymentDeadline': paymentDeadline?.toIso8601String(),
      'insuranceSelected': insuranceSelected,
      'mealPreferences': mealPreferences,
      'specialRequests': specialRequests,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'reference': reference,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'metadata': metadata,
    };
  }

  // Helper getters
  bool get isPending => bookingStatus == 'pending';
  bool get isConfirmed => bookingStatus == 'confirmed';
  bool get isCancelled => bookingStatus == 'cancelled';
  bool get isExpired => bookingStatus == 'expired' || (expiryDate != null && expiryDate!.isBefore(DateTime.now()));

  bool get isPaid => paymentStatus == 'paid' || paymentStatus == 'completed';
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentFailed => paymentStatus == 'failed';

  int get passengerCount => passengerDetails.length;

  String get passengerNames {
    return passengerDetails.map((p) => p.name ?? 'Unknown').join(', ');
  }

  List<String> get passengerSeatNumbers {
    return passengerDetails.map((p) => p.seatNumber).toList();
  }
}