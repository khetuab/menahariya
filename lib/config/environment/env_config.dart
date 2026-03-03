// lib/config/environment/env_config.dart

import 'package:flutter/material.dart';
import 'package:menahariya/config/environment/dev_config.dart';
import 'package:menahariya/config/environment/staging_config.dart';
import 'package:menahariya/config/environment/prod_config.dart';

enum Environment { development, staging, production }

class EnvConfig {
  static EnvConfig? _instance;
  static EnvConfig get instance {
    if (_instance == null) {
      throw StateError('EnvConfig must be initialized before use. Call EnvConfig.initialize() first.');
    }
    return _instance!;
  }

  late Environment _environment;
  late String _appName;
  late String _apiBaseUrl;
  late String _socketUrl;
  late String _apiVersion;
  late int _connectTimeout;
  late int _receiveTimeout;
  late bool _enableLogging;
  late bool _enableAnalytics;
  late bool _enableCrashReporting;
  late String _appVersion;
  late String _buildNumber;
  late Map<String, dynamic> _firebaseConfig;
  late Map<String, dynamic> _paymentConfig;

  // Getters
  Environment get environment => _environment;
  String get appName => _appName;
  String get apiBaseUrl => _apiBaseUrl;
  String get socketUrl => _socketUrl;
  String get apiVersion => _apiVersion;
  int get connectTimeout => _connectTimeout;
  int get receiveTimeout => _receiveTimeout;
  bool get enableLogging => _enableLogging;
  bool get enableAnalytics => _enableAnalytics;
  bool get enableCrashReporting => _enableCrashReporting;
  String get appVersion => _appVersion;
  String get buildNumber => _buildNumber;
  Map<String, dynamic> get firebaseConfig => _firebaseConfig;
  Map<String, dynamic> get paymentConfig => _paymentConfig;

  bool get isDevelopment => _environment == Environment.development;
  bool get isStaging => _environment == Environment.staging;
  bool get isProduction => _environment == Environment.production;

  String get environmentName {
    switch (_environment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  String get fullApiUrl => '$apiBaseUrl/api/$apiVersion';

  EnvConfig._internal();

  static Future<void> initialize({required Environment environment}) async {
    final config = EnvConfig._internal();
    config._environment = environment;

    switch (environment) {
      case Environment.development:
        config._loadDevConfig();
        break;
      case Environment.staging:
        config._loadStagingConfig();
        break;
      case Environment.production:
        config._loadProdConfig();
        break;
    }

    _instance = config;
  }

  void _loadDevConfig() {
    _appName = DevConfig.appName;
    _apiBaseUrl = DevConfig.apiBaseUrl;
    _socketUrl = DevConfig.socketUrl;
    _apiVersion = DevConfig.apiVersion;
    _connectTimeout = DevConfig.connectTimeout;
    _receiveTimeout = DevConfig.receiveTimeout;
    _enableLogging = DevConfig.enableLogging;
    _enableAnalytics = DevConfig.enableAnalytics;
    _enableCrashReporting = DevConfig.enableCrashReporting;
    _appVersion = DevConfig.appVersion;
    _buildNumber = DevConfig.buildNumber;
    _firebaseConfig = DevConfig.firebaseConfig;
    _paymentConfig = DevConfig.paymentConfig;
  }

  void _loadStagingConfig() {
    _appName = StagingConfig.appName;
    _apiBaseUrl = StagingConfig.apiBaseUrl;
    _socketUrl = StagingConfig.socketUrl;
    _apiVersion = StagingConfig.apiVersion;
    _connectTimeout = StagingConfig.connectTimeout;
    _receiveTimeout = StagingConfig.receiveTimeout;
    _enableLogging = StagingConfig.enableLogging;
    _enableAnalytics = StagingConfig.enableAnalytics;
    _enableCrashReporting = StagingConfig.enableCrashReporting;
    _appVersion = StagingConfig.appVersion;
    _buildNumber = StagingConfig.buildNumber;
    _firebaseConfig = StagingConfig.firebaseConfig;
    _paymentConfig = StagingConfig.paymentConfig;
  }

  void _loadProdConfig() {
    _appName = ProdConfig.appName;
    _apiBaseUrl = ProdConfig.apiBaseUrl;
    _socketUrl = ProdConfig.socketUrl;
    _apiVersion = ProdConfig.apiVersion;
    _connectTimeout = ProdConfig.connectTimeout;
    _receiveTimeout = ProdConfig.receiveTimeout;
    _enableLogging = ProdConfig.enableLogging;
    _enableAnalytics = ProdConfig.enableAnalytics;
    _enableCrashReporting = ProdConfig.enableCrashReporting;
    _appVersion = ProdConfig.appVersion;
    _buildNumber = ProdConfig.buildNumber;
    _firebaseConfig = ProdConfig.firebaseConfig;
    _paymentConfig = ProdConfig.paymentConfig;
  }

  Map<String, dynamic> toJson() {
    return {
      'environment': environmentName,
      'appName': _appName,
      'apiBaseUrl': _apiBaseUrl,
      'socketUrl': _socketUrl,
      'apiVersion': _apiVersion,
      'connectTimeout': _connectTimeout,
      'receiveTimeout': _receiveTimeout,
      'enableLogging': _enableLogging,
      'enableAnalytics': _enableAnalytics,
      'enableCrashReporting': _enableCrashReporting,
      'appVersion': _appVersion,
      'buildNumber': _buildNumber,
    };
  }
}

// Environment helper extension
extension EnvironmentHelper on Environment {
  String get displayName {
    switch (this) {
      case Environment.development:
        return 'DEV';
      case Environment.staging:
        return 'STG';
      case Environment.production:
        return 'PROD';
    }
  }

  Color get color {
    switch (this) {
      case Environment.development:
        return Colors.green;
      case Environment.staging:
        return Colors.orange;
      case Environment.production:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}