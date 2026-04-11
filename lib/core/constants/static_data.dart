import 'package:flutter/material.dart';

class StaticData {
  // Payment Methods
  static const List<Map<String, dynamic>> paymentMethods = [
    {
      'code': 'telebirr',
      'name': 'Telebirr',
      'icon': 'assets/icons/telebirr.png',
      'minAmount': 10,
      'maxAmount': 50000,
    },
    {
      'code': 'cbe_birr',
      'name': 'CBE Birr',
      'icon': 'assets/icons/cbe_birr.png',
      'minAmount': 10,
      'maxAmount': 100000,
    },
    {
      'code': 'card',
      'name': 'Credit/Debit Card',
      'icon': 'assets/icons/card.png',
      'minAmount': 50,
      'maxAmount': 50000,
    },
    {
      'code': 'cash',
      'name': 'Cash',
      'icon': 'assets/icons/cash.png',
      'minAmount': 50,
      'maxAmount': 10000,
    },
    {
      'code': 'wallet',
      'name': 'Wallet',
      'icon': 'assets/icons/wallet.png',
      'minAmount': 10,
      'maxAmount': 50000,
    },
  ];

  // Cargo Types
  static const List<Map<String, dynamic>> cargoTypes = [
    {
      'id': 'general',
      'name': 'General Goods',
      'baseRate': 5,
      'minFee': 50,
      'icon': 'general',
      'description': 'General merchandise and goods',
    },
    {
      'id': 'electronics',
      'name': 'Electronics',
      'baseRate': 10,
      'minFee': 100,
      'icon': 'electronics',
      'description': 'Electronic devices and equipment',
    },
    {
      'id': 'furniture',
      'name': 'Furniture',
      'baseRate': 8,
      'minFee': 200,
      'icon': 'furniture',
      'description': 'Furniture and large items',
    },
    {
      'id': 'perishables',
      'name': 'Perishables',
      'baseRate': 12,
      'minFee': 80,
      'icon': 'perishables',
      'description': 'Food items, flowers, etc.',
    },
    {
      'id': 'documents',
      'name': 'Documents',
      'baseRate': 2,
      'minFee': 30,
      'icon': 'documents',
      'description': 'Papers, documents, envelopes',
    },
    {
      'id': 'clothing',
      'name': 'Clothing',
      'baseRate': 4,
      'minFee': 40,
      'icon': 'clothing',
      'description': 'Clothes and textiles',
    },
  ];

  // Amenities
  static const List<Map<String, dynamic>> amenities = [
    {
      'id': 'ac',
      'name': 'Air Conditioning',
      'icon': Icons.ac_unit,
      'category': 'comfort',
    },
    {
      'id': 'wifi',
      'name': 'WiFi',
      'icon': Icons.wifi,
      'category': 'connectivity',
    },
    {
      'id': 'usb',
      'name': 'USB Charging',
      'icon': Icons.usb,
      'category': 'connectivity',
    },
    {
      'id': 'tv',
      'name': 'Entertainment System',
      'icon': Icons.tv,
      'category': 'entertainment',
    },
    {
      'id': 'restroom',
      'name': 'Restroom',
      'icon': Icons.wc,
      'category': 'facility',
    },
    {
      'id': 'snacks',
      'name': 'Snacks',
      'icon': Icons.fastfood,
      'category': 'refreshments',
    },
    {
      'id': 'drinks',
      'name': 'Beverages',
      'icon': Icons.local_drink,
      'category': 'refreshments',
    },
    {
      'id': 'blanket',
      'name': 'Blanket',
      'icon': Icons.airline_seat_individual_suite,
      'category': 'comfort',
    },
    {
      'id': 'power_outlet',
      'name': 'Power Outlet',
      'icon': Icons.power,
      'category': 'connectivity',
    },
    {
      'id': 'recliner',
      'name': 'Reclining Seat',
      'icon': Icons.airline_seat_recline_normal,
      'category': 'comfort',
    },
  ];

  // Get payment method by code
  static Map<String, dynamic>? getPaymentMethod(String code) {
    try {
      return paymentMethods.firstWhere((method) => method['code'] == code);
    } catch (e) {
      return null;
    }
  }

  // Get cargo type by id
  static Map<String, dynamic>? getCargoType(String id) {
    try {
      return cargoTypes.firstWhere((type) => type['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get amenity by id
  static Map<String, dynamic>? getAmenity(String id) {
    try {
      return amenities.firstWhere((amenity) => amenity['id'] == id);
    } catch (e) {
      return null;
    }
  }
}