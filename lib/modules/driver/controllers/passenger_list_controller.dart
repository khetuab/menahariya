// lib/modules/driver/controllers/passenger_list_controller.dart

import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/passenger/passenger_model.dart';

import '../../../core/utils/app_snackbar.dart';

class PassengerListController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;

  final _tripId = ''.obs;
  String get tripId => _tripId.value;

  final _isLoading = false.obs;
  final _passengers = <PassengerModel>[].obs;
  final _filteredPassengers = <PassengerModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedFilter = PassengerFilter.all.obs;
  final _selectedPassenger = Rxn<PassengerModel>();

  bool get isLoading => _isLoading.value;
  List<PassengerModel> get passengers => _filteredPassengers;
  String get searchQuery => _searchQuery.value;
  PassengerFilter get selectedFilter => _selectedFilter.value;
  PassengerModel? get selectedPassenger => _selectedPassenger.value;

  int get totalCount => _passengers.length;
  int get checkedInCount => _passengers.where((p) => p.checkedIn).length;
  int get pendingCount => _passengers.where((p) => !p.checkedIn).length;

  @override
  void onInit() {
    super.onInit();
    // Do not auto-load; wait for setTripId()
  }

  void setTripId(String id) {
    if (_tripId.value == id) return;
    _tripId.value = id;
    loadPassengerList();
  }

  Future<void> loadPassengerList() async {
    if (_tripId.value.isEmpty) {
      print('⚠️ Cannot load passenger list: tripId is empty');
      return;
    }

    try {
      _isLoading.value = true;
      print('👥 Loading passenger list for trip: ${_tripId.value}');

      final response = await _apiClient.get('/driver/boarding-list/${_tripId.value}');

      if (response != null && response['data'] != null) {
        final List<dynamic> passengers = response['data'];
        _passengers.value = passengers
            .map((p) => PassengerModel.fromJson(p as Map<String, dynamic>))
            .toList();
        print('✅ Loaded ${_passengers.length} passengers');
        _applyFilters();
      } else {
        _passengers.value = [];
      }
    } catch (e) {
      print('❌ Error loading passenger list: $e');
      _passengers.value = [];
    } finally {
      _isLoading.value = false;
    }
  }

  void _applyFilters() {
    var filtered = List<PassengerModel>.from(_passengers);

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

    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.ticketNumber.toLowerCase().contains(query) ||
            (p.phone?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    _filteredPassengers.value = filtered;
    print('👥 Filtered passengers: ${_filteredPassengers.length}');
  }

  void setFilter(PassengerFilter filter) {
    _selectedFilter.value = filter;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }
// lib/modules/driver/controllers/passenger_list_controller.dart

  Future<void> markPassengerCheckedIn(String passengerId) async {
    try {
      await _apiClient.post(
        '/driver/mark-checked-in',
        data: {
          'tripId': _tripId.value,
          'passengerId': passengerId,
        },
      );

      // Update local state
      final index = _passengers.indexWhere((p) => p.id == passengerId);
      if (index != -1) {
        _passengers[index] = _passengers[index].copyWith(checkedIn: true);
        _passengers.refresh();
        _applyFilters();
      }

      AppSnackbar.show('Success', 'Passenger checked in successfully');
    } catch (e) {
      print('Error marking passenger checked in: $e');
      AppSnackbar.show('Error', 'Failed to check in passenger');
    }
  }
  Future<void> selectPassenger(String passengerId) async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.get('/driver/passenger/$passengerId');
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
    await loadPassengerList();
  }

  @override
  void onClose() {
    super.onClose();
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