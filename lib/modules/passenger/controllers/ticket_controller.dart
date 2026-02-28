// lib/modules/passenger/controllers/ticket_controller.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';

class PassengerTicketController extends GetxController {
  static PassengerTicketController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Screenshot controller for ticket capture
  final ScreenshotController screenshotController = ScreenshotController();

  // Observables
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _tickets = <TicketModel>[].obs;
  final _activeTickets = <TicketModel>[].obs;
  final _pastTickets = <TicketModel>[].obs;
  final _selectedTicket = Rxn<TicketModel>();
  final _currentFilter = TicketFilter.all.obs;
  final _searchQuery = ''.obs;

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;
  final _totalCount = 0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  List<TicketModel> get tickets => _tickets;
  List<TicketModel> get activeTickets => _activeTickets;
  List<TicketModel> get pastTickets => _pastTickets;
  TicketModel? get selectedTicket => _selectedTicket.value;
  TicketFilter get currentFilter => _currentFilter.value;
  String get searchQuery => _searchQuery.value;
  bool get hasMorePages => _hasMorePages.value;
  int get totalCount => _totalCount.value;

  // Filtered tickets based on current filter
  List<TicketModel> get filteredTickets {
    List<TicketModel> filtered = _tickets;

    // Apply filter
    switch (_currentFilter.value) {
      case TicketFilter.all:
        break;
      case TicketFilter.active:
        filtered = _activeTickets;
        break;
      case TicketFilter.past:
        filtered = _pastTickets;
        break;
      case TicketFilter.cancelled:
        filtered = _tickets.where((t) => t.status == 'cancelled').toList();
        break;
    }

    // Apply search
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.origin.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
            t.destination.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
            t.id.toLowerCase().contains(_searchQuery.value.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
  }

  Future<void> fetchTickets({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _tickets.clear();
    }

    if (!_hasMorePages.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        ApiEndpoints.ticketsMyTickets,
        queryParameters: {
          'page': _currentPage.value,
          'limit': AppConstants.defaultPageSize,
        },
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> ticketsData = response['data'];
        final newTickets = ticketsData.map((t) => TicketModel.fromJson(t)).toList();

        if (_currentPage.value == 1) {
          _tickets.value = newTickets;
        } else {
          _tickets.addAll(newTickets);
        }

        _totalCount.value = response['total'] ?? _tickets.length;
        _hasMorePages.value = newTickets.length >= AppConstants.defaultPageSize;
        _currentPage.value++;

        _categorizeTickets();
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  void _categorizeTickets() {
    final now = DateTime.now();

    _activeTickets.value = _tickets.where((t) {
      return t.departureTime.isAfter(now) &&
          t.status != 'cancelled' &&
          t.status != 'used';
    }).toList();

    _pastTickets.value = _tickets.where((t) {
      return t.departureTime.isBefore(now) ||
          t.status == 'used';
    }).toList();

    // Sort active tickets by departure time (soonest first)
    _activeTickets.sort((a, b) => a.departureTime.compareTo(b.departureTime));

    // Sort past tickets by departure time (most recent first)
    _pastTickets.sort((a, b) => b.departureTime.compareTo(a.departureTime));
  }

  Future<void> refreshTickets() async {
    _isRefreshing.value = true;
    await fetchTickets(refresh: true);
    _isRefreshing.value = false;
  }

  Future<void> loadMoreTickets() async {
    if (!_hasMorePages.value || _isLoading.value) return;
    await fetchTickets();
  }

  Future<TicketModel?> getTicketDetails(String ticketId) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '${ApiEndpoints.tickets}/$ticketId',
      );

      if (response != null && response['data'] != null) {
        final ticket = TicketModel.fromJson(response['data']);
        _selectedTicket.value = ticket;
        return ticket;
      }
      return null;
    } catch (e) {
      print('Error fetching ticket details: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  void setFilter(TicketFilter filter) {
    _currentFilter.value = filter;
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  Future<bool> cancelTicket(String ticketId) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.bookingsCancel,
        data: {'ticketId': ticketId},
      );

      if (response != null && response['success'] == true) {
        // Update local ticket status
        final index = _tickets.indexWhere((t) => t.id == ticketId);
        if (index != -1) {
          _tickets[index] = _tickets[index].copyWith(paymentStatus: 'cancelled');
          _tickets.refresh();
          _categorizeTickets();
        }

        Get.snackbar(
          'Success',
          'Ticket cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error cancelling ticket: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel ticket',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> shareTicket(TicketModel ticket) async {
    try {
      // Capture ticket widget as image
      final imageFile = await screenshotController.capture();

      if (imageFile != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/ticket_${ticket.id}.png')
            .writeAsBytes(imageFile);

        // Use XFile
        final xfile = XFile(file.path);

        await Share.shareXFiles(
          [xfile],
          text: 'My Ticket - ${ticket.origin} to ${ticket.destination}',
        );
      } else {
        // Fallback to text sharing
        Share.share(
          'Ticket: ${ticket.origin} to ${ticket.destination}\n'
              'Date: ${ticket.departureTime}\n'
              'Seat: ${ticket.seatNumber}\n'
              'Ticket ID: ${ticket.id}',
        );
      }
    } catch (e) {
      print('Error sharing ticket: $e');
      Get.snackbar(
        'Error',
        'Failed to share ticket',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> downloadTicket(TicketModel ticket) async {
    try {
      Get.snackbar(
        'Downloading',
        'Your ticket is being downloaded...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      final response = await _apiClient.get(
        '${ApiEndpoints.ticketsDownload}/$ticket.id',
        requiresAuth: true,
      );

      if (response != null && response['data'] != null) {
        final pdfUrl = response['data']['url'];

        // Download PDF
        // Implementation depends on your file handling
      }
    } catch (e) {
      print('Error downloading ticket: $e');
      Get.snackbar(
        'Error',
        'Failed to download ticket',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> validateTicket(String qrCode) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.ticketsValidate,
        data: {'qrCode': qrCode},
      );

      if (response != null && response['success'] == true) {
        Get.snackbar(
          'Success',
          'Ticket validated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error validating ticket: $e');
      Get.snackbar(
        'Error',
        'Invalid ticket',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  int getActiveTicketsCount() {
    return _activeTickets.length;
  }

  List<TicketModel> getUpcomingTickets({int limit = 3}) {
    return _activeTickets.take(limit).toList();
  }
}

enum TicketFilter {
  all,
  active,
  past,
  cancelled,
}

extension TicketFilterExtension on TicketFilter {
  String get displayName {
    switch (this) {
      case TicketFilter.all:
        return 'All Tickets';
      case TicketFilter.active:
        return 'Active';
      case TicketFilter.past:
        return 'Past';
      case TicketFilter.cancelled:
        return 'Cancelled';
    }
  }
}