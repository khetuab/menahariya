// lib/core/services/api/api_interceptor.dart

import 'package:dio/dio.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/core/constants/app_constants.dart';

class ApiInterceptor extends Interceptor {
  final SecureStorage _storage = SecureStorage();

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // Add timestamp to prevent caching
    options.queryParameters['_t'] = DateTime.now().millisecondsSinceEpoch.toString();

    // Add request ID for tracking
    options.headers['X-Request-ID'] = _generateRequestId();

    // Add device info
    options.headers['X-Device-ID'] = await _getDeviceId();

    handler.next(options);
  }

  @override
  Future<void> onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) async {
    // Cache successful responses if needed
    if (response.statusCode == 200) {
      _cacheResponse(response);
    }

    handler.next(response);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    // Handle token refresh
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the request
        try {
          final response = await _retryRequest(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Refresh failed, continue with error
        }
      }
    }

    // Log error
    _logError(err);

    handler.next(err);
  }

  String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${_randomString(8)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) {
      final random = DateTime.now().microsecondsSinceEpoch % chars.length;
      return chars[random];
    }).join();
  }

  Future<String> _getDeviceId() async {
    // Get or generate device ID
    const key = 'device_id';
    var deviceId = await _storage.read(key);
    if (deviceId == null) {
      deviceId = _generateRequestId();
      await _storage.write(key, deviceId);
    }
    return deviceId;
  }

  void _cacheResponse(Response response) {
    // Implement caching logic if needed
    // This could store responses in local storage for offline use
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read('refresh_token');
      if (refreshToken == null) return false;

      final dio = Dio();
      final response = await dio.post(
        '${AppConstants.baseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access_token'];
        await _storage.write(AppConstants.prefKeyToken, newToken);
        if (response.data['refresh_token'] != null) {
          await _storage.write('refresh_token', response.data['refresh_token']);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    final dio = Dio();
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  void _logError(DioException err) {
    // Implement error logging
    // This could send errors to a logging service
    print('API Error: ${err.message}');
    if (err.response != null) {
      print('Status Code: ${err.response?.statusCode}');
      print('Data: ${err.response?.data}');
    }
  }
}