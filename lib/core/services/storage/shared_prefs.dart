// lib/core/services/storage/shared_prefs.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../constants/app_constants.dart';

class SharedPrefs {
  static SharedPrefs? _instance;
  factory SharedPrefs() => _instance ??= SharedPrefs._internal();

  SharedPrefs._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String methods
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Boolean methods
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Integer methods
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Double methods
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // String List methods
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // Object methods (JSON)
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    return await setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getObject(String key) {
    final string = getString(key);
    if (string == null) return null;
    try {
      return jsonDecode(string) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // List of objects
  Future<bool> setObjectList(String key, List<Map<String, dynamic>> value) async {
    return await setString(key, jsonEncode(value));
  }

  List<Map<String, dynamic>>? getObjectList(String key) {
    final string = getString(key);
    if (string == null) return null;
    try {
      final list = jsonDecode(string) as List;
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      return null;
    }
  }

  // Remove key
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Clear all
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Check if contains key
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  // Get with default values
  String getStringOrDefault(String key, String defaultValue) {
    return _prefs.getString(key) ?? defaultValue;
  }

  bool getBoolOrDefault(String key, bool defaultValue) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  int getIntOrDefault(String key, int defaultValue) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  double getDoubleOrDefault(String key, double defaultValue) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  // Increment/Decrement
  Future<int> incrementInt(String key, {int by = 1}) async {
    final current = getInt(key) ?? 0;
    final newValue = current + by;
    await setInt(key, newValue);
    return newValue;
  }

  Future<int> decrementInt(String key, {int by = 1}) async {
    final current = getInt(key) ?? 0;
    final newValue = current - by;
    await setInt(key, newValue);
    return newValue;
  }

  // Toggle boolean
  Future<bool> toggleBool(String key) async {
    final current = getBool(key) ?? false;
    final newValue = !current;
    await setBool(key, newValue);
    return newValue;
  }

  // App-specific preferences
  Future<void> setOnboardingSeen(bool value) async {
    await setBool(AppConstants.prefKeyOnboardingSeen, value);
  }

  bool isOnboardingSeen() {
    return getBool(AppConstants.prefKeyOnboardingSeen) ?? false;
  }

  Future<void> setLanguage(String languageCode) async {
    await setString(AppConstants.prefKeyLanguage, languageCode);
  }

  String? getLanguage() {
    return getString(AppConstants.prefKeyLanguage);
  }

  Future<void> setThemeMode(String themeMode) async {
    await setString(AppConstants.prefKeyTheme, themeMode);
  }

  String? getThemeMode() {
    return getString(AppConstants.prefKeyTheme);
  }

  Future<void> setRememberMe(bool value) async {
    await setBool(AppConstants.prefKeyRememberMe, value);
  }

  bool getRememberMe() {
    return getBool(AppConstants.prefKeyRememberMe) ?? false;
  }
}