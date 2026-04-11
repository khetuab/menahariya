// lib/data/models/notification/notification_model.dart

class NotificationModel {
  final String id;
  final dynamic userId; // Changed from String to dynamic to handle both String and Map
  final String? userFullName; // Added for populated user data
  final String? userPhone;
  final String? userEmail;
  final String? userRole;
  final String title;
  final String body;
  final String type; // booking, payment, trip, cargo, promo, system
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? imageUrl;
  final String? actionUrl;
  final String? priority; // high, normal, low

  NotificationModel({
    required this.id,
    this.userId,
    this.userFullName,
    this.userPhone,
    this.userEmail,
    this.userRole,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.imageUrl,
    this.actionUrl,
    this.priority,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Handle userId - could be String or Map
    dynamic userIdValue = json['userId'];
    String? userIdString;
    String? userFullName;
    String? userPhone;
    String? userEmail;
    String? userRole;

    if (userIdValue is Map<String, dynamic>) {
      // It's a populated user object
      userIdString = userIdValue['_id'] ?? userIdValue['id'];
      userFullName = userIdValue['fullName'];
      userPhone = userIdValue['phone'];
      userEmail = userIdValue['email'];
      userRole = userIdValue['role'];
    } else if (userIdValue is String) {
      userIdString = userIdValue;
    }

    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: userIdString,
      userFullName: userFullName,
      userPhone: userPhone,
      userEmail: userEmail,
      userRole: userRole,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'system',
      data: json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
      priority: json['priority'],
    );
  }

  // Helper getter to get user display name
  String get userDisplayName {
    if (userFullName != null && userFullName!.isNotEmpty) return userFullName!;
    if (userId != null && userId is String && userId.toString().isNotEmpty) {
      return userId.toString().substring(0, 8);
    }
    return 'All Users';
  }

  // Helper getter to check if this is a broadcast notification
  bool get isBroadcast => userId == null || userId.toString().isEmpty;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'priority': priority,
    };
  }

  // Copy with method
  NotificationModel copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      userFullName: userFullName,
      userPhone: userPhone,
      userEmail: userEmail,
      userRole: userRole,
      title: title,
      body: body,
      type: type,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      priority: priority,
    );
  }
}

// Notification Settings
class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final Map<String, bool> typeSettings;

  NotificationSettings({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.typeSettings,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? false,
      smsEnabled: json['smsEnabled'] ?? false,
      typeSettings: Map<String, bool>.from(json['typeSettings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
      'typeSettings': typeSettings,
    };
  }
}

// Push Notification Token
class PushNotificationToken {
  final String userId;
  final String token;
  final String deviceType;
  final DateTime createdAt;

  PushNotificationToken({
    required this.userId,
    required this.token,
    required this.deviceType,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'token': token,
      'deviceType': deviceType,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}