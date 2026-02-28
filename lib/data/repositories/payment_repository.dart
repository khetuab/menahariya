// lib/data/repositories/payment_repository.dart

import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/core/services/storage/local_storage.dart';
import 'package:menahariya/data/providers/payment_provider.dart';
import 'package:menahariya/data/models/payment/payment_model.dart';

class PaymentRepository extends GetxController {
  static PaymentRepository get instance => Get.find();

  final PaymentProvider _paymentProvider = PaymentProvider.instance;
  final LocalStorage _localStorage = LocalStorage();

  // Cache keys
  static const String _cachePaymentMethods = 'payment_methods';
  static const String _cacheWalletBalance = 'wallet_balance';
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Initiate Payment
  Future<Map<String, dynamic>> initiatePayment({
    required String bookingId,
    required double amount,
    required String method,
    Map<String, dynamic>? paymentDetails,
    bool useWallet = false,
  }) async {
    try {
      final response = await _paymentProvider.initiatePayment(
        bookingId: bookingId,
        amount: amount,
        method: method,
        paymentDetails: paymentDetails,
        useWallet: useWallet,
      );

      if (response.success) {
        return response.data ?? {};
      }

      throw ApiException(
        message: response.message ?? 'Payment initiation failed',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handlePaymentError(e);
    }
  }

  // Telebirr Payment
  Future<Map<String, dynamic>> initiateTelebirrPayment({
    required String bookingId,
    required double amount,
    required String phone,
  }) async {
    try {
      final response = await _paymentProvider.initiateTelebirrPayment(
        bookingId: bookingId,
        amount: amount,
        phone: phone,
      );

      if (response.success) {
        return response.data ?? {};
      }

      throw ApiException(
        message: response.message ?? 'Telebirr payment failed',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handlePaymentError(e);
    }
  }

  // CBE Birr Payment
  Future<Map<String, dynamic>> initiateCbeBirrPayment({
    required String bookingId,
    required double amount,
    required String phone,
  }) async {
    try {
      final response = await _paymentProvider.initiateCbeBirrPayment(
        bookingId: bookingId,
        amount: amount,
        phone: phone,
      );

      if (response.success) {
        return response.data ?? {};
      }

      throw ApiException(
        message: response.message ?? 'CBE Birr payment failed',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handlePaymentError(e);
    }
  }

  // Verify Payment
  Future<Map<String, dynamic>> verifyPayment(String paymentId) async {
    try {
      final response = await _paymentProvider.verifyPayment(paymentId);

      if (response.success) {
        return response.data ?? {};
      }

      throw ApiException(
        message: response.message ?? 'Payment verification failed',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handlePaymentError(e);
    }
  }

  // Get Payment Status
  Future<String> getPaymentStatus(String paymentId) async {
    try {
      final response = await _paymentProvider.getPaymentStatus(paymentId);

      if (response.success) {
        return response.data?['status'] ?? 'unknown';
      }

      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  // Get Payment Methods with Caching
  Future<List<PaymentMethodModel>> getPaymentMethods({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _localStorage.getCachedData(_cachePaymentMethods);
        if (cached != null) {
          return (cached as List)
              .map((item) => PaymentMethodModel.fromJson(item))
              .toList();
        }
      }

      final response = await _paymentProvider.getPaymentMethods();

      if (response.success) {
        final methods = (response.data ?? [])
            .map((item) => PaymentMethodModel.fromJson(item))
            .toList();

        // Cache the result
        await _localStorage.cacheData(
          _cachePaymentMethods,
          methods.map((m) => m.toJson()).toList(),
          expiry: _cacheDuration,
        );

        return methods;
      }

      return [];
    } catch (e) {
      print('Error getting payment methods: $e');
      return [];
    }
  }

  // Process Refund
  Future<Map<String, dynamic>> processRefund({
    required String paymentId,
    double? amount,
    String? reason,
  }) async {
    try {
      final response = await _paymentProvider.processRefund(
        paymentId: paymentId,
        amount: amount,
        reason: reason,
      );

      if (response.success) {
        return response.data ?? {};
      }

      throw ApiException(
        message: response.message ?? 'Refund failed',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handlePaymentError(e);
    }
  }

  // Get Payment History
  Future<List<PaymentModel>> getPaymentHistory({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final response = await _paymentProvider.getPaymentHistory(
        page: page,
        limit: limit,
        status: status,
      );

      if (response.success) {
        return response.data ?? [];
      }

      return [];
    } catch (e) {
      print('Error getting payment history: $e');
      return [];
    }
  }

  // Get Wallet Balance with Caching
  Future<double> getWalletBalance({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _localStorage.getCachedData(_cacheWalletBalance);
        if (cached != null) {
          return cached['balance']?.toDouble() ?? 0.0;
        }
      }

      final response = await _paymentProvider.getWalletBalance();

      if (response.success) {
        final balance = response.data ?? 0.0;

        // Cache the result
        await _localStorage.cacheData(
          _cacheWalletBalance,
          {'balance': balance},
          expiry: _cacheDuration,
        );

        return balance;
      }

      return 0.0;
    } catch (e) {
      print('Error getting wallet balance: $e');
      return 0.0;
    }
  }

  // Handle Payment Errors
  ApiException _handlePaymentError(ApiException e) {
    switch (e.statusCode) {
      case 400:
        return ApiException(
          message: 'Invalid payment details',
          statusCode: 400,
        );
      case 402:
        return ApiException(
          message: 'Payment failed - insufficient funds',
          statusCode: 402,
        );
      case 409:
        return ApiException(
          message: 'Payment already processed',
          statusCode: 409,
        );
      default:
        return e;
    }
  }
}