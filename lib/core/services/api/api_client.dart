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
  Dio get dio => _dio;
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

  // ==================== AUTH TOKEN MANAGEMENT ====================

  /// Set authentication token for all future requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('🔐 Auth token set successfully');
  }

  /// Clear authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    print('🔐 Auth token cleared');
  }

  /// Check if auth token is set
  bool hasAuthToken() {
    return _dio.options.headers.containsKey('Authorization');
  }

  /// Get current auth token
  String? getAuthToken() {
    final authHeader = _dio.options.headers['Authorization'];
    if (authHeader is String && authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7);
    }
    return null;
  }

  // ==================== GENERIC REQUEST METHODS ====================

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

      print('📤 POST Request to: $endpoint');
      print('📦 Data: $data');

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

  // ==================== FILE UPLOAD/DOWNLOAD ====================

  // Multipart file upload
  Future<dynamic> uploadFile(
      String endpoint,
      String filePath, {
        Map<String, dynamic>? data,
        String fieldName = 'file',
        Function(int, int)? onSendProgress,
        bool requiresAuth = true,
      }) async {
    try {
      isLoading = true;

      if (requiresAuth) {
        await _addAuthHeader();
      }

      print('📤 Uploading to: $endpoint');
      print('📤 Field name: $fieldName');
      print('📤 File path: $filePath');

      final file = await MultipartFile.fromFile(filePath);
      print('📤 File size: ${file.length} bytes');
      print('📤 File name: ${file.filename}');

      final formData = FormData.fromMap({
        ...?data,
        fieldName: file,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(contentType: 'multipart/form-data'),
      );

      print('✅ Upload response status: ${response.statusCode}');
      print('✅ Upload response data: ${response.data}');

      return _handleResponse(response);
    } on DioException catch (e) {
      print('❌ Upload error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
      throw _handleDioError(e);
    } finally {
      isLoading = false;
    }
  }

  // Upload multiple files
  Future<dynamic> uploadMultipleFiles(
      String endpoint,
      List<String> filePaths, {
        Map<String, dynamic>? data,
        String fieldName = 'files',
        Function(int, int)? onSendProgress,
        bool requiresAuth = true,
      }) async {
    try {
      isLoading = true;

      if (requiresAuth) {
        await _addAuthHeader();
      }

      final formData = FormData();

      // Add files
      for (int i = 0; i < filePaths.length; i++) {
        final file = await MultipartFile.fromFile(filePaths[i]);
        formData.files.add(MapEntry('$fieldName[$i]', file));
      }

      // Add other data
      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

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

  // ==================== AUTH HEADER MANAGEMENT ====================

  // Add authentication header (reads from storage)
  Future<void> _addAuthHeader() async {
    final token = await _storage.read(AppConstants.prefKeyToken);
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Add custom header
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  // Remove header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  // Clear all custom headers
  void clearHeaders() {
    _dio.options.headers = _getDefaultHeaders();
  }

  // ==================== RESPONSE HANDLING ====================

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
    await _storage.delete('admin_token');
    await _storage.delete('admin_user');

    // Navigate to login based on current route
    final currentRoute = getx.Get.currentRoute;
    if (currentRoute.contains('/admin')) {
      getx.Get.offAllNamed('/admin/login');
    } else {
      getx.Get.offAllNamed('/auth/login');
    }
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

  // ==================== UTILITY METHODS ====================

  // Clear auth header (removes from memory only)
  void clearAuthHeader() {
    _dio.options.headers.remove('Authorization');
    print('🔐 Auth header cleared from memory');
  }

  // Update base URL
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    print('🌐 Base URL updated to: $newBaseUrl');
  }

  // Cancel all requests
  void cancelRequests() {
    _dio.close(force: true);
    _initDio();
  }

  // Get current base URL
  String getBaseUrl() {
    return _dio.options.baseUrl;
  }

  // Set custom options for specific request
  void setOptions(BaseOptions options) {
    _dio.options = options;
  }

  // Add interceptor
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  // Remove interceptor
  void removeInterceptor(Interceptor interceptor) {
    _dio.interceptors.remove(interceptor);
  }
}