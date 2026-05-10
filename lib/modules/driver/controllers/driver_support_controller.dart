import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/common/support_ticket_model.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../passenger/controllers/support_controller.dart';

class DriverSupportController extends GetxController {
  static DriverSupportController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  final _isLoading = false.obs;
  final _isLoadingReplies = false.obs;
  final _myTickets = <SupportTicketModel>[].obs;
  final _replies = <ReplyModel>[].obs;

  bool get isLoading => _isLoading.value;
  bool get isLoadingReplies => _isLoadingReplies.value;
  List<SupportTicketModel> get myTickets => _myTickets;
  List<ReplyModel> get replies => _replies;
  final userId = AuthController.instance.currentUser?.id;
  @override
  void onInit() {
    super.onInit();
    fetchMyTickets();
  }

  Future<void> fetchMyTickets() async {
    try {
      _isLoading.value = true;
      print('📋 Fetching driver support tickets...');

      final response = await _apiClient.get('/support/my-tickets');

      if (response != null && response['data'] != null) {
        final List<dynamic> data = response['data'];
        _myTickets.value = data.map((t) => SupportTicketModel.fromJson(t)).toList();
        print('✅ Loaded ${_myTickets.length} tickets');
      }
    } catch (e) {
      print('❌ Error fetching tickets: $e');
    } finally {
      _isLoading.value = false;
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

      final response = await _apiClient.post(
        '/support/contact',
        data: {
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
          'userRole': 'driver',
          'userId': userId,
        },
      );

      if (response != null && response['success'] == true) {
        await fetchMyTickets();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error submitting support request: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchTicketReplies(String ticketId) async {
    try {
      _isLoadingReplies.value = true;
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
      final response = await _apiClient.post(
        '/support/$ticketId/reply',
        data: {'message': message},
      );

      if (response != null && response['success'] == true) {
        await fetchTicketReplies(ticketId);
        await fetchMyTickets();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error adding reply: $e');
      return false;
    }
  }
}