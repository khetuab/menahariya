// lib/data/local/daos/user_dao.dart

import 'package:hive/hive.dart';
import 'package:menahariya/data/local/database/app_database.dart';
import 'package:menahariya/data/models/user/user_model.dart';

class UserDao {
  final AppDatabase _db;

  UserDao(this._db);

  Box<UserModel> get _box => _db.userBoxInstance;

  // Create or Update
  Future<void> insertUser(UserModel user) async {
    await _box.put(user.id, user);
  }

  Future<void> insertUsers(List<UserModel> users) async {
    await _box.putAll({
      for (var user in users) user.id: user,
    });
  }

  // Read
  UserModel? getUser(String userId) {
    return _box.get(userId);
  }

  List<UserModel> getAllUsers() {
    return _box.values.toList();
  }

  List<UserModel> getUsersByRole(String role) {
    return _box.values.where((user) => user.role == role).toList();
  }

  UserModel? getUserByPhone(String phone) {
    try {
      return _box.values.firstWhere((user) => user.phone == phone);
    } catch (e) {
      return null;
    }
  }

  // Update
  Future<void> updateUser(UserModel user) async {
    await _box.put(user.id, user);
  }

  Future<void> updateUserField(String userId, String field, dynamic value) async {
    final user = getUser(userId);
    if (user != null) {
      // Use copyWith to create updated user
      UserModel updatedUser;
      switch (field) {
        case 'fullName':
          updatedUser = user.copyWith(fullName: value);
          break;
        case 'email':
          updatedUser = user.copyWith(email: value);
          break;
        case 'profileImage':
          updatedUser = user.copyWith(profileImage: value);
          break;
        case 'address':
          updatedUser = user.copyWith(address: value);
          break;
        case 'city':
          updatedUser = user.copyWith(city: value);
          break;
        case 'isAvailable':
          updatedUser = user.copyWith(isAvailable: value);
          break;
        case 'walletBalance':
          updatedUser = user.copyWith(walletBalance: value);
          break;
        case 'loyaltyPoints':
          updatedUser = user.copyWith(loyaltyPoints: value);
          break;
        default:
          return;
      }
      await _box.put(userId, updatedUser);
    }
  }

  // Delete
  Future<void> deleteUser(String userId) async {
    await _box.delete(userId);
  }

  Future<void> deleteAllUsers() async {
    await _box.clear();
  }

  // Check existence
  bool userExists(String userId) {
    return _box.containsKey(userId);
  }

  // Count
  int getUserCount() {
    return _box.length;
  }

  int getUserCountByRole(String role) {
    return _box.values.where((user) => user.role == role).length;
  }

  // Search
  List<UserModel> searchUsers(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values.where((user) {
      return user.fullName.toLowerCase().contains(lowerQuery) ||
          user.phone.contains(lowerQuery) ||
          (user.email?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Get active/inactive users
  List<UserModel> getActiveUsers() {
    return _box.values.where((user) => user.isActive).toList();
  }

  List<UserModel> getInactiveUsers() {
    return _box.values.where((user) => !user.isActive).toList();
  }

  // Get verified/unverified users
  List<UserModel> getVerifiedUsers() {
    return _box.values.where((user) => user.isVerified).toList();
  }

  List<UserModel> getUnverifiedUsers() {
    return _box.values.where((user) => !user.isVerified).toList();
  }

  // Batch operations
  Future<void> insertUsersBatch(List<UserModel> users) async {
    await _box.putAll({
      for (var user in users) user.id: user,
    });
  }

  Future<void> deleteUsersBatch(List<String> userIds) async {
    await _box.deleteAll(userIds);
  }

  // Sync operations
  Future<void> syncUsers(List<UserModel> serverUsers) async {
    final localUsers = getAllUsers();
    final localUserMap = {for (var u in localUsers) u.id: u};
    final serverUserMap = {for (var u in serverUsers) u.id: u};

    // Find users to update, insert, or delete
    final toUpdate = <UserModel>[];
    final toInsert = <UserModel>[];
    final toDeleteIds = <String>[];

    for (var serverUser in serverUsers) {
      final localUser = localUserMap[serverUser.id];
      if (localUser == null) {
        toInsert.add(serverUser);
      } else if (localUser.updatedAt != serverUser.updatedAt) {
        toUpdate.add(serverUser);
      }
    }

    for (var localUser in localUsers) {
      if (!serverUserMap.containsKey(localUser.id)) {
        toDeleteIds.add(localUser.id);
      }
    }

    // Perform operations
    if (toInsert.isNotEmpty) await insertUsersBatch(toInsert);
    if (toUpdate.isNotEmpty) await insertUsersBatch(toUpdate);
    if (toDeleteIds.isNotEmpty) await deleteUsersBatch(toDeleteIds);
  }

  // Get statistics
  Map<String, dynamic> getStats() {
    return {
      'total': _box.length,
      'passengers': getUserCountByRole('passenger'),
      'drivers': getUserCountByRole('driver'),
      'admins': getUserCountByRole('admin'),
      'staff': getUserCountByRole('staff'),
      'active': getActiveUsers().length,
      'verified': getVerifiedUsers().length,
    };
  }

  // Listen to changes
  Stream<BoxEvent> watchUser(String userId) {
    return _box.watch(key: userId);
  }

  Stream<BoxEvent> watchAllUsers() {
    return _box.watch();
  }
}

// User preferences DAO
class UserPreferencesDao {
  final Box<Map> _settingsBox;

  UserPreferencesDao(this._settingsBox);

  static const String _prefsKey = 'user_preferences_';

  Future<void> savePreferences(String userId, Map<dynamic, dynamic> preferences) async {
    await _settingsBox.put('$_prefsKey$userId', preferences);
  }

  Map? getPreferences(String userId) {
    return _settingsBox.get('$_prefsKey$userId');
  }

  Future<void> deletePreferences(String userId) async {
    await _settingsBox.delete('$_prefsKey$userId');
  }

  Future<void> updatePreference(String userId, String key, dynamic value) async {
    final prefs = getPreferences(userId) ?? {};
    prefs[key] = value;
    await savePreferences(userId, prefs);
  }

  // Get specific preference
  dynamic getPreference(String userId, String key, {dynamic defaultValue}) {
    final prefs = getPreferences(userId);
    return prefs?[key] ?? defaultValue;
  }
}