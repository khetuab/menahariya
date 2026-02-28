// lib/core/services/connectivity/connectivity_service.dart

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_strings.dart';

class ConnectivityService extends GetxService {
  static ConnectivityService get instance => Get.find();

  final Connectivity _connectivity = Connectivity();

  // Observable connection status
  final RxBool _isConnected = true.obs;

  // Expose the RxBool if you need reactive listeners
  RxBool get isConnectedRx => _isConnected;

  // Convenience getter for non-reactive access
  bool get isConnected => _isConnected.value;


  // Connection type
  final _connectionType = Rx<ConnectionType>(ConnectionType.none);
  ConnectionType get connectionType => _connectionType.value;

  // Stream subscription
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _subscribeToConnectivityChanges();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _isConnected.value = false;
    }
  }

  void _subscribeToConnectivityChanges() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _setDisconnected();
      return;
    }

    final result = results.first;

    switch (result) {
      case ConnectivityResult.wifi:
        _isConnected.value = true;
        _connectionType.value = ConnectionType.wifi;
        break;
      case ConnectivityResult.mobile:
        _isConnected.value = true;
        _connectionType.value = ConnectionType.mobile;
        break;
      case ConnectivityResult.ethernet:
        _isConnected.value = true;
        _connectionType.value = ConnectionType.ethernet;
        break;
      case ConnectivityResult.none:
        _setDisconnected();
        break;
      default:
        _isConnected.value = true;
        _connectionType.value = ConnectionType.other;
        break;
    }
  }

  void _setDisconnected() {
    _isConnected.value = false;
    _connectionType.value = ConnectionType.none;
    _showNoInternetSnackbar();
  }

  void _showNoInternetSnackbar() {
    if (!Get.isSnackbarOpen) {
      Get.rawSnackbar(
        message: AppStrings.errorNoInternet,
        isDismissible: false,
        duration: const Duration(days: 0),
        backgroundColor: Get.theme.colorScheme.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.zero,
        borderRadius: 0,
      );
    }
  }

  // Check internet with actual request
  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        return false;
      }

      // Additional check with DNS lookup
      final list = await InternetAddress.lookup('google.com');
      return list.isNotEmpty && list[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get connection quality
  ConnectionQuality getConnectionQuality() {
    if (!isConnected) return ConnectionQuality.none;

    switch (_connectionType.value) {
      case ConnectionType.wifi:
      case ConnectionType.ethernet:
        return ConnectionQuality.good;
      case ConnectionType.mobile:
      // Could add more sophisticated check based on network type
        return ConnectionQuality.fair;
      default:
        return ConnectionQuality.unknown;
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}

enum ConnectionType {
  none,
  mobile,
  wifi,
  ethernet,
  other,
}

enum ConnectionQuality {
  none,
  poor,
  fair,
  good,
  excellent,
  unknown,
}