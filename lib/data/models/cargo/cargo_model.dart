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
    return CargoModel(
      id: json['_id'] ?? json['id'] ?? '',
      trackingCode: json['trackingCode'] ?? '',
      tripId: json['tripId'] ?? json['trip']?['_id'] ?? '',
      trip: json['trip'] != null ? TripModel.fromJson(json['trip']) : null,
      senderName: json['senderName'] ?? '',
      senderPhone: json['senderPhone'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      cargoType: json['cargoType'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      dimensions: json['dimensions'],
      description: json['description'],
      declaredValue: json['declaredValue']?.toDouble(),
      fee: (json['fee'] ?? 0).toDouble(),
      isFragile: json['isFragile'] ?? false,
      isPerishable: json['isPerishable'] ?? false,
      needsRefrigeration: json['needsRefrigeration'] ?? false,
      status: json['status'] ?? 'registered',
      location: json['location'],
      registeredDate: DateTime.parse(json['registeredDate'] ?? DateTime.now().toIso8601String()),
      loadedDate: json['loadedDate'] != null ? DateTime.parse(json['loadedDate']) : null,
      inTransitDate: json['inTransitDate'] != null ? DateTime.parse(json['inTransitDate']) : null,
      deliveredDate: json['deliveredDate'] != null ? DateTime.parse(json['deliveredDate']) : null,
      cancelledDate: json['cancelledDate'] != null ? DateTime.parse(json['cancelledDate']) : null,
      notes: json['notes'],
      metadata: json['metadata'],
      origin: json['origin'] ?? json['trip']?['route']?['origin'] ?? '',
      destination: json['destination'] ?? json['trip']?['route']?['destination'] ?? '',
      departureTime: DateTime.parse(json['departureTime'] ?? json['trip']?['departureTime'] ?? DateTime.now().toIso8601String()),
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