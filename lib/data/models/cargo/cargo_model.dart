// lib/data/models/cargo/cargo_model.dart

import '../trip/trip_model.dart';

class CargoModel {
  final String id;
  final String trackingCode;
  final String tripId;
  final TripModel? trip;
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String cargoType;
  final double weight;
  final String? dimensions;
  final String? description;
  final double? declaredValue;
  final double fee;
  final bool isFragile;
  final bool isPerishable;
  final bool needsRefrigeration;
  final String status; // registered, loaded, in_transit, delivered, cancelled
  final String? location;
  final DateTime registeredDate;
  final DateTime? loadedDate;
  final DateTime? inTransitDate;
  final DateTime? deliveredDate;
  final DateTime? cancelledDate;
  final String? notes;
  final Map<String, dynamic>? metadata;

  // Denormalized fields
  final String origin;
  final String destination;
  final DateTime departureTime;

  CargoModel({
    required this.id,
    required this.trackingCode,
    required this.tripId,
    this.trip,
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.cargoType,
    required this.weight,
    this.dimensions,
    this.description,
    this.declaredValue,
    required this.fee,
    this.isFragile = false,
    this.isPerishable = false,
    this.needsRefrigeration = false,
    required this.status,
    this.location,
    required this.registeredDate,
    this.loadedDate,
    this.inTransitDate,
    this.deliveredDate,
    this.cancelledDate,
    this.notes,
    this.metadata,
    required this.origin,
    required this.destination,
    required this.departureTime,
  });

  factory CargoModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely extract tripId whether it's a string or object
    String extractTripId(dynamic tripField) {
      if (tripField == null) return '';
      if (tripField is String) return tripField;
      if (tripField is Map<String, dynamic>) {
        // If it's a populated trip object, extract its ID
        if (tripField.containsKey('_id')) {
          return tripField['_id']?.toString() ?? '';
        }
        if (tripField.containsKey('id')) {
          return tripField['id']?.toString() ?? '';
        }
      }
      return tripField.toString();
    }

    // Helper function to safely parse dates
    DateTime parseDate(dynamic dateField, {DateTime? fallback}) {
      if (dateField == null) return fallback ?? DateTime.now();
      try {
        if (dateField is DateTime) return dateField;
        if (dateField is String) return DateTime.parse(dateField);
        if (dateField is Map && dateField.containsKey('\$date')) {
          return DateTime.parse(dateField['\$date'].toString());
        }
      } catch (e) {
        print('⚠️ Error parsing date: $dateField');
      }
      return fallback ?? DateTime.now();
    }

    // Extract trip data - could be string or object
    dynamic tripData = json['tripId'] ?? json['trip'];
    String extractedTripId = extractTripId(tripData);

    // Parse trip if it's a full object
    TripModel? parsedTrip;
    if (tripData is Map<String, dynamic> && tripData.isNotEmpty) {
      try {
        parsedTrip = TripModel.fromJson(tripData);
      } catch (e) {
        print('⚠️ Error parsing trip data: $e');
      }
    }

    // Extract origin/destination from various possible locations
    String origin = json['origin'] ?? '';
    String destination = json['destination'] ?? '';
    DateTime departureTime = parseDate(json['departureTime']);

    // If we have a parsed trip, use its data as fallback
    if (parsedTrip != null) {
      if (origin.isEmpty) origin = parsedTrip.origin;
      if (destination.isEmpty) destination = parsedTrip.destination;
      if (json['departureTime'] == null) departureTime = parsedTrip.departureTime;
    }

