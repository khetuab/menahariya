// lib/modules/driver/controllers/passenger_list_controller.dart

import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/passenger/passenger_model.dart';

class PassengerListController extends GetxController {
  static PassengerListController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Current trip ID
  late final String tripId;

  // Observables
  final _isLoading = false.obs;
  final _passengers = <PassengerModel>[].obs;
  final _filteredPassengers = <PassengerModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedFilter = PassengerFilter.all.obs;
  final _selectedPassenger = Rxn<PassengerModel>();

  // Getters
  bool get isLoading => _isLoading.value;
  List<PassengerModel> get passengers => _filteredPassengers;
  String get searchQuery => _searchQuery.value;
  PassengerFilter get selectedFilter => _selectedFilter.value;
  PassengerModel? get selectedPassenger => _selectedPassenger.value;

  // Statistics
  int get totalCount => _passengers.length;
  int get checkedInCount => _passengers.where((p) => p.checkedIn).length;
  int get pendingCount => _passengers.where((p) => !p.checkedIn).length;

  @override
  void onInit() {
    super.onInit();
    _getTripId();
    loadPassengerList();
  }

  void _getTripId() {
    final args = Get.arguments;
    if (args != null && args['tripId'] != null) {
      tripId = args['tripId'];
    }
  }

  Future<void> loadPassengerList() async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '/driver/passenger-list/$tripId',
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> passengers = response['data'];
        _passengers.value = passengers
            .map((p) => PassengerModel.fromJson(p))
            .toList();

        _applyFilters();
      }
    } catch (e) {
      print('Error loading passenger list: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _applyFilters() {
    var filtered = List<PassengerModel>.from(_passengers);

    // Apply status filter
    switch (_selectedFilter.value) {
      case PassengerFilter.all:
        break;
      case PassengerFilter.checkedIn:
        filtered = filtered.where((p) => p.checkedIn).toList();
        break;
      case PassengerFilter.pending:
        filtered = filtered.where((p) => !p.checkedIn).toList();
        break;
      case PassengerFilter.withCargo:
        filtered = filtered.where((p) => p.hasCargo).toList();
        break;
    }

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.ticketNumber.toLowerCase().contains(query) ||
            (p.phone?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    _filteredPassengers.value = filtered;
  }

  void setFilter(PassengerFilter filter) {
    _selectedFilter.value = filter;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  Future<void> selectPassenger(String passengerId) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '/driver/passenger/$passengerId',
      );

      if (response != null && response['data'] != null) {
        _selectedPassenger.value = PassengerModel.fromJson(response['data']);
      }
    } catch (e) {
      print('Error loading passenger details: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void clearSelection() {
    _selectedPassenger.value = null;
  }

  Future<void> refreshList() async {
    loadPassengerList();
  }

  List<PassengerModel> getPassengersBySeatRange(int start, int end) {
    return _passengers
        .where((p) {
      final seatNum = int.tryParse(p.seatNumber.replaceAll(RegExp(r'[^0-9]'), ''));
      return seatNum != null && seatNum >= start && seatNum <= end;
    })
        .toList();
  }

  Map<String, int> getSeatOccupancyStats() {
    return {
      'total': totalCount,
      'occupied': checkedInCount,
      'available': 50 - totalCount, // Assuming 50 seats per bus
    };
  }
}

enum PassengerFilter {
  all,
  checkedIn,
  pending,
  withCargo,
}

extension PassengerFilterExtension on PassengerFilter {
  String get displayName {
    switch (this) {
      case PassengerFilter.all:
        return 'All Passengers';
      case PassengerFilter.checkedIn:
        return 'Checked In';
      case PassengerFilter.pending:
        return 'Pending';
      case PassengerFilter.withCargo:
        return 'With Cargo';
    }
  }
}