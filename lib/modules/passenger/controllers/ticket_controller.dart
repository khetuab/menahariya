// lib/modules/passenger/controllers/ticket_controller.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/modules/passenger/controllers/search_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/formatters/date_formatter.dart';
import '../../../data/models/trip/trip_model.dart';

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

  // Trip search observables
  final origin = ''.obs;
  final destination = ''.obs;
  final selectedDate = Rxn<DateTime>();
  final availableTrips = <TripModel>[].obs;
  final _isLoadingTrips = false.obs;
  final placeSuggestions = <Place>[].obs;

  // Focus nodes for suggestions
  final originFocusNode = FocusNode();
  final destinationFocusNode = FocusNode();
  final showOriginSuggestions = false.obs;
  final showDestinationSuggestions = false.obs;

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;
  final _totalCount = 0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoadingTrips => _isLoadingTrips.value;
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
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    originFocusNode.addListener(() {
      showOriginSuggestions.value = originFocusNode.hasFocus;
    });

    destinationFocusNode.addListener(() {
      showDestinationSuggestions.value = destinationFocusNode.hasFocus;
    });
  }

  Future<void> getPlaceSuggestions(String query) async {
    if (query.length < 2) {
      placeSuggestions.clear();
      return;
    }

    try {
      final response = await _apiClient.get(
        '/places/suggest',  // Make sure this endpoint exists
        queryParameters: {'q': query},
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> placesData = response['data'];
        placeSuggestions.value = placesData
            .map((p) => Place.fromJson(p))
            .toList();
      }
    } catch (e) {
      print('❌ Error getting suggestions: $e');
      placeSuggestions.clear();
    }
  }

  Future<void> searchTripsForTicket() async {
    if (origin.value.isEmpty || destination.value.isEmpty || selectedDate.value == null) {
      Get.snackbar(
        'Missing Information',
        'Please fill all search fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      _isLoadingTrips.value = true;

      final response = await _apiClient.get(
        ApiEndpoints.tripsSearch,
        queryParameters: {
          'origin': origin.value,
          'destination': destination.value,
          'date': DateFormatter.toApiDate(selectedDate.value!),
        },
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> tripsData = response['data'];
        availableTrips.value = tripsData.map((t) => TripModel.fromJson(t)).toList();

        if (availableTrips.isEmpty) {
          Get.snackbar(
            'No Trips',
            'No trips found for your search',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print('Error searching trips: $e');
      Get.snackbar(
        'Error',
        'Failed to search trips',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingTrips.value = false;
    }
  }

  // In PassengerTicketController, update selectTripForTicket:

  void selectTripForTicket(TripModel trip) {
    // Clear suggestions before navigating
    placeSuggestions.clear();
    originFocusNode.unfocus();
    destinationFocusNode.unfocus();

    // Navigate to trip detail to book the ticket
    Get.toNamed(
      AppRoutes.passengerTripDetail,  // Changed from passengerTicketSelectTrip
      arguments: {'tripId': trip.id},
    );
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

  // In PassengerTicketController, make sure getTicketDetails is working:

  Future<TicketModel?> getTicketDetails(String ticketId) async {
    try {
      _isLoading.value = true;

      print('🔍 Fetching ticket details for ID: $ticketId');

      final response = await _apiClient.get(
        '${ApiEndpoints.tickets}/$ticketId',
      );

      if (response != null && response['data'] != null) {
        print('✅ Ticket details received');
        final ticket = TicketModel.fromJson(response['data']);
        _selectedTicket.value = ticket;
        return ticket;
      }
      return null;
    } catch (e) {
      print('❌ Error fetching ticket details: $e');
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

  // In PassengerTicketController, fix the downloadTicket method:

  // In PassengerTicketController, alternative Dio approach:

  Future<void> downloadTicket(TicketModel ticket) async {
    try {
      final String ticketId = ticket.id;
      if (ticketId.isEmpty) {
        Get.snackbar('Error', 'Invalid ticket ID');
        return;
      }

      Get.snackbar('Processing', 'Downloading your ticket...');

      // Configure Dio for binary response
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.ticketsDownload}/$ticketId',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );

      if (response.statusCode == 200) {
        // Save the PDF file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/ticket_$ticketId.pdf');
        await file.writeAsBytes(response.data);

        print('✅ PDF saved to: ${file.path}');

        // Share the PDF file
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Your Ticket - ${ticket.origin} to ${ticket.destination}',
        );

        Get.snackbar('Success', 'Ticket downloaded successfully');
      }
    } catch (e) {
      print('❌ Error downloading ticket: $e');
      Get.snackbar('Error', 'Failed to download ticket');
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

  void swapLocations() {
    final temp = origin.value;
    origin.value = destination.value;
    destination.value = temp;
  }

  @override
  void onClose() {
    originFocusNode.dispose();
    destinationFocusNode.dispose();
    super.onClose();
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