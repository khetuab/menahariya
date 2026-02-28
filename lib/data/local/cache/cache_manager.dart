// lib/data/local/cache/cache_manager.dart

import 'dart:async';
import 'package:menahariya/data/local/daos/cache_dao.dart';
import 'package:menahariya/data/local/database/app_database.dart';

class CacheManager {
  static CacheManager? _instance;
  factory CacheManager() => _instance ??= CacheManager._internal();
  CacheManager._internal();

  late final CacheDao _cacheDao;
  late final AppDatabase _database;
  final CacheStats _stats = CacheStats();

  // Configuration
  static const Duration defaultExpiry = Duration(hours: 1);
  static const Duration shortExpiry = Duration(minutes: 5);
  static const Duration longExpiry = Duration(days: 1);

  // Cache tags for grouping
  static const String tagUser = 'user';
  static const String tagTrip = 'trip';
  static const String tagTicket = 'ticket';
  static const String tagCargo = 'cargo';
  static const String tagNotification = 'notification';
  static const String tagSettings = 'settings';
  static const String tagSearch = 'search';

  // Initialize
  Future<void> init(AppDatabase database) async {
    _database = database;
    _cacheDao = CacheDao(database);

    // Start cleanup timer
    _startCleanupTimer();
  }

  // Generic cache methods
  Future<void> set(
      String key,
      dynamic value, {
        Duration? expiry,
        List<String>? tags,
      }) async {
    try {
      await _cacheDao.cacheData(
        key,
        value,
        expiry: expiry ?? defaultExpiry,
        tags: tags,
      );
    } catch (e) {
      print('Cache set error for key $key: $e');
    }
  }

  dynamic get(String key) {
    final value = _cacheDao.getCachedData(key);
    if (value != null) {
      _stats.recordHit(key);
    } else {
      _stats.recordMiss(key);
    }
    return value;
  }

  Future<void> remove(String key) async {
    await _cacheDao.invalidate(key);
  }

  Future<void> clear() async {
    await _cacheDao.clearAll();
    _stats.reset();
  }

  // Typed getters
  T? getAs<T>(String key) {
    final value = get(key);
    if (value == null) return null;
    try {
      return value as T;
    } catch (e) {
      print('Cache type error for key $key: $e');
      return null;
    }
  }

  // User cache methods
  Future<void> cacheUser(String userId, Map<String, dynamic> userData) async {
    await set(
      'user:$userId',
      userData,
      tags: [tagUser],
    );
  }

  Map<String, dynamic>? getCachedUser(String userId) {
    return getAs<Map<String, dynamic>>('user:$userId');
  }

  // Trip cache methods
  Future<void> cacheTrip(String tripId, Map<String, dynamic> tripData) async {
    await set(
      'trip:$tripId',
      tripData,
      tags: [tagTrip],
    );
  }

  Map<String, dynamic>? getCachedTrip(String tripId) {
    return getAs<Map<String, dynamic>>('trip:$tripId');
  }

  // Ticket cache methods
  Future<void> cacheTicket(String ticketId, Map<String, dynamic> ticketData) async {
    await set(
      'ticket:$ticketId',
      ticketData,
      tags: [tagTicket],
    );
  }

  Map<String, dynamic>? getCachedTicket(String ticketId) {
    return getAs<Map<String, dynamic>>('ticket:$ticketId');
  }

  // Cargo cache methods
  Future<void> cacheCargo(String cargoId, Map<String, dynamic> cargoData) async {
    await set(
      'cargo:$cargoId',
      cargoData,
      tags: [tagCargo],
    );
  }

  Map<String, dynamic>? getCachedCargo(String cargoId) {
    return getAs<Map<String, dynamic>>('cargo:$cargoId');
  }

  // Search results cache
  Future<void> cacheSearchResults(
      String query,
      List<Map<String, dynamic>> results,
      ) async {
    await set(
      'search:$query',
      results,
      expiry: shortExpiry,
      tags: [tagSearch],
    );
  }

  List<Map<String, dynamic>>? getCachedSearchResults(String query) {
    return getAs<List<Map<String, dynamic>>>('search:$query');
  }

  // List caches
  Future<void> cacheTripsList(
      String key,
      List<Map<String, dynamic>> trips,
      ) async {
    await set(
      'trips:$key',
      trips,
      expiry: shortExpiry,
      tags: [tagTrip],
    );
  }

