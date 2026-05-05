// lib/modules/passenger/controllers/history_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';
import 'package:menahariya/data/models/cargo/cargo_model.dart';
import 'package:menahariya/data/models/payment/payment_model.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';

class PassengerHistoryController extends GetxController {
  static PassengerHistoryController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Observables
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _currentTab = HistoryTab.tickets.obs;
  late var deliveredCount = 0.obs;
  // Tickets history
  final _tickets = <TicketModel>[].obs;
  final filteredTickets = <TicketModel>[].obs;
  final _ticketsCurrentPage = 1.obs;
  final _ticketsHasMore = true.obs;

  // Cargo history
  final _cargoList = <CargoModel>[].obs;
  final filteredCargo = <CargoModel>[].obs;
  final _cargoCurrentPage = 1.obs;
  final _cargoHasMore = true.obs;

  // Payments history
  final _payments = <PaymentModel>[].obs;
  final _filteredPayments = <PaymentModel>[].obs;
  final _paymentsCurrentPage = 1.obs;
  final _paymentsHasMore = true.obs;

  // Filters
  final _dateRange = Rxn<DateTimeRange>();
  final _searchQuery = ''.obs;
  final _statusFilter = ''.obs;
  final _sortOrder = SortOrder.descending.obs;

  // Statistics
  final _totalSpent = 0.0.obs;
  final _totalTrips = 0.obs;
  final _totalCargo = 0.obs;
  final _totalRefunds = 0.0.obs;
  final _mostFrequentRoute = Rxn<String>();
  final _averageSpending = 0.0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  HistoryTab get currentTab => _currentTab.value;

  // Lists getters
  List<TicketModel> get tickets => filteredTickets;
  List<CargoModel> get cargoList => filteredCargo;
  List<PaymentModel> get payments => _filteredPayments;

  // Pagination getters
  bool get ticketsHasMore => _ticketsHasMore.value;
  bool get cargoHasMore => _cargoHasMore.value;
  bool get paymentsHasMore => _paymentsHasMore.value;

  // Filter getters
  DateTimeRange? get dateRange => _dateRange.value;
  String get searchQuery => _searchQuery.value;
  String get statusFilter => _statusFilter.value;
  SortOrder get sortOrder => _sortOrder.value;

  // Statistics getters
  double get totalSpent => _totalSpent.value;
  int get totalTrips => _totalTrips.value;
  int get totalCargo => _totalCargo.value;
  double get totalRefunds => _totalRefunds.value;
  String? get mostFrequentRoute => _mostFrequentRoute.value;
  double get averageSpending => _averageSpending.value;

  // Status filter options
  final List<String> ticketStatuses = ['all', 'active', 'completed', 'cancelled', 'refunded'];
  final List<String> cargoStatuses = ['all', 'in_transit', 'delivered', 'cancelled'];
  final List<String> paymentStatuses = ['all', 'completed', 'pending', 'failed', 'refunded'];

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    loadTickets();
    loadCargoHistory();
    loadPayments();
    _calculateStatistics();
  }

  // Add this method to PassengerHistoryController class

  void resetStatusFilter() {
    _statusFilter.value = '';
    print('🔄 Status filter reset to: ${_statusFilter.value}');
  }

