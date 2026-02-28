// lib/core/services/storage/secure_storage.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static SecureStorage? _instance;
  factory SecureStorage() => _instance ??= SecureStorage._internal();

  SecureStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Write string
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Write boolean
  Future<void> writeBool(String key, bool value) async {
    await write(key, value.toString());
  }

  // Write integer
  Future<void> writeInt(String key, int value) async {
    await write(key, value.toString());
  }

  // Write double
  Future<void> writeDouble(String key, double value) async {
    await write(key, value.toString());
  }

  // Write object (JSON)
  Future<void> writeObject(String key, Map<String, dynamic> value) async {
    await write(key, jsonEncode(value));
  }

  // Write list
  Future<void> writeList(String key, List<dynamic> value) async {
    await write(key, jsonEncode(value));
  }

  // Read string
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Read boolean
  Future<bool?> readBool(String key) async {
    final value = await read(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  // Read integer
  Future<int?> readInt(String key) async {
    final value = await read(key);
    return value != null ? int.tryParse(value) : null;
  }

  // Read double
  Future<double?> readDouble(String key) async {
    final value = await read(key);
    return value != null ? double.tryParse(value) : null;
  }

  // Read object
  Future<Map<String, dynamic>?> readObject(String key) async {
    final value = await read(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Read list
  Future<List<dynamic>?> readList(String key) async {
    final value = await read(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as List<dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Read typed list
  Future<List<T>?> readTypedList<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    final list = await readList(key);
    if (list == null) return null;
    try {
      return list.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return null;
    }
  }

  // Delete key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Delete all
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    final value = await read(key);
    return value != null;
  }

  // Get all keys
  Future<List<String>> getAllKeys() async {
    return await _storage.readAll().then((map) => map.keys.toList());
  }

  // Get all values
  Future<Map<String, String>> getAll() async {
    return await _storage.readAll();
  }

  // Read with default value
  Future<String> readOrDefault(String key, String defaultValue) async {
    final value = await read(key);
    return value ?? defaultValue;
  }

  // Read int with default
  Future<int> readIntOrDefault(String key, int defaultValue) async {
    final value = await readInt(key);
    return value ?? defaultValue;
  }

  // Read bool with default
  Future<bool> readBoolOrDefault(String key, bool defaultValue) async {
    final value = await readBool(key);
    return value ?? defaultValue;
  }
}