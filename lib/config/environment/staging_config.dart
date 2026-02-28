// lib/config/environment/staging_config.dart

class StagingConfig {
  // App Info
  static const String appName = 'Menahariya Smart (Staging)';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // API Configuration
  static const String apiBaseUrl = 'https://staging-api.menahariya.com';
  static const String socketUrl = 'https://staging-socket.menahariya.com';
  static const String apiVersion = 'v1';

  // Timeouts
  static const int connectTimeout = 20000; // 20 seconds
  static const int receiveTimeout = 20000; // 20 seconds

  // Feature Flags
  static const bool enableLogging = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = false;

  // Firebase Configuration (Staging)
  static const Map<String, dynamic> firebaseConfig = {
    'apiKey': 'staging-api-key',
    'authDomain': 'staging-auth-domain',
    'projectId': 'staging-project-id',
    'storageBucket': 'staging-storage-bucket',
    'messagingSenderId': 'staging-sender-id',
    'appId': 'staging-app-id',
  };

  // Payment Gateway Configuration (Staging)
  static const Map<String, dynamic> paymentConfig = {
    'telebirr': {
      'baseUrl': 'https://staging.telebirr.et',
      'appId': 'staging-telebirr-app-id',
      'appKey': 'staging-telebirr-app-key',
      'shortCode': 'staging-short-code',
    },
    'cbeBirr': {
      'baseUrl': 'https://staging.cbebirr.com',
      'merchantId': 'staging-merchant-id',
      'apiKey': 'staging-api-key',
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