// Also update the loadTickets method to ensure it doesn't use a stale status filter:
  Future<void> loadTickets({bool refresh = false}) async {
    if (refresh) {
      _ticketsCurrentPage.value = 1;
      _ticketsHasMore.value = true;
      _tickets.clear();
    }

    if (!_ticketsHasMore.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      // Don't send status filter unless it's specifically set
      final Map<String, dynamic> queryParams = {
        'page': _ticketsCurrentPage.value,
        'limit': 100,
      };

      // Only add status filter if it's not empty
      if (_statusFilter.value.isNotEmpty && _statusFilter.value != 'all') {
        queryParams['status'] = _statusFilter.value;
      }

      final response = await _apiClient.get(
        ApiEndpoints.ticketsMyTickets,
        queryParameters: queryParams,
      );

      print('📊 Tickets API Response: $response');

      if (response != null && response['data'] != null) {
        List<TicketModel> newTickets = [];

        if (response['data'] is List) {
          newTickets = (response['data'] as List)
              .map((t) => TicketModel.fromJson(t))
              .toList();
        }

        print('✅ Loaded ${newTickets.length} tickets');

        if (refresh) {
          _tickets.value = newTickets;
        } else {
          _tickets.addAll(newTickets);
        }

        _applyTicketFilters();
        _ticketsHasMore.value = newTickets.length >= 100;
        _ticketsCurrentPage.value++;

        _calculateStatistics();
      }
    } catch (e) {
      print('❌ Error loading tickets: $e');
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  // In history_controller.dart, add a method to reset filters for tickets view:

  void resetToTicketsView() {
    // Reset status filter to empty (show all)
    _statusFilter.value = '';
    // Reset other filters
    _dateRange.value = null;
    _searchQuery.value = '';
    _sortOrder.value = SortOrder.descending;
    // Reload tickets
    loadTickets(refresh: true);
  }
// Update _applyTicketFilters to work with empty filters
  void _applyTicketFilters() {
    var filtered = List<TicketModel>.from(_tickets);

    print('🔍 Applying filters to ${_tickets.length} tickets');
    print('🔍 Status filter: ${_statusFilter.value}');
    print('🔍 Search query: ${_searchQuery.value}');

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.origin.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
            t.destination.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
            t.id.toLowerCase().contains(_searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_statusFilter.value.isNotEmpty && _statusFilter.value != 'all') {
      filtered = filtered.where((t) {
        return t.status.toLowerCase() == _statusFilter.value.toLowerCase();
      }).toList();
    }

    // Apply date range
    if (_dateRange.value != null) {
      filtered = filtered.where((t) {
        return t.departureTime.isAfter(_dateRange.value!.start) &&
            t.departureTime.isBefore(_dateRange.value!.end);
      }).toList();
    }

    // Apply sorting
    if (_sortOrder.value == SortOrder.ascending) {
      filtered.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    } else {
      filtered.sort((a, b) => b.departureTime.compareTo(a.departureTime));
    }

    filteredTickets.value = filtered;
    print('✅ After filter: ${filteredTickets.length} tickets');
  }

  // Add this to PassengerHistoryController class
  final _cargoStatusFilter = ''.obs;
  String get cargoStatusFilter => _cargoStatusFilter.value;

  void setCargoStatusFilter(String status) {
    _cargoStatusFilter.value = status;
    _applyCargoFilters();
  }

  void resetStatusFilterForCargo() {
    _cargoStatusFilter.value = '';
    print('🔄 Cargo status filter reset');
    loadCargoHistory(refresh: true);
  }

// Update _applyCargoFilters method:
  void _applyCargoFilters() {
    var filtered = List<CargoModel>.from(_cargoList);

    print('🔍 Applying cargo filters to ${_cargoList.length} items');
    print('🔍 Cargo status filter: ${_cargoStatusFilter.value}');

    // Apply status filter
    if (_cargoStatusFilter.value.isNotEmpty && _cargoStatusFilter.value != 'all') {
      filtered = filtered.where((c) {
        return c.status.toLowerCase() == _cargoStatusFilter.value.toLowerCase();
      }).toList();
    }

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.trackingCode.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
            c.destination.toLowerCase().contains(_searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply date range
    if (_dateRange.value != null) {
      filtered = filtered.where((c) {
        return c.registeredDate.isAfter(_dateRange.value!.start) &&
            c.registeredDate.isBefore(_dateRange.value!.end);
      }).toList();
    }

    // Apply sorting
    if (_sortOrder.value == SortOrder.ascending) {
      filtered.sort((a, b) => a.registeredDate.compareTo(b.registeredDate));
    } else {
      filtered.sort((a, b) => b.registeredDate.compareTo(a.registeredDate));
    }

    filteredCargo.value = filtered;
    print('✅ After filter: ${filteredCargo.length} cargo items');
  }
  // ============== Cargo History ==============

  // Replace the loadCargoHistory method with this:

  Future<void> loadCargoHistory({bool refresh = false}) async {
    if (refresh) {
      _cargoCurrentPage.value = 1;
      _cargoHasMore.value = true;
      _cargoList.clear();
    }

    if (!_cargoHasMore.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      print('📦 Loading cargo history...');

      // Use the correct endpoint from ApiEndpoints
      final response = await _apiClient.get(
        ApiEndpoints.cargoHistory,
        queryParameters: {
          'page': _cargoCurrentPage.value,
          'limit': 100,  // Get more items
        },
      );

      print('📦 Cargo API Response: $response');

      if (response != null && response['data'] != null) {
        List<CargoModel> newCargo = [];

        // Handle different response structures
        if (response['data'] is List) {
          newCargo = (response['data'] as List)
              .map((c) => CargoModel.fromJson(c))
              .toList();
        } else if (response['data']['data'] is List) {
          newCargo = (response['data']['data'] as List)
              .map((c) => CargoModel.fromJson(c))
              .toList();
        } else if (response['data']['cargos'] is List) {
          newCargo = (response['data']['cargos'] as List)
              .map((c) => CargoModel.fromJson(c))
              .toList();
        }

        print('✅ Loaded ${newCargo.length} cargo items');

        if (refresh) {
          _cargoList.value = newCargo;
        } else {
          _cargoList.addAll(newCargo);
        }

        _applyCargoFilters();
        _cargoHasMore.value = newCargo.length >= 100;
        _cargoCurrentPage.value++;

        // Update total cargo count
        _totalCargo.value = _cargoList.length;
      } else {
        print('⚠️ No cargo data found');
        if (refresh) {
          _cargoList.clear();
          filteredCargo.clear();
        }
      }
    } catch (e) {
      print('❌ Error loading cargo history: $e');
      if (refresh) {
        _cargoList.clear();
        filteredCargo.clear();
      }
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  // void _applyCargoFilters() {
  //   var filtered = List<CargoModel>.from(_cargoList);
  //
  //   // Apply search query
  //   if (_searchQuery.value.isNotEmpty) {
  //     filtered = filtered.where((c) {
  //       return c.trackingCode.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
  //           c.destination.toLowerCase().contains(_searchQuery.value.toLowerCase());
  //     }).toList();
  //   }
  //
  //   // Apply date range
  //   if (_dateRange.value != null) {
  //     filtered = filtered.where((c) {
  //       return c.registeredDate.isAfter(_dateRange.value!.start) &&
  //           c.registeredDate.isBefore(_dateRange.value!.end);
  //     }).toList();
  //   }
  //
  //   // Apply sorting
  //   if (_sortOrder.value == SortOrder.ascending) {
  //     filtered.sort((a, b) => a.registeredDate.compareTo(b.registeredDate));
  //   } else {
  //     filtered.sort((a, b) => b.registeredDate.compareTo(a.registeredDate));
  //   }
  //
  //   filteredCargo.value = filtered;
  // }

  // ============== Payments History ==============

  Future<void> loadPayments({bool refresh = false}) async {
    if (refresh) {
      _paymentsCurrentPage.value = 1;
      _paymentsHasMore.value = true;
      _payments.clear();
    }

    if (!_paymentsHasMore.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '/payments/history',
        queryParameters: {
          'page': _paymentsCurrentPage.value,
          'limit': AppConstants.defaultPageSize,
          'status': _statusFilter.value != 'all' ? _statusFilter.value : null,
          'sort': _sortOrder.value == SortOrder.ascending ? 'asc' : 'desc',
          ..._getDateRangeParams(),
        },
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final newPayments = data.map((p) => PaymentModel.fromJson(p)).toList();

        if (_paymentsCurrentPage.value == 1) {
          _payments.value = newPayments;
        } else {
          _payments.addAll(newPayments);
        }

        _applyPaymentFilters();
        _paymentsHasMore.value = newPayments.length >= AppConstants.defaultPageSize;
        _paymentsCurrentPage.value++;
      }
    } catch (e) {
      print('Error loading payments: $e');
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  void _applyPaymentFilters() {
    var filtered = List<PaymentModel>.from(_payments);

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((p) {
        return p.reference!.toLowerCase().contains(_searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply date range
    if (_dateRange.value != null) {
      filtered = filtered.where((p) {
        return p.createdAt.isAfter(_dateRange.value!.start) &&
            p.createdAt.isBefore(_dateRange.value!.end);
      }).toList();
    }

    // Apply sorting
    if (_sortOrder.value == SortOrder.ascending) {
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    _filteredPayments.value = filtered;
  }

  // ============== Statistics ==============

  void _calculateStatistics() {
    double total = 0;
    int trips = 0;
    int cargo = 0;
    double refunds = 0;
    final routeCount = <String, int>{};

    for (var ticket in _tickets) {
      if (ticket.status == 'paid' || ticket.status == 'used') {
        total += ticket.price;
        trips++;

        final route = '${ticket.origin} - ${ticket.destination}';
        routeCount[route] = (routeCount[route] ?? 0) + 1;
      }
      if (ticket.status == 'refunded') {
        refunds += ticket.price;
      }
    }

    for (var cargo in _cargoList) {
      if (cargo.status == 'delivered') {
        deliveredCount++;
      }
    }

    _totalSpent.value = total;
    _totalTrips.value = trips;
    _totalCargo.value = cargo;
    _totalRefunds.value = refunds;
    _averageSpending.value = trips > 0 ? total / trips : 0;

    // Find most frequent route
    if (routeCount.isNotEmpty) {
      _mostFrequentRoute.value = routeCount.entries.reduce((a, b) =>
      a.value > b.value ? a : b).key;
    }
  }

  // ============== Filter Methods ==============

  void changeTab(HistoryTab tab) {
    _currentTab.value = tab;
    resetFilters();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange.value = range;
    _refreshCurrentTab();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _refreshCurrentTab();
  }

  void setStatusFilter(String status) {
    _statusFilter.value = status;
    _refreshCurrentTab(refresh: true);
  }

  void setSortOrder(SortOrder order) {
    _sortOrder.value = order;
    _refreshCurrentTab();
  }

  void clearDateRange() {
    _dateRange.value = null;
    _refreshCurrentTab();
  }

  void resetFilters() {
    _dateRange.value = null;
    _searchQuery.value = '';
    _statusFilter.value = '';
    _sortOrder.value = SortOrder.descending;
    _refreshCurrentTab(refresh: true);
  }

  void _refreshCurrentTab({bool refresh = false}) {
    switch (_currentTab.value) {
      case HistoryTab.tickets:
        loadTickets(refresh: refresh);
        break;
      case HistoryTab.cargo:
        loadCargoHistory(refresh: refresh);
        break;
      case HistoryTab.payments:
        loadPayments(refresh: refresh);
        break;
    }
  }

  Map<String, dynamic> _getDateRangeParams() {
    if (_dateRange.value == null) return {};

    return {
      'start_date': DateFormatter.toApiDate(_dateRange.value!.start),
      'end_date': DateFormatter.toApiDate(_dateRange.value!.end),
    };
  }

  // ============== Load More Methods ==============

  void loadMoreTickets() {
    if (_ticketsHasMore.value && !_isLoading.value) {
      loadTickets();
    }
  }

  void loadMoreCargo() {
    if (_cargoHasMore.value && !_isLoading.value) {
      loadCargoHistory();
    }
  }

  void loadMorePayments() {
    if (_paymentsHasMore.value && !_isLoading.value) {
      loadPayments();
    }
  }

  // ============== Refresh Methods ==============

  Future<void> refreshAll() async {
    _isRefreshing.value = true;

    await Future.wait([
      loadTickets(refresh: true),
      loadCargoHistory(refresh: true),
      loadPayments(refresh: true),
    ]);

    _calculateStatistics();
    _isRefreshing.value = false;
  }

  void refreshCurrentTab() {
    _refreshCurrentTab(refresh: true);
  }

  // ============== Export Methods ==============

  Future<String?> exportHistoryAsCSV() async {
    try {
      // Implementation for CSV export
      // This would generate a CSV file with history data
      return null;
    } catch (e) {
      print('Error exporting history: $e');
      return null;
    }
  }

  Future<String?> exportHistoryAsPDF() async {
    try {
      // Implementation for PDF export
      return null;
    } catch (e) {
      print('Error exporting history: $e');
      return null;
    }
  }
}

enum HistoryTab {
  tickets,
  cargo,
  payments,
}

enum SortOrder {
  ascending,
  descending,
}

extension HistoryTabExtension on HistoryTab {
  String get displayName {
    switch (this) {
      case HistoryTab.tickets:
        return 'Tickets';
      case HistoryTab.cargo:
        return 'Cargo';
      case HistoryTab.payments:
        return 'Payments';
    }
  }

  IconData get icon {
    switch (this) {
      case HistoryTab.tickets:
        return Icons.confirmation_number_rounded;
      case HistoryTab.cargo:
        return Icons.inventory_2_rounded;
      case HistoryTab.payments:
        return Icons.payments_rounded;
    }
  }
}