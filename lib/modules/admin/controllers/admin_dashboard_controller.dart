// lib/modules/admin/controllers/admin_dashboard_controller.dart

import 'package:get/get.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/services/socket/socket_service.dart';
import '../models/admin_models.dart';

class AdminDashboardController extends GetxController {
  static AdminDashboardController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;

  // Observables
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _stats = Rxn<AdminDashboardStats>();
  final _revenueChart = Rxn<RevenueChartData>();
  final _tripAnalytics = Rxn<TripAnalytics>();
  final _bookingAnalytics = Rxn<BookingAnalytics>();
  final _cargoAnalytics = Rxn<CargoAnalytics>();
  final _recentActivities = <AuditLogEntry>[].obs;
  final _selectedPeriod = DashboardPeriod.weekly.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  AdminDashboardStats? get stats => _stats.value;
  RevenueChartData? get revenueChart => _revenueChart.value;
  TripAnalytics? get tripAnalytics => _tripAnalytics.value;
  BookingAnalytics? get bookingAnalytics => _bookingAnalytics.value;
  CargoAnalytics? get cargoAnalytics => _cargoAnalytics.value;
  List<AuditLogEntry> get recentActivities => _recentActivities;
  DashboardPeriod get selectedPeriod => _selectedPeriod.value;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.on('dashboard_update', _handleDashboardUpdate);
    _socketService.on('new_booking', (_) => loadDashboardData(refresh: true));
    _socketService.on('new_cargo', (_) => loadDashboardData(refresh: true));
    _socketService.on('payment_completed', (_) => loadDashboardData(refresh: true));
  }

  void _handleDashboardUpdate(dynamic data) {
    loadDashboardData(refresh: true);
  }

  Future<void> loadDashboardData({bool refresh = false}) async {
    if (refresh) {
      _isRefreshing.value = true;
    } else {
      _isLoading.value = true;
    }

    try {
      // Load all dashboard data in parallel
      await Future.wait([
        _loadStats(),
        _loadRevenueChart(),
        _loadTripAnalytics(),
        _loadBookingAnalytics(),
        _loadCargoAnalytics(),
        _loadRecentActivities(),
      ]);
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  Future<void> _loadStats() async {
    try {
      final response = await _apiClient.get(
        '/admin/dashboard/stats',
        queryParameters: {'period': _selectedPeriod.value.name},
      );

      if (response != null && response['data'] != null) {
        _stats.value = AdminDashboardStats.fromJson(response['data']);
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> _loadRevenueChart() async {
    try {
      final response = await _apiClient.get(
        '/admin/dashboard/revenue-chart',
        queryParameters: {'period': _selectedPeriod.value.name},
      );

      if (response != null && response['data'] != null) {
        _revenueChart.value = RevenueChartData.fromJson(response['data']);
      }
    } catch (e) {
      print('Error loading revenue chart: $e');
    }
  }

  Future<void> _loadTripAnalytics() async {
    try {
      final response = await _apiClient.get('/admin/dashboard/trip-analytics');

      if (response != null && response['data'] != null) {
        _tripAnalytics.value = TripAnalytics.fromJson(response['data']);
      }
    } catch (e) {
      print('Error loading trip analytics: $e');
    }
  }

  Future<void> _loadBookingAnalytics() async {
    try {
      final response = await _apiClient.get('/admin/dashboard/booking-analytics');

      if (response != null && response['data'] != null) {
        _bookingAnalytics.value = BookingAnalytics.fromJson(response['data']);
      }
    } catch (e) {
      print('Error loading booking analytics: $e');
    }
  }

  Future<void> _loadCargoAnalytics() async {
    try {
      final response = await _apiClient.get('/admin/dashboard/cargo-analytics');

      if (response != null && response['data'] != null) {
        _cargoAnalytics.value = CargoAnalytics.fromJson(response['data']);
      }
    } catch (e) {
      print('Error loading cargo analytics: $e');
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      final response = await _apiClient.get(
        '/admin/audit/logs',
        queryParameters: {'limit': 10},
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> logs = response['data'];
        _recentActivities.value = logs
            .map((l) => AuditLogEntry.fromJson(l))
            .toList();
      }
    } catch (e) {
      print('Error loading recent activities: $e');
    }
  }

  void setPeriod(DashboardPeriod period) {
    if (_selectedPeriod.value == period) return;
    _selectedPeriod.value = period;
    loadDashboardData(refresh: true);
  }

  Future<void> refreshDashboard() async {
    loadDashboardData(refresh: true);
  }

  @override
  void onClose() {
    _socketService.off('dashboard_update', _handleDashboardUpdate);
    super.onClose();
  }
}

enum DashboardPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}

extension DashboardPeriodExtension on DashboardPeriod {
  String get displayName {
    switch (this) {
      case DashboardPeriod.daily:
        return 'Today';
      case DashboardPeriod.weekly:
        return 'This Week';
      case DashboardPeriod.monthly:
        return 'This Month';
      case DashboardPeriod.yearly:
        return 'This Year';
    }
  }
}