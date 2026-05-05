// lib/modules/passenger/controllers/booking_controller.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/data/models/booking/booking_model.dart' hide PassengerDetail;
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../../core/routes/app_routes.dart';
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
      // Validate primary passenger
      final isPrimaryValid = passengerNameController.text.isNotEmpty &&
          passengerPhoneController.text.isNotEmpty &&
          _validateEmail() &&
          _agreeToTerms.value;

      if (!isPrimaryValid) return false;

      // Validate all additional passengers
      return _areAllAdditionalPassengersValid();
    }
    return true;
  }

  final _canProceed = false.obs;
  bool get canProceed => _canProceed.value;

  void _onFormChanged() {
    updateValidationState();
  }

  void updateValidationState() {
    bool newValue;
    if (_currentStep.value == 0) {
      final isPrimaryValid = passengerNameController.text.isNotEmpty &&
          passengerPhoneController.text.isNotEmpty &&
          _validateEmail() &&
          _agreeToTerms.value;

      final areAdditionalValid = _areAllAdditionalPassengersValid();
      newValue = isPrimaryValid && areAdditionalValid;
    } else {
      newValue = true;
    }

    if (_canProceed.value != newValue) {
      _canProceed.value = newValue;
    }
  }

// Add this helper method
  bool _areAllAdditionalPassengersValid() {
    // If no additional passengers, return true
    if (_additionalPassengers.isEmpty) return true;

    // Check each additional passenger has a name
    for (final passenger in _additionalPassengers) {
      if (passenger.name == null || passenger.name!.trim().isEmpty) {
        return false;
      }
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

    // Add all listeners
    passengerNameController.addListener(_onFormChanged);
    passengerPhoneController.addListener(_onFormChanged);
    passengerEmailController.addListener(_onFormChanged);

    ever(_agreeToTerms, (_) => updateValidationState());
    ever(_currentStep, (_) => updateValidationState());
    ever(_additionalPassengers, (_) => updateValidationState());

    // Initial validation
    updateValidationState();
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
      // Fix: Use correct endpoint - wallet is under payments
      final response = await _apiClient.get('/payments/wallet/balance');
      if (response != null && response['data'] != null) {
        _walletBalance.value = response['data']['balance']?.toDouble() ?? 0;
        print('💰 Wallet balance loaded: ${_walletBalance.value}');
      }
    } catch (e) {
      print('⚠️ Error loading wallet balance: $e');
      // Don't show error to user, just set balance to 0
      _walletBalance.value = 0;
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

  // In PassengerBookingController, update createBooking method:

  Future<void> createBooking() async {
    if (!canProceedToPayment) return;

    try {
      _isProcessing.value = true;

      // Validate required fields
      if (passengerNameController.text.trim().isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Passenger name is required',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (passengerPhoneController.text.trim().isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Phone number is required',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Validate phone number format (basic validation)
      final phone = passengerPhoneController.text.trim();
      if (phone.length < 10) {
        Get.snackbar(
          'Validation Error',
          'Please enter a valid phone number',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Prepare primary passenger
      final primaryPassenger = {
        'name': passengerNameController.text.trim(),
        'phone': passengerPhoneController.text.trim(),
        'seatNumber': selectedSeats.first.number,
      };

      // Add email only if provided
      if (passengerEmailController.text.trim().isNotEmpty) {
        primaryPassenger['email'] = passengerEmailController.text.trim();
      }

      // Prepare additional passengers
      final additionalPassengersList = [];
      for (int i = 0; i < _additionalPassengers.length; i++) {
        final detail = _additionalPassengers[i];
        if (detail.name != null && detail.name!.trim().isNotEmpty) {
          final passenger = {
            'name': detail.name!.trim(),
            'seatNumber': detail.seatNumber,
          };
          if (detail.phone != null && detail.phone!.trim().isNotEmpty) {
            passenger['phone'] = detail.phone!.trim();
          }
          if (detail.email != null && detail.email!.trim().isNotEmpty) {
            passenger['email'] = detail.email!.trim();
          }
          additionalPassengersList.add(passenger);
        }
      }

      // Combine all passengers
      final allPassengers = [primaryPassenger, ...additionalPassengersList];

      // Prepare seat numbers
      final seatNumbers = selectedSeats.map((s) => s.number).toList();

      // Prepare request body
      final requestBody = {
        'tripId': trip.id,
        'seatNumbers': seatNumbers,
        'passengers': allPassengers,
        'totalAmount': finalTotal,
        'useWalletBalance': _useWalletBalance.value,
        'insuranceSelected': _insuranceSelected.value,
      };

      // Add optional fields only if they have values
      if (_selectedPaymentMethod.value != null) {
        requestBody['paymentMethod'] = _selectedPaymentMethod.value!;
      }

      if (specialRequestsController.text.trim().isNotEmpty) {
        requestBody['specialRequests'] = specialRequestsController.text.trim();
      }

      if (_mealPreferences.isNotEmpty) {
        requestBody['mealPreferences'] = _mealPreferences.toList();
      }

      // Log the request for debugging
      print('📦 Creating booking with:');
      print('  URL: ${ApiEndpoints.bookingsCreate}');
      print('  Request body: ${jsonEncode(requestBody)}');

      final response = await _apiClient.post(
        ApiEndpoints.bookingsCreate,
        data: requestBody,
      );

      if (response != null && response['data'] != null) {
        _booking.value = BookingModel.fromJson(response['data']);
        print('✅ Booking created successfully: ${_booking.value?.id}');

        // Navigate to payment
        Get.toNamed(
          AppRoutes.passengerPayment,
          arguments: {
            'booking': _booking.value,
            'finalTotal': finalTotal,
          },
        );
      }
    } on ApiException catch (e) {
      print('❌ API Exception: ${e.message}');
      print('❌ Status Code: ${e.statusCode}');
      if (e.data != null) {
        print('❌ Error data: ${e.data}');
      }
      Get.snackbar(
        'Booking Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ Error creating booking: $e');
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
