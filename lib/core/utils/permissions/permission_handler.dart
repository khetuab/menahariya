// lib/core/utils/permissions/permission_handler.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:local_auth/local_auth.dart';
import 'package:menahariya/core/widgets/dialogs/confirmation_dialog.dart';

class PermissionHandler {
  // Private constructor
  PermissionHandler._();

  // Biometric authentication instance
  static final LocalAuthentication _localAuth = LocalAuthentication();

  // Permission types
  static const List<ph.Permission> cameraPermissions = [
    ph.Permission.camera,
  ];

  static const List<ph.Permission> storagePermissions = [
    ph.Permission.storage,
  ];

  static const List<ph.Permission> mediaPermissions = [
    ph.Permission.photos,
    ph.Permission.videos,
    ph.Permission.audio,
  ];

  static const List<ph.Permission> locationPermissions = [
    ph.Permission.location,
    ph.Permission.locationAlways,
    ph.Permission.locationWhenInUse,
  ];

  static const List<ph.Permission> notificationPermissions = [
    ph.Permission.notification,
  ];

  // ============== Biometric Authentication Methods ==============

  /// Check if device supports biometrics
  static Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      print('❌ Error checking device support: $e');
      return false;
    }
  }

  /// Check if biometric authentication is available on the device
  static Future<bool> checkBiometricSupport() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      print('🔐 Biometric support - Available: $isAvailable');
      return isAvailable;
    } on PlatformException catch (e) {
      print('❌ Error checking biometric support: $e');
      return false;
    }
  }

  /// Get available biometric types on the device
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('❌ Error getting available biometrics: $e');
      return [];
    }
  }

  /// Get human-readable biometric type name
  static String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris Scan';
      case BiometricType.strong:
        return 'Biometric';
      default:
        return 'Biometric';
    }
  }

  /// Authenticate with biometrics using the official API
  /// Authenticate with biometrics using the correct API
  static Future<bool> authenticateWithBiometrics({
    required String reason,
    bool biometricOnly = true,
    bool persistAcrossBackgrounding = false,
    bool sensitiveTransaction = true,
  }) async {
    try {
      // First check if biometrics are available
      final isAvailable = await checkBiometricSupport();
      if (!isAvailable) {
        print('⚠️ Biometric authentication not available');
        if (Get.context != null) {
          Get.snackbar(
            'Not Available',
            'Biometric authentication is not available on this device',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return false;
      }

      // Get the current activity context
      final context = Get.context;
      if (context == null) {
        print('⚠️ No current context available');
        return false;
      }

      // Use the correct API parameters
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        sensitiveTransaction: sensitiveTransaction,
        persistAcrossBackgrounding: persistAcrossBackgrounding,
      );

      print('🔐 Biometric authentication result: $isAuthenticated');
      return isAuthenticated;

    } on PlatformException catch (e) {
      print('❌ Error during biometric authentication: $e');

      // Handle specific errors
      final errorMsg = e.message?.toLowerCase() ?? '';
      if (errorMsg.contains('not enrolled')) {
        if (Get.context != null) {
          Get.snackbar(
            'No Biometrics Set Up',
            'Please set up fingerprint or face recognition in your device settings',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (errorMsg.contains('locked out')) {
        if (Get.context != null) {
          Get.snackbar(
            'Too Many Attempts',
            'Biometric authentication is locked. Please use your device PIN or password.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (errorMsg.contains('uiUnavailable') || errorMsg.contains('fragment')) {
        print('⚠️ UI unavailable - trying alternative approach');
        // Try without androidAuthCallback
        return await _authenticateAlternative(reason, biometricOnly);
      } else if (!errorMsg.contains('canceled') && !errorMsg.contains('cancelled')) {
        if (Get.context != null) {
          Get.snackbar(
            'Authentication Failed',
            'Please try again',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      return false;
    }
  }

  /// Alternative authentication method without callbacks
  static Future<bool> _authenticateAlternative(String reason, bool biometricOnly) async {
    try {
      print('🔄 Trying alternative authentication method...');

      // Simple authentication without any callbacks
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
      );

      return isAuthenticated;
    } catch (e) {
      print('❌ Alternative authentication failed: $e');
      return false;
    }
  }



  /// Authenticate with biometrics allowing device credentials fallback
  /// Authenticate with biometrics allowing device credentials fallback
  static Future<bool> authenticateWithFallback({
    required String reason,
    bool allowDeviceCredentials = true,
  }) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: !allowDeviceCredentials,
        persistAcrossBackgrounding: true,
      );

      return isAuthenticated;
    } on LocalAuthException catch (e) {
      print('🔐 Auth error: ${e.code}');
      return false;
    } on PlatformException catch (e) {
      print('❌ Error during authentication: $e');
      return false;
    }
  }
  /// Stop current biometric authentication
  static Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      print('Error stopping authentication: $e');
    }
  }

  // ============== Permission Methods ==============

  /// Check if permission is granted
  static Future<bool> isGranted(ph.Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// Check if multiple permissions are granted
  static Future<bool> areGranted(List<ph.Permission> permissions) async {
    for (final permission in permissions) {
      if (!await isGranted(permission)) {
        return false;
      }
    }
    return true;
  }

  /// Request single permission
  static Future<bool> requestPermission(
      ph.Permission permission, {
        String? rationale,
        bool showDialog = true,
      }) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (showDialog) {
        await _showSettingsDialog(permission, rationale);
      }
      return false;
    }

    if (status.isDenied && showDialog && rationale != null) {
      final shouldRequest = await _showRationaleDialog(permission, rationale);
      if (!shouldRequest) {
        return false;
      }
    }

    final result = await permission.request();
    return result.isGranted;
  }

  /// Request multiple permissions
  static Future<Map<ph.Permission, bool>> requestPermissions(
      List<ph.Permission> permissions, {
        String? rationale,
        bool showDialog = true,
      }) async {
    final results = <ph.Permission, bool>{};

    for (final permission in permissions) {
      results[permission] = await requestPermission(
        permission,
        rationale: rationale,
        showDialog: showDialog,
      );
    }

    return results;
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission({
    String? rationale,
    bool showDialog = true,
  }) async {
    return requestPermission(
      ph.Permission.camera,
      rationale: rationale ?? 'Camera access is needed to scan QR codes and take photos',
      showDialog: showDialog,
    );
  }

  /// Request storage permission - Updated for Android 13+
  static Future<bool> requestStoragePermission({
    String? rationale,
    bool showDialog = true,
  }) async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), use photos permission
      try {
        if (await ph.Permission.photos.isGranted) {
          return true;
        }
        final photosStatus = await ph.Permission.photos.request();
        if (photosStatus.isGranted) {
          return true;
        }
      } catch (e) {
        // Fallback to storage permission for older Android versions
      }

      // Fallback to storage permission (Android 12 and below)
      if (await ph.Permission.storage.isGranted) {
        return true;
      }

      return requestPermission(
        ph.Permission.storage,
        rationale: rationale ?? 'Storage access is needed to select images for your profile',
        showDialog: showDialog,
      );
    } else if (Platform.isIOS) {
      return requestPermission(
        ph.Permission.photos,
        rationale: rationale ?? 'Photo access is needed to select images for your profile',
        showDialog: showDialog,
      );
    }
    return false;
  }

  /// Request location permission
  static Future<bool> requestLocationPermission({
    String? rationale,
    bool showDialog = true,
  }) async {
    return requestPermission(
      ph.Permission.locationWhenInUse,
      rationale: rationale ?? 'Location access is needed to track buses near you',
      showDialog: showDialog,
    );
  }

  /// Request notification permission
  static Future<bool> requestNotificationPermission({
    String? rationale,
    bool showDialog = true,
  }) async {
    return requestPermission(
      ph.Permission.notification,
      rationale: rationale ?? 'Notifications keep you updated about your trips',
      showDialog: showDialog,
    );
  }

  /// Request QR scanner permissions
  static Future<bool> requestQRScannerPermissions() async {
    if (Platform.isAndroid) {
      return requestCameraPermission();
    } else if (Platform.isIOS) {
      return requestCameraPermission();
    }
    return false;
  }

  /// Request ticket download permissions
  static Future<bool> requestTicketDownloadPermissions() async {
    return requestStoragePermission(
      rationale: 'Storage permission is needed to download and save your tickets',
    );
  }

  /// Request image picker permission
  static Future<bool> requestImagePickerPermission() async {
    if (Platform.isAndroid) {
      // Try photos permission first (Android 13+)
      try {
        if (await ph.Permission.photos.isGranted) {
          return true;
        }
        final photosStatus = await ph.Permission.photos.request();
        if (photosStatus.isGranted) {
          return true;
        }
      } catch (e) {
        print('Photos permission not available: $e');
      }

      // Fallback to storage permission
      if (await ph.Permission.storage.isGranted) {
        return true;
      }
      final storageStatus = await ph.Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      return false;
    } else if (Platform.isIOS) {
      return requestPermission(
        ph.Permission.photos,
        rationale: 'Photos access is needed to select a profile picture',
      );
    }
    return false;
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  /// Show settings dialog for permanently denied permissions
  static Future<void> _showSettingsDialog(
      ph.Permission permission,
      String? rationale,
      ) async {
    final permissionName = _getPermissionName(permission);

    final shouldOpen = await Get.dialog<bool>(
      ConfirmationDialog(
        title: 'Permission Required',
        message: '$permissionName permission is permanently denied. '
            'Please enable it in app settings to continue.\n\n'
            '${rationale ?? ''}',
        confirmText: 'Open Settings',
        cancelText: 'Cancel',
      ),
    );

    if (shouldOpen == true) {
      await openAppSettings();
    }
  }

  /// Show rationale dialog for denied permissions
  static Future<bool> _showRationaleDialog(
      ph.Permission permission,
      String rationale,
      ) async {
    final permissionName = _getPermissionName(permission);

    final result = await Get.dialog<bool>(
      ConfirmationDialog(
        title: '$permissionName Access',
        message: rationale,
        confirmText: 'Allow',
        cancelText: 'Deny',
      ),
    );

    return result ?? false;
  }

  /// Get human-readable permission name
  static String _getPermissionName(ph.Permission permission) {
    switch (permission) {
      case ph.Permission.camera:
        return 'Camera';
      case ph.Permission.storage:
        return 'Storage';
      case ph.Permission.photos:
        return 'Photos';
      case ph.Permission.videos:
        return 'Videos';
      case ph.Permission.audio:
        return 'Audio';
      case ph.Permission.location:
      case ph.Permission.locationAlways:
      case ph.Permission.locationWhenInUse:
        return 'Location';
      case ph.Permission.notification:
        return 'Notification';
      default:
        return 'Permission';
    }
  }

  /// Check and request permission with status callback
  static Future<PermissionStatus> checkAndRequest(
      ph.Permission permission, {
        VoidCallback? onGranted,
        VoidCallback? onDenied,
        VoidCallback? onPermanentlyDenied,
      }) async {
    final status = await permission.status;

    if (status.isGranted) {
      onGranted?.call();
      return PermissionStatus.granted;
    }

    if (status.isPermanentlyDenied) {
      onPermanentlyDenied?.call();
      return PermissionStatus.permanentlyDenied;
    }

    final result = await permission.request();

    if (result.isGranted) {
      onGranted?.call();
      return PermissionStatus.granted;
    } else {
      onDenied?.call();
      return PermissionStatus.denied;
    }
  }

  /// Get permission status stream
  static Stream<ph.PermissionStatus> getPermissionStream(ph.Permission permission) {
    return permission.status.asStream();
  }

  /// Debug permissions
  static Future<void> debugPermissions() async {
    print('📱 Checking permissions status:');
    print('  - Camera: ${await ph.Permission.camera.status}');
    print('  - Photos: ${await ph.Permission.photos.status}');
    print('  - Storage: ${await ph.Permission.storage.status}');
    print('  - Location: ${await ph.Permission.location.status}');
    print('  - Notifications: ${await ph.Permission.notification.status}');

    // Biometric info
    final isSupported = await isDeviceSupported();
    final biometricAvailable = await checkBiometricSupport();
    final biometrics = await getAvailableBiometrics();
    print('  - Device Supported: $isSupported');
    print('  - Biometric Available: $biometricAvailable');
    print('  - Biometric Types: ${biometrics.map((b) => getBiometricTypeName(b)).toList()}');
  }

  /// Reset all permissions (useful for testing)
  static Future<void> resetAllPermissions() async {
    await ph.Permission.camera.request();
    await ph.Permission.storage.request();
    await ph.Permission.location.request();
    await ph.Permission.notification.request();
  }
}

