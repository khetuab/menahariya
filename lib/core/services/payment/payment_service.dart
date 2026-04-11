// lib/core/services/payment/payment_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/data/models/payment/payment_model.dart';
import 'package:menahariya/data/models/payment/payment_request.dart';

class PaymentService extends GetxService {
  static PaymentService get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;

  // Payment state
  final _currentPayment = Rxn<PaymentModel>();
  PaymentModel? get currentPayment => _currentPayment.value;

  final _paymentStatus = Rx<PaymentStatus>(PaymentStatus.idle);
  PaymentStatus get paymentStatus => _paymentStatus.value;

  final _isProcessing = false.obs;
  bool get isProcessing => _isProcessing.value;

  @override
  void onInit() {
    super.onInit();
    _initPaymentListener();
  }

  void _initPaymentListener() {
    _socketService.on(ApiEndpoints.wsPaymentConfirm, _handleSocketPaymentConfirm);
  }

  // Initialize Telebirr payment
  Future<PaymentModel?> initiateTelebirrPayment({
    required double amount,
    required String phone,
    required String reference,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isProcessing.value = true;
      _paymentStatus.value = PaymentStatus.initiating;

      final response = await _apiClient.post(
        ApiEndpoints.paymentsTelebirr,
        data: {
          'amount': amount,
          'phone': phone,
          'reference': reference,
          'metadata': metadata,
          'currency': AppConstants.currencyCode,
        },
      );

      if (response != null && response['data'] != null) {
        final payment = PaymentModel.fromJson(response['data']);
        _currentPayment.value = payment;
        _paymentStatus.value = PaymentStatus.pending;

        // Start polling for payment status
        _startPolling(payment.id);

        return payment;
      }
      return null;
    } catch (e) {
      _paymentStatus.value = PaymentStatus.failed;
      throw e;
    } finally {
      _isProcessing.value = false;
    }
  }

  // Initialize CBE Birr payment
  Future<PaymentModel?> initiateCbeBirrPayment({
    required double amount,
    required String phone,
    required String reference,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isProcessing.value = true;
      _paymentStatus.value = PaymentStatus.initiating;

      final response = await _apiClient.post(
        ApiEndpoints.paymentsCBE,
        data: {
          'amount': amount,
          'phone': phone,
          'reference': reference,
          'metadata': metadata,
          'currency': AppConstants.currencyCode,
        },
      );

      if (response != null && response['data'] != null) {
        final payment = PaymentModel.fromJson(response['data']);
        _currentPayment.value = payment;
        _paymentStatus.value = PaymentStatus.pending;

        // Start polling for payment status
        _startPolling(payment.id);

        return payment;
      }
      return null;
    } catch (e) {
      _paymentStatus.value = PaymentStatus.failed;
      throw e;
    } finally {
      _isProcessing.value = false;
    }
  }

  // Initialize card payment
  Future<PaymentModel?> initiateCardPayment({
    required double amount,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String reference,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isProcessing.value = true;
      _paymentStatus.value = PaymentStatus.initiating;

      final response = await _apiClient.post(
        ApiEndpoints.paymentsInitiate,
        data: {
          'amount': amount,
          'method': 'card',
          'card_details': {
            'number': cardNumber,
            'expiry_month': expiryMonth,
            'expiry_year': expiryYear,
            'cvv': cvv,
          },
          'reference': reference,
          'metadata': metadata,
          'currency': AppConstants.currencyCode,
        },
      );

      if (response != null && response['data'] != null) {
        final payment = PaymentModel.fromJson(response['data']);
        _currentPayment.value = payment;
        _paymentStatus.value = payment.status == 'completed'
            ? PaymentStatus.completed
            : PaymentStatus.pending;

        return payment;
      }
      return null;
    } catch (e) {
      _paymentStatus.value = PaymentStatus.failed;
      throw e;
    } finally {
      _isProcessing.value = false;
    }
  }

