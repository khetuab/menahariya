// lib/data/models/trip/trip_model.dart

import 'package:menahariya/data/models/trip/route_model.dart';
import 'package:menahariya/data/models/vehicle/vehicle_model.dart';

import '../user/user_model.dart';

class TripModel {
  final String id;
  final String routeId;
  final RouteModel? route;
  final String vehicleId;
  final VehicleModel? vehicle;
  final String driverId;
  final UserModel? driver;
  late final DateTime departureTime;
  late final DateTime arrivalTime;
  final double price;
  final int availableSeats;
  final int totalSeats;
  late final String status;
  final List<String> amenities;
  final Map<String, dynamic>? seatLayout;
  final double? cargoCapacity;
  final double? currentCargoWeight;
  final int? passengerCount;
  final int? cargoCount;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  // Computed fields
  String get origin => route?.origin ?? '';
  String get destination => route?.destination ?? '';
  String get routeName => route?.name ?? '$origin → $destination';
  String get busType => vehicle?.type ?? 'Standard';
  int get maxSeatsPerBooking => 10; // Can be configured per trip

  TripModel({
    required this.id,
    required this.routeId,
    this.route,
    required this.vehicleId,
    this.vehicle,
    required this.driverId,
    this.driver,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.availableSeats,
    required this.totalSeats,
    required this.status,
    this.amenities = const [],
    this.seatLayout,
    this.cargoCapacity,
    this.currentCargoWeight,
    this.passengerCount,
    this.cargoCount,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['_id'] ?? json['id'] ?? '',
      routeId: json['routeId'] ?? json['route']?['_id'] ?? '',
      route: json['route'] != null ? RouteModel.fromJson(json['route']) : null,
      vehicleId: json['vehicleId'] ?? json['vehicle']?['_id'] ?? '',
      vehicle: json['vehicle'] != null ? VehicleModel.fromJson(json['vehicle']) : null,
      driverId: json['driverId'] ?? json['driver']?['_id'] ?? '',
      driver: json['driver'] != null ? UserModel.fromJson(json['driver']) : null,
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      price: (json['price'] ?? 0).toDouble(),
      availableSeats: json['availableSeats'] ?? 0,
      totalSeats: json['totalSeats'] ?? 0,
      status: json['status'] ?? 'scheduled',
      amenities: List<String>.from(json['amenities'] ?? []),
      seatLayout: json['seatLayout'],
      cargoCapacity: json['cargoCapacity']?.toDouble(),
      currentCargoWeight: json['currentCargoWeight']?.toDouble(),
      passengerCount: json['passengerCount'],
      cargoCount: json['cargoCount'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'price': price,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'status': status,
      'amenities': amenities,
      'seatLayout': seatLayout,
      'cargoCapacity': cargoCapacity,
      'currentCargoWeight': currentCargoWeight,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Check if trip is cancellable
  bool get isCancellable {
    if (status == 'cancelled' || status == 'completed') return false;
    final now = DateTime.now();
    final hoursUntilDeparture = departureTime.difference(now).inHours;
    return hoursUntilDeparture > 2; // Can cancel up to 2 hours before
  }

  // Check if trip is boardable
  bool get isBoardable {
    final now = DateTime.now();
    final minutesUntilDeparture = departureTime.difference(now).inMinutes;
    return status == 'scheduled' && minutesUntilDeparture <= 30 && minutesUntilDeparture > -60;
  }

  // Get duration
  Duration get duration => arrivalTime.difference(departureTime);
}

// Trip Search Filters
class TripSearchFilters {
  final String? origin;
  final String? destination;
  final DateTime? date;
  final DateTime? returnDate;
  final int? passengers;
  final double? minPrice;
  final double? maxPrice;
  final List<String>? busTypes;
  final List<String>? amenities;
  final String? sortBy;
  final String? departureTimeRange;

  TripSearchFilters({
    this.origin,
    this.destination,
    this.date,
    this.returnDate,
    this.passengers,
    this.minPrice,
    this.maxPrice,
    this.busTypes,
    this.amenities,
    this.sortBy,
    this.departureTimeRange,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (origin != null) params['origin'] = origin;
    if (destination != null) params['destination'] = destination;
    if (date != null) params['date'] = date!.toIso8601String().split('T')[0];
    if (passengers != null) params['passengers'] = passengers;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (busTypes != null && busTypes!.isNotEmpty) {
      params['busTypes'] = busTypes!.join(',');
    }
    if (amenities != null && amenities!.isNotEmpty) {
      params['amenities'] = amenities!.join(',');
    }
    if (sortBy != null) params['sortBy'] = sortBy;
    if (departureTimeRange != null) params['timeRange'] = departureTimeRange;

    return params;
  }
}