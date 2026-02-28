// lib/core/services/api/api_exception.dart

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.originalError,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }

  // Check if it's a network error
  bool get isNetworkError =>
      message.contains('network') ||
          message.contains('connection') ||
          statusCode == null;

  // Check if it's a server error
  bool get isServerError => statusCode != null && statusCode! >= 500;

  // Check if it's a client error
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  // Check if it's authentication error
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  // Check if it's validation error
  bool get isValidationError => statusCode == 422;

  // Check if it's not found
  bool get isNotFound => statusCode == 404;

  // Get validation errors map
  Map<String, List<String>>? get validationErrors {
    if (!isValidationError || data == null) return null;

    try {
      if (data is Map && data['errors'] != null) {
        final errors = <String, List<String>>{};
        final errorData = data['errors'] as Map;
        errorData.forEach((key, value) {
          if (value is List) {
            errors[key] = List<String>.from(value);
          } else if (value is String) {
            errors[key] = [value];
          }
        });
        return errors;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // Get first validation error message
  String? get firstValidationError {
    final errors = validationErrors;
    if (errors != null && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError.isNotEmpty) {
        return firstError.first;
      }
    }
    return null;
  }

  // Create from dynamic error
  factory ApiException.from(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    if (error is String) {
      return ApiException(message: error);
    }
    return ApiException(
      message: 'An unexpected error occurred',
      originalError: error,
    );
  }

  // Common exceptions
  static ApiException networkError() => ApiException(
    message: 'Network connection error. Please check your internet.',
  );

  static ApiException timeoutError() => ApiException(
    message: 'Request timeout. Please try again.',
  );

  static ApiException serverError() => ApiException(
    message: 'Server error. Please try again later.',
    statusCode: 500,
  );

  static ApiException unauthorizedError() => ApiException(
    message: 'Session expired. Please login again.',
    statusCode: 401,
  );

  static ApiException notFoundError(String resource) => ApiException(
    message: '$resource not found.',
    statusCode: 404,
  );
}