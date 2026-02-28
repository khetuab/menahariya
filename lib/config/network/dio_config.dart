// lib/config/network/dio_config.dart

import 'package:dio/dio.dart';
import 'package:menahariya/config/environment/env_config.dart';

class DioConfig {
  static DioConfig? _instance;
  factory DioConfig() => _instance ??= DioConfig._internal();
  DioConfig._internal();

  late Dio _dio;
  Dio get dio => _dio;

  // Default headers
  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Initialize Dio with configuration
  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.instance.fullApiUrl,
        connectTimeout: Duration(milliseconds: EnvConfig.instance.connectTimeout),
        receiveTimeout: Duration(milliseconds: EnvConfig.instance.receiveTimeout),
        headers: defaultHeaders,
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _addInterceptors();
  }

  // Add interceptors
  void _addInterceptors() {
    if (EnvConfig.instance.enableLogging) {
      _dio.interceptors.add(_createLoggingInterceptor());
    }

    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
    _dio.interceptors.add(_createCacheInterceptor());
  }

  // Logging interceptor
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🌐 [DIO] Request: ${options.method} ${options.path}');
        print('📦 Headers: ${options.headers}');
        print('📦 Data: ${options.data}');
        print('📦 Query: ${options.queryParameters}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ [DIO] Response: ${response.statusCode} ${response.requestOptions.path}');
        print('📦 Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ [DIO] Error: ${error.message}');
        print('📍 Path: ${error.requestOptions.path}');
        print('📦 Response: ${error.response?.data}');
        return handler.next(error);
      },
    );
  }

  // Auth interceptor
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 errors - token refresh
        if (error.response?.statusCode == 401) {
          try {
            final newToken = await _refreshToken();
            if (newToken != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    );
  }

  // Error interceptor
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // Transform error messages
        String errorMessage = _getErrorMessage(error);
        error = DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: errorMessage,
        );
        return handler.next(error);
      },
    );
  }

  // Cache interceptor
  Interceptor _createCacheInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add cache control headers
        if (options.extra['cache'] == true) {
          options.headers['Cache-Control'] = 'max-age=300';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Cache successful responses if needed
        if (response.requestOptions.extra['cache'] == true) {
          _cacheResponse(response);
        }
        return handler.next(response);
      },
    );
  }

  // Helper methods
  Future<String?> _getToken() async {
    // Get token from secure storage
    // This will be implemented with the storage service
    return null;
  }

  Future<String?> _refreshToken() async {
    // Implement token refresh logic
    return null;
  }

  String _getErrorMessage(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout.';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  void _cacheResponse(Response response) {
    // Implement response caching
  }

  // Configure for different environments
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Add custom headers
  void addHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }

  // Remove header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  // Clear all headers
  void clearHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers.addAll(defaultHeaders);
  }

  // Set authentication token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

// Dio extensions
extension DioExtensions on Dio {
  // GET with cache
  Future<Response> getCached(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    return get(
      path,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(extra: {'cache': true}),
    );
  }

  // POST with progress
  Future<Response> postWithProgress(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) async {
    return post(
      path,
      data: data,
      queryParameters: queryParameters,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

// Network constants
class NetworkConstants {
  static const int success = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int unprocessable = 422;
  static const int tooManyRequests = 429;
  static const int serverError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
}

// Network status codes
enum NetworkStatus {
  success,
  created,
  accepted,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  unprocessable,
  tooManyRequests,
  serverError,
  badGateway,
  serviceUnavailable,
  unknown;

  static NetworkStatus fromCode(int? code) {
    switch (code) {
      case 200:
        return NetworkStatus.success;
      case 201:
        return NetworkStatus.created;
      case 202:
        return NetworkStatus.accepted;
      case 400:
        return NetworkStatus.badRequest;
      case 401:
        return NetworkStatus.unauthorized;
      case 403:
        return NetworkStatus.forbidden;
      case 404:
        return NetworkStatus.notFound;
      case 409:
        return NetworkStatus.conflict;
      case 422:
        return NetworkStatus.unprocessable;
      case 429:
        return NetworkStatus.tooManyRequests;
      case 500:
        return NetworkStatus.serverError;
      case 502:
        return NetworkStatus.badGateway;
      case 503:
        return NetworkStatus.serviceUnavailable;
      default:
        return NetworkStatus.unknown;
    }
  }

  bool get isSuccess => this == success || this == created || this == accepted;
  bool get isClientError => index >= badRequest.index && index < serverError.index;
  bool get isServerError => index >= serverError.index;
}