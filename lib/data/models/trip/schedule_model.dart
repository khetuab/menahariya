// lib/data/models/trip/schedule_model.dart

import 'package:menahariya/data/models/trip/route_model.dart';
import 'package:menahariya/data/models/vehicle/vehicle_model.dart';

import '../user/user_model.dart';

class ScheduleModel {
  final String id;
  final String routeId;
  final RouteModel? route;
  final String vehicleId;
  final VehicleModel? vehicle;
  final String driverId;
  final UserModel? driver;
  final List<String> operatingDays; // Monday, Tuesday, etc.
  final String departureTime; // HH:MM format
  final String arrivalTime; // HH:MM format
  final double price;
  final bool isActive;
  final DateTime validFrom;
  final DateTime? validUntil;
  final Map<String, dynamic>? exceptions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ScheduleModel({
    required this.id,
    required this.routeId,
    this.route,
    required this.vehicleId,
    this.vehicle,
    required this.driverId,
    this.driver,
    required this.operatingDays,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    this.isActive = true,
    required this.validFrom,
    this.validUntil,
    this.exceptions,
    required this.createdAt,
    this.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['_id'] ?? json['id'] ?? '',
      routeId: json['routeId'] ?? json['route']?['_id'] ?? '',
      route: json['route'] != null ? RouteModel.fromJson(json['route']) : null,
      vehicleId: json['vehicleId'] ?? json['vehicle']?['_id'] ?? '',
      vehicle: json['vehicle'] != null ? VehicleModel.fromJson(json['vehicle']) : null,
      driverId: json['driverId'] ?? json['driver']?['_id'] ?? '',
      driver: json['driver'] != null ? UserModel.fromJson(json['driver']) : null,
      operatingDays: List<String>.from(json['operatingDays'] ?? []),
      departureTime: json['departureTime'] ?? '00:00',
      arrivalTime: json['arrivalTime'] ?? '00:00',
      price: (json['price'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      validFrom: DateTime.parse(json['validFrom'] ?? DateTime.now().toIso8601String()),
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil']) : null,
      exceptions: json['exceptions'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'operatingDays': operatingDays,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'price': price,
      'isActive': isActive,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'exceptions': exceptions,
    };
  }

  // Check if schedule operates on a specific day
  bool operatesOn(DateTime date) {
    final dayName = _getDayName(date.weekday);
    if (!operatingDays.contains(dayName)) return false;

    // Check date range
    if (date.isBefore(validFrom)) return false;
    if (validUntil != null && date.isAfter(validUntil!)) return false;

    // Check exceptions
    if (exceptions != null) {
      final dateStr = date.toIso8601String().split('T')[0];
      if (exceptions!['cancelled']?.contains(dateStr) ?? false) return false;
      if (exceptions!['added']?.contains(dateStr) ?? false) return true;
    }

    return true;
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
}

// Schedule Exception
class ScheduleException {
  final DateTime date;
  final String type; // 'cancelled', 'added', 'modified'
  final String? newDepartureTime;
  final String? newArrivalTime;
  final double? newPrice;
  final String? reason;

  ScheduleException({
    required this.date,
    required this.type,
    this.newDepartureTime,
    this.newArrivalTime,
    this.newPrice,
    this.reason,
  });

  factory ScheduleException.fromJson(Map<String, dynamic> json) {
    return ScheduleException(
      date: DateTime.parse(json['date']),
      type: json['type'],
      newDepartureTime: json['newDepartureTime'],
      newArrivalTime: json['newArrivalTime'],
      newPrice: json['newPrice']?.toDouble(),
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'type': type,
      'newDepartureTime': newDepartureTime,
      'newArrivalTime': newArrivalTime,
      'newPrice': newPrice,
      'reason': reason,
    };
  }
}