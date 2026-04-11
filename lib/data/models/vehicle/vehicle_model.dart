// lib/data/models/vehicle/vehicle_model.dart

import '../user/user_model.dart';

class VehicleModel {
  final String id;
  final String plateNumber;
  final String model;
  final String type;
  final int capacity;
  final double? cargoCapacity;
  final List<String> amenities;
  final String status;
  final dynamic driverId; // Change from String? to dynamic
  final UserModel? driver; // Add this for populated driver
  final DateTime? lastMaintenance;
  final DateTime? nextMaintenance;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.plateNumber,
    required this.model,
    required this.type,
    required this.capacity,
    this.cargoCapacity,
    required this.amenities,
    required this.status,
    this.driverId,
    this.driver,
    this.lastMaintenance,
    this.nextMaintenance,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Parse driverId - could be String or Map
    dynamic driverIdValue = json['driverId'];
    UserModel? driver;
    String? driverIdString;

    if (driverIdValue is Map<String, dynamic>) {
      // It's a populated driver object
      driver = UserModel.fromJson(driverIdValue);
      driverIdString = driverIdValue['_id'];
    } else if (driverIdValue is String) {
      // It's just an ID string
      driverIdString = driverIdValue;
    }

    return VehicleModel(
      id: json['_id'] ?? json['id'],
      plateNumber: json['plateNumber'] ?? '',
      model: json['model'] ?? '',
      type: json['type'] ?? 'Standard',
      capacity: json['capacity'] ?? 0,
      cargoCapacity: (json['cargoCapacity'] ?? 0).toDouble(),
      amenities: List<String>.from(json['amenities'] ?? []),
      status: json['status'] ?? 'active',
      driverId: driverIdString,
      driver: driver,
      lastMaintenance: json['lastMaintenance'] != null
          ? DateTime.parse(json['lastMaintenance'])
          : null,
      nextMaintenance: json['nextMaintenance'] != null
          ? DateTime.parse(json['nextMaintenance'])
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Helper getters
  bool get isAvailable => status == 'active' && isActive;
  String get driverName => driver?.fullName ?? 'Not Assigned';
  String get driverPhone => driver?.phone ?? 'N/A';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'model': model,
      'type': type,
      'capacity': capacity,
      'cargoCapacity': cargoCapacity,
      'amenities': amenities,
      'status': status,
      'driverId': driverId,
      'lastMaintenance': lastMaintenance?.toIso8601String(),
      'nextMaintenance': nextMaintenance?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}