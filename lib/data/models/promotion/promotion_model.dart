// lib/data/models/promotion/promotion_model.dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'package:iconsax/iconsax.dart';

class PromotionModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String linkType;
  final String linkUrl;
  final String buttonText;
  final String? discountCode;
  final double discountPercentage;
  final DateTime validFrom;
  final DateTime validUntil;
  final List<String> targetAudience;
  final int priority;
  final bool isActive;
  final int views;
  final int clicks;

  PromotionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.linkType,
    required this.linkUrl,
    required this.buttonText,
    this.discountCode,
    required this.discountPercentage,
    required this.validFrom,
    required this.validUntil,
    required this.targetAudience,
    required this.priority,
    required this.isActive,
    required this.views,
    required this.clicks,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      linkType: json['linkType'] ?? 'web',
      linkUrl: json['linkUrl'] ?? '',
      buttonText: json['buttonText'] ?? 'Learn More',
      discountCode: json['discountCode'],
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      validFrom: DateTime.parse(json['validFrom']),
      validUntil: DateTime.parse(json['validUntil']),
      targetAudience: List<String>.from(json['targetAudience'] ?? ['all']),
      priority: json['priority'] ?? 0,
      isActive: json['isActive'] ?? false,
      views: json['views'] ?? 0,
      clicks: json['clicks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'linkType': linkType,
      'linkUrl': linkUrl,
      'buttonText': buttonText,
      'discountCode': discountCode,
      'discountPercentage': discountPercentage,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'targetAudience': targetAudience,
      'priority': priority,
    };
  }

  IconData get linkIcon {
    switch (linkType) {
      case 'youtube':
        return Icons.play_circle_filled_rounded;
      case 'telegram':
        return Icons.telegram;
      case 'whatsapp':
        return Icons.camera;
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Iconsax.instagram;
      case 'twitter':
        return Icons.chat_outlined;
      default:
        return Icons.open_in_browser_rounded;
    }
  }

  Color get linkColor {
    switch (linkType) {
      case 'youtube':
        return Colors.red;
      case 'telegram':
        return Colors.blue;
      case 'whatsapp':
        return Colors.green;
      case 'facebook':
        return Color(0xFF1877F2);
      case 'instagram':
        return Colors.purple;
      case 'twitter':
        return Colors.cyan;
      default:
        return AppColors.primaryGreen;
    }
  }

  bool get hasDiscount => discountCode != null && discountCode!.isNotEmpty && discountPercentage > 0;
}

