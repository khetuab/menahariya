// lib/data/local/daos/cache_dao.dart

import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:menahariya/data/local/database/app_database.dart';

class CacheDao {
  final AppDatabase _db;

  CacheDao(this._db);

  Box<Map> get _box => _db.cacheBoxInstance;

  // Cache item structure
  static const String _keyData = 'data';
  static const String _keyTimestamp = 'timestamp';
  static const String _keyExpiry = 'expiry';
  static const String _keyTags = 'tags';

  // Store data in cache
  Future<void> cacheData(
      String key,
      dynamic data, {
        Duration? expiry,
        List<String>? tags,
      }) async {
    final cacheItem = {
      _keyData: data,
      _keyTimestamp: DateTime.now().millisecondsSinceEpoch,
      if (expiry != null) _keyExpiry: expiry.inMilliseconds,
      if (tags != null) _keyTags: tags,
    };

    await _box.put(key, cacheItem);

    // Also index by tags if provided
    if (tags != null) {
      for (var tag in tags) {
        await _addToTagIndex(tag, key);
      }
    }
  }

  // Retrieve cached data
  dynamic getCachedData(String key) {
    final cacheItem = _box.get(key);
    if (cacheItem == null) return null;

    // Check expiry
    final expiry = cacheItem[_keyExpiry] as int?;
    if (expiry != null) {
      final timestamp = cacheItem[_keyTimestamp] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > expiry) {
        // Expired - remove
        _box.delete(key);
        return null;
      }
    }

    return cacheItem[_keyData];
  }

  // Get cache metadata
  Map<String, dynamic>? getCacheMetadata(String key) {
    final cacheItem = _box.get(key);
    if (cacheItem == null) return null;

    return {
      'timestamp': DateTime.fromMillisecondsSinceEpoch(cacheItem[_keyTimestamp]),
      'expiry': cacheItem[_keyExpiry] != null
          ? Duration(milliseconds: cacheItem[_keyExpiry])
          : null,
      'tags': cacheItem[_keyTags],
      'size': _getSize(cacheItem[_keyData]),
    };
  }

  // Check if cache exists and is valid
  bool isCacheValid(String key) {
    return getCachedData(key) != null;
  }

  // Delete cached data
  Future<void> invalidate(String key) async {
    await _box.delete(key);
  }

  // Invalidate multiple keys
  Future<void> invalidateAll(List<String> keys) async {
    await _box.deleteAll(keys);
  }

  // Invalidate by tag
  Future<void> invalidateByTag(String tag) async {
    final keys = await _getKeysByTag(tag);
    if (keys.isNotEmpty) {
      await _box.deleteAll(keys);
    }
  }

  // Clear all cache
  Future<void> clearAll() async {
    await _box.clear();
    await _clearTagIndex();
  }

  // Get all cache keys
  List<String> getAllKeys() {
    return _box.keys.cast<String>().toList();
  }

  // Get cache statistics
  Map<String, dynamic> getStats() {
    int totalSize = 0;
    final keys = getAllKeys();

    for (var key in keys) {
      final data = getCachedData(key);
      totalSize += _getSize(data);
    }

    return {
      'totalItems': _box.length,
      'totalSize': totalSize,
      'totalSizeFormatted': _formatSize(totalSize),
      'keys': keys,
    };
  }

  // Clean expired cache
  Future<int> cleanExpired() async {
    int cleaned = 0;
    final keys = getAllKeys();

    for (var key in keys) {
      if (getCachedData(key) == null) {
        cleaned++;
      }
    }

    return cleaned;
  }

  // Tag index management
  final Box<List> _tagIndex = Hive.box<List>('tag_index');

  Future<void> _addToTagIndex(String tag, String key) async {
    final keys = _tagIndex.get(tag, defaultValue: []) as List;
    if (!keys.contains(key)) {
      keys.add(key);
      await _tagIndex.put(tag, keys);
    }
  }

  Future<List<String>> _getKeysByTag(String tag) async {
    final keys = _tagIndex.get(tag, defaultValue: []) as List;
    return keys.cast<String>();
  }

  Future<void> _clearTagIndex() async {
    await _tagIndex.clear();
  }

  // Utility methods
  int _getSize(dynamic data) {
    try {
      final json = jsonEncode(data);
      return utf8.encode(json).length;
    } catch (e) {
      return 0;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Batch cache operations
  Future<void> cacheMultiple(Map<String, dynamic> items, {Duration? expiry}) async {
    for (var entry in items.entries) {
      await cacheData(entry.key, entry.value, expiry: expiry);
    }
  }

  Map<String, dynamic> getMultiple(List<String> keys) {
    final result = <String, dynamic>{};
    for (var key in keys) {
      final data = getCachedData(key);
      if (data != null) {
        result[key] = data;
      }
    }
    return result;
  }

  // Cache with versioning
  Future<void> cacheWithVersion(
      String key,
      dynamic data,
      int version, {
        Duration? expiry,
      }) async {
    final cacheItem = {
      _keyData: data,
      _keyTimestamp: DateTime.now().millisecondsSinceEpoch,
      'version': version,
      if (expiry != null) _keyExpiry: expiry.inMilliseconds,
    };
    await _box.put(key, cacheItem);
  }

  dynamic getCachedWithVersion(String key, int requiredVersion) {
    final cacheItem = _box.get(key);
    if (cacheItem == null) return null;

    final version = cacheItem['version'] as int?;
    if (version != requiredVersion) return null;

    // Check expiry
    final expiry = cacheItem[_keyExpiry] as int?;
    if (expiry != null) {
      final timestamp = cacheItem[_keyTimestamp] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > expiry) {
        _box.delete(key);
        return null;
      }
    }

    return cacheItem[_keyData];
  }
}

// Cache statistics tracker
class CacheStats {
  int hits = 0;
  int misses = 0;
  final Map<String, int> accessCount = {};

  double get hitRatio => hits + misses > 0 ? hits / (hits + misses) : 0;

  void recordHit(String key) {
    hits++;
    accessCount[key] = (accessCount[key] ?? 0) + 1;
  }

  void recordMiss(String key) {
    misses++;
  }

  void reset() {
    hits = 0;
    misses = 0;
    accessCount.clear();
  }

  Map<String, dynamic> toJson() {
    return {
      'hits': hits,
      'misses': misses,
      'hitRatio': hitRatio,
      'totalRequests': hits + misses,
      'topKeys': accessCount.entries
          .toList()
          .sorted((a, b) => b.value.compareTo(a.value))
          .take(10)
          .map((e) => {'key': e.key, 'count': e.value})
          .toList(),
    };
  }
}

// Extension for sorting
extension ListSorting<T> on List<T> {
  List<T> sorted(int Function(T a, T b) compare) {
    final list = [...this];
    list.sort(compare);
    return list;
  }
}