/// Permission status enum
enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

/// Permission mixin for easy use in controllers and widgets
mixin PermissionMixin {
  Future<bool> ensureCameraPermission() {
    return PermissionHandler.requestCameraPermission();
  }

  Future<bool> ensureStoragePermission() {
    return PermissionHandler.requestStoragePermission();
  }

  Future<bool> ensureImagePickerPermission() {
    return PermissionHandler.requestImagePickerPermission();
  }

  Future<bool> ensureLocationPermission() {
    return PermissionHandler.requestLocationPermission();
  }

  Future<bool> ensureNotificationPermission() {
    return PermissionHandler.requestNotificationPermission();
  }

  Future<bool> ensureQRPermissions() {
    return PermissionHandler.requestQRScannerPermissions();
  }

  Future<bool> ensureBiometricSupport() {
    return PermissionHandler.checkBiometricSupport();
  }

  Future<bool> authenticateWithBiometrics({required String reason}) {
    return PermissionHandler.authenticateWithBiometrics(reason: reason);
  }

  Future<void> handlePermissionResult(
      bool granted, {
        required String permissionName,
        VoidCallback? onGranted,
        VoidCallback? onDenied,
      }) async {
    if (granted) {
      onGranted?.call();
    } else {
      onDenied?.call();
      Get.snackbar(
        'Permission Denied',
        '$permissionName permission is required for this feature',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}