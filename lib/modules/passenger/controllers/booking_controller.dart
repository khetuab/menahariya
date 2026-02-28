// lib/modules/passenger/controllers/booking_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/data/models/booking/booking_model.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../../data/models/ticket/booking_request.dart';
import '../../../data/models/ticket/seat_model.dart';

class PassengerBookingController extends GetxController {
  static PassengerBookingController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;
  final AuthController _authController = AuthController.instance;

  // Booking data from arguments
  late final TripModel trip;
  late final List<SeatModel> selectedSeats;
  late final double totalPrice;

  // Form controllers
  late final TextEditingController passengerNameController;
  late final TextEditingController passengerPhoneController;
  late final TextEditingController passengerEmailController;
  late final TextEditingController specialRequestsController;

  // Observables
  final _isLoading = false.obs;
  final _isProcessing = false.obs;
  final _currentStep = 0.obs;
  final _booking = Rxn<BookingModel>();
  final _selectedPaymentMethod = Rxn<String>();
  final _agreeToTerms = false.obs;
  final _useWalletBalance = false.obs;
  final _walletBalance = 0.0.obs;
  final _insuranceSelected = false.obs;
  final _mealPreferences = <String>[].obs;

  // Additional passengers
  final _additionalPassengers = <PassengerDetail>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isProcessing => _isProcessing.value;
  int get currentStep => _currentStep.value;
  BookingModel? get booking => _booking.value;
  String? get selectedPaymentMethod => _selectedPaymentMethod.value;
  bool get agreeToTerms => _agreeToTerms.value;
  bool get useWalletBalance => _useWalletBalance.value;
  double get walletBalance => _walletBalance.value;
  bool get insuranceSelected => _insuranceSelected.value;
  List<String> get mealPreferences => _mealPreferences;
  List<PassengerDetail> get additionalPassengers => _additionalPassengers;

  // Computed getters
  double get subtotal => totalPrice;

  double get insuranceFee => insuranceSelected ? totalPrice * 0.05 : 0;

  double get walletDeduction {
    if (!useWalletBalance) return 0;
    return walletBalance > subtotal ? subtotal : walletBalance;
  }

  double get finalTotal {
    double total = subtotal + insuranceFee;
    total -= walletDeduction;
    return total;
  }

  String get formattedSubtotal => CurrencyFormatter.format(subtotal);
  String get formattedInsurance => CurrencyFormatter.format(insuranceFee);
  String get formattedWalletDeduction => CurrencyFormatter.format(walletDeduction);
  String get formattedFinalTotal => CurrencyFormatter.format(finalTotal);

  bool get canProceedToPayment {
    if (_currentStep.value == 0) {
      return passengerNameController.text.isNotEmpty &&
          passengerPhoneController.text.isNotEmpty &&
          _validateEmail() &&
          _agreeToTerms.value;
    }
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    _getArguments();
    _initializeControllers();
    _loadWalletBalance();
    _initializePassengerDetails();
  }

