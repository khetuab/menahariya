// lib/data/models/trip/route_model.dart

class RouteModel {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final double distance;
  final int duration; // in minutes
  final List<String>? stops;
  final double basePrice;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Popularity metrics
  final int? tripCount;
  final int? passengerCount;

  RouteModel({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.distance,
    required this.duration,
    this.stops,
    required this.basePrice,
    this.isActive = true,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.tripCount,
    this.passengerCount,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      stops: json['stops'] != null ? List<String>.from(json['stops']) : null,
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      tripCount: json['tripCount'],
      passengerCount: json['passengerCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'origin': origin,
      'destination': destination,
      'distance': distance,
      'duration': duration,
      'stops': stops,
      'basePrice': basePrice,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  // Get formatted duration
  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

// Popular Route Stats
class PopularRouteStats {
  final RouteModel route;
  final int searchCount;
  final int bookingCount;
  final double revenue;

  PopularRouteStats({
    required this.route,
    required this.searchCount,
    required this.bookingCount,
    required this.revenue,
  });

  factory PopularRouteStats.fromJson(Map<String, dynamic> json) {
    return PopularRouteStats(
      route: RouteModel.fromJson(json['route']),
      searchCount: json['searchCount'] ?? 0,
      bookingCount: json['bookingCount'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}