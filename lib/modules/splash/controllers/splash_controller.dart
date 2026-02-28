// lib/modules/splash/controllers/splash_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/connectivity/connectivity_service.dart';
import 'package:menahariya/core/services/notification/local_notification.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/core/services/storage/local_storage.dart';
import 'package:menahariya/core/services/storage/shared_prefs.dart';
import 'package:menahariya/core/theme/theme_controller.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';

import '../../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  static SplashController get instance => Get.find();

  // Services
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final SecureStorage _secureStorage = SecureStorage();
  final LocalStorage _localStorage = LocalStorage();
  final SharedPrefs _sharedPrefs = SharedPrefs();
  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;
  final LocalNotificationService _notificationService = LocalNotificationService.instance;
  final ThemeController _themeController = ThemeController.to;
  final AuthController _authController = AuthController.instance;

  // Observables
  final _loadingProgress = 0.0.obs;
  final _loadingMessage = 'Initializing...'.obs;
  final _isInitialized = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;

  // Animation controllers (to be set from view)
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  // Getters
  double get loadingProgress => _loadingProgress.value;
  String get loadingMessage => _loadingMessage.value;
  bool get isInitialized => _isInitialized.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    // Animations will be set by view
  }

  @override
  void onReady() {
    super.onReady();
    _startInitialization();
  }

  // Method to set animations from view
  void setAnimations({
    required AnimationController controller,
    required Animation<double> fade,
    required Animation<double> scale,
  }) {
    animationController = controller;
    fadeAnimation = fade;
    scaleAnimation = scale;
  }

  Future<void> _startInitialization() async {
    try {
      _updateProgress(0.1, 'Checking connection...');
      await _checkConnectivity();

      _updateProgress(0.3, 'Loading storage...');
      await _initializeStorage();

      _updateProgress(0.5, 'Loading preferences...');
      await _loadThemePreferences();

      _updateProgress(0.7, 'Checking session...');
      await _checkSession();

      _updateProgress(0.9, 'Starting services...');
      await _initializeServices();

      _updateProgress(1.0, 'Ready!');
      await Future.delayed(const Duration(milliseconds: 500));

      _isInitialized.value = true;
      _navigateToNext();
    } catch (e) {
      _handleError(e.toString());
    }
  }

  void _updateProgress(double progress, String message) {
    _loadingProgress.value = progress;
    _loadingMessage.value = message;
  }

  Future<void> _checkConnectivity() async {
    if (!_connectivityService.isConnected) {
      bool hasConnection = false;
      for (int i = 0; i < 30; i++) {
        hasConnection = await _connectivityService.hasInternetConnection();
        if (hasConnection) break;
        await Future.delayed(const Duration(seconds: 1));
      }
      if (!hasConnection) _showOfflineModeDialog();
    }
  }

  Future<void> _initializeStorage() async {
    await _sharedPrefs.init();
    await _localStorage.init();
  }

  Future<void> _loadThemePreferences() async {
    final themeMode = await _sharedPrefs.getString(AppConstants.prefKeyTheme);
    if (themeMode != null) {
      switch (themeMode) {
        case 'light':
          _themeController.setLightMode();
          break;
        case 'dark':
          _themeController.setDarkMode();
          break;
        default:
          _themeController.setSystemMode();
      }
    }
  }

  Future<void> _checkSession() async {
    final hasToken = await _secureStorage.containsKey(AppConstants.prefKeyToken);
    if (hasToken) {
      final isValid = await _authController.isSessionValid();
      if (!isValid) {
        await _secureStorage.delete(AppConstants.prefKeyToken);
        await _secureStorage.delete(AppConstants.prefKeyUser);
      }
    }
  }

  Future<void> _initializeServices() async {
    try {
      await _notificationService.requestPermissions();
      if (_authController.isAuthenticated) {
        await _socketService.connect();
      }
      // Preload background data (non-blocking)
      Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      print('Service initialization warning: $e');
      // Don't throw - continue even if some services fail
    }
  }

  // Check the _navigateToNext method
  Future<void> _navigateToNext() async {
    final onboardingSeen = await _sharedPrefs.getBoolOrDefault(
      AppConstants.prefKeyOnboardingSeen,
      false,
    );

    if (!onboardingSeen) {
      // Make sure you have an onboarding route defined
      Get.offNamed(AppRoutes.onboarding);
      return;
    }

    if (_authController.isAuthenticated) {
      switch (_authController.userRole) {
        case AppConstants.rolePassenger:
          Get.offNamed(AppRoutes.passengerDashboard);
          break;
        case AppConstants.roleDriver:
          Get.offNamed(AppRoutes.driverDashboard);
          break;
        case AppConstants.roleAdmin:
        case AppConstants.roleTicketingStaff:
        case AppConstants.roleCargoStaff:
          Get.offNamed('/staff/dashboard'); // Make sure this route exists
          break;
        default:
          Get.offNamed(AppRoutes.passengerDashboard);
      }
    } else {
      Get.offNamed(AppRoutes.login); // This should be your login route
    }
  }

  void _showOfflineModeDialog() {
    _hasError.value = true;
    _errorMessage.value = 'No internet connection';

    Get.dialog(
      AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text(
          'Please check your internet connection and try again.\n\n'
              'You can continue in offline mode with limited functionality.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _startInitialization();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _navigateToNext();
            },
            child: const Text('Offline Mode'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _handleError(String error) {
    _hasError.value = true;
    _errorMessage.value = error;

    Get.snackbar(
      'Initialization Error',
      error,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          Get.back();
          _startInitialization();
        },
        child: const Text('Retry'),
      ),
    );
  }

  void retryInitialization() {
    _hasError.value = false;
    _errorMessage.value = '';
    _loadingProgress.value = 0.0;
    _startInitialization();
  }

  // @override
  // void onClose() {
  //   if (animationController.hasListeners) {
  //     animationController.dispose();
  //   }
  //   super.onClose();
  // }
}