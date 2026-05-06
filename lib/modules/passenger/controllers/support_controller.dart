import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../../data/models/common/support_ticket_model.dart';

class SupportController extends GetxController {
  static SupportController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorage _secureStorage = SecureStorage();
  final AuthController _authController = AuthController.instance;

  final _isLoading = false.obs;
  final _myTickets = <SupportTicketModel>[].obs;
  bool get isLoading => _isLoading.value;
  List<SupportTicketModel> get myTickets => _myTickets;
  final _replies = <ReplyModel>[].obs;
  List<ReplyModel> get replies => _replies;

  final _isLoadingReplies = false.obs;
  bool get isLoadingReplies => _isLoadingReplies.value;

  @override
  void onInit() {
    super.onInit();
    if (_authController.isAuthenticated) {
      fetchMyTickets();
    }
  }

  Future<void> fetchTicketReplies(String ticketId) async {
    try {
      _isLoadingReplies.value = true;
      print('📦 Fetching replies for ticket: $ticketId');

      final response = await _apiClient.get('/support/$ticketId/replies');

      if (response != null && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> repliesData = data['replies'] ?? [];
        _replies.value = repliesData.map((r) => ReplyModel.fromJson(r)).toList();
        print('✅ Loaded ${_replies.length} replies');
      }
    } catch (e) {
      print('❌ Error fetching replies: $e');
    } finally {
      _isLoadingReplies.value = false;
    }
  }

  Future<bool> addReply(String ticketId, String message) async {
    try {
      print('📤 Adding reply to ticket: $ticketId');

      final response = await _apiClient.post(
        '/support/$ticketId/reply',
        data: {'message': message},
      );

      if (response != null && response['success'] == true) {
        Get.snackbar(
          'Success',
          'Reply sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error adding reply: $e');
      Get.snackbar('Error', 'Failed to send reply');
      return false;
    }
  }
  Future<bool> submitSupportRequest({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      _isLoading.value = true;

      String? userId;
      if (_authController.isAuthenticated && _authController.currentUser != null) {
        userId = _authController.currentUser!.id;
      }

      final response = await _apiClient.post(
        '/support/contact',
        data: {
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
          'userId': userId,
        },
        requiresAuth: false,
      );

      if (response != null && response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error submitting support request: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }


  Future<void> fetchMyTickets() async {
    if (!_authController.isAuthenticated) return;

    try {
      _isLoading.value = true;
      print('📦 Fetching my support tickets...');

      final response = await _apiClient.get('/support/my-tickets');

      print('📦 Response: $response');

      if (response != null && response['data'] != null) {
        final List<dynamic> data = response['data'];
        _myTickets.value = data.map((t) => SupportTicketModel.fromJson(t)).toList();
        print('✅ Loaded ${_myTickets.length} tickets');
      } else {
        print('⚠️ No tickets found');
        _myTickets.clear();
      }
    } catch (e) {
      print('❌ Error fetching my tickets: $e');
      _myTickets.clear();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<SupportTicketModel?> getTicketDetails(String ticketId) async {
    try {
      final response = await _apiClient.get('/support/$ticketId');
      if (response != null && response['data'] != null) {
        return SupportTicketModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching ticket details: $e');
      return null;
    }
  }
}

class ReplyModel {
  final String id;
  final String? userId;
  final String userRole;
  final String message;
  final DateTime createdAt;
  final UserInfo? user;

  ReplyModel({
    required this.id,
    this.userId,
    required this.userRole,
    required this.message,
    required this.createdAt,
    this.user,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString(),
      userRole: json['userRole'] ?? 'user',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
    );
  }

  bool get isAdmin => userRole == 'admin';
  bool get isUser => userRole == 'passenger' || userRole == 'driver';
}

class UserInfo {
  final String id;
  final String fullName;
  final String role;
  final String? profileImage;

  UserInfo({
    required this.id,
    required this.fullName,
    required this.role,
    this.profileImage,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? '',
      profileImage: json['profileImage'],
    );
  }
}