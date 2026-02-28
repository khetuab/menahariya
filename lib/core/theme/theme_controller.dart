// lib/core/theme/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';

import 'light_theme.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final SecureStorage _storage = SecureStorage();

  // Observable for theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;

  // Getter for theme mode
  ThemeMode get themeMode => _themeMode.value;

  // Boolean getters for convenience
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;
  bool get isLightMode => _themeMode.value == ThemeMode.light;
  bool get isSystemMode => _themeMode.value == ThemeMode.system;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  // Load saved theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      final savedTheme = await _storage.read(AppConstants.prefKeyTheme);
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            _themeMode.value = ThemeMode.light;
            break;
          case 'dark':
            _themeMode.value = ThemeMode.dark;
            break;
          default:
            _themeMode.value = ThemeMode.system;
        }
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  // Switch theme mode
  Future<void> switchThemeMode(ThemeMode mode) async {
    if (_themeMode.value == mode) return;

    _themeMode.value = mode;

    // Save to storage
    try {
      String themeString = 'system';
      if (mode == ThemeMode.light) {
        themeString = 'light';
      } else if (mode == ThemeMode.dark) {
        themeString = 'dark';
      }
      await _storage.write(AppConstants.prefKeyTheme, themeString);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  // Toggle between light and dark mode
  void toggleTheme() {
    if (_themeMode.value == ThemeMode.light) {
      switchThemeMode(ThemeMode.dark);
    } else if (_themeMode.value == ThemeMode.dark) {
      switchThemeMode(ThemeMode.light);
    } else {
      // If system mode, check system brightness
      final brightness = Get.mediaQuery.platformBrightness;
      if (brightness == Brightness.light) {
        switchThemeMode(ThemeMode.dark);
      } else {
        switchThemeMode(ThemeMode.light);
      }
    }
  }

  // Set light mode
  void setLightMode() => switchThemeMode(ThemeMode.light);

  // Set dark mode
  void setDarkMode() => switchThemeMode(ThemeMode.dark);

  // Set system mode
  void setSystemMode() => switchThemeMode(ThemeMode.system);

  // Check if dark mode is currently active (considering system)
  bool get isDarkModeActive {
    if (_themeMode.value == ThemeMode.system) {
      final brightness = Get.mediaQuery.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  // Get current theme data based on mode
  ThemeData getCurrentTheme() {
    return isDarkModeActive ? AppTheme.dark : AppTheme.light;
  }
}