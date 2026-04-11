// lib/modules/admin/controllers/admin_payment_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/payment/payment_model.dart';
import '../../../data/models/booking/booking_model.dart';

class AdminPaymentController extends GetxController {
  static AdminPaymentController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Search controller
  final searchController = TextEditingController();

  // Observables
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _payments = <PaymentModel>[].obs;
  final _filteredPayments = <PaymentModel>[].obs;
  final _selectedPayment = Rxn<PaymentModel>();
  final _selectedBooking = Rxn<BookingModel>();
  final _searchQuery = ''.obs;
  final _statusFilter = ''.obs;
  final _methodFilter = ''.obs;
  final _dateFilter = Rxn<DateTime>();

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;
  final _totalCount = 0.obs;
  final _totalAmount = 0.0.obs;
  final _totalRefunded = 0.0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  List<PaymentModel> get payments => _filteredPayments;
  PaymentModel? get selectedPayment => _selectedPayment.value;
  BookingModel? get selectedBooking => _selectedBooking.value;
  String get searchQuery => _searchQuery.value;
  String get statusFilter => _statusFilter.value;
  String get methodFilter => _methodFilter.value;
  DateTime? get dateFilter => _dateFilter.value;
  bool get hasMorePages => _hasMorePages.value;
  int get totalCount => _totalCount.value;
  double get totalAmount => _totalAmount.value;
  double get totalRefunded => _totalRefunded.value;

  // Statistics
  int get totalPayments => _payments.length;
  int get completedPayments => _payments.where((p) => p.isCompleted).length;
  int get pendingPayments => _payments.where((p) => p.isPending).length;
  int get failedPayments => _payments.where((p) => p.isFailed).length;
  int get refundedPayments => _payments.where((p) => p.isRefunded).length;

  // Available payment methods
  final List<String> availableMethods = [
    'all',
    'telebirr',
    'cbe_birr',
    'card',
    'wallet',
    'cash',
  ];

  // Available statuses
  final List<String> availableStatuses = [
    'all',
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchPayments();
  }

  Future<void> fetchPayments({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _payments.clear();
    }

    if (!_hasMorePages.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      final params = <String, dynamic>{
        'page': _currentPage.value,
        'limit': AppConstants.defaultPageSize,
      };

      if (_searchQuery.value.isNotEmpty) params['search'] = _searchQuery.value;
      if (_statusFilter.value.isNotEmpty && _statusFilter.value != 'all') {
        params['status'] = _statusFilter.value;
      }
      if (_methodFilter.value.isNotEmpty && _methodFilter.value != 'all') {
        params['method'] = _methodFilter.value;
      }
      if (_dateFilter.value != null) params['date'] = _dateFilter.value!.toIso8601String();

      final response = await _apiClient.get(
        ApiEndpoints.paymentsHistory,
        queryParameters: params,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> paymentsData = response['data'];
        final newPayments = paymentsData.map((p) => PaymentModel.fromJson(p)).toList();

        if (_currentPage.value == 1) {
          _payments.value = newPayments;
        } else {
          _payments.addAll(newPayments);
        }

        _applyFilters();
        _totalCount.value = response['total'] ?? _payments.length;
        _hasMorePages.value = newPayments.length >= AppConstants.defaultPageSize;
        _currentPage.value++;

        _calculateTotals();
      }
    } catch (e) {
      print('Error fetching payments: $e');
      AppSnackbar.show('Error', 'Failed to load payments');
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  void _applyFilters() {
    var filtered = List<PaymentModel>.from(_payments);

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((p) =>
      p.id.toLowerCase().contains(query) ||
          p.transactionId?.toLowerCase().contains(query) == true ||
          p.reference?.toLowerCase().contains(query) == true).toList();
    }

    _filteredPayments.value = filtered;
  }

  void _calculateTotals() {
    double total = 0;
    double refunded = 0;

    for (var payment in _payments) {
      if (payment.isCompleted) {
        total += payment.amount;
      } else if (payment.isRefunded) {
        refunded += payment.amount;
      }
    }

    _totalAmount.value = total;
    _totalRefunded.value = refunded;
  }

  Future<PaymentModel?> getPaymentDetails(String paymentId) async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.get('${ApiEndpoints.payments}/$paymentId');
      if (response != null && response['data'] != null) {
        final payment = PaymentModel.fromJson(response['data']);
        _selectedPayment.value = payment;

        // Fetch associated booking if exists
        if (payment.bookingId.isNotEmpty) {
          final bookingResponse = await _apiClient.get('${ApiEndpoints.bookings}/${payment.bookingId}');
          if (bookingResponse != null && bookingResponse['data'] != null) {
            _selectedBooking.value = BookingModel.fromJson(bookingResponse['data']);
          }
        }

        return payment;
      }
      return null;
    } catch (e) {
      print('Error fetching payment details: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> processRefund(String paymentId, double amount, String reason) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.paymentsRefund,
        data: {
          'paymentId': paymentId,
          'amount': amount,
          'reason': reason,
        },
      );

      if (response != null && response['success'] == true) {
        await fetchPayments(refresh: true);
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

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    searchController.text = query;
    _applyFilters();
  }

  void setStatusFilter(String status) {
    _statusFilter.value = status;
    fetchPayments(refresh: true);
  }

  void setMethodFilter(String method) {
    _methodFilter.value = method;
    fetchPayments(refresh: true);
  }

  void setDateFilter(DateTime? date) {
    _dateFilter.value = date;
    fetchPayments(refresh: true);
  }

  void clearFilters() {
    _searchQuery.value = '';
    _statusFilter.value = '';
    _methodFilter.value = '';
    _dateFilter.value = null;
    searchController.clear();
    fetchPayments(refresh: true);
  }

  Future<void> refreshPayments() async {
    _isRefreshing.value = true;
    await fetchPayments(refresh: true);
    _isRefreshing.value = false;
  }

  Future<void> loadMorePayments() async {
    if (_hasMorePages.value && !_isLoading.value) {
      await fetchPayments();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}