// lib/data/repositories/booking_repository.dart

import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/core/services/storage/local_storage.dart';
import 'package:menahariya/data/providers/booking_provider.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';
import 'package:menahariya/data/models/ticket/booking_request.dart';
import 'package:menahariya/data/models/booking/booking_model.dart'; // Add this import

class BookingRepository extends GetxController {
  static BookingRepository get instance => Get.find();

  final BookingProvider _bookingProvider = BookingProvider.instance;
  final LocalStorage _localStorage = LocalStorage();

  // Cache keys
  static const String _cacheMyTickets = 'my_tickets';
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Create Booking
  Future<BookingModel> createBooking(BookingRequest request) async {
    try {
      final response = await _bookingProvider.createBooking(request);

      if (response.success && response.data != null) {
        return BookingModel.fromJson(response.data!);
      }

      throw ApiException(
        message: response.message ?? 'Failed to create booking',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleBookingError(e);
    }
  }

  // Confirm Booking
  Future<Map<String, dynamic>> confirmBooking(String bookingId) async {
    try {
      final response = await _bookingProvider.confirmBooking(bookingId);

      if (response.success && response.data != null) {
        // Clear cached tickets as they're now outdated
        await _localStorage.clear(_cacheMyTickets);

        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to confirm booking',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleBookingError(e);
    }
  }

  // Get Booking Details
  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    try {
      final response = await _bookingProvider.getBookingDetails(bookingId);

      if (response.success) {
        return response.data ?? {};
      }

      throw ApiException(
        message: response.message ?? 'Failed to get booking details',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleBookingError(e);
    }
  }

  // Get Booking History with Pagination
  Future<List<TicketModel>> getBookingHistory({
    int page = 1,
    int limit = 10,
    String? status,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache for first page only
      if (!forceRefresh && page == 1 && status == null) {
        final cached = await _localStorage.getCachedData(_cacheMyTickets);
        if (cached != null) {
          if (cached is List) {
            return cached.map((item) => TicketModel.fromJson(item)).toList();
          }
        }
      }

      final response = await _bookingProvider.getBookingHistory(
        page: page,
        limit: limit,
        status: status,
      );

      if (response.success) {
        final tickets = response.data ?? [];

        // Cache first page results
        if (page == 1 && status == null) {
          await _localStorage.cacheData(
            _cacheMyTickets,
            tickets.map((t) => t.toJson()).toList(),
            expiry: _cacheDuration,
          );
        }

        return tickets;
      }

      return [];
    } on ApiException catch (e) {
      print('Error getting booking history: ${e.message}');
      return [];
    }
  }

  // Get My Tickets with Pagination
  Future<List<TicketModel>> getMyTickets({
    int page = 1,
    int limit = 10,
    String? status,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _bookingProvider.getMyTickets(
        page: page,
        limit: limit,
        status: status,
      );

      if (response.success) {
        return response.data ?? [];
      }

      return [];
    } on ApiException catch (e) {
      print('Error getting my tickets: ${e.message}');
      return [];
    }
  }

  // Get Ticket Details
  Future<TicketModel> getTicketDetails(String ticketId) async {
    try {
      // Check cache first
      final cached = await _localStorage.getCachedData('ticket_$ticketId');
      if (cached != null) {
        if (cached is Map) {
          return TicketModel.fromJson(Map<String, dynamic>.from(cached));
        }
      }

      final response = await _bookingProvider.getTicketDetails(ticketId);

      if (response.success && response.data != null) {
        // Cache the result
        await _localStorage.cacheData(
          'ticket_$ticketId',
          response.data!.toJson(),
          expiry: _cacheDuration,
        );

        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to get ticket details',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleBookingError(e);
    }
  }

  // Cancel Booking
  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final response = await _bookingProvider.cancelBooking(bookingId, reason: reason);

      if (response.success) {
        // Clear caches
        await _localStorage.clear(_cacheMyTickets);
        await _localStorage.delete('ticket_$bookingId', ''); // Fixed: Added box name parameter
        return true;
      }

      return false;
    } on ApiException catch (e) {
      print('Error cancelling booking: ${e.message}');
      return false;
    }
  }

  // Validate Ticket
  Future<Map<String, dynamic>> validateTicket(String ticketCode) async {
    try {
      final response = await _bookingProvider.validateTicket(ticketCode);

      if (response.success) {
        return response.data ?? {};
      }

      throw ApiException(
        message: response.message ?? 'Invalid ticket',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleBookingError(e);
    }
  }

  // Generate QR Code
  Future<String?> generateQRCode(String ticketId) async {
    try {
      final response = await _bookingProvider.generateQRCode(ticketId);

      if (response.success) {
        return response.data;
      }

      return null;
    } on ApiException catch (e) {
      print('Error generating QR code: ${e.message}');
      return null;
    }
  }

  // Download Ticket
  Future<String?> downloadTicket(String ticketId) async {
    try {
      final response = await _bookingProvider.downloadTicket(ticketId);

      if (response.success) {
        return response.data;
      }

      return null;
    } on ApiException catch (e) {
      print('Error downloading ticket: ${e.message}');
      return null;
    }
  }

  // Get Active Tickets Count
  Future<int> getActiveTicketsCount() async {
    try {
      final tickets = await getMyTickets(status: 'active');
      return tickets.length;
    } catch (e) {
      return 0;
    }
  }

  // Handle Booking Errors
  ApiException _handleBookingError(ApiException e) {
    switch (e.statusCode) {
      case 400:
        return ApiException(
          message: 'Invalid booking request',
          statusCode: 400,
        );
      case 409:
        return ApiException(
          message: 'Seats are no longer available',
          statusCode: 409,
        );
      case 410:
        return ApiException(
          message: 'Booking session expired',
          statusCode: 410,
        );
      default:
        return e;
    }
  }
}