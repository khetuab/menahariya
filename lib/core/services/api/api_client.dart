// lib/core/services/api/api_client.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_interceptor.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/config/environment/env_config.dart';

class ApiClient extends getx.GetxService {
  static ApiClient get instance => getx.Get.find();

  late Dio _dio;
  final SecureStorage _storage = SecureStorage();

  // Observable for API loading state
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: EnvConfig.instance.apiBaseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.connectionTimeout,
      headers: _getDefaultHeaders(),
      responseType: ResponseType.json,
      contentType: 'application/json',
    ));

    // Add interceptors
    _dio.interceptors.addAll([
      ApiInterceptor(),
      LogInterceptor(
        request: kDebugMode,
        requestHeader: kDebugMode,
        requestBody: kDebugMode,
        responseHeader: kDebugMode,
        responseBody: kDebugMode,
        error: kDebugMode,
      ),
    ]);
  }

  Map<String, dynamic> _getDefaultHeaders() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Accept-Language': 'en',
      'Platform': 'mobile',
      'App-Version': AppConstants.appVersion,
    };
  }

  // Generic GET request
  Future<dynamic> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        bool requiresAuth = true,
      }) async {
    try {
      isLoading = true;

      if (requiresAuth) {
        await _addAuthHeader();
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } finally {
      isLoading = false;
    }
  }

  // Generic POST request
  Future<dynamic> post(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        bool requiresAuth = true,
      }) async {
    try {
      isLoading = true;

      if (requiresAuth) {
        await _addAuthHeader();
      }

      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } finally {
      isLoading = false;
    }
  }

  // Generic PUT request
  Future<dynamic> put(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        bool requiresAuth = true,
      }) async {
    try {
      isLoading = true;

      if (requiresAuth) {
        await _addAuthHeader();
      }

      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } finally {
      isLoading = false;
    }
  }

  // Generic PATCH request
  Future<dynamic> patch(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        bool requiresAuth = true,
      }) async {
    try {
      isLoading = true;

      if (requiresAuth) {
        await _addAuthHeader();
      }

      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } finally {
      isLoading = false;
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        bool requiresAuth = true,
      }) async {
    try {
      isLoading = true;

      if (requiresAuth) {
        await _addAuthHeader();
      }

      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } finally {
      isLoading = false;
    }
  }

  // Multipart file upload
  Future<dynamic> uploadFile(
      String endpoint,
      String filePath, {
        Map<String, dynamic>? data,
        Function(int, int)? onSendProgress,
        bool requiresAuth = true,
      }) async {
    try {
      isLoading = true;

      if (requiresAuth) {
        await _addAuthHeader();
      }

      final formData = FormData.fromMap({
        ...?data,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(contentType: 'multipart/form-data'),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } finally {
      isLoading = false;
    }
  }

  // Download file
  Future<String> downloadFile(
      String url,
      String savePath, {
        Function(int, int)? onReceiveProgress,
        Map<String, dynamic>? queryParameters,
        bool requiresAuth = true,
      }) async {
    try {
      isLoading = true;

      if (requiresAuth) {
        await _addAuthHeader();
      }

      final response = await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );

      if (response.statusCode == 200) {
        return savePath;
      } else {
        throw ApiException(
          message: 'Download failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } finally {
      isLoading = false;
    }
  }

  // Add authentication header
  Future<void> _addAuthHeader() async {
    final token = await _storage.read(AppConstants.prefKeyToken);
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Handle successful response
  dynamic _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    }

    throw ApiException(
      message: 'Unexpected response status: ${response.statusCode}',
      statusCode: response.statusCode,
      data: response.data,
    );
  }

  // Handle Dio error
  ApiException _handleDioError(DioException error) {
    String message;
    int? statusCode;
    dynamic data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = AppConstants.errorTimeout;
        break;
      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode;
        data = error.response?.data;

        if (statusCode == 401) {
          message = AppConstants.errorUnauthorized;
          _handleUnauthorized();
        } else if (statusCode == 403) {
          message = AppConstants.errorForbidden;
        } else if (statusCode == 404) {
          message = AppConstants.errorNotFound;
        } else if (statusCode == 422) {
          message = AppConstants.errorValidation;
        } else {
          message = _extractErrorMessage(error.response?.data) ??
              AppConstants.errorServer;
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        message = AppConstants.errorNetwork;
        break;
      default:
        message = AppConstants.errorUnknown;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
      originalError: error,
    );
  }

  // Handle unauthorized response
  Future<void> _handleUnauthorized() async {
    await _storage.delete(AppConstants.prefKeyToken);
    await _storage.delete(AppConstants.prefKeyUser);

    // Navigate to login
    getx.Get.offAllNamed('/auth/login');
  }

  // Extract error message from response
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is String) return data;

    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
      if (data['errors'] != null && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.values.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
          return firstError.toString();
        }
      }
    }

    return null;
  }

  // Clear auth header
  void clearAuthHeader() {
    _dio.options.headers.remove('Authorization');
  }

  // Update base URL
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Cancel all requests
  void cancelRequests() {
    _dio.close(force: true);
    _initDio();
  }
}