    return CargoModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      trackingCode: json['trackingCode']?.toString() ?? '',
      tripId: extractedTripId,
      trip: parsedTrip,
      senderName: json['senderName']?.toString() ?? '',
      senderPhone: json['senderPhone']?.toString() ?? '',
      receiverName: json['receiverName']?.toString() ?? '',
      receiverPhone: json['receiverPhone']?.toString() ?? '',
      cargoType: json['cargoType']?.toString() ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      dimensions: json['dimensions']?.toString(),
      description: json['description']?.toString(),
      declaredValue: json['declaredValue']?.toDouble(),
      fee: (json['fee'] ?? 0).toDouble(),
      isFragile: json['isFragile'] ?? false,
      isPerishable: json['isPerishable'] ?? false,
      needsRefrigeration: json['needsRefrigeration'] ?? false,
      status: json['status']?.toString() ?? 'registered',
      location: json['location']?.toString(),
      registeredDate: parseDate(json['registeredDate'] ?? json['createdAt']),
      loadedDate: json['loadedDate'] != null ? parseDate(json['loadedDate']) : null,
      inTransitDate: json['inTransitDate'] != null ? parseDate(json['inTransitDate']) : null,
      deliveredDate: json['deliveredDate'] != null ? parseDate(json['deliveredDate']) : null,
      cancelledDate: json['cancelledDate'] != null ? parseDate(json['cancelledDate']) : null,
      notes: json['notes']?.toString(),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
      origin: origin,
      destination: destination,
      departureTime: departureTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackingCode': trackingCode,
      'tripId': tripId,
      'senderName': senderName,
      'senderPhone': senderPhone,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'cargoType': cargoType,
      'weight': weight,
      'dimensions': dimensions,
      'description': description,
      'declaredValue': declaredValue,
      'fee': fee,
      'isFragile': isFragile,
      'isPerishable': isPerishable,
      'needsRefrigeration': needsRefrigeration,
      'status': status,
      'location': location,
      'registeredDate': registeredDate.toIso8601String(),
      'loadedDate': loadedDate?.toIso8601String(),
      'inTransitDate': inTransitDate?.toIso8601String(),
      'deliveredDate': deliveredDate?.toIso8601String(),
      'cancelledDate': cancelledDate?.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
      'origin': origin,
      'destination': destination,
      'departureTime': departureTime.toIso8601String(),
    };
  }

  // Copy with method
  CargoModel copyWith({
    String? status,
    String? location,
    DateTime? loadedDate,
    DateTime? inTransitDate,
    DateTime? deliveredDate,
    DateTime? cancelledDate,
  }) {
    return CargoModel(
      id: id,
      trackingCode: trackingCode,
      tripId: tripId,
      trip: trip,
      senderName: senderName,
      senderPhone: senderPhone,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      cargoType: cargoType,
      weight: weight,
      dimensions: dimensions,
      description: description,
      declaredValue: declaredValue,
      fee: fee,
      isFragile: isFragile,
      isPerishable: isPerishable,
      needsRefrigeration: needsRefrigeration,
      status: status ?? this.status,
      location: location ?? this.location,
      registeredDate: registeredDate,
      loadedDate: loadedDate ?? this.loadedDate,
      inTransitDate: inTransitDate ?? this.inTransitDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      cancelledDate: cancelledDate ?? this.cancelledDate,
      notes: notes,
      metadata: metadata,
      origin: origin,
      destination: destination,
      departureTime: departureTime,
    );
  }

  // Helper getters
  bool get isRegistered => status == 'registered';
  bool get isLoaded => status == 'loaded';
  bool get isInTransit => status == 'in_transit';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  String get formattedFee => fee.toStringAsFixed(2);

  String get statusText {
    switch (status) {
      case 'registered':
        return 'Registered';
      case 'loaded':
        return 'Loaded';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

// Cargo Tracking Update
class CargoTrackingUpdate {
  final String cargoId;
  final String status;
  final String location;
  final String description;
  final DateTime timestamp;

  CargoTrackingUpdate({
    required this.cargoId,
    required this.status,
    required this.location,
    required this.description,
    required this.timestamp,
  });

  factory CargoTrackingUpdate.fromJson(Map<String, dynamic> json) {
    return CargoTrackingUpdate(
      cargoId: json['cargoId'] ?? '',
      status: json['status'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}