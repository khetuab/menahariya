// lib/data/models/user/user_model.dart

import 'package:menahariya/core/constants/app_constants.dart';

class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? profileImage;
  final String role;
  final String? address;
  final String? city;
  final DateTime? dateOfBirth;
  final String? gender;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  // Driver specific fields
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final double? rating;
  final int? totalTrips;
  final bool? isAvailable;

  // Passenger specific fields
  final double? walletBalance;
  final int? loyaltyPoints;
  final String? loyaltyTier;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.profileImage,
    required this.role,
    this.address,
    this.city,
    this.dateOfBirth,
    this.gender,
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
    // Driver fields
    this.licenseNumber,
    this.licenseExpiry,
    this.rating,
    this.totalTrips,
    this.isAvailable,
    // Passenger fields
    this.walletBalance,
    this.loyaltyPoints,
    this.loyaltyTier,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      profileImage: json['profileImage'] ?? json['avatar'],
      role: json['role'] ?? AppConstants.rolePassenger,
      address: json['address'],
      city: json['city'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      isActive: json['isActive'] ?? true,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      metadata: json['metadata'],
      // Driver fields
      licenseNumber: json['licenseNumber'],
      licenseExpiry: json['licenseExpiry'] != null
          ? DateTime.parse(json['licenseExpiry'])
          : null,
      rating: json['rating']?.toDouble(),
      totalTrips: json['totalTrips'],
      isAvailable: json['isAvailable'],
      // Passenger fields
      walletBalance: json['walletBalance']?.toDouble(),
      loyaltyPoints: json['loyaltyPoints'],
      loyaltyTier: json['loyaltyTier'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'fullName': fullName,
      'phone': phone,
      'role': role,
    };

    if (email != null) data['email'] = email;
    if (profileImage != null) data['profileImage'] = profileImage;
    if (address != null) data['address'] = address;
    if (city != null) data['city'] = city;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (gender != null) data['gender'] = gender;
    if (metadata != null) data['metadata'] = metadata;

    // Driver fields
    if (licenseNumber != null) data['licenseNumber'] = licenseNumber;
    if (licenseExpiry != null) data['licenseExpiry'] = licenseExpiry!.toIso8601String();
    if (rating != null) data['rating'] = rating;
    if (totalTrips != null) data['totalTrips'] = totalTrips;
    if (isAvailable != null) data['isAvailable'] = isAvailable;

    // Passenger fields
    if (walletBalance != null) data['walletBalance'] = walletBalance;
    if (loyaltyPoints != null) data['loyaltyPoints'] = loyaltyPoints;
    if (loyaltyTier != null) data['loyaltyTier'] = loyaltyTier;

    return data;
  }

  // Copy with method for immutability
  UserModel copyWith({
    String? fullName,
    String? email,
    String? profileImage,
    String? address,
    String? city,
    DateTime? dateOfBirth,
    String? gender,
    bool? isActive,
    bool? isVerified,
    Map<String, dynamic>? metadata,
    // Driver fields
    String? licenseNumber,
    DateTime? licenseExpiry,
    double? rating,
    int? totalTrips,
    bool? isAvailable,
    // Passenger fields
    double? walletBalance,
    int? loyaltyPoints,
    String? loyaltyTier,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      role: role,
      address: address ?? this.address,
      city: city ?? this.city,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      metadata: metadata ?? this.metadata,
      // Driver fields
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      isAvailable: isAvailable ?? this.isAvailable,
      // Passenger fields
      walletBalance: walletBalance ?? this.walletBalance,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      loyaltyTier: loyaltyTier ?? this.loyaltyTier,
    );
  }

  // Helper getters
  String get initials {
    if (fullName.isEmpty) return '';
    final nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  bool get isDriver => role == AppConstants.roleDriver;
  bool get isPassenger => role == AppConstants.rolePassenger;
  bool get isAdmin => role == AppConstants.roleAdmin;
  bool get isStaff => role == AppConstants.roleTicketingStaff ||
      role == AppConstants.roleCargoStaff;
}

// User Preferences Model
class UserPreferences {
  final String userId;
  final bool notificationsEnabled;
  final bool darkMode;
  final String language;
  final bool saveHistory;
  final bool autoDownloadTickets;
  final bool receivePromotions;
  final Map<String, dynamic>? additionalPrefs;

  UserPreferences({
    required this.userId,
    required this.notificationsEnabled,
    required this.darkMode,
    required this.language,
    required this.saveHistory,
    required this.autoDownloadTickets,
    required this.receivePromotions,
    this.additionalPrefs,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'] ?? '',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      darkMode: json['darkMode'] ?? false,
      language: json['language'] ?? 'en',
      saveHistory: json['saveHistory'] ?? true,
      autoDownloadTickets: json['autoDownloadTickets'] ?? false,
      receivePromotions: json['receivePromotions'] ?? true,
      additionalPrefs: json['additionalPrefs'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'notificationsEnabled': notificationsEnabled,
      'darkMode': darkMode,
      'language': language,
      'saveHistory': saveHistory,
      'autoDownloadTickets': autoDownloadTickets,
      'receivePromotions': receivePromotions,
      'additionalPrefs': additionalPrefs,
    };
  }
}