  List<Map<String, dynamic>>? getCachedTripsList(String key) {
    return getAs<List<Map<String, dynamic>>>('trips:$key');
  }

  // Invalidation by tag
  Future<void> invalidateByTag(String tag) async {
    await _cacheDao.invalidateByTag(tag);
  }

  Future<void> invalidateUserCache() async {
    await invalidateByTag(tagUser);
  }

  Future<void> invalidateTripCache() async {
    await invalidateByTag(tagTrip);
  }

  Future<void> invalidateTicketCache() async {
    await invalidateByTag(tagTicket);
  }

  Future<void> invalidateCargoCache() async {
    await invalidateByTag(tagCargo);
  }

  Future<void> invalidateSearchCache() async {
    await invalidateByTag(tagSearch);
  }

  // Memory pressure handling
  Future<void> handleLowMemory() async {
    // Clear all caches on low memory
    await clear();
  }

  // Periodic cleanup
  Timer? _cleanupTimer;

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 15),
          (_) => _performCleanup(),
    );
  }

  Future<void> _performCleanup() async {
    final cleaned = await _cacheDao.cleanExpired();
    if (cleaned > 0) {
      print('Cache cleanup: removed $cleaned expired items');
    }
  }

  // Preload cache
  Future<void> preload(List<Map<String, dynamic>> items) async {
    for (var item in items) {
      final type = item['type'];
      final id = item['id'];
      final data = item['data'];

      switch (type) {
        case 'user':
          await cacheUser(id, data);
          break;
        case 'trip':
          await cacheTrip(id, data);
          break;
        case 'ticket':
          await cacheTicket(id, data);
          break;
        case 'cargo':
          await cacheCargo(id, data);
          break;
      }
    }
  }

  // Cache statistics
  Map<String, dynamic> getStats() {
    final daoStats = _cacheDao.getStats();
    return {
      ...daoStats,
      'hitRatio': _stats.hitRatio,
      'hits': _stats.hits,
      'misses': _stats.misses,
      'totalRequests': _stats.hits + _stats.misses,
    };
  }

  // Warm up cache
  Future<void> warmUp() async {
    // Preload frequently accessed data
    // This would be implemented based on app needs
  }

  // Dispose
  void dispose() {
    _cleanupTimer?.cancel();
  }
}

// Cache key builder
class CacheKeys {
  static String user(String userId) => 'user:$userId';
  static String trip(String tripId) => 'trip:$tripId';
  static String ticket(String ticketId) => 'ticket:$ticketId';
  static String cargo(String cargoId) => 'cargo:$cargoId';
  static String search(String query) => 'search:$query';
  static String tripsList(String filter) => 'trips:$filter';
  static String routesList() => 'routes:all';
  static String popularRoutes() => 'routes:popular';
  static String featuredTrips() => 'trips:featured';
  static String userPreferences(String userId) => 'prefs:$userId';
  static String notifications(String userId) => 'notifications:$userId';
}

// Cache policy enums
enum CachePolicy {
  always, // Always use cache first
  networkFirst, // Try network first, fallback to cache
  cacheFirst, // Try cache first, fallback to network
  never, // Never use cache
  refresh, // Force refresh
}

// Cache options for requests
class CacheOptions {
  final CachePolicy policy;
  final Duration? expiry;
  final List<String>? tags;
  final bool allowStale;
  final Duration? staleWhileRevalidate;

  const CacheOptions({
    this.policy = CachePolicy.cacheFirst,
    this.expiry,
    this.tags,
    this.allowStale = false,
    this.staleWhileRevalidate,
  });

  // Predefined options
  static const CacheOptions defaultCache = CacheOptions(
    policy: CachePolicy.cacheFirst,
    expiry: Duration(hours: 1),
  );

  static const CacheOptions shortCache = CacheOptions(
    policy: CachePolicy.cacheFirst,
    expiry: Duration(minutes: 5),
  );

  static const CacheOptions longCache = CacheOptions(
    policy: CachePolicy.cacheFirst,
    expiry: Duration(days: 1),
  );

  static const CacheOptions networkFirst = CacheOptions(
    policy: CachePolicy.networkFirst,
  );

  static const CacheOptions refresh = CacheOptions(
    policy: CachePolicy.refresh,
  );
}