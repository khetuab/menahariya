// lib/data/models/booking/booking_model.dart

import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';

import '../trip/route_model.dart';

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

    // Parse passenger details
    List<PassengerDetail> passengers = [];

    if (json['passengerDetails'] != null) {
      if (json['passengerDetails'] is List) {
        passengers = (json['passengerDetails'] as List)
            .map((p) => PassengerDetail.fromJson(p as Map<String, dynamic>))
            .toList();
        print('✅ Parsed ${passengers.length} passenger details from List');
      } else if (json['passengerDetails'] is Map) {
        final map = json['passengerDetails'] as Map<String, dynamic>;
        if (map.containsKey('passengers') && map['passengers'] is List) {
          passengers = (map['passengers'] as List)
              .map((p) => PassengerDetail.fromJson(p as Map<String, dynamic>))
              .toList();
        } else {
          passengers = [PassengerDetail.fromJson(map)];
        }
      }
    }

    // Parse seat numbers
    List<String> seatNumbers = [];
    if (json['seatNumbers'] != null) {
      if (json['seatNumbers'] is List) {
        seatNumbers = List<String>.from(json['seatNumbers'].map((s) => s.toString()));
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
        if (date is String) {
          return DateTime.parse(date);
        }
        return DateTime.now();
      } catch (e) {
        print('⚠️ Error parsing date: $date - $e');
        return DateTime.now();
      }
    }

    // CRITICAL FIX: Parse trip data correctly
    TripModel? trip;

// Check if there's a 'trip' field in the response (from backend transformation)
    if (json['trip'] != null) {
      print('🔍 Found trip field in response');
      try {
        trip = TripModel.fromJson(json['trip']);
        print('✅ Parsed trip from trip field - origin: ${trip?.origin}, destination: ${trip?.destination}');
      } catch (e, stackTrace) {
        print('❌ Error parsing trip from trip field: $e');
        print('Stack trace: $stackTrace');
      }
    }
// Fallback: check if tripId is populated with route data
    else if (json['tripId'] != null && json['tripId'] is Map) {
      print('🔍 tripId is a populated object');
      try {
        trip = TripModel.fromJson(json['tripId']);
        print('✅ Parsed trip from tripId - origin: ${trip?.origin}, destination: ${trip?.destination}');
      } catch (e, stackTrace) {
        print('❌ Error parsing trip from tripId: $e');
        print('Stack trace: $stackTrace');
      }
    }
    // Last fallback: try to extract from various possible structures
    else {
      print('⚠️ No trip object found, trying to extract from other fields');
      // Try to build a simple trip object from available data
      String origin = '';
      String destination = '';
      DateTime? departureTime;
      DateTime? arrivalTime;
      double price = 0;

      // Extract from nested routeId if available
      if (json['tripId'] != null && json['tripId'] is Map) {
        var tripData = json['tripId'] as Map;
        if (tripData['routeId'] != null && tripData['routeId'] is Map) {
          var routeData = tripData['routeId'] as Map;
          origin = routeData['origin']?.toString() ?? '';
          destination = routeData['destination']?.toString() ?? '';
        }
        departureTime = tripData['departureTime'] != null ? parseDate(tripData['departureTime']) : null;
        arrivalTime = tripData['arrivalTime'] != null ? parseDate(tripData['arrivalTime']) : null;
        price = (tripData['price'] ?? 0).toDouble();
      }

      if (origin.isNotEmpty && destination.isNotEmpty) {
        // Create a minimal TripModel
        trip = TripModel(
          id: json['tripId'] is Map ? (json['tripId']['_id']?.toString() ?? '') : '',
          routeId: '',
          route: RouteModel(
            id: '',
            name: '$origin to $destination',
            origin: origin,
            destination: destination,
            distance: 0,
            duration: 0,
            basePrice: price,
            createdAt: DateTime.now(),
          ),
          vehicleId: '',
          driverId: '',
          departureTime: departureTime ?? DateTime.now(),
          arrivalTime: arrivalTime ?? DateTime.now(),
          price: price,
          availableSeats: 0,
          totalSeats: 0,
          status: 'scheduled',
          amenities: const [],
          createdAt: DateTime.now(),
        );
        print('✅ Created fallback trip - origin: $origin, destination: $destination');
      }
    }

    return BookingModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId'] is Map
          ? (json['userId']['_id']?.toString() ?? '')
          : (json['userId']?.toString() ?? ''),
      tripId: json['tripId'] is Map
          ? (json['tripId']['_id']?.toString() ?? '')
          : (json['tripId']?.toString() ?? ''),
      trip: trip,
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