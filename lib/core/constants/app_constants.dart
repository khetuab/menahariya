// lib/core/constants/app_constants.dart

import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Menahariya Smart';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Wolkite University';
  static const String departmentName = 'Software Engineering';
  static const String baseUrl = 'baseUrl';

  // Shared Preferences Keys
  static const String prefKeyToken = 'auth_token';
  static const String prefKeyUser = 'user_data';
  static const String prefKeyUserId = 'user_id';
  static const String prefKeyUserRole = 'user_role';
  static const String prefKeyTheme = 'theme_mode';
  static const String prefKeyLanguage = 'language_code';
  static const String prefKeyOnboardingSeen = 'onboarding_seen';
  static const String prefKeyRememberMe = 'remember_me';

  // Cache Keys
  static const String cacheKeyTrips = 'cached_trips';
  static const String cacheKeyRoutes = 'cached_routes';
  static const String cacheKeyTickets = 'cached_tickets';
  static const String cacheKeyNotifications = 'cached_notifications';

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 13;
  static const int otpLength = 6;

  // Seat Lock Duration (in minutes)
  static const int seatLockDuration = 5;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration socketTimeout = Duration(seconds: 60);

  // Date Formats
  static const String dateFormatDisplay = 'MMM dd, yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String timeFormatDisplay = 'hh:mm a';
  static const String timeFormat24h = 'HH:mm';
  static const String dateTimeFormatDisplay = 'MMM dd, yyyy hh:mm a';
  static const String dateTimeFormatApi = 'yyyy-MM-dd HH:mm:ss';

  // Currency
  static const String currencySymbol = 'ETB';
  static const String currencyCode = 'ETB';

  // File Size Limits
  static const int maxImageSizeInMB = 5;
  static const int maxImageSizeInBytes = maxImageSizeInMB * 1024 * 1024;

  // QR Code
  static const double qrCodeSize = 200.0;

  // User Roles
  static const String rolePassenger = 'passenger';
  static const String roleDriver = 'driver';
  static const String roleAdmin = 'admin';
  static const String roleTicketingStaff = 'ticketing_staff';
  static const String roleCargoStaff = 'cargo_staff';

  // Trip Status
  static const String tripStatusScheduled = 'scheduled';
  static const String tripStatusDeparted = 'departed';
  static const String tripStatusCompleted = 'completed';
  static const String tripStatusCancelled = 'cancelled';
  static const String tripStatusDelayed = 'delayed';

  // Ticket Status
  static const String ticketStatusAvailable = 'available';
  static const String ticketStatusLocked = 'locked';
  static const String ticketStatusReserved = 'reserved';
  static const String ticketStatusPaid = 'paid';
  static const String ticketStatusUsed = 'used';
  static const String ticketStatusCancelled = 'cancelled';
  static const String ticketStatusExpired = 'expired';

  // Payment Status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';
  static const String paymentStatusRefunded = 'refunded';
  static const String paymentStatusCancelled = 'cancelled';

  // Payment Methods
  static const String paymentMethodTelebirr = 'telebirr';
  static const String paymentMethodCBE = 'cbe_birr';
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodCard = 'card';

  // Cargo Status
  static const String cargoStatusRegistered = 'registered';
  static const String cargoStatusLoaded = 'loaded';
  static const String cargoStatusInTransit = 'in_transit';
  static const String cargoStatusDelivered = 'delivered';
  static const String cargoStatusCancelled = 'cancelled';

  // Notification Types
  static const String notificationTypeBooking = 'booking';
  static const String notificationTypePayment = 'payment';
  static const String notificationTypeTrip = 'trip';
  static const String notificationTypeCargo = 'cargo';
  static const String notificationTypeReminder = 'reminder';
  static const String notificationTypePromo = 'promo';

  // Error Messages
  static const String errorNetwork = 'Network connection error. Please check your internet.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorTimeout = 'Request timeout. Please try again.';
  static const String errorUnauthorized = 'Session expired. Please login again.';
  static const String errorForbidden = 'You don\'t have permission to perform this action.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorValidation = 'Validation error. Please check your input.';
  static const String errorUnknown = 'An unknown error occurred.';
  static const String errorNoData = 'No data available.';
  static const String errorInvalidOTP = 'Invalid OTP code.';
  static const String errorInvalidCredentials = 'Invalid phone number or password.';
  static const String errorPhoneExists = 'Phone number already registered.';
  static const String errorWeakPassword = 'Password is too weak.';
}