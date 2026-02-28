// lib/data/models/notification/notification_model.dart

class NotificationModel {
  final String id;
  final String userId;
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
    required this.userId,
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
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
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