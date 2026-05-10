// lib/config/environment/dev_config.dart

class DevConfig {
  // App Info
  static const String appName = 'Menahariya Smart (Dev)';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // API Configuration
  static const String apiBaseUrl = 'http://10.194.117.58:3000/api';
  static const String socketUrl = 'http://10.194.117.58:3000';
  // static const String apiBaseUrl = 'https://menahariya-backend.onrender.com/api';
  // static const String socketUrl = 'https://menahariya-backend.onrender.com';
  static const String apiVersion = 'v1';

  // Timeout
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds


  // Feature Flags
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;

  // Firebase Configuration (Development)
  static const Map<String, dynamic> firebaseConfig = {
    'apiKey': 'dev-api-key',
    'authDomain': 'dev-auth-domain',
    'projectId': 'dev-project-id',
    'storageBucket': 'dev-storage-bucket',
    'messagingSenderId': 'dev-sender-id',
    'appId': 'dev-app-id',
  };

  // Payment Gateway Configuration (Test)
  static const Map<String, dynamic> paymentConfig = {
    'telebirr': {
      'baseUrl': 'https://test.telebirr.et',
      'appId': 'dev-telebirr-app-id',
      'appKey': 'dev-telebirr-app-key',
      'shortCode': 'dev-short-code',
    },
    'cbeBirr': {
      'baseUrl': 'https://test.cbebirr.com',
      'merchantId': 'dev-merchant-id',
      'apiKey': 'dev-api-key',
    },
  };

  // Feature Toggles
  static const Map<String, bool> features = {
    'onlinePayment': true,
    'cargoTracking': true,
    'realTimeTracking': true,
    'notifications': true,
    'offlineMode': true,
  };
}