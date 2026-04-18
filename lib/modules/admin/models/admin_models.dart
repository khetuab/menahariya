// lib/modules/admin/models/admin_models.dart

// Dashboard Stats
class AdminDashboardStats {
  final int totalUsers;
  final int totalDrivers;
  final int totalStaff;
  final int totalTrips;
  final int totalBookings;
  final int confirmedBookings;  // ADD THIS
  final int totalCargo;
  final double totalRevenue;
  final double todayRevenue;
  final int pendingPayments;
  final int activeTrips;
  final int completedTrips;
  final int cancelledTrips;
  final double occupancyRate;
  final int availableSeats;
  final int vehiclesInService;
  final int vehiclesInMaintenance;

  AdminDashboardStats({
    required this.totalUsers,
    required this.totalDrivers,
    required this.totalStaff,
    required this.totalTrips,
    required this.totalBookings,
    required this.confirmedBookings,  // ADD THIS
    required this.totalCargo,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.pendingPayments,
    required this.activeTrips,
    required this.completedTrips,
    required this.cancelledTrips,
    required this.occupancyRate,
    required this.availableSeats,
    required this.vehiclesInService,
    required this.vehiclesInMaintenance,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalDrivers: json['totalDrivers'] ?? 0,
      totalStaff: json['totalStaff'] ?? 0,
      totalTrips: json['totalTrips'] ?? 0,
      totalBookings: json['totalBookings'] ?? 0,
      confirmedBookings: json['confirmedBookings'] ?? 0,  // ADD THIS
      totalCargo: json['totalCargo'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      todayRevenue: (json['todayRevenue'] ?? 0).toDouble(),
      pendingPayments: json['pendingPayments'] ?? 0,
      activeTrips: json['activeTrips'] ?? 0,
      completedTrips: json['completedTrips'] ?? 0,
      cancelledTrips: json['cancelledTrips'] ?? 0,
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
      availableSeats: json['availableSeats'] ?? 0,
      vehiclesInService: json['vehiclesInService'] ?? 0,
      vehiclesInMaintenance: json['vehiclesInMaintenance'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalUsers': totalUsers,
    'totalDrivers': totalDrivers,
    'totalStaff': totalStaff,
    'totalTrips': totalTrips,
    'totalBookings': totalBookings,
    'confirmedBookings': confirmedBookings,  // ADD THIS
    'totalCargo': totalCargo,
    'totalRevenue': totalRevenue,
    'todayRevenue': todayRevenue,
    'pendingPayments': pendingPayments,
    'activeTrips': activeTrips,
    'completedTrips': completedTrips,
    'cancelledTrips': cancelledTrips,
    'occupancyRate': occupancyRate,
    'availableSeats': availableSeats,
    'vehiclesInService': vehiclesInService,
    'vehiclesInMaintenance': vehiclesInMaintenance,
  };
}
// Revenue Chart Data
class RevenueChartData {
  final List<String> labels;
  final List<double> revenue;
  final List<double> expenses;
  final List<double> profit;

  RevenueChartData({
    required this.labels,
    required this.revenue,
    required this.expenses,
    required this.profit,
  });

  factory RevenueChartData.fromJson(Map<String, dynamic> json) {
    // Safely convert int lists to double lists
    final revenueList = (json['revenue'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    final expensesList = (json['expenses'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    final profitList = (json['profit'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    return RevenueChartData(
      labels: List<String>.from(json['labels']),
      revenue: revenueList,
      expenses: expensesList,
      profit: profitList,
    );
  }

  Map<String, dynamic> toJson() => {
    'labels': labels,
    'revenue': revenue,
    'expenses': expenses,
    'profit': profit,
  };
}

// Trip Analytics
class TripAnalytics {
  final int totalTrips;
  final int completedTrips;
  final int cancelledTrips;
  final int delayedTrips;
  final double onTimeRate;
  final double averageDelayMinutes;
  final Map<String, int> tripsByRoute;
  final Map<String, int> tripsByVehicle;
  final Map<String, double> routePopularity;

  TripAnalytics({
    required this.totalTrips,
    required this.completedTrips,
    required this.cancelledTrips,
    required this.delayedTrips,
    required this.onTimeRate,
    required this.averageDelayMinutes,
    required this.tripsByRoute,
    required this.tripsByVehicle,
    required this.routePopularity,
  });

  factory TripAnalytics.fromJson(Map<String, dynamic> json) {
    return TripAnalytics(
      totalTrips: json['totalTrips'] ?? 0,
      completedTrips: json['completedTrips'] ?? 0,
      cancelledTrips: json['cancelledTrips'] ?? 0,
      delayedTrips: json['delayedTrips'] ?? 0,
      onTimeRate: (json['onTimeRate'] ?? 0).toDouble(),
      averageDelayMinutes: (json['averageDelayMinutes'] ?? 0).toDouble(),
      tripsByRoute: Map<String, int>.from(json['tripsByRoute'] ?? {}),
      tripsByVehicle: Map<String, int>.from(json['tripsByVehicle'] ?? {}),
      routePopularity: (json['routePopularity'] as Map?)?.map((k, v) => MapEntry(k, (v ?? 0).toDouble())) ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'totalTrips': totalTrips,
    'completedTrips': completedTrips,
    'cancelledTrips': cancelledTrips,
    'delayedTrips': delayedTrips,
    'onTimeRate': onTimeRate,
    'averageDelayMinutes': averageDelayMinutes,
    'tripsByRoute': tripsByRoute,
    'tripsByVehicle': tripsByVehicle,
    'routePopularity': routePopularity,
  };
}

// Booking Analytics
class BookingAnalytics {
  final int totalBookings;
  final int confirmedBookings;
  final int cancelledBookings;
  final int pendingPayments;
  final double averageBookingValue;
  final Map<String, int> bookingsByPaymentMethod;
  final Map<String, int> bookingsByDay;

  BookingAnalytics({
    required this.totalBookings,
    required this.confirmedBookings,
    required this.cancelledBookings,
    required this.pendingPayments,
    required this.averageBookingValue,
    required this.bookingsByPaymentMethod,
    required this.bookingsByDay,
  });

  factory BookingAnalytics.fromJson(Map<String, dynamic> json) {
    return BookingAnalytics(
      totalBookings: json['totalBookings'] ?? 0,
      confirmedBookings: json['confirmedBookings'] ?? 0,
      cancelledBookings: json['cancelledBookings'] ?? 0,
      pendingPayments: json['pendingPayments'] ?? 0,
      averageBookingValue: (json['averageBookingValue'] ?? 0).toDouble(),
      bookingsByPaymentMethod: Map<String, int>.from(json['bookingsByPaymentMethod'] ?? {}),
      bookingsByDay: Map<String, int>.from(json['bookingsByDay'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalBookings': totalBookings,
    'confirmedBookings': confirmedBookings,
    'cancelledBookings': cancelledBookings,
    'pendingPayments': pendingPayments,
    'averageBookingValue': averageBookingValue,
    'bookingsByPaymentMethod': bookingsByPaymentMethod,
    'bookingsByDay': bookingsByDay,
  };
}

// Cargo Analytics
class CargoAnalytics {
  final int totalCargo;
  final int deliveredCargo;
  final int inTransitCargo;
  final int pendingCargo;
  final double totalWeight;
  final double totalRevenue;
  final Map<String, int> cargoByType;
  final Map<String, int> cargoByDestination;

  CargoAnalytics({
    required this.totalCargo,
    required this.deliveredCargo,
    required this.inTransitCargo,
    required this.pendingCargo,
    required this.totalWeight,
    required this.totalRevenue,
    required this.cargoByType,
    required this.cargoByDestination,
  });

  factory CargoAnalytics.fromJson(Map<String, dynamic> json) {
    return CargoAnalytics(
      totalCargo: json['totalCargo'] ?? 0,
      deliveredCargo: json['deliveredCargo'] ?? 0,
      inTransitCargo: json['inTransitCargo'] ?? 0,
      pendingCargo: json['pendingCargo'] ?? 0,
      totalWeight: (json['totalWeight'] ?? 0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      cargoByType: Map<String, int>.from(json['cargoByType'] ?? {}),
      cargoByDestination: Map<String, int>.from(json['cargoByDestination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalCargo': totalCargo,
    'deliveredCargo': deliveredCargo,
    'inTransitCargo': inTransitCargo,
    'pendingCargo': pendingCargo,
    'totalWeight': totalWeight,
    'totalRevenue': totalRevenue,
    'cargoByType': cargoByType,
    'cargoByDestination': cargoByDestination,
  };
}

// Report Filters
class ReportFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? reportType;
  final String? format;
  final List<String>? routes;
  final List<String>? statuses;

  ReportFilters({
    this.startDate,
    this.endDate,
    this.reportType,
    this.format,
    this.routes,
    this.statuses,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    if (reportType != null) params['type'] = reportType;
    if (format != null) params['format'] = format;
    if (routes != null && routes!.isNotEmpty) params['routes'] = routes!.join(',');
    if (statuses != null && statuses!.isNotEmpty) params['statuses'] = statuses!.join(',');
    return params;
  }
}

// Report Response
class ReportResponse {
  final String id;
  final String title;
  final String type;
  final String format;
  final DateTime generatedAt;
  final String downloadUrl;
  final int fileSize;
  final Map<String, dynamic>? data;

  ReportResponse({
    required this.id,
    required this.title,
    required this.type,
    required this.format,
    required this.generatedAt,
    required this.downloadUrl,
    required this.fileSize,
    this.data,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      format: json['format'] ?? '',
      generatedAt: DateTime.tryParse(json['generatedAt'] ?? '') ?? DateTime.now(),
      downloadUrl: json['downloadUrl'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'format': format,
    'generatedAt': generatedAt.toIso8601String(),
    'downloadUrl': downloadUrl,
    'fileSize': fileSize,
    'data': data,
  };
}

// System Settings
class SystemSettings {
  final BookingSettings booking;
  final CargoSettings cargo;
  final PaymentSettings payment;
  final NotificationSettingsConfig notification;
  final SecuritySettings security;
  final MaintenanceSettings maintenance;

  SystemSettings({
    required this.booking,
    required this.cargo,
    required this.payment,
    required this.notification,
    required this.security,
    required this.maintenance,
  });

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    return SystemSettings(
      booking: BookingSettings.fromJson(json['booking'] ?? {}),
      cargo: CargoSettings.fromJson(json['cargo'] ?? {}),
      payment: PaymentSettings.fromJson(json['payment'] ?? {}),
      notification: NotificationSettingsConfig.fromJson(json['notification'] ?? {}),
      security: SecuritySettings.fromJson(json['security'] ?? {}),
      maintenance: MaintenanceSettings.fromJson(json['maintenance'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking': booking.toJson(),
      'cargo': cargo.toJson(),
      'payment': payment.toJson(),
      'notification': notification.toJson(),
      'security': security.toJson(),
      'maintenance': maintenance.toJson(),
    };
  }
}

class BookingSettings {
  final int maxSeatsPerBooking;
  final int seatLockDurationMinutes;
  final int cancellationWindowHours;
  final double cancellationFeePercentage;
  final bool enableInsurance;
  final double insuranceRate;

  BookingSettings({
    required this.maxSeatsPerBooking,
    required this.seatLockDurationMinutes,
    required this.cancellationWindowHours,
    required this.cancellationFeePercentage,
    required this.enableInsurance,
    required this.insuranceRate,
  });

  factory BookingSettings.fromJson(Map<String, dynamic> json) {
    return BookingSettings(
      maxSeatsPerBooking: json['maxSeatsPerBooking'] ?? 10,
      seatLockDurationMinutes: json['seatLockDurationMinutes'] ?? 5,
      cancellationWindowHours: json['cancellationWindowHours'] ?? 2,
      cancellationFeePercentage: (json['cancellationFeePercentage'] ?? 10).toDouble(),
      enableInsurance: json['enableInsurance'] ?? true,
      insuranceRate: (json['insuranceRate'] ?? 0.05).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxSeatsPerBooking': maxSeatsPerBooking,
      'seatLockDurationMinutes': seatLockDurationMinutes,
      'cancellationWindowHours': cancellationWindowHours,
      'cancellationFeePercentage': cancellationFeePercentage,
      'enableInsurance': enableInsurance,
      'insuranceRate': insuranceRate,
    };
  }
}

class CargoSettings {
  final double baseRatePerKg;
  final double fragileSurcharge;
  final double perishableSurcharge;
  final double refrigerationSurcharge;
  final double minFee;
  final double maxWeightPerTrip;
  final bool requireDimensions;

  CargoSettings({
    required this.baseRatePerKg,
    required this.fragileSurcharge,
    required this.perishableSurcharge,
    required this.refrigerationSurcharge,
    required this.minFee,
    required this.maxWeightPerTrip,
    required this.requireDimensions,
  });

  factory CargoSettings.fromJson(Map<String, dynamic> json) {
    return CargoSettings(
      baseRatePerKg: (json['baseRatePerKg'] ?? 5).toDouble(),
      fragileSurcharge: (json['fragileSurcharge'] ?? 0.2).toDouble(),
      perishableSurcharge: (json['perishableSurcharge'] ?? 0.15).toDouble(),
      refrigerationSurcharge: (json['refrigerationSurcharge'] ?? 0.25).toDouble(),
      minFee: (json['minFee'] ?? 50).toDouble(),
      maxWeightPerTrip: (json['maxWeightPerTrip'] ?? 500).toDouble(),
      requireDimensions: json['requireDimensions'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseRatePerKg': baseRatePerKg,
      'fragileSurcharge': fragileSurcharge,
      'perishableSurcharge': perishableSurcharge,
      'refrigerationSurcharge': refrigerationSurcharge,
      'minFee': minFee,
      'maxWeightPerTrip': maxWeightPerTrip,
      'requireDimensions': requireDimensions,
    };
  }
}

class PaymentSettings {
  final List<String> enabledMethods;
  final double walletMinBalance;
  final double walletMaxBalance;
  final int paymentTimeoutMinutes;
  final bool autoConfirmPayments;
  final int refundProcessingDays;

  PaymentSettings({
    required this.enabledMethods,
    required this.walletMinBalance,
    required this.walletMaxBalance,
    required this.paymentTimeoutMinutes,
    required this.autoConfirmPayments,
    required this.refundProcessingDays,
  });

  factory PaymentSettings.fromJson(Map<String, dynamic> json) {
    return PaymentSettings(
      enabledMethods: List<String>.from(json['enabledMethods'] ?? ['telebirr', 'cbe_birr', 'wallet', 'cash']),
      walletMinBalance: (json['walletMinBalance'] ?? 0).toDouble(),
      walletMaxBalance: (json['walletMaxBalance'] ?? 10000).toDouble(),
      paymentTimeoutMinutes: json['paymentTimeoutMinutes'] ?? 30,
      autoConfirmPayments: json['autoConfirmPayments'] ?? true,
      refundProcessingDays: json['refundProcessingDays'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabledMethods': enabledMethods,
      'walletMinBalance': walletMinBalance,
      'walletMaxBalance': walletMaxBalance,
      'paymentTimeoutMinutes': paymentTimeoutMinutes,
      'autoConfirmPayments': autoConfirmPayments,
      'refundProcessingDays': refundProcessingDays,
    };
  }
}

class NotificationSettingsConfig {
  final bool enableSms;
  final bool enableEmail;
  final bool enablePush;

  NotificationSettingsConfig({
    required this.enableSms,
    required this.enableEmail,
    required this.enablePush,
  });

  factory NotificationSettingsConfig.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsConfig(
      enableSms: json['enableSms'] ?? true,
      enableEmail: json['enableEmail'] ?? false,
      enablePush: json['enablePush'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableSms': enableSms,
      'enableEmail': enableEmail,
      'enablePush': enablePush,
    };
  }
}

class NotificationSettings {
  final bool enableSms;
  final bool enableEmail;
  final bool enablePush;
  final Map<String, bool> typeSettings;

  NotificationSettings({
    required this.enableSms,
    required this.enableEmail,
    required this.enablePush,
    required this.typeSettings,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enableSms: json['enableSms'] ?? true,
      enableEmail: json['enableEmail'] ?? false,
      enablePush: json['enablePush'] ?? true,
      typeSettings: Map<String, bool>.from(json['typeSettings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'enableSms': enableSms,
    'enableEmail': enableEmail,
    'enablePush': enablePush,
    'typeSettings': typeSettings,
  };
}

class SecuritySettings {
  final int sessionTimeoutMinutes;
  final int maxLoginAttempts;
  final int passwordExpiryDays;
  final bool requireMfaForAdmin;
  final bool enableAuditLogging;

  SecuritySettings({
    required this.sessionTimeoutMinutes,
    required this.maxLoginAttempts,
    required this.passwordExpiryDays,
    required this.requireMfaForAdmin,
    required this.enableAuditLogging,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      sessionTimeoutMinutes: json['sessionTimeoutMinutes'] ?? 30,
      maxLoginAttempts: json['maxLoginAttempts'] ?? 5,
      passwordExpiryDays: json['passwordExpiryDays'] ?? 90,
      requireMfaForAdmin: json['requireMfaForAdmin'] ?? false,
      enableAuditLogging: json['enableAuditLogging'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'maxLoginAttempts': maxLoginAttempts,
      'passwordExpiryDays': passwordExpiryDays,
      'requireMfaForAdmin': requireMfaForAdmin,
      'enableAuditLogging': enableAuditLogging,
    };
  }
}

class MaintenanceSettings {
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final int estimatedDurationMinutes;

  MaintenanceSettings({
    required this.maintenanceMode,
    this.maintenanceMessage,
    required this.estimatedDurationMinutes,
  });

  factory MaintenanceSettings.fromJson(Map<String, dynamic> json) {
    return MaintenanceSettings(
      maintenanceMode: json['maintenanceMode'] ?? false,
      maintenanceMessage: json['maintenanceMessage'],
      estimatedDurationMinutes: json['estimatedDurationMinutes'] ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maintenanceMode': maintenanceMode,
      'maintenanceMessage': maintenanceMessage,
      'estimatedDurationMinutes': estimatedDurationMinutes,
    };
  }
}

// lib/modules/admin/models/admin_models.dart

class AdminProfile {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String? profileImage;
  final String role;
  final DateTime createdAt;
  final DateTime lastLogin;
  final Map<String, dynamic>? preferences;

  AdminProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    this.profileImage,
    required this.role,
    required this.createdAt,
    required this.lastLogin,
    this.preferences,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    // Safe date parsing
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          print('Error parsing date: $dateValue - $e');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return AdminProfile(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
      role: json['role']?.toString() ?? 'admin',
      createdAt: parseDate(json['createdAt']),
      lastLogin: parseDate(json['lastLogin']),
      preferences: json['preferences'] is Map ? Map<String, dynamic>.from(json['preferences']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'profileImage': profileImage,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'preferences': preferences,
    };
  }

  AdminProfile copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? profileImage,
  }) {
    return AdminProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      role: role,
      createdAt: createdAt,
      lastLogin: lastLogin,
      preferences: preferences,
    );
  }
}

class ActivityLog {
  final String id;
  final String adminId;
  final String action;
  final String details;
  final String ipAddress;
  final String userAgent;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.adminId,
    required this.action,
    required this.details,
    required this.ipAddress,
    required this.userAgent,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    // Safe date parsing
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          print('Error parsing date: $dateValue - $e');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return ActivityLog(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      adminId: json['adminId']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      ipAddress: json['ipAddress']?.toString() ?? '',
      userAgent: json['userAgent']?.toString() ?? '',
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminId': adminId,
      'action': action,
      'details': details,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
// Audit Log Entry
class AuditLogEntry {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final String ipAddress;
  final DateTime timestamp;

  AuditLogEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entityType,
    this.entityId,
    this.oldValue,
    this.newValue,
    required this.ipAddress,
    required this.timestamp,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      action: json['action'] ?? '',
      entityType: json['entityType'] ?? '',
      entityId: json['entityId'],
      oldValue: json['oldValue'],
      newValue: json['newValue'],
      ipAddress: json['ipAddress'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'action': action,
    'entityType': entityType,
    'entityId': entityId,
    'oldValue': oldValue,
    'newValue': newValue,
    'ipAddress': ipAddress,
    'timestamp': timestamp.toIso8601String(),
  };
}


// Bulk Operation Result
class BulkOperationResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;
  final List<String> successIds;

  BulkOperationResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
    required this.successIds,
  });

  factory BulkOperationResult.fromJson(Map<String, dynamic> json) {
    return BulkOperationResult(
      successCount: json['successCount'] ?? 0,
      failureCount: json['failureCount'] ?? 0,
      errors: List<String>.from(json['errors'] ?? []),
      successIds: List<String>.from(json['successIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'successCount': successCount,
    'failureCount': failureCount,
    'errors': errors,
    'successIds': successIds,
  };
}