  // Verify payment status
  Future<PaymentStatus> verifyPayment(String paymentId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.paymentsStatus}/$paymentId',
      );

      if (response != null && response['data'] != null) {
        final status = response['data']['status'];

        switch (status) {
          case 'completed':
          case 'success':
            _paymentStatus.value = PaymentStatus.completed;
            break;
          case 'failed':
            _paymentStatus.value = PaymentStatus.failed;
            break;
          case 'pending':
            _paymentStatus.value = PaymentStatus.pending;
            break;
          case 'refunded':
            _paymentStatus.value = PaymentStatus.refunded;
            break;
          case 'cancelled':
            _paymentStatus.value = PaymentStatus.cancelled;
            break;
          default:
            _paymentStatus.value = PaymentStatus.unknown;
        }

        return _paymentStatus.value;
      }
      return PaymentStatus.unknown;
    } catch (e) {
      return PaymentStatus.unknown;
    }
  }

  // Process refund
  Future<bool> processRefund(String paymentId, {double? amount}) async {
    try {
      _isProcessing.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.paymentsRefund,
        data: {
          'paymentId': paymentId,
          'amount': amount,
        },
      );

      if (response != null && response['data'] != null) {
        final refund = response['data'];
        return refund['success'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isProcessing.value = false;
    }
  }

  // Get payment methods
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.paymentsMethods,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> methods = response['data'];
        return methods.map((m) => PaymentMethod.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Calculate payment breakdown
  PaymentBreakdown calculateBreakdown({
    required double baseFare,
    double? cargoFee,
    double? serviceFee,
    double? discount,
    double? taxRate,
  }) {
    final subtotal = baseFare + (cargoFee ?? 0);
    final tax = taxRate != null ? subtotal * (taxRate / 100) : 0;
    final total = subtotal + tax + (serviceFee ?? 0) - (discount ?? 0);

    return PaymentBreakdown(
      baseFare: baseFare,
      cargoFee: cargoFee,
      serviceFee: serviceFee,
      discount: discount,
      tax: tax.toDouble(),
      total: total,
    );
  }

  // Start polling for payment status
  void _startPolling(String paymentId) {
    int attempts = 0;
    const maxAttempts = 30; // 30 attempts * 2 seconds = 1 minute max

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      attempts++;

      final status = await verifyPayment(paymentId);

      if (status == PaymentStatus.completed ||
          status == PaymentStatus.failed ||
          attempts >= maxAttempts) {
        timer.cancel();

        if (status == PaymentStatus.completed) {
          _paymentStatus.value = PaymentStatus.completed;
        } else if (status == PaymentStatus.failed || attempts >= maxAttempts) {
          _paymentStatus.value = PaymentStatus.failed;
        }
      }
    });
  }

  // Handle socket payment confirmation
  void _handleSocketPaymentConfirm(dynamic data) {
    try {
      final paymentId = data['paymentId'];
      final status = data['status'];

      if (_currentPayment.value?.id == paymentId) {
        switch (status) {
          case 'completed':
          case 'success':
            _paymentStatus.value = PaymentStatus.completed;
            break;
          case 'failed':
            _paymentStatus.value = PaymentStatus.failed;
            break;
        }
      }
    } catch (e) {
      print('Error handling socket payment confirm: $e');
    }
  }

  // Reset payment state
  void reset() {
    _currentPayment.value = null;
    _paymentStatus.value = PaymentStatus.idle;
    _isProcessing.value = false;
  }
}

// Enums and Models
enum PaymentStatus {
  idle,
  initiating,
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled,
  unknown,
}

class PaymentBreakdown {
  final double baseFare;
  final double? cargoFee;
  final double? serviceFee;
  final double? discount;
  final double tax;
  final double total;

  PaymentBreakdown({
    required this.baseFare,
    this.cargoFee,
    this.serviceFee,
    this.discount,
    required this.tax,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
    'baseFare': baseFare,
    'cargoFee': cargoFee,
    'serviceFee': serviceFee,
    'discount': discount,
    'tax': tax,
    'total': total,
  };
}

class PaymentMethod {
  final String id;
  final String name;
  final String code;
  final String? icon;
  final double? minAmount;
  final double? maxAmount;
  final bool isActive;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.code,
    this.icon,
    this.minAmount,
    this.maxAmount,
    required this.isActive,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    // Clean up the icon path
    String? iconPath = json['icon']?.toString();

    if (iconPath != null) {
      // Remove leading slash if present
      if (iconPath.startsWith('/')) {
        iconPath = iconPath.substring(1);
      }

      // Ensure it starts with 'assets/'
      if (!iconPath.startsWith('assets/')) {
        iconPath = 'assets/$iconPath';
      }

      // Remove double slashes if any
      iconPath = iconPath.replaceAll('//', '/');
    }

    return PaymentMethod(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? json['id'] ?? '',
      icon: iconPath,
      minAmount: json['minAmount']?.toDouble(),
      maxAmount: json['maxAmount']?.toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }
}