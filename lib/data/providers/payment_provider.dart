// lib/data/providers/payment_provider.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/data/models/payment/payment_model.dart';
import 'package:menahariya/data/models/common/api_response.dart';

class PaymentProvider extends GetxController {
  static PaymentProvider get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Initiate Payment
  Future<ApiResponse<Map<String, dynamic>>> initiatePayment({
    required String bookingId,
    required double amount,
    required String method,
    Map<String, dynamic>? paymentDetails,
    bool useWallet = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.paymentsInitiate,
        data: {
          'bookingId': bookingId,
          'amount': amount,
          'method': method,
          'paymentDetails': paymentDetails,
          'useWallet': useWallet,
        },
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

  // Telebirr Payment
  Future<ApiResponse<Map<String, dynamic>>> initiateTelebirrPayment({
    required String bookingId,
    required double amount,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.paymentsTelebirr,
        data: {
          'bookingId': bookingId,
          'amount': amount,
          'phone': phone,
        },
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

  // CBE Birr Payment
  Future<ApiResponse<Map<String, dynamic>>> initiateCbeBirrPayment({
    required String bookingId,
    required double amount,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.paymentsCBE,
        data: {
          'bookingId': bookingId,
          'amount': amount,
          'phone': phone,
        },
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

  // Verify Payment
  Future<ApiResponse<Map<String, dynamic>>> verifyPayment(String paymentId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.paymentsVerify}/$paymentId',
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

  // Get Payment Status
  Future<ApiResponse<Map<String, dynamic>>> getPaymentStatus(String paymentId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.paymentsStatus}/$paymentId',
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

  // Get Payment Methods
  Future<ApiResponse<List<Map<String, dynamic>>>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.paymentsMethods);

      return ApiResponse<List<Map<String, dynamic>>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Process Refund
  Future<ApiResponse<Map<String, dynamic>>> processRefund({
    required String paymentId,
    double? amount,
    String? reason,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.paymentsRefund,
        data: {
          'paymentId': paymentId,
          'amount': amount,
          'reason': reason,
        },
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

  // Get Payment History
  Future<ApiResponse<List<PaymentModel>>> getPaymentHistory({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final response = await _apiClient.get(
        '/payments/history',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );

      return ApiResponse<List<PaymentModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => PaymentModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Wallet Balance
  Future<ApiResponse<double>> getWalletBalance() async {
    try {
      final response = await _apiClient.get('/wallet/balance');

      return ApiResponse<double>.fromJson(
        response,
            (data) => (data['balance'] ?? 0).toDouble(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}