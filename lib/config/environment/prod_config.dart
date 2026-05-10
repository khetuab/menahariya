// lib/config/environment/prod_config.dart

class ProdConfig {
  // App Info
  static const String appName = 'Menahariya Smart';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // static const String apiBaseUrl = 'http://10.156.108.200:3000/api';
  // static const String socketUrl = 'http://10.156.108.200:3000';

  static const String apiBaseUrl = 'http://10.194.117.58:3000/api';
  static const String socketUrl = 'http://10.194.117.58:3000';
  // API Configuration
  // static const String apiBaseUrl = 'https://menahariya-backend.onrender.com/api';
  // static const String socketUrl = 'https://menahariya-backend.onrender.com';
  static const String apiVersion = 'v1';

  // Timeouts
  static const int connectTimeout = 60000; // 15 seconds
  static const int receiveTimeout = 60000; // 15 seconds

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