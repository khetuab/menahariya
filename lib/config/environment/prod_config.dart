// lib/config/environment/prod_config.dart

class ProdConfig {
  // App Info
  static const String appName = 'Menahariya Smart';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // API Configuration
  static const String apiBaseUrl = 'https://api.menahariya.com';
  static const String socketUrl = 'https://socket.menahariya.com';
  static const String apiVersion = 'v1';

  // Timeouts
  static const int connectTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 15000; // 15 seconds

  // Feature Flags
  static const bool enableLogging = false;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Firebase Configuration (Production)
  static const Map<String, dynamic> firebaseConfig = {
    'apiKey': 'prod-api-key',
    'authDomain': 'prod-auth-domain',
    'projectId': 'prod-project-id',
    'storageBucket': 'prod-storage-bucket',
    'messagingSenderId': 'prod-sender-id',
    'appId': 'prod-app-id',
  };

  // Payment Gateway Configuration (Production)
  static const Map<String, dynamic> paymentConfig = {
    'telebirr': {
      'baseUrl': 'https://api.telebirr.et',
      'appId': 'prod-telebirr-app-id',
      'appKey': 'prod-telebirr-app-key',
      'shortCode': 'prod-short-code',
    },
    'cbeBirr': {
      'baseUrl': 'https://api.cbebirr.com',
      'merchantId': 'prod-merchant-id',
      'apiKey': 'prod-api-key',
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