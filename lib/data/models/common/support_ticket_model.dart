import 'package:flutter/material.dart';

class SupportTicketModel {
  final String id;
  final String name;
  final String email;
  final String subject;
  final String message;
  final String? userId;
  final String status;
  final String? adminResponse;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? updatedAt;
  final int replyCount;  // Add this
  final bool hasReplies;  // Add this

  SupportTicketModel({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    this.userId,
    required this.status,
    this.adminResponse,
    required this.createdAt,
    this.resolvedAt,
    this.updatedAt,
    this.replyCount = 0,
    this.hasReplies = false,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse DateTime
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

    // Calculate reply count and hasReplies from replies array
    final replies = json['replies'] as List?;
    final replyCount = replies?.length ?? 0;
    final hasReplies = replyCount > 0;

    return SupportTicketModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      userId: json['userId']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      adminResponse: json['adminResponse']?.toString(),
      createdAt: parseDate(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null ? parseDate(json['resolvedAt']) : null,
      updatedAt: json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
      replyCount: replyCount,
      hasReplies: hasReplies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      'userId': userId,
      'status': status,
      'adminResponse': adminResponse,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'replyCount': replyCount,
      'hasReplies': hasReplies,
    };
  }

  SupportTicketModel copyWith({
    String? status,
    String? adminResponse,
    int? replyCount,
    bool? hasReplies,
  }) {
    return SupportTicketModel(
      id: id,
      name: name,
      email: email,
      subject: subject,
      message: message,
      userId: userId,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
      createdAt: createdAt,
      resolvedAt: resolvedAt,
      updatedAt: updatedAt,
      replyCount: replyCount ?? this.replyCount,
      hasReplies: hasReplies ?? this.hasReplies,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}