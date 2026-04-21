// lib/core/services/socket/socket_service.dart

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/config/environment/env_config.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';
import 'package:menahariya/modules/passenger/controllers/trip_detail_controller.dart' as passenger;
import 'package:menahariya/modules/driver/controllers/trip_detail_controller.dart' as driver;
import 'package:menahariya/modules/passenger/controllers/seat_controller.dart' as passenger_seat;
import 'package:menahariya/modules/passenger/controllers/payment_controller.dart' as passenger_payment;

class SocketService extends GetxService {
  static SocketService get instance => Get.find();

  late IO.Socket _socket;
  final SecureStorage _storage = SecureStorage();

  // Connection status
  final _isConnected = false.obs;
  bool get isConnected => _isConnected.value;

  // Socket ID
  final _socketId = Rxn<String>();
  String? get socketId => _socketId.value;

  // Active trip IDs for reconnection
  final List<String> _activeTripIds = [];

  // Flag to track initialization
  bool _isInitialized = false;
  bool _isConnecting = false;

  @override
  void onInit() {
    super.onInit();
    // Initialize socket but don't connect automatically
    _initSocket();
  }

  Future<void> _initSocket() async {
    if (_isInitialized) return;

    try {
      final token = await _storage.read(AppConstants.prefKeyToken);

      // Use socketUrl from env config
      final socketUrl = EnvConfig.instance.socketUrl;
      print('🔌 Initializing Socket.IO client for: $socketUrl');

      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token ?? ''})
            .setQuery({'device': 'mobile'})
            .enableForceNew()
            .disableAutoConnect()
            .build(),
      );

      _setupListeners();
      _isInitialized = true;
      print('✅ Socket initialized');
    } catch (e) {
      print('❌ Socket initialization error: $e');
    }
  }

  void _setupListeners() {
    _socket.onConnect((_) {
      _isConnected.value = true;
      _isConnecting = false;
      _socketId.value = _socket.id;
      print('✅ Socket connected: ${_socket.id}');
    });

    _socket.onDisconnect((_) {
      _isConnected.value = false;
      _isConnecting = false;
      print('🔌 Socket disconnected');
    });

    _socket.onConnectError((data) {
      print('❌ Socket connection error: $data');
      _isConnected.value = false;
      _isConnecting = false;

      // If it's an authentication error, we don't need to retry
      if (data.toString().contains('Authentication error')) {
        print('⚠️ Authentication failed - user not logged in');
      }
    });

    _socket.onError((data) {
      print('❌ Socket error: $data');
      _isConnecting = false;
    });

    _socket.onReconnect((_) {
      print('🔄 Socket reconnected');
      _resubscribeToRooms();
    });

    // Custom event listeners
    _socket.on(ApiEndpoints.wsSeatUpdate, _handleSeatUpdate);
    _socket.on(ApiEndpoints.wsTripUpdate, _handleTripUpdate);
    _socket.on(ApiEndpoints.wsPaymentConfirm, _handlePaymentConfirm);
    _socket.on(ApiEndpoints.wsDriverLocation, _handleDriverLocation);
    _socket.on(ApiEndpoints.wsNotification, _handleNotification);
  }

  // Connect to socket - only if user is authenticated
  Future<void> connect() async {
    if (_isConnecting) return;

    final authController = Get.find<AuthController>();

    // Only connect if user is authenticated
    if (!authController.isAuthenticated) {
      print('⚠️ User not authenticated, skipping socket connection');
      return;
    }

    if (!_isInitialized) {
      await _initSocket();
    }

    if (!_socket.connected && !_isConnecting) {
      _isConnecting = true;
      print('🔌 Attempting to connect socket...');

      // Update token before connecting
      final token = await _storage.read(AppConstants.prefKeyToken);
      _socket.io.options?['auth'] = {'token': token};

      _socket.connect();
    }
  }

  // Disconnect socket
  void disconnect() {
    if (_isInitialized && _socket.connected) {
      _socket.disconnect();
    }
  }

  // Reconnect socket
  void reconnect() {
    if (_isInitialized && !_isConnecting) {
      _socket.connect();
    }
  }

  // Emit event
  void emit(String event, [dynamic data]) {
    if (_isInitialized && _socket.connected) {
      _socket.emit(event, data);
    }
  }

  // Listen to event
  void on(String event, Function(dynamic) callback) {
    if (_isInitialized) {
      _socket.on(event, callback);
    } else {
      print('⚠️ Socket not initialized, cannot listen to $event');
    }
  }

  // Remove listener
  void off(String event, [Function? callback]) {
    if (_isInitialized) {
      if (callback != null) {
        _socket.off(event, (data) => callback(data));
      } else {
        _socket.off(event);
      }
    }
  }

  // Join room
  void joinRoom(String room) {
    if (_isInitialized && _socket.connected) {
      emit('join_room', {'room': room});
      print('📦 Joined room: $room');
    }
  }

  // Leave room
  void leaveRoom(String room) {
    if (_isInitialized && _socket.connected) {
      emit('leave_room', {'room': room});
      print('📦 Left room: $room');
    }
  }

  // Join user-specific room
  void joinUserRoom(String userId) {
    final room = 'user:$userId';
    joinRoom(room);
  }

  // Join trip-specific room
  void joinTripRoom(String tripId) {
    final room = 'trip:$tripId';
    joinRoom(room);

    if (!_activeTripIds.contains(tripId)) {
      _activeTripIds.add(tripId);
    }
  }

  // Leave trip-specific room
  void leaveTripRoom(String tripId) {
    final room = 'trip:$tripId';
    leaveRoom(room);
    _activeTripIds.remove(tripId);
  }

  // Join driver room
  void joinDriverRoom(String driverId) {
    joinRoom('driver:$driverId');
  }

  // Send seat lock
  void lockSeat(String tripId, int seatNumber, int durationMinutes) {
    emit('lock_seat', {
      'tripId': tripId,
      'seatNumber': seatNumber,
      'duration': durationMinutes,
    });
  }

  // Send seat release
  void releaseSeat(String tripId, int seatNumber) {
    emit('release_seat', {
      'tripId': tripId,
      'seatNumber': seatNumber,
    });
  }

  // Update driver location
  void updateDriverLocation(String tripId, double lat, double lng) {
    emit('driver_location', {
      'tripId': tripId,
      'lat': lat,
      'lng': lng,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Send trip status update
  void sendTripStatusUpdate(String tripId, String status) {
    emit('trip_status', {
      'tripId': tripId,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Event handlers
  void _handleSeatUpdate(dynamic data) {
    print('🪑 Seat update received: $data');
    if (Get.isRegistered<passenger_seat.SeatController>()) {
      Get.find<passenger_seat.SeatController>().handleSeatUpdate(data);
    }
  }

  void _handleTripUpdate(dynamic data) {
    print('🚌 Trip update received: $data');
    final authController = Get.find<AuthController>();

    if (authController.isPassenger && Get.isRegistered<passenger.PassengerTripDetailController>()) {
      Get.find<passenger.PassengerTripDetailController>().handleTripUpdate(data);
    } else if (authController.isDriver && Get.isRegistered<driver.DriverTripDetailController>()) {
      Get.find<driver.DriverTripDetailController>().handleTripUpdate(data);
    }
  }

  void _handlePaymentConfirm(dynamic data) {
    print('💰 Payment confirmation received: $data');
    if (Get.isRegistered<passenger_payment.PassengerPaymentController>()) {
      Get.find<passenger_payment.PassengerPaymentController>().handlePaymentConfirmed(data);
    }
  }

  void _handleDriverLocation(dynamic data) {
    print('📍 Driver location received: $data');
    if (Get.isRegistered<passenger.PassengerTripDetailController>()) {
      Get.find<passenger.PassengerTripDetailController>().updateDriverLocation(data);
    }
  }

  void _handleNotification(dynamic data) {
    print('🔔 Notification received: $data');
  }

  // Notification listener
  void onNotification(Function(dynamic) callback) {
    if (_isInitialized) {
      on('notification', callback);
    } else {
      print('⚠️ Socket not initialized, notification listener queued');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isInitialized) {
          on('notification', callback);
        }
      });
    }
  }

  // Resubscribe to rooms after reconnection
  void _resubscribeToRooms() {
    final authController = Get.find<AuthController>();
    final userId = authController.userId;

    if (userId.isNotEmpty) {
      joinUserRoom(userId);
      print('🔄 Resubscribed to user room: $userId');
    }

    for (final tripId in _activeTripIds) {
      joinTripRoom(tripId);
      print('🔄 Resubscribed to trip room: $tripId');
    }
  }

  // Add active trip
  void addActiveTrip(String tripId) {
    if (!_activeTripIds.contains(tripId)) {
      _activeTripIds.add(tripId);
    }
  }

  // Remove active trip
  void removeActiveTrip(String tripId) {
    _activeTripIds.remove(tripId);
  }

  // Clear all active trips
  void clearActiveTrips() {
    _activeTripIds.clear();
  }

  @override
  void onClose() {
    if (_isInitialized) {
      disconnect();
      _socket.dispose();
    }
    super.onClose();
  }

  // Check socket health
  bool isSocketHealthy() {
    return _isInitialized && _socket.connected;
  }

  // Get socket ID
  Future<String?> getSocketId() async {
    if (_isInitialized) {
      return _socket.id;
    }
    return null;
  }
}