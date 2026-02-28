// lib/modules/passenger/controllers/payment_controller.dart

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/core/services/payment/payment_service.dart';
import 'package:menahariya/data/models/booking/booking_model.dart';
import 'package:menahariya/data/models/payment/payment_model.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';

class PassengerPaymentController extends GetxController {
  static PassengerPaymentController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;
  final PaymentService _paymentService = PaymentService.instance;

  // Payment data from arguments
  late final BookingModel booking;
  late final double amount;

  // Observables
  final _isLoading = false.obs;
  final _isProcessing = false.obs;
  final _paymentStatus = PaymentStatus.processing.obs;
  final _paymentMethods = <PaymentMethod>[].obs;
  final _selectedMethod = Rxn<PaymentMethod>();
  final _payment = Rxn<PaymentModel>();
  final _countdownSeconds = 300.obs; // 5 minutes countdown
  Timer? _countdownTimer;
  Timer? _statusChecker;

  // Form controllers for card payment
  late final TextEditingController cardNumberController;
  late final TextEditingController cardExpiryController;
  late final TextEditingController cardCvvController;
  late final TextEditingController cardNameController;

  // Mobile money fields
  late final TextEditingController mobileMoneyPhoneController;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isProcessing => _isProcessing.value;
  PaymentStatus get paymentStatus => _paymentStatus.value;
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  PaymentMethod? get selectedMethod => _selectedMethod.value;
  PaymentModel? get payment => _payment.value;
  int get countdownSeconds => _countdownSeconds.value;
  String get formattedAmount => CurrencyFormatter.format(amount);

  String get countdownText {
    final minutes = _countdownSeconds.value ~/ 60;
    final seconds = _countdownSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    _getArguments();
    _initializeControllers();
    _loadPaymentMethods();
    _startCountdown();
    _setupSocketListeners();
  }

