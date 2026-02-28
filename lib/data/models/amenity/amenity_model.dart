// lib/data/models/amenity/amenity_model.dart

import 'package:flutter/material.dart';

class AmenityModel {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final IconData? icon;
  final bool isAvailable;
  final String? category;
  final Map<String, dynamic>? metadata;

  AmenityModel({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    this.icon,
    this.isAvailable = true,
    this.category,
    this.metadata,
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      iconName: json['icon'],
      icon: _getIconFromName(json['icon']),
      isAvailable: json['isAvailable'] ?? true,
      category: json['category'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': iconName,
      'isAvailable': isAvailable,
      'category': category,
      'metadata': metadata,
    };
  }

  // Helper to get IconData from icon name string
  static IconData? _getIconFromName(String? iconName) {
    if (iconName == null) return null;

    switch (iconName.toLowerCase()) {
      case 'ac':
      case 'air_conditioning':
        return Icons.ac_unit_rounded;
      case 'wifi':
        return Icons.wifi_rounded;
      case 'usb':
      case 'usb_charging':
        return Icons.usb_rounded;
      case 'tv':
      case 'entertainment':
        return Icons.tv_rounded;
      case 'restroom':
      case 'toilet':
        return Icons.wc_rounded;
      case 'snacks':
      case 'refreshments':
        return Icons.fastfood_rounded;
      case 'drinks':
      case 'beverages':
        return Icons.local_drink_rounded;
      case 'blanket':
        return Icons.airline_seat_individual_suite_rounded;
      case 'power_outlet':
        return Icons.power_rounded;
      case 'recliner':
      case 'reclining_seat':
        return Icons.airline_seat_recline_normal_rounded;
      case 'legroom':
      case 'extra_legroom':
        return Icons.airline_seat_legroom_extra_rounded;
      case 'reading_light':
        return Icons.light_rounded;
      case 'curtain':
      case 'privacy_curtain':
        return Icons.curtains_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  // Predefined common amenities
  static final List<AmenityModel> commonAmenities = [
    AmenityModel(
      id: 'ac',
      name: 'Air Conditioning',
      icon: Icons.ac_unit_rounded,
      category: 'comfort',
    ),
    AmenityModel(
      id: 'wifi',
      name: 'WiFi',
      icon: Icons.wifi_rounded,
      category: 'connectivity',
    ),
    AmenityModel(
      id: 'usb',
      name: 'USB Charging',
      icon: Icons.usb_rounded,
      category: 'connectivity',
    ),
    AmenityModel(
      id: 'tv',
      name: 'Entertainment System',
      icon: Icons.tv_rounded,
      category: 'entertainment',
    ),
    AmenityModel(
      id: 'restroom',
      name: 'Restroom',
      icon: Icons.wc_rounded,
      category: 'facility',
    ),
    AmenityModel(
      id: 'snacks',
      name: 'Snacks',
      icon: Icons.fastfood_rounded,
      category: 'refreshments',
    ),
    AmenityModel(
      id: 'drinks',
      name: 'Beverages',
      icon: Icons.local_drink_rounded,
      category: 'refreshments',
    ),
    AmenityModel(
      id: 'blanket',
      name: 'Blanket',
      icon: Icons.airline_seat_individual_suite_rounded,
      category: 'comfort',
    ),
    AmenityModel(
      id: 'power_outlet',
      name: 'Power Outlet',
      icon: Icons.power_rounded,
      category: 'connectivity',
    ),
    AmenityModel(
      id: 'recliner',
      name: 'Reclining Seat',
      icon: Icons.airline_seat_recline_normal_rounded,
      category: 'comfort',
    ),
  ];

  // Get category color
  Color getCategoryColor() {
    switch (category) {
      case 'comfort':
        return Colors.blue;
      case 'connectivity':
        return Colors.green;
      case 'entertainment':
        return Colors.purple;
      case 'facility':
        return Colors.orange;
      case 'refreshments':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  String toString() {
    return 'AmenityModel(id: $id, name: $name, category: $category)';
  }
}

// Extension for amenity list operations
extension AmenityListExtension on List<AmenityModel> {
  List<AmenityModel> getByCategory(String category) {
    return where((a) => a.category == category).toList();
  }

  List<String> getCategories() {
    return map((a) => a.category ?? 'other').toSet().toList();
  }

  Map<String, List<AmenityModel>> groupByCategory() {
    final Map<String, List<AmenityModel>> grouped = {};
    for (var amenity in this) {
      final category = amenity.category ?? 'other';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(amenity);
    }
    return grouped;
  }
}