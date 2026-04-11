// lib/modules/admin/controllers/admin_booking_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/booking/booking_model.dart';
import '../../../data/models/ticket/ticket_model.dart';

class AdminBookingController extends GetxController {
  static AdminBookingController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Observables
  final searchController = TextEditingController();
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _bookings = <BookingModel>[].obs;
  final _filteredBookings = <BookingModel>[].obs;
  final _selectedBooking = Rxn<BookingModel>();
  final _tickets = <TicketModel>[].obs;
  final _searchQuery = ''.obs;
  final _statusFilter = ''.obs;
  final _paymentStatusFilter = ''.obs;
  final _dateFilter = Rxn<DateTime>();

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;
  final _totalCount = 0.obs;
  final _totalRevenue = 0.0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  List<BookingModel> get bookings => _filteredBookings;
  BookingModel? get selectedBooking => _selectedBooking.value;
  List<TicketModel> get tickets => _tickets;
  String get searchQuery => _searchQuery.value;
  String get statusFilter => _statusFilter.value;
  String get paymentStatusFilter => _paymentStatusFilter.value;
  DateTime? get dateFilter => _dateFilter.value;
  bool get hasMorePages => _hasMorePages.value;
  int get totalCount => _totalCount.value;
  double get totalRevenue => _totalRevenue.value;

  // Statistics
  int get totalBookings => _bookings.length;
  int get confirmedBookings => _bookings.where((b) => b.isConfirmed).length;
  int get pendingBookings => _bookings.where((b) => b.isPending).length;
  int get cancelledBookings => _bookings.where((b) => b.isCancelled).length;
  int get expiredBookings => _bookings.where((b) => b.isExpired).length;

  // Payment statistics
  int get paidBookings => _bookings.where((b) => b.isPaid).length;
  int get pendingPayments => _bookings.where((b) => b.isPaymentPending).length;
  int get failedPayments => _bookings.where((b) => b.isPaymentFailed).length;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> fetchBookings({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _bookings.clear();
    }

    if (!_hasMorePages.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      final params = <String, dynamic>{
        'page': _currentPage.value,
        'limit': AppConstants.defaultPageSize,
      };

      if (_searchQuery.value.isNotEmpty) params['search'] = _searchQuery.value;
      if (_statusFilter.value.isNotEmpty) params['status'] = _statusFilter.value;
      if (_paymentStatusFilter.value.isNotEmpty) params['paymentStatus'] = _paymentStatusFilter.value;
      if (_dateFilter.value != null) params['date'] = _dateFilter.value!.toIso8601String();

      final response = await _apiClient.get(
        ApiEndpoints.bookingsHistory,
        queryParameters: params,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> bookingsData = response['data'];
        final newBookings = bookingsData.map((b) => BookingModel.fromJson(b)).toList();

        if (_currentPage.value == 1) {
          _bookings.value = newBookings;
        } else {
          _bookings.addAll(newBookings);
        }

        _applyFilters();
        _totalCount.value = response['total'] ?? _bookings.length;
        _hasMorePages.value = newBookings.length >= AppConstants.defaultPageSize;
        _currentPage.value++;

        _calculateTotalRevenue();
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      AppSnackbar.show('Error', 'Failed to load bookings');
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  void _applyFilters() {
    var filtered = List<BookingModel>.from(_bookings);

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((b) =>
      b.id.toLowerCase().contains(query) ||
          b.userId.toLowerCase().contains(query) ||
          b.passengerNames.toLowerCase().contains(query)).toList();
    }

    // Apply status filter
    if (_statusFilter.value.isNotEmpty) {
      filtered = filtered.where((b) => b.bookingStatus == _statusFilter.value).toList();
    }

    // Apply payment status filter
    if (_paymentStatusFilter.value.isNotEmpty) {
      filtered = filtered.where((b) => b.paymentStatus == _paymentStatusFilter.value).toList();
    }

    // Apply date filter
    if (_dateFilter.value != null) {
      final filterDate = _dateFilter.value;
      filtered = filtered.where((b) =>
      b.bookingDate.year == filterDate!.year &&
          b.bookingDate.month == filterDate.month &&
          b.bookingDate.day == filterDate.day).toList();
    }

    _filteredBookings.value = filtered;
  }

  void _calculateTotalRevenue() {
    double total = 0;
    for (var booking in _bookings) {
      if (booking.isPaid) {
        total += booking.totalAmount;
      }
    }
    _totalRevenue.value = total;
  }

  Future<BookingModel?> getBookingDetails(String bookingId) async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.get('${ApiEndpoints.bookings}/$bookingId');
      if (response != null && response['data'] != null) {
        final booking = BookingModel.fromJson(response['data']);
        _selectedBooking.value = booking;

        // Also fetch tickets for this booking
        if (booking.tickets != null) {
          _tickets.value = booking.tickets!;
        }
        return booking;
      }
      return null;
    } catch (e) {
      print('Error fetching booking details: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> refundBooking(String bookingId, {double? amount, String? reason}) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.bookingsRefund,
        data: {
          'bookingId': bookingId,
          'amount': amount,
          'reason': reason,
        },
      );

      if (response != null && response['success'] == true) {
        await fetchBookings(refresh: true);
        AppSnackbar.show('Success', 'Refund processed successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error processing refund: $e');
      AppSnackbar.show('Error', 'Failed to process refund');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.bookingsCancel,
        data: {
          'bookingId': bookingId,
          'reason': reason,
        },
      );

      if (response != null && response['success'] == true) {
        await fetchBookings(refresh: true);
        AppSnackbar.show('Success', 'Booking cancelled successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error cancelling booking: $e');
      AppSnackbar.show('Error', 'Failed to cancel booking');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    searchController.text = query;
    _applyFilters();
  }

  void setStatusFilter(String status) {
    _statusFilter.value = status;
    fetchBookings(refresh: true);
  }

  void setPaymentStatusFilter(String status) {
    _paymentStatusFilter.value = status;
    fetchBookings(refresh: true);
  }

  void setDateFilter(DateTime? date) {
    _dateFilter.value = date;
    fetchBookings(refresh: true);
  }

  void clearFilters() {
    _searchQuery.value = '';
    _statusFilter.value = '';
    _paymentStatusFilter.value = '';
    searchController.clear();
    _dateFilter.value = null;
    fetchBookings(refresh: true);
  }

  Future<void> refreshBookings() async {
    _isRefreshing.value = true;
    await fetchBookings(refresh: true);
    _isRefreshing.value = false;
  }

  Future<void> loadMoreBookings() async {
    if (_hasMorePages.value && !_isLoading.value) {
      await fetchBookings();
    }
  }

  @override
  void onClose() {
    super.onClose();
    searchController.dispose();
  }
}