  void _getArguments() {
    final args = Get.arguments;
    if (args != null) {
      booking = args['booking'];
      amount = args['finalTotal'];
    } else {
      Get.back();
      Get.snackbar(
        'Error',
        'Payment information not found',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Handle payment confirmation from socket
  void handlePaymentConfirmation(Map<String, dynamic> data) {
    if (data['paymentId'] == _payment.value?.id) {
      final String status = data['status'];

      if (status == 'completed') {
        _paymentStatus.value = PaymentStatus.completed;
        _countdownTimer?.cancel();
        _statusChecker?.cancel();
        _handlePaymentSuccess();
      } else if (status == 'failed') {
        _paymentStatus.value = PaymentStatus.failed;
        Get.snackbar(
          'Payment Failed',
          data['message'] ?? 'Transaction failed',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void _initializeControllers() {
    cardNumberController = TextEditingController();
    cardExpiryController = TextEditingController();
    cardCvvController = TextEditingController();
    cardNameController = TextEditingController();
    mobileMoneyPhoneController = TextEditingController();
  }

  void _setupSocketListeners() {
    _socketService.on('payment_confirmed', _handlePaymentConfirmed);
    _socketService.on('payment_failed', _handlePaymentFailed);
  }

  Future<void> _loadPaymentMethods() async {
    try {
      _isLoading.value = true;
      final methods = await _paymentService.getPaymentMethods();
      _paymentMethods.value = methods;

      // Select first available method by default
      if (methods.isNotEmpty) {
        _selectedMethod.value = methods.first;
      }
    } catch (e) {
      print('Error loading payment methods: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds.value > 0) {
        _countdownSeconds.value--;
      } else {
        _handlePaymentTimeout();
      }
    });
  }

  void _handlePaymentTimeout() {
    _countdownTimer?.cancel();
    _statusChecker?.cancel();
    _paymentStatus.value = PaymentStatus.timeout;

    Get.snackbar(
      'Payment Timeout',
      'The payment session has expired. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  }

  void selectPaymentMethod(PaymentMethod method) {
    _selectedMethod.value = method;
  }

  Future<void> initiatePayment() async {
    if (_selectedMethod.value == null) {
      Get.snackbar(
        'No Payment Method',
        'Please select a payment method',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      _isProcessing.value = true;

      PaymentModel? payment;

      switch (_selectedMethod.value!.code) {
        case 'telebirr':
          payment = await _paymentService.initiateTelebirrPayment(
            amount: amount,
            phone: mobileMoneyPhoneController.text,
            reference: booking.id,
            metadata: {'bookingId': booking.id},
          );
          break;

        case 'cbe_birr':
          payment = await _paymentService.initiateCbeBirrPayment(
            amount: amount,
            phone: mobileMoneyPhoneController.text,
            reference: booking.id,
            metadata: {'bookingId': booking.id},
          );
          break;

        case 'card':
          payment = await _paymentService.initiateCardPayment(
            amount: amount,
            cardNumber: cardNumberController.text,
            expiryMonth: cardExpiryController.text.split('/').first,
            expiryYear: '20${cardExpiryController.text.split('/').last}',
            cvv: cardCvvController.text,
            reference: booking.id,
            metadata: {
              'bookingId': booking.id,
              'cardHolder': cardNameController.text,
            },
          );
          break;

        case 'wallet':
          payment = await _processWalletPayment();
          break;
      }

      if (payment != null) {
        _payment.value = payment;
        _paymentStatus.value = PaymentStatus.pending;
        _startStatusChecking(payment.id);
      }
    } catch (e) {
      print('Payment initiation error: $e');
      _paymentStatus.value = PaymentStatus.failed;
      Get.snackbar(
        'Payment Failed',
        'Failed to initiate payment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<PaymentModel?> _processWalletPayment() async {
    try {
      final response = await _apiClient.post(
        '/payments/wallet',
        data: {
          'bookingId': booking.id,
          'amount': amount,
        },
      );

      if (response != null && response['data'] != null) {
        return PaymentModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Wallet payment error: $e');
      return null;
    }
  }

  void _startStatusChecking(String paymentId) {
    int attempts = 0;
    const maxAttempts = 30; // 30 attempts * 2 seconds = 1 minute

    _statusChecker = Timer.periodic(const Duration(seconds: 2), (timer) async {
      attempts++;

      final status = await _paymentService.verifyPayment(paymentId);

      if (status == PaymentStatus.completed) {
        timer.cancel();
        _countdownTimer?.cancel();
        _paymentStatus.value = PaymentStatus.completed;
        _handlePaymentSuccess();
      } else if (status == PaymentStatus.failed || attempts >= maxAttempts) {
        timer.cancel();
        _paymentStatus.value = PaymentStatus.failed;
      }
    });
  }

  void _handlePaymentConfirmed(dynamic data) {
    if (data['paymentId'] == _payment.value?.id) {
      _countdownTimer?.cancel();
      _statusChecker?.cancel();
      _paymentStatus.value = PaymentStatus.completed;
      _handlePaymentSuccess();
    }
  }

  void _handlePaymentFailed(dynamic data) {
    if (data['paymentId'] == _payment.value?.id) {
      _paymentStatus.value = PaymentStatus.failed;
      Get.snackbar(
        'Payment Failed',
        data['message'] ?? 'Transaction failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handlePaymentSuccess() {
    Get.offAllNamed(
      '/passenger/payment/success',
      arguments: {
        'booking': booking,
        'payment': _payment.value,
      },
    );
  }

  void retryPayment() {
    _paymentStatus.value = ProcessingStatus.processing as PaymentStatus;
    _countdownSeconds.value = 300;
    _startCountdown();
    initiatePayment();
  }

  void cancelPayment() {
    _countdownTimer?.cancel();
    _statusChecker?.cancel();
    Get.back();
    Get.snackbar(
      'Payment Cancelled',
      'Your payment has been cancelled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Card input formatters
  void formatCardNumber(String value) {
    // Remove all non-digits
    String digits = value.replaceAll(RegExp(r'\D'), '');

    // Add spaces every 4 digits
    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += digits[i];
    }

    cardNumberController.value = cardNumberController.value.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void formatExpiry(String value) {
    // Remove all non-digits
    String digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length >= 2) {
      String month = digits.substring(0, 2);
      if (int.parse(month) > 12) {
        month = '12';
      }

      String formatted = month;
      if (digits.length > 2) {
        String year = digits.substring(2, digits.length > 4 ? 4 : digits.length);
        formatted += '/$year';
      }

      cardExpiryController.value = cardExpiryController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      cardExpiryController.text = digits;
    }
  }

  void formatCvv(String value) {
    if (value.length > 3) {
      cardCvvController.text = value.substring(0, 3);
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _statusChecker?.cancel();
    cardNumberController.dispose();
    cardExpiryController.dispose();
    cardCvvController.dispose();
    cardNameController.dispose();
    mobileMoneyPhoneController.dispose();
    _socketService.off('payment_confirmed', _handlePaymentConfirmed);
    _socketService.off('payment_failed', _handlePaymentFailed);
    super.onClose();
  }
}

enum PaymentStatus {
  processing,
  pending,
  completed,
  failed,
  timeout,
}

enum ProcessingStatus {
  idle,
  processing,
  completed,
  failed,
}