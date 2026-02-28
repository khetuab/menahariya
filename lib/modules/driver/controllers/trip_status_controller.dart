// lib/modules/driver/controllers/trip_status_controller.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';

class TripStatusController extends GetxController {
  static TripStatusController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;

  // Current trip ID
  late final String tripId;

  // Observables
  final _isLoading = false.obs;
  final _currentStatus = ''.obs;
  final _availableStatuses = <String>[].obs;
  final _statusHistory = <StatusUpdate>[].obs;
  final _delayMinutes = 0.obs;
  final _delayReason = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get currentStatus => _currentStatus.value;
  List<String> get availableStatuses => _availableStatuses;
  List<StatusUpdate> get statusHistory => _statusHistory;
  int get delayMinutes => _delayMinutes.value;
  String get delayReason => _delayReason.value;

  // Status flow definitions
  final Map<String, List<String>> statusFlow = {
    'scheduled': ['departed', 'delayed', 'cancelled'],
    'delayed': ['departed', 'cancelled'],
    'departed': ['in_transit', 'cancelled'],
    'in_transit': ['completed', 'breakdown', 'cancelled'],
    'breakdown': ['in_transit', 'cancelled'],
    'completed': [],
    'cancelled': [],
  };

  @override
  void onInit() {
    super.onInit();
    _getTripId();
    loadTripStatus();
  }

  void _getTripId() {
    final args = Get.arguments;
    if (args != null && args['tripId'] != null) {
      tripId = args['tripId'];
    }
  }

  Future<void> loadTripStatus() async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '${ApiEndpoints.trips}/$tripId/status',
      );

      if (response != null && response['data'] != null) {
        _currentStatus.value = response['data']['currentStatus'];

        final List<dynamic> history = response['data']['history'] ?? [];
        _statusHistory.value = history
            .map((h) => StatusUpdate.fromJson(h))
            .toList();

        _updateAvailableStatuses();
      }
    } catch (e) {
      print('Error loading trip status: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _updateAvailableStatuses() {
    _availableStatuses.value = statusFlow[_currentStatus.value] ?? [];
  }

  Future<bool> updateStatus(String newStatus, {String? reason}) async {
    if (!_availableStatuses.contains(newStatus)) {
      Get.snackbar(
        'Invalid Status',
        'Cannot change from $_currentStatus to $newStatus',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        '${ApiEndpoints.trips}/$tripId/status',
        data: {
          'status': newStatus,
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response != null && response['success'] == true) {
        final oldStatus = _currentStatus.value;
        _currentStatus.value = newStatus;

        // Add to history
        _statusHistory.add(StatusUpdate(
          fromStatus: oldStatus,
          toStatus: newStatus,
          reason: reason,
          timestamp: DateTime.now(),
        ));

        _updateAvailableStatuses();

        // Emit socket event
        _socketService.sendTripStatusUpdate(tripId, newStatus);

        Get.snackbar(
          'Status Updated',
          'Trip status changed to $newStatus',
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      }
      return false;
    } catch (e) {
      print('Error updating status: $e');
      Get.snackbar(
        'Error',
        'Failed to update trip status',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> reportDelay(int minutes, String reason) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        '${ApiEndpoints.trips}/$tripId/delay',
        data: {
          'delayMinutes': minutes,
          'reason': reason,
        },
      );

      if (response != null && response['success'] == true) {
        _delayMinutes.value = minutes;
        _delayReason.value = reason;

        await updateStatus('delayed', reason: reason);

        Get.snackbar(
          'Delay Reported',
          'Trip delayed by $minutes minutes',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error reporting delay: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  bool canUpdateTo(String status) {
    return _availableStatuses.contains(status);
  }

  String getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return 'blue';
      case 'delayed':
        return 'orange';
      case 'departed':
      case 'in_transit':
        return 'green';
      case 'completed':
        return 'teal';
      case 'cancelled':
        return 'red';
      case 'breakdown':
        return 'purple';
      default:
        return 'grey';
    }
  }

  Duration getTimeInCurrentStatus() {
    if (_statusHistory.isEmpty) return Duration.zero;

    final lastUpdate = _statusHistory.last.timestamp;
    return DateTime.now().difference(lastUpdate);
  }

  void refreshStatus() {
    loadTripStatus();
  }
}

class StatusUpdate {
  final String fromStatus;
  final String toStatus;
  final String? reason;
  final DateTime timestamp;

  StatusUpdate({
    required this.fromStatus,
    required this.toStatus,
    this.reason,
    required this.timestamp,
  });

  factory StatusUpdate.fromJson(Map<String, dynamic> json) {
    return StatusUpdate(
      fromStatus: json['fromStatus'],
      toStatus: json['toStatus'],
      reason: json['reason'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromStatus': fromStatus,
      'toStatus': toStatus,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}