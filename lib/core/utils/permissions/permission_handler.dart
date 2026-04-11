// lib/core/utils/permissions/permission_handler.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:menahariya/core/constants/app_strings.dart';
import 'package:menahariya/core/widgets/dialogs/confirmation_dialog.dart';

class PermissionHandler {
  // Private constructor
  PermissionHandler._();

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

  // Check if permission is granted
  static Future<bool> isGranted(ph.Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  // Check if multiple permissions are granted
  static Future<bool> areGranted(List<ph.Permission> permissions) async {
    for (final permission in permissions) {
      if (!await isGranted(permission)) {
        return false;
      }
    }
    return true;
  }

  // Request single permission
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

  // Request multiple permissions
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

  // Request camera permission
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

  // Request storage permission - UPDATED for Android 13+
  static Future<bool> requestStoragePermission({
    String? rationale,
    bool showDialog = true,
  }) async {
    if (Platform.isAndroid) {
      // Check Android version
      if (await _isAndroidVersionOrAbove(33)) {
        // Android 13+ (API 33+) - Use photos permission
        if (await ph.Permission.photos.isGranted) {
          return true;
        }

        return requestPermission(
          ph.Permission.photos,
          rationale: rationale ?? 'Photos access is needed to select images for your profile',
          showDialog: showDialog,
        );
      } else {
        // Android 12 and below - Use storage permission
        if (await ph.Permission.storage.isGranted) {
          return true;
        }

        return requestPermission(
          ph.Permission.storage,
          rationale: rationale ?? 'Storage access is needed to select images for your profile',
          showDialog: showDialog,
        );
      }
    } else if (Platform.isIOS) {
      // iOS uses photo library permission
      return requestPermission(
        ph.Permission.photos,
        rationale: rationale ?? 'Photo access is needed to select images for your profile',
        showDialog: showDialog,
      );
    }
    return false;
  }

  // Helper to check Android version
  static Future<bool> _isAndroidVersionOrAbove(int version) async {
    // You can use DeviceInfoPlugin for more accurate version checking
    // For now, we'll check which permissions are available
    try {
      final sdkInt = await ph.Permission.storage.status;
      // If storage is available, it's likely Android 12 or below
      return false; // Placeholder - you should implement proper version checking
    } catch (e) {
      return true;
    }
  }

  // Request location permission
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

  // Request notification permission
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

  // Request QR scanner permissions (camera + storage)
  static Future<bool> requestQRScannerPermissions() async {
    if (Platform.isAndroid) {
      final cameraGranted = await requestCameraPermission();
      if (!cameraGranted) return false;

      // On newer Android versions, storage permission might not be needed for QR scanning
      return true;
    } else if (Platform.isIOS) {
      return requestCameraPermission();
    }
    return false;
  }

  // Request ticket download permissions
  static Future<bool> requestTicketDownloadPermissions() async {
    return requestStoragePermission(
      rationale: 'Storage permission is needed to download and save your tickets',
    );
  }

  static Future<bool> requestImagePickerPermission() async {
    if (Platform.isAndroid) {
      // First try photos permission (Android 13+)
      if (await ph.Permission.photos.isGranted) {
        return true;
      }

      // Try to request photos
      final photosStatus = await ph.Permission.photos.request();
      if (photosStatus.isGranted) {
        return true;
      }

      // Fallback to storage (Android 12 and below)
      if (await ph.Permission.storage.isGranted) {
        return true;
      }

      final storageStatus = await ph.Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      // Last resort - try mediaLibrary
      if (await ph.Permission.mediaLibrary.isGranted) {
        return true;
      }

      final mediaStatus = await ph.Permission.mediaLibrary.request();
      return mediaStatus.isGranted;
    } else if (Platform.isIOS) {
      return requestPermission(
        ph.Permission.photos,
        rationale: 'Photos access is needed to select a profile picture',
      );
    }
    return false;
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  // Show settings dialog
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

  // Show rationale dialog
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

  // Get human-readable permission name
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

  // Check and request permission with status callback
  static Future<PermissionStatus> checkAndRequest(
      ph.Permission permission, {
        Function? onGranted,
        Function? onDenied,
        Function? onPermanentlyDenied,
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

  // Get permission status stream
  static Stream<ph.PermissionStatus> getPermissionStream(ph.Permission permission) {
    return permission.status.asStream();
  }

  static Future<void> debugPermissions() async {
    print('📱 Checking permissions status:');
    print('  - Camera: ${await ph.Permission.camera.status}');
    print('  - Photos: ${await ph.Permission.photos.status}');
    print('  - Storage: ${await ph.Permission.storage.status}');
    print('  - READ_MEDIA_IMAGES: ${await ph.Permission.mediaLibrary.status}');
  }
  // Reset all permissions (useful for testing)
  static Future<void> resetAllPermissions() async {
    await ph.Permission.camera.request();
    await ph.Permission.storage.request();
    await ph.Permission.location.request();
    await ph.Permission.notification.request();
  }
}

// Permission status enum
enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

// Usage example mixin
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