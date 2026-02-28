// lib/data/providers/booking_provider.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/data/models/ticket/booking_request.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';
import 'package:menahariya/data/models/common/api_response.dart';

class BookingProvider extends GetxController {
  static BookingProvider get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Create Booking
  Future<ApiResponse<Map<String, dynamic>>> createBooking(BookingRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.bookingsCreate,
        data: request.toJson(),
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
            (data) => Map<String, dynamic>.from(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Confirm Booking
  Future<ApiResponse<Map<String, dynamic>>> confirmBooking(String bookingId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.bookingsConfirm,
        data: {'bookingId': bookingId},
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
            (data) => Map<String, dynamic>.from(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Booking Details
  Future<ApiResponse<Map<String, dynamic>>> getBookingDetails(String bookingId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.bookingsDetails}/$bookingId',
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
            (data) => Map<String, dynamic>.from(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Booking History
  Future<ApiResponse<List<TicketModel>>> getBookingHistory({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.bookingsHistory,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );

      return ApiResponse<List<TicketModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => TicketModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Cancel Booking
  Future<ApiResponse<dynamic>> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.bookingsCancel,
        data: {
          'bookingId': bookingId,
          'reason': reason,
        },
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get My Tickets
  Future<ApiResponse<List<TicketModel>>> getMyTickets({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.ticketsMyTickets,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );

      return ApiResponse<List<TicketModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => TicketModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Ticket Details
  Future<ApiResponse<TicketModel>> getTicketDetails(String ticketId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.tickets}/$ticketId',
      );

      return ApiResponse<TicketModel>.fromJson(
        response,
            (data) => TicketModel.fromJson(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Validate Ticket
  Future<ApiResponse<Map<String, dynamic>>> validateTicket(String ticketCode) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.ticketsValidate,
        data: {'ticketCode': ticketCode},
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
            (data) => Map<String, dynamic>.from(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Generate QR Code
  Future<ApiResponse<String>> generateQRCode(String ticketId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.ticketsGenerateQR}/$ticketId',
      );

      return ApiResponse<String>.fromJson(
        response,
            (data) => data['qrCode'] ?? '',
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Download Ticket
  Future<ApiResponse<String>> downloadTicket(String ticketId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.ticketsDownload}/$ticketId',
      );

      return ApiResponse<String>.fromJson(
        response,
            (data) => data['url'] ?? '',
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}