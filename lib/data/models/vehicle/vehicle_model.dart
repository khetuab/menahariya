// lib/data/models/vehicle/vehicle_model.dart

import '../user/user_model.dart';

class VehicleModel {
  final String id;
  final String plateNumber;
  final String model;
  final String type; // Standard, Executive, VIP, Luxury
  final int capacity;
  final int? cargoCapacity; // in kg
  final List<String> amenities;
  final Map<String, dynamic>? seatLayout;
  final List<String>? images;
  final String status; // active, maintenance, inactive
  final String? driverId;
  final UserModel? driver;
  final DateTime? lastMaintenance;
  final DateTime? nextMaintenance;
  final Map<String, dynamic>? specifications;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VehicleModel({
    required this.id,
    required this.plateNumber,
    required this.model,
    required this.type,
    required this.capacity,
    this.cargoCapacity,
    this.amenities = const [],
    this.seatLayout,
    this.images,
    required this.status,
    this.driverId,
    this.driver,
    this.lastMaintenance,
    this.nextMaintenance,
    this.specifications,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['_id'] ?? json['id'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      model: json['model'] ?? '',
      type: json['type'] ?? 'Standard',
      capacity: json['capacity'] ?? 0,
      cargoCapacity: json['cargoCapacity'],
      amenities: List<String>.from(json['amenities'] ?? []),
      seatLayout: json['seatLayout'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      status: json['status'] ?? 'active',
      driverId: json['driverId'] ?? json['driver']?['_id'],
      driver: json['driver'] != null ? UserModel.fromJson(json['driver']) : null,
      lastMaintenance: json['lastMaintenance'] != null
          ? DateTime.parse(json['lastMaintenance'])
          : null,
      nextMaintenance: json['nextMaintenance'] != null
          ? DateTime.parse(json['nextMaintenance'])
          : null,
      specifications: json['specifications'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plateNumber': plateNumber,
      'model': model,
      'type': type,
      'capacity': capacity,
      'cargoCapacity': cargoCapacity,
      'amenities': amenities,
      'seatLayout': seatLayout,
      'images': images,
      'status': status,
      'driverId': driverId,
      'lastMaintenance': lastMaintenance?.toIso8601String(),
      'nextMaintenance': nextMaintenance?.toIso8601String(),
      'specifications': specifications,
      'isActive': isActive,
    };
  }

  // Helper getters
  bool get isAvailable => status == 'active' && isActive;
  bool get needsMaintenance {
    if (nextMaintenance == null) return false;
    return DateTime.now().isAfter(nextMaintenance!);
  }
}