// lib/modules/driver/controllers/driver_state_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/utils/app_snackbar.dart';

class DriverStateController extends GetxController {
  static DriverStateController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Make these observable (they are already Rx)
  final _isOnline = false.obs;
  final _isLoading = false.obs;
  final _autoAcceptTrips = false.obs;
  final _maxTripDistance = 100.obs;

  // Getters - return the Rx values for reactivity
  Rx<bool> get isOnline => _isOnline;
  Rx<bool> get isLoading => _isLoading;
  Rx<bool> get autoAcceptTrips => _autoAcceptTrips;
  Rx<int> get maxTripDistance => _maxTripDistance;

  // Also provide value getters for convenience
  bool get isOnlineValue => _isOnline.value;
  bool get isLoadingValue => _isLoading.value;
  bool get autoAcceptTripsValue => _autoAcceptTrips.value;
  int get maxTripDistanceValue => _maxTripDistance.value;

  @override
  void onInit() {
    super.onInit();
    _loadDriverStatus();
  }

  Future<void> _loadDriverStatus() async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.get('/driver/availability-settings');

      if (response != null && response['data'] != null) {
        _isOnline.value = response['data']['isOnline'] ?? false;
        _autoAcceptTrips.value = response['data']['autoAcceptTrips'] ?? false;
        _maxTripDistance.value = response['data']['maxTripDistance'] ?? 100;
      }
    } catch (e) {
      print('Error loading driver status: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateDriverStatus(bool online) async {
    try {
      await _apiClient.post(
        '/driver/update-status',
        data: {'status': online ? 'online' : 'offline'},
      );
      _isOnline.value = online;

      AppSnackbar.show(
        online ? 'Online' : 'Offline',
        online ? 'You are now online and available for trips' : 'You are now offline',
      );
    } catch (e) {
      print('Error updating driver status: $e');
      AppSnackbar.show('Error', 'Failed to update status');
    }
  }

  Future<void> refreshStatus() async {
    await _loadDriverStatus();
  }
}