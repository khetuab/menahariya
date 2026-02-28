// lib/modules/driver/controllers/validation_controller.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';

class ValidationController extends GetxController {
  static ValidationController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Observables
  final _isLoading = false.obs;
  final _isValidating = false.obs;
  final _lastValidation = Rxn<ValidationResult>();
  final _validationHistory = <ValidationResult>[].obs;
  final _scannedTickets = <String>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isValidating => _isValidating.value;
  ValidationResult? get lastValidation => _lastValidation.value;
  List<ValidationResult> get validationHistory => _validationHistory;
  List<String> get scannedTickets => _scannedTickets;

  Future<ValidationResult?> validateTicket(String ticketCode) async {
    try {
      _isValidating.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.ticketsValidate,
        data: {'ticketCode': ticketCode},
      );

      if (response != null && response['data'] != null) {
        final data = response['data'];
        final isValid = data['valid'] ?? false;

        final result = ValidationResult(
          ticketCode: ticketCode,
          isValid: isValid,
          message: data['message'] ?? (isValid ? 'Valid ticket' : 'Invalid ticket'),
          ticket: isValid ? TicketModel.fromJson(data['ticket']) : null,
          timestamp: DateTime.now(),
        );

        _lastValidation.value = result;

        if (!_scannedTickets.contains(ticketCode)) {
          _scannedTickets.add(ticketCode);
          _validationHistory.add(result);

          // Keep only last 50 history items
          if (_validationHistory.length > 50) {
            _validationHistory.removeAt(0);
          }
        }

        return result;
      }

      return ValidationResult(
        ticketCode: ticketCode,
        isValid: false,
        message: 'Invalid response from server',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Error validating ticket: $e');
      return ValidationResult(
        ticketCode: ticketCode,
        isValid: false,
        message: 'Connection error',
        timestamp: DateTime.now(),
      );
    } finally {
      _isValidating.value = false;
    }
  }

  void clearLastValidation() {
    _lastValidation.value = null;
  }

  void clearHistory() {
    _validationHistory.clear();
    _scannedTickets.clear();
  }

  int getValidCount() {
    return _validationHistory.where((v) => v.isValid).length;
  }

  int getInvalidCount() {
    return _validationHistory.where((v) => !v.isValid).length;
  }

  List<ValidationResult> getRecentValidations({int limit = 10}) {
    return _validationHistory.reversed.take(limit).toList();
  }
}

class ValidationResult {
  final String ticketCode;
  final bool isValid;
  final String message;
  final TicketModel? ticket;
  final DateTime timestamp;

  ValidationResult({
    required this.ticketCode,
    required this.isValid,
    required this.message,
    this.ticket,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticketCode': ticketCode,
      'isValid': isValid,
      'message': message,
      'ticket': ticket?.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}