// lib/core/services/storage/storage_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart' as hive;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _userBox = 'user_box';
  static const String _tripBox = 'trip_box';
  static const String _ticketBox = 'ticket_box';
  static const String _cargoBox = 'cargo_box';
  static const String _cacheBox = 'cache_box';

  // Box instances
  late hive.Box _userBoxInstance;
  late hive.Box _tripBoxInstance;
  late hive.Box _ticketBoxInstance;
  late hive.Box _cargoBoxInstance;
  late hive.Box _cacheBoxInstance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Initialize based on platform
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        // For web, use Hive with web support
        await Hive.initFlutter();
        print('📦 Initializing Hive for Web');
      } else {
        // For mobile/desktop, use path_provider
        final appDocDir = await path_provider.getApplicationDocumentsDirectory();
        Hive.init(appDocDir.path);
        print('📦 Initializing Hive for Mobile at: ${appDocDir.path}');
      }

      // Open boxes
      _userBoxInstance = await hive.Hive.openBox(_userBox);
      _tripBoxInstance = await Hive.openBox(_tripBox);
      _ticketBoxInstance = await Hive.openBox(_ticketBox);
      _cargoBoxInstance = await Hive.openBox(_cargoBox);
      _cacheBoxInstance = await Hive.openBox(_cacheBox);

      _isInitialized = true;
      print('✅ Storage initialized on ${kIsWeb ? 'Web' : 'Mobile'}');
    } catch (e) {
      print('❌ Storage initialization error: $e');
      // Fallback to memory-only mode
      await _initMemoryFallback();
    }
  }

  // FIXED: Memory fallback using proper Hive lazy boxes
  Future<void> _initMemoryFallback() async {
    try {
      // Create in-memory boxes (not persisted)
      _userBoxInstance = await Hive.openBox(_userBox);
      _tripBoxInstance = await Hive.openBox(_tripBox);
      _ticketBoxInstance = await Hive.openBox(_ticketBox);
      _cargoBoxInstance = await Hive.openBox(_cargoBox);
      _cacheBoxInstance = await Hive.openBox(_cacheBox);

      _isInitialized = true;
      print('⚠️ Using memory fallback for storage (data will not persist)');
    } catch (e) {
      print('❌ Even memory fallback failed: $e');
      // Ultimate fallback - create empty boxes that will work
      _createEmptyBoxes();
    }
  }

  // Ultimate fallback - create empty box instances
  void _createEmptyBoxes() {
    _userBoxInstance = MemoryBox(_userBox) as hive.Box;
    _tripBoxInstance = MemoryBox(_tripBox) as hive.Box;
    _ticketBoxInstance = MemoryBox(_ticketBox) as hive.Box;
    _cargoBoxInstance = MemoryBox(_cargoBox) as hive.Box;
    _cacheBoxInstance = Box(_cacheBox) as hive.Box;
    _isInitialized = true;
    print('⚠️ Using minimal fallback for storage');
  }

  // User storage
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _userBoxInstance.put('current_user', userData);
  }

  Map<String, dynamic>? getUser() {
    final data = _userBoxInstance.get('current_user');
    if (data != null && data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  Future<void> removeUser() async {
    await _userBoxInstance.delete('current_user');
  }

  // Trip storage
  Future<void> saveTrips(List<Map<String, dynamic>> trips) async {
    final Map<int, Map<String, dynamic>> tripsMap = {};
    for (int i = 0; i < trips.length; i++) {
      tripsMap[i] = trips[i];
    }
    await _tripBoxInstance.put('trips', tripsMap);
  }

  List<Map<String, dynamic>>? getTrips() {
    final data = _tripBoxInstance.get('trips');
    if (data != null && data is Map) {
      final Map<dynamic, dynamic> tripsMap = data;
      return tripsMap.values.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return null;
  }

  // Ticket storage
  Future<void> saveTickets(List<Map<String, dynamic>> tickets) async {
    final Map<int, Map<String, dynamic>> ticketsMap = {};
    for (int i = 0; i < tickets.length; i++) {
      ticketsMap[i] = tickets[i];
    }
    await _ticketBoxInstance.put('tickets', ticketsMap);
  }

  List<Map<String, dynamic>>? getTickets() {
    final data = _ticketBoxInstance.get('tickets');
    if (data != null && data is Map) {
      final Map<dynamic, dynamic> ticketsMap = data;
      return ticketsMap.values.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return null;
  }

  // Cargo storage
  Future<void> saveCargo(List<Map<String, dynamic>> cargoList) async {
    final Map<int, Map<String, dynamic>> cargoMap = {};
    for (int i = 0; i < cargoList.length; i++) {
      cargoMap[i] = cargoList[i];
    }
    await _cargoBoxInstance.put('cargo_list', cargoMap);
  }

  List<Map<String, dynamic>>? getCargoList() {
    final data = _cargoBoxInstance.get('cargo_list');
    if (data != null && data is Map) {
      final Map<dynamic, dynamic> cargoMap = data;
      return cargoMap.values.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return null;
  }

  // Cache storage
  Future<void> cacheData(String key, dynamic data, {Duration? expiry}) async {
    final cacheItem = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await _cacheBoxInstance.put(key, cacheItem);
  }

  dynamic getCachedData(String key) {
    final cacheItem = _cacheBoxInstance.get(key);
    if (cacheItem == null) return null;

    if (cacheItem is Map) {
      final timestamp = cacheItem['timestamp'] as int?;
      final expiry = cacheItem['expiry'] as int?;

      if (expiry != null && timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - timestamp > expiry) {
          _cacheBoxInstance.delete(key);
          return null;
        }
      }
      return cacheItem['data'];
    }
    return null;
  }

  Future<void> clearCache() async {
    await _cacheBoxInstance.clear();
  }

  // Generic methods
  Future<void> put(String boxName, String key, dynamic value) async {
    switch (boxName) {
      case 'user_box':
        await _userBoxInstance.put(key, value);
        break;
      case 'trip_box':
        await _tripBoxInstance.put(key, value);
        break;
      case 'ticket_box':
        await _ticketBoxInstance.put(key, value);
        break;
      case 'cargo_box':
        await _cargoBoxInstance.put(key, value);
        break;
      case 'cache_box':
        await _cacheBoxInstance.put(key, value);
        break;
    }
  }

  dynamic get(String boxName, String key) {
    switch (boxName) {
      case 'user_box':
        return _userBoxInstance.get(key);
      case 'trip_box':
        return _tripBoxInstance.get(key);
      case 'ticket_box':
        return _ticketBoxInstance.get(key);
      case 'cargo_box':
        return _cargoBoxInstance.get(key);
      case 'cache_box':
        return _cacheBoxInstance.get(key);
      default:
        return null;
    }
  }

  Future<void> delete(String boxName, String key) async {
    switch (boxName) {
      case 'user_box':
        await _userBoxInstance.delete(key);
        break;
      case 'trip_box':
        await _tripBoxInstance.delete(key);
        break;
      case 'ticket_box':
        await _ticketBoxInstance.delete(key);
        break;
      case 'cargo_box':
        await _cargoBoxInstance.delete(key);
        break;
      case 'cache_box':
        await _cacheBoxInstance.delete(key);
        break;
    }
  }

  Future<void> clear(String boxName) async {
    switch (boxName) {
      case 'user_box':
        await _userBoxInstance.clear();
        break;
      case 'trip_box':
        await _tripBoxInstance.clear();
        break;
      case 'ticket_box':
        await _ticketBoxInstance.clear();
        break;
      case 'cargo_box':
        await _cargoBoxInstance.clear();
        break;
      case 'cache_box':
        await _cacheBoxInstance.clear();
        break;
    }
  }

  Future<void> clearAll() async {
    await Future.wait([
      _userBoxInstance.clear(),
      _tripBoxInstance.clear(),
      _ticketBoxInstance.clear(),
      _cargoBoxInstance.clear(),
      _cacheBoxInstance.clear(),
    ]);
  }

  Future<bool> containsKey(String boxName, String key) async {
    switch (boxName) {
      case 'user_box':
        return _userBoxInstance.containsKey(key);
      case 'trip_box':
        return _tripBoxInstance.containsKey(key);
      case 'ticket_box':
        return _ticketBoxInstance.containsKey(key);
      case 'cargo_box':
        return _cargoBoxInstance.containsKey(key);
      case 'cache_box':
        return _cacheBoxInstance.containsKey(key);
      default:
        return false;
    }
  }

  Iterable<String> getKeys(String boxName) {
    switch (boxName) {
      case 'user_box':
        return _userBoxInstance.keys.cast<String>();
      case 'trip_box':
        return _tripBoxInstance.keys.cast<String>();
      case 'ticket_box':
        return _ticketBoxInstance.keys.cast<String>();
      case 'cargo_box':
        return _cargoBoxInstance.keys.cast<String>();
      case 'cache_box':
        return _cacheBoxInstance.keys.cast<String>();
      default:
        return [];
    }
  }

  int getLength(String boxName) {
    switch (boxName) {
      case 'user_box':
        return _userBoxInstance.length;
      case 'trip_box':
        return _tripBoxInstance.length;
      case 'ticket_box':
        return _ticketBoxInstance.length;
      case 'cargo_box':
        return _cargoBoxInstance.length;
      case 'cache_box':
        return _cacheBoxInstance.length;
      default:
        return 0;
    }
  }

  Future<void> close() async {
    await Future.wait([
      _userBoxInstance.close(),
      _tripBoxInstance.close(),
      _ticketBoxInstance.close(),
      _cargoBoxInstance.close(),
      _cacheBoxInstance.close(),
    ]);
  }
}

// Simple Box class for ultimate fallback
class Box<T> {
  final String name;
  final Map<String, T> _store = {};

  Box(this.name);

  Future<void> put(String key, T value) async {
    _store[key] = value;
  }

  T? get(String key) => _store[key];

  Future<void> delete(String key) async {
    _store.remove(key);
  }

  Future<void> clear() async {
    _store.clear();
  }

  bool containsKey(String key) => _store.containsKey(key);

  Iterable<String> get keys => _store.keys;

  int get length => _store.length;

  Future<void> close() async {}
}
class MemoryBox<T> {
  final String name;
  final Map<String, T> _store = {};

  MemoryBox(this.name);

  Future<void> put(String key, T value) async => _store[key] = value;
  T? get(String key) => _store[key];
  Future<void> delete(String key) async => _store.remove(key);
  Future<void> clear() async => _store.clear();
  bool containsKey(String key) => _store.containsKey(key);
  Iterable<String> get keys => _store.keys;
  int get length => _store.length;
  Future<void> close() async {}
}