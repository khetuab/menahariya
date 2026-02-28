// lib/modules/driver/controllers/boarding_controller.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';

import '../../../data/models/passenger/passenger_model.dart';

class BoardingController extends GetxController {
  static BoardingController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;

  // Current trip ID
  late final String tripId;

  // Observables
  final _isLoading = false.obs;
  final _isScanning = false.obs;
  final _currentPassenger = Rxn<PassengerModel>();
  final _boardingList = <PassengerModel>[].obs;
  final _checkedInPassengers = <PassengerModel>[].obs;
  final _pendingPassengers = <PassengerModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedBoardingMethod = BoardingMethod.scan.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isScanning => _isScanning.value;
  PassengerModel? get currentPassenger => _currentPassenger.value;
  List<PassengerModel> get boardingList => _boardingList;
  List<PassengerModel> get checkedInPassengers => _checkedInPassengers;
  List<PassengerModel> get pendingPassengers => _pendingPassengers;
  String get searchQuery => _searchQuery.value;
  BoardingMethod get selectedMethod => _selectedBoardingMethod.value;

  // Statistics
  int get totalPassengers => _boardingList.length;
  int get checkedInCount => _checkedInPassengers.length;
  int get pendingCount => _pendingPassengers.length;
  double get boardingProgress => totalPassengers > 0
      ? checkedInCount / totalPassengers
      : 0;

  @override
  void onInit() {
    super.onInit();
    _getTripId();
    loadBoardingList();
    _setupSocketListeners();
  }

  void _getTripId() {
    final args = Get.arguments;
    if (args != null && args['tripId'] != null) {
      tripId = args['tripId'];
    }
  }

  void _setupSocketListeners() {
    _socketService.on('passenger_checked_in', _handlePassengerCheckIn);
  }

  Future<void> loadBoardingList() async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '/driver/boarding-list/$tripId',
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> passengers = response['data'];
        _boardingList.value = passengers
            .map((p) => PassengerModel.fromJson(p))
            .toList();

        _categorizePassengers();
      }
    } catch (e) {
      print('Error loading boarding list: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _categorizePassengers() {
    _checkedInPassengers.value = _boardingList.where((p) => p.checkedIn).toList();
    _pendingPassengers.value = _boardingList.where((p) => !p.checkedIn).toList();
  }

  void _handlePassengerCheckIn(dynamic data) {
    if (data['tripId'] == tripId) {
      final passengerId = data['passengerId'];
      final index = _boardingList.indexWhere((p) => p.id == passengerId);

      if (index != -1) {
        _boardingList[index] = _boardingList[index].copyWith(checkedIn: true);
        _boardingList.refresh();
        _categorizePassengers();
      }
    }
  }

  Future<bool> validateTicket(String ticketCode) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.ticketsValidate,
        data: {
          'tripId': tripId,
          'ticketCode': ticketCode,
        },
      );

      if (response != null && response['data'] != null) {
        final passenger = PassengerModel.fromJson(response['data']['passenger']);
        _currentPassenger.value = passenger;

        // Mark as checked in
        await markPassengerCheckedIn(passenger.id);

        return true;
      }
      return false;
    } catch (e) {
      print('Error validating ticket: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> markPassengerCheckedIn(String passengerId) async {
    try {
      await _apiClient.post(
        '/driver/mark-checked-in',
        data: {
          'tripId': tripId,
          'passengerId': passengerId,
        },
      );

      // Update local state
      final index = _boardingList.indexWhere((p) => p.id == passengerId);
      if (index != -1) {
        _boardingList[index] = _boardingList[index].copyWith(checkedIn: true);
        _boardingList.refresh();
        _categorizePassengers();
      }

      // Emit socket event
      _socketService.emit('passenger_checked_in', {
        'tripId': tripId,
        'passengerId': passengerId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error marking passenger checked in: $e');
      return false;
    }
  }

  Future<void> searchPassenger(String query) async {
    _searchQuery.value = query;

    if (query.isEmpty) {
      _categorizePassengers();
      return;
    }

    final lowerQuery = query.toLowerCase();
    _pendingPassengers.value = _boardingList
        .where((p) => !p.checkedIn && (
        p.name.toLowerCase().contains(lowerQuery) ||
            p.ticketNumber.toLowerCase().contains(lowerQuery)
    ))
        .toList();
  }

  void setBoardingMethod(BoardingMethod method) {
    _selectedBoardingMethod.value = method;
  }

  void setScanning(bool scanning) {
    _isScanning.value = scanning;
  }

  void clearCurrentPassenger() {
    _currentPassenger.value = null;
  }

  void refreshBoardingStatus() {
    loadBoardingList();
  }

  @override
  void onClose() {
    _socketService.off('passenger_checked_in', _handlePassengerCheckIn);
    super.onClose();
  }
}

enum BoardingMethod {
  scan,
  manual,
  list,
}