import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/common/support_ticket_model.dart';

import '../../passenger/controllers/support_controller.dart';

class AdminSupportController extends GetxController {
  static AdminSupportController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  final _isLoading = false.obs;
  final _tickets = <SupportTicketModel>[].obs;
  final _filteredTickets = <SupportTicketModel>[].obs;
  final _selectedTicket = Rxn<SupportTicketModel>();
  final _selectedStatus = 'all'.obs;
  final _searchQuery = ''.obs;

  bool get isLoading => _isLoading.value;
  List<SupportTicketModel> get tickets => _filteredTickets;
  SupportTicketModel? get selectedTicket => _selectedTicket.value;
  String get selectedStatus => _selectedStatus.value;
  String get searchQuery => _searchQuery.value;

  final _replies = <ReplyModel>[].obs;
  final _isLoadingReplies = false.obs;
  List<ReplyModel> get replies => _replies;
  bool get isLoadingReplies => _isLoadingReplies.value;
  final List<String> statusOptions = [
    'all',
    'pending',
    'in_progress',
    'resolved',
    'closed',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
  }

  Future<void> fetchTicketReplies(String ticketId) async {
    try {
      _isLoadingReplies.value = true;
      final response = await _apiClient.get('/support/$ticketId/replies');

      if (response != null && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> repliesData = data['replies'] ?? [];
        _replies.value = repliesData.map((r) => ReplyModel.fromJson(r)).toList();
      }
    } catch (e) {
      print('Error fetching replies: $e');
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
        Get.snackbar('Success', 'Reply sent successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding reply: $e');
      Get.snackbar('Error', 'Failed to send reply');
      return false;
    }
  }
  Future<void> fetchTickets() async {
    try {
      _isLoading.value = true;
      print('📦 Fetching support tickets...');

      final response = await _apiClient.get('/support/all');

      print('📦 Response received');

      if (response != null && response['data'] != null) {
        final List<dynamic> data = response['data'];
        _tickets.value = data.map((t) => SupportTicketModel.fromJson(t)).toList();
        print('✅ Loaded ${_tickets.length} tickets');

        // Print statuses for debugging
        final statuses = _tickets.map((t) => t.status).toList();
        print('📊 Ticket statuses: $statuses');

        _applyFilters();
      } else {
        print('⚠️ No tickets data found');
        _tickets.clear();
        _filteredTickets.clear();
      }
    } catch (e) {
      print('❌ Error fetching support tickets: $e');
      Get.snackbar('Error', 'Failed to load support tickets');
    } finally {
      _isLoading.value = false;
    }
  }

  void _applyFilters() {
    var filtered = List<SupportTicketModel>.from(_tickets);

    // Apply status filter
    if (_selectedStatus.value != 'all') {
      filtered = filtered.where((t) => t.status == _selectedStatus.value).toList();
    }

    // Apply search
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((t) =>
      t.name.toLowerCase().contains(query) ||
          t.email.toLowerCase().contains(query) ||
          t.subject.toLowerCase().contains(query) ||
          t.id.toLowerCase().contains(query)).toList();
    }

    _filteredTickets.value = filtered;
    print('🔍 Filtered to ${_filteredTickets.length} tickets');
  }

  void setStatusFilter(String status) {
    _selectedStatus.value = status;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  Future<void> fetchTicketDetails(String ticketId) async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.get('/support/$ticketId');

      if (response != null && response['data'] != null) {
        _selectedTicket.value = SupportTicketModel.fromJson(response['data']);
      }
    } catch (e) {
      print('Error fetching ticket details: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateTicketStatus(String ticketId, String status, {String? adminResponse}) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.patch(
        '/support/$ticketId/status',
        data: {
          'status': status,
          if (adminResponse != null && adminResponse.isNotEmpty) 'adminResponse': adminResponse,
        },
      );

      if (response != null && response['success'] == true) {
        // Update local list
        final index = _tickets.indexWhere((t) => t.id == ticketId);
        if (index != -1) {
          _tickets[index] = _tickets[index].copyWith(status: status);
          if (adminResponse != null && adminResponse.isNotEmpty) {
            _tickets[index] = _tickets[index].copyWith(adminResponse: adminResponse);
          }
          _applyFilters();
        }

        Get.snackbar(
          'Success',
          'Ticket status updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Refresh to get latest data
        await fetchTickets();
      }
    } catch (e) {
      print('Error updating ticket: $e');
      Get.snackbar('Error', 'Failed to update ticket status');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshTickets() async {
    await fetchTickets();
  }

  void clearSelectedTicket() {
    _selectedTicket.value = null;
  }

  // Fix the count getters - use _tickets instead of _filteredTickets
  int get pendingCount {
    final count = _tickets.where((t) => t.status == 'pending').length;
    print('📊 Pending count: $count');
    return count;
  }

  int get inProgressCount {
    final count = _tickets.where((t) => t.status == 'in_progress').length;
    print('📊 In Progress count: $count');
    return count;
  }

  int get resolvedCount {
    // Count both 'resolved' and 'closed' as resolved
    final count = _tickets.where((t) => t.status == 'resolved' || t.status == 'closed').length;
    print('📊 Resolved/Closed count: $count');
    return count;
  }
}