  void _getArguments() {
    final args = Get.arguments;
    if (args != null) {
      trip = args['trip'];
      selectedSeats = (args['selectedSeats'] as List)
          .map((s) => SeatModel.fromJson(s))
          .toList();
      totalPrice = args['totalPrice'];
    } else {
      Get.back();
      Get.snackbar(
        'Error',
        'Booking information not found',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _initializeControllers() {
    passengerNameController = TextEditingController(
      text: _authController.currentUser?.fullName,
    );
    passengerPhoneController = TextEditingController(
      text: _authController.currentUser?.phone,
    );
    passengerEmailController = TextEditingController(
      text: _authController.currentUser?.email,
    );
    specialRequestsController = TextEditingController();
  }

  void _initializePassengerDetails() {
    // Initialize additional passengers based on seat count
    for (int i = 1; i < selectedSeats.length; i++) {
      _additionalPassengers.add(PassengerDetail(seatNumber: selectedSeats[i].number));
    }
  }

  Future<void> _loadWalletBalance() async {
    try {
      final response = await _apiClient.get('/wallet/balance');
      if (response != null && response['data'] != null) {
        _walletBalance.value = response['data']['balance']?.toDouble() ?? 0;
      }
    } catch (e) {
      print('Error loading wallet balance: $e');
    }
  }

  bool _validateEmail() {
    final email = passengerEmailController.text;
    if (email.isEmpty) return true; // Email is optional
    return GetUtils.isEmail(email);
  }

  void nextStep() {
    if (_currentStep.value < 2 && canProceedToPayment) {
      _currentStep.value++;
    }
  }

  void previousStep() {
    if (_currentStep.value > 0) {
      _currentStep.value--;
    }
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod.value = method;
  }

  void toggleTermsAgreement(bool? value) {
    _agreeToTerms.value = value ?? false;
  }

  void toggleWalletUsage(bool? value) {
    _useWalletBalance.value = value ?? false;
  }

  void toggleInsurance(bool? value) {
    _insuranceSelected.value = value ?? false;
  }

  void toggleMealPreference(String meal, bool selected) {
    if (selected) {
      if (!_mealPreferences.contains(meal)) {
        _mealPreferences.add(meal);
      }
    } else {
      _mealPreferences.remove(meal);
    }
  }

  void updatePassengerDetail(int index, PassengerDetail detail) {
    if (index >= 0 && index < _additionalPassengers.length) {
      _additionalPassengers[index] = detail;
      _additionalPassengers.refresh();
    }
  }

  Future<void> createBooking() async {
    if (!canProceedToPayment) return;

    try {
      _isProcessing.value = true;

      // Prepare passenger details
      final allPassengers = [
        PassengerDetail(
          name: passengerNameController.text,
          phone: passengerPhoneController.text,
          email: passengerEmailController.text.isEmpty
              ? null
              : passengerEmailController.text,
          seatNumber: selectedSeats.first.number,
        ),
        ..._additionalPassengers,
      ];

      final request = BookingRequest(
        tripId: trip.id,
        seatNumbers: selectedSeats.map((s) => s.number).toList(),
        passengers: allPassengers,
        totalAmount: finalTotal,
        paymentMethod: _selectedPaymentMethod.value,
        specialRequests: specialRequestsController.text.isEmpty
            ? null
            : specialRequestsController.text,
        useWalletBalance: _useWalletBalance.value,
        insuranceSelected: _insuranceSelected.value,
        mealPreferences: _mealPreferences.isEmpty ? null : _mealPreferences,
      );

      final response = await _apiClient.post(
        ApiEndpoints.bookingsCreate,
        data: request.toJson(),
      );

      if (response != null && response['data'] != null) {
        _booking.value = BookingModel.fromJson(response['data']);

        // Navigate to payment
        Get.toNamed(
          '/passenger/payment',
          arguments: {
            'booking': _booking.value,
            'finalTotal': finalTotal,
          },
        );
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'Booking Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error creating booking: $e');
      Get.snackbar(
        'Error',
        'Failed to create booking. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<void> confirmBooking() async {
    if (_booking.value == null) return;

    try {
      _isProcessing.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.bookingsConfirm,
        data: {'bookingId': _booking.value!.id},
      );

      if (response != null && response['success'] == true) {
        // Navigate to success page
        Get.offAllNamed(
          '/passenger/booking/success',
          arguments: {'booking': _booking.value},
        );
      }
    } catch (e) {
      print('Error confirming booking: $e');
      Get.snackbar(
        'Error',
        'Failed to confirm booking. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isProcessing.value = false;
    }
  }

  void cancelBooking() {
    Get.back();
    Get.snackbar(
      'Booking Cancelled',
      'Your booking has been cancelled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    passengerNameController.dispose();
    passengerPhoneController.dispose();
    passengerEmailController.dispose();
    specialRequestsController.dispose();
    super.onClose();
  }
}
