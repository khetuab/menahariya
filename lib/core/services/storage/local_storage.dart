// lib/core/services/storage/local_storage.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:menahariya/core/services/storage/storage_service.dart';

class LocalStorage {
  static LocalStorage? _instance;
  factory LocalStorage() => _instance ??= LocalStorage._internal();
  LocalStorage._internal();

  final StorageService _storage = StorageService();

  Future<void> init() async {
    await _storage.init();
  }

  // User storage
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _storage.saveUser(userData);
  }

  Map<String, dynamic>? getUser() {
    return _storage.getUser();
  }

  Future<void> removeUser() async {
    await _storage.removeUser();
  }

  // Trip storage
  Future<void> saveTrips(List<Map<String, dynamic>> trips) async {
    await _storage.saveTrips(trips);
  }

  List<Map<String, dynamic>>? getTrips() {
    return _storage.getTrips();
  }

  Future<void> saveRecentTrips(List<Map<String, dynamic>> trips) async {
    final Map<int, Map<String, dynamic>> tripsMap = {};
    for (int i = 0; i < trips.length; i++) {
      tripsMap[i] = trips[i];
    }
    await _storage.put('trip_box', 'recent_trips', tripsMap);
  }

  List<Map<String, dynamic>>? getRecentTrips() {
    final data = _storage.get('trip_box', 'recent_trips');
    if (data != null && data is Map) {
      final Map<dynamic, dynamic> tripsMap = data;
      return tripsMap.values.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return null;
  }

  // Ticket storage
  Future<void> saveTickets(List<Map<String, dynamic>> tickets) async {
    await _storage.saveTickets(tickets);
  }

  List<Map<String, dynamic>>? getTickets() {
    return _storage.getTickets();
  }

  Future<void> saveTicket(String ticketId, Map<String, dynamic> ticket) async {
    await _storage.put('ticket_box', 'ticket_$ticketId', ticket);
  }

  Map<String, dynamic>? getTicket(String ticketId) {
    final data = _storage.get('ticket_box', 'ticket_$ticketId');
    if (data != null && data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Cargo storage
  Future<void> saveCargo(List<Map<String, dynamic>> cargoList) async {
    await _storage.saveCargo(cargoList);
  }

  List<Map<String, dynamic>>? getCargoList() {
    return _storage.getCargoList();
  }

  // Cache storage
  Future<void> cacheData(String key, dynamic data, {Duration? expiry}) async {
    await _storage.cacheData(key, data, expiry: expiry);
  }

  dynamic getCachedData(String key) {
    return _storage.getCachedData(key);
  }

  Future<void> clearCache() async {
    await _storage.clearCache();
  }

  // Generic methods
  Future<void> put(String boxName, String key, dynamic value) async {
    await _storage.put(boxName, key, value);
  }

  dynamic get(String boxName, String key) {
    return _storage.get(boxName, key);
  }

  Future<void> delete(String boxName, String key) async {
    await _storage.delete(boxName, key);
  }

  Future<void> clear(String boxName) async {
    await _storage.clear(boxName);
  }

  Future<void> clearAll() async {
    await _storage.clearAll();
  }

  Future<void> close() async {
    await _storage.close();
  }

  // Utility methods
  Future<void> saveList<T>(String boxName, String key, List<T> list) async {
    final map = <int, T>{};
    for (int i = 0; i < list.length; i++) {
      map[i] = list[i];
    }
    await put(boxName, key, map);
  }

  List<T>? getList<T>(String boxName, String key) {
    final data = get(boxName, key);
    if (data != null && data is Map) {
      final Map<dynamic, dynamic> map = data;
      return map.values.map((item) => item as T).toList();
    }
    return null;
  }

  Future<bool> containsKey(String boxName, String key) async {
    return _storage.containsKey(boxName, key);
  }

  Iterable<String> getKeys(String boxName) {
    return _storage.getKeys(boxName);
  }

  int getLength(String boxName) {
    return _storage.getLength(boxName);
  }
}

// Extension methods for easier list handling
extension LocalStorageListExtension on LocalStorage {
  Future<void> saveTypedList<T>(String boxName, String key, List<T> list) async {
    final map = <int, T>{};
    for (int i = 0; i < list.length; i++) {
      map[i] = list[i];
    }
    await put(boxName, key, map);
  }

  List<T>? getTypedList<T>(String boxName, String key) {
    final data = get(boxName, key);
    if (data != null && data is Map) {
      final Map<dynamic, dynamic> map = data;
      return map.values.map((item) => item as T).toList();
    }
    return null;
  }
}

// Specific extensions for common operations
extension UserStorageExtension on LocalStorage {
  static const String _userKey = 'current_user';

  Future<void> saveCurrentUser(Map<String, dynamic> user) => saveUser(user);
  Map<String, dynamic>? getCurrentUser() => getUser();
  Future<void> removeCurrentUser() => removeUser();
}

extension TripsStorageExtension on LocalStorage {
  static const String _tripsKey = 'trips';
  static const String _recentTripsKey = 'recent_trips';

  Future<void> saveAllTrips(List<Map<String, dynamic>> trips) => saveTrips(trips);
  List<Map<String, dynamic>>? getAllTrips() => getTrips();
  Future<void> saveRecentTripsList(List<Map<String, dynamic>> trips) => saveRecentTrips(trips);
  List<Map<String, dynamic>>? getRecentTripsList() => getRecentTrips();
}

extension TicketsStorageExtension on LocalStorage {
  static const String _ticketsKey = 'tickets';

  Future<void> saveAllTickets(List<Map<String, dynamic>> tickets) => saveTickets(tickets);
  List<Map<String, dynamic>>? getAllTickets() => getTickets();
  Future<void> saveTicketById(String ticketId, Map<String, dynamic> ticket) => saveTicket(ticketId, ticket);
  Map<String, dynamic>? getTicketById(String ticketId) => getTicket(ticketId);
}

extension CargoStorageExtension on LocalStorage {
  static const String _cargoKey = 'cargo_list';

  Future<void> saveAllCargo(List<Map<String, dynamic>> cargo) => saveCargo(cargo);
  List<Map<String, dynamic>>? getAllCargo() => getCargoList();
}

extension CacheStorageExtension on LocalStorage {
  Future<void> cacheWithExpiry(String key, dynamic data, Duration expiry) =>
      cacheData(key, data, expiry: expiry);
  dynamic getCached(String key) => getCachedData(key);
  Future<void> clearAllCache() => clearCache();
}