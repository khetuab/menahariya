// lib/data/models/common/error_model.dart

class ApiError {
  final String code;
  final String message;
  final String? field;
  final Map<String, dynamic>? details;

  ApiError({
    required this.code,
    required this.message,
    this.field,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An unknown error occurred',
      field: json['field'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'field': field,
      'details': details,
    };
  }
}

// Validation Error
class ValidationError {
  final String field;
  final String message;
  final dynamic rejectedValue;

  ValidationError({
    required this.field,
    required this.message,
    this.rejectedValue,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
      rejectedValue: json['rejectedValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'message': message,
      'rejectedValue': rejectedValue,
    };
  }
}

// Error Response
class ErrorResponse {
  final bool success;
  final String message;
  final int? statusCode;
  final List<ApiError>? errors;
  final Map<String, dynamic>? details;

  ErrorResponse({
    required this.success,
    required this.message,
    this.statusCode,
    this.errors,
    this.details,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'An error occurred',
      statusCode: json['statusCode'],
      errors: json['errors'] != null
          ? (json['errors'] as List)
          .map((e) => ApiError.fromJson(e))
          .toList()
          : null,
      details: json['details'],
    );
  }

  // Helper to get first error message
  String get firstErrorMessage {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.first.message;
    }
    return message;
  }

  // Helper to get field errors
  Map<String, String> get fieldErrors {
    final fieldErrors = <String, String>{};
    if (errors != null) {
      for (var error in errors!) {
        if (error.field != null) {
          fieldErrors[error.field!] = error.message;
        }
      }
    }
    return fieldErrors;
  }
}

// Network Error
class NetworkError {
  final String message;
  final bool isTimeout;
  final bool isConnectionError;

  NetworkError({
    required this.message,
    this.isTimeout = false,
    this.isConnectionError = false,
  });

  factory NetworkError.timeout() {
    return NetworkError(
      message: 'Connection timeout. Please check your internet and try again.',
      isTimeout: true,
    );
  }

  factory NetworkError.noInternet() {
    return NetworkError(
      message: 'No internet connection. Please check your network settings.',
      isConnectionError: true,
    );
  }

  factory NetworkError.unknown() {
    return NetworkError(
      message: 'Network error occurred. Please try again.',
    );
  }
}

// Error Code Constants
class ErrorCodes {
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String notFound = 'NOT_FOUND';
  static const String validation = 'VALIDATION_ERROR';
  static const String serverError = 'SERVER_ERROR';
  static const String networkError = 'NETWORK_ERROR';
  static const String timeout = 'TIMEOUT';
  static const String duplicate = 'DUPLICATE_ENTRY';
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String accountLocked = 'ACCOUNT_LOCKED';
  static const String insufficientBalance = 'INSUFFICIENT_BALANCE';
  static const String paymentFailed = 'PAYMENT_FAILED';
  static const String bookingFailed = 'BOOKING_FAILED';
  static const String seatUnavailable = 'SEAT_UNAVAILABLE';
  static const String tripCancelled = 'TRIP_CANCELLED';
  static const String cargoLimitExceeded = 'CARGO_LIMIT_EXCEEDED';
}