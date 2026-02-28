// lib/data/models/common/api_response.dart

import 'error_model.dart';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? meta;
  final List<ApiError>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.meta,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
      ) {
    return ApiResponse(
      success: json['success'] ?? json['status'] == 'success',
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      meta: json['meta'],
      errors: json['errors'] != null
          ? (json['errors'] as List)
          .map((e) => ApiError.fromJson(e))
          .toList()
          : null,
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'meta': meta,
      'errors': errors?.map((e) => e.toJson()).toList(),
      'statusCode': statusCode,
    };
  }
}

// Paginated Response
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
      ) {
    final pagination = json['pagination'] ?? json;
    return PaginatedResponse(
      items: (json['data'] ?? json['items'] as List)
          .map((item) => fromJsonT(item))
          .toList(),
      total: pagination['total'] ?? 0,
      page: pagination['page'] ?? 1,
      limit: pagination['limit'] ?? 10,
      totalPages: pagination['totalPages'] ?? 1,
      hasNext: pagination['hasNext'] ?? false,
      hasPrevious: pagination['hasPrevious'] ?? false,
    );
  }
}

// Success Response
class SuccessResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  SuccessResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory SuccessResponse.fromJson(Map<String, dynamic> json) {
    return SuccessResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
    );
  }
}