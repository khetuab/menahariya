// lib/modules/admin/controllers/admin_report_controller.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../models/admin_models.dart';

class AdminReportController extends GetxController {
  static AdminReportController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Observables
  final _isLoading = false.obs;
  final _isGenerating = false.obs;
  final _reports = <ReportResponse>[].obs;
  final _selectedReportType = ReportType.revenue.obs;
  final _startDate = Rxn<DateTime>();
  final _endDate = Rxn<DateTime>();
  final _selectedFormat = ReportFormat.pdf.obs;
  final _selectedRoutes = <String>[].obs;
  final _selectedStatuses = <String>[].obs;
  final _generatedReportUrl = Rxn<String>();

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isGenerating => _isGenerating.value;
  List<ReportResponse> get reports => _reports;
  ReportType get selectedReportType => _selectedReportType.value;
  DateTime? get startDate => _startDate.value;
  DateTime? get endDate => _endDate.value;
  ReportFormat get selectedFormat => _selectedFormat.value;
  List<String> get selectedRoutes => _selectedRoutes;
  List<String> get selectedStatuses => _selectedStatuses;
  String? get generatedReportUrl => _generatedReportUrl.value;
  bool get hasMorePages => _hasMorePages.value;

  // Available report types
  final List<ReportTypeInfo> reportTypes = const [
    ReportTypeInfo(
      type: ReportType.revenue,
      title: 'Revenue Report',
      icon: Icons.attach_money_rounded,
      description: 'Daily, weekly, monthly revenue breakdown',
    ),
    ReportTypeInfo(
      type: ReportType.trips,
      title: 'Trip Report',
      icon: Icons.directions_bus_rounded,
      description: 'Trip schedules, status, and performance',
    ),
    ReportTypeInfo(
      type: ReportType.bookings,
      title: 'Booking Report',
      icon: Icons.confirmation_number_rounded,
      description: 'Ticket sales and booking statistics',
    ),
    ReportTypeInfo(
      type: ReportType.cargo,
      title: 'Cargo Report',
      icon: Icons.inventory_2_rounded,
      description: 'Cargo shipments and revenue',
    ),
    ReportTypeInfo(
      type: ReportType.users,
      title: 'User Report',
      icon: Icons.people_rounded,
      description: 'User registration and activity',
    ),
    ReportTypeInfo(
      type: ReportType.performance,
      title: 'Performance Report',
      icon: Icons.analytics_rounded,
      description: 'KPIs and operational metrics',
    ),
  ];

  // Available status options
  final List<String> statusOptions = [
    'all',
    'scheduled',
    'in_progress',
    'completed',
    'cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    _setDefaultDateRange();
    fetchReports();
  }

  void _setDefaultDateRange() {
    _startDate.value = DateTime.now().subtract(const Duration(days: 30));
    _endDate.value = DateTime.now();
  }

  Future<void> fetchReports({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _hasMorePages.value = true;
      _reports.clear();
    }

    if (!_hasMorePages.value || _isLoading.value) return;

    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '/admin/reports/list',
        queryParameters: {
          'page': _currentPage.value,
          'limit': 20,
        },
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> reportsData = response['data'];
        final newReports = reportsData
            .map((r) => ReportResponse.fromJson(r))
            .toList();

        if (_currentPage.value == 1) {
          _reports.value = newReports;
        } else {
          _reports.addAll(newReports);
        }

        _hasMorePages.value = newReports.length >= 20;
        _currentPage.value++;
      }
    } catch (e) {
      print('Error fetching reports: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> generateReport() async {
    if (_startDate.value == null || _endDate.value == null) {
      AppSnackbar.show('Error', 'Please select date range');
      return;
    }

    try {
      _isGenerating.value = true;

      final filters = ReportFilters(
        startDate: _startDate.value,
        endDate: _endDate.value,
        reportType: _selectedReportType.value.name,
        format: _selectedFormat.value.name,
        routes: _selectedRoutes.isEmpty ? null : _selectedRoutes,
        statuses: _selectedStatuses.isEmpty ? null : _selectedStatuses,
      );

      final response = await _apiClient.post(
        '/admin/reports/generate',
        data: filters.toQueryParams(),
      );

      if (response != null && response['data'] != null) {
        final report = ReportResponse.fromJson(response['data']);
        _generatedReportUrl.value = report.downloadUrl;

        AppSnackbar.show(
          'Report Generated',
          'Your report is ready for download',
        );

        // Add to reports list
        _reports.insert(0, report);
      }
    } catch (e) {
      print('Error generating report: $e');
      AppSnackbar.show('Error', 'Failed to generate report');
    } finally {
      _isGenerating.value = false;
    }
  }

  Future<void> downloadReport(ReportResponse report) async {
    try {
      _isLoading.value = true;

      final dio = Dio();
      final response = await dio.get(
        report.downloadUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileExtension = report.format.toLowerCase();
        final fileName = '${report.title.replaceAll(' ', '_')}.$fileExtension';
        final filePath = '${directory.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.data);

        // Share the file
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Report: ${report.title}',
        );

        AppSnackbar.show('Success', 'Report downloaded successfully');
      }
    } catch (e) {
      print('Error downloading report: $e');
      AppSnackbar.show('Error', 'Failed to download report');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> downloadCurrentReport() async {
    if (_generatedReportUrl.value == null) {
      AppSnackbar.show('Error', 'No report generated yet');
      return;
    }

    try {
      _isLoading.value = true;

      final dio = Dio();
      final response = await dio.get(
        _generatedReportUrl.value!,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final extension = _selectedFormat.value.name.toLowerCase();
        final fileName = '${_selectedReportType.value.name}_report_${DateTime.now().millisecondsSinceEpoch}.$extension';
        final filePath = '${directory.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.data);

        await Share.shareXFiles(
          [XFile(filePath)],
          text: '${_selectedReportType.value.name} Report',
        );

        AppSnackbar.show('Success', 'Report downloaded successfully');
      }
    } catch (e) {
      print('Error downloading report: $e');
      AppSnackbar.show('Error', 'Failed to download report');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> scheduleReport({
    required ReportType type,
    required String frequency,
    required List<String> recipients,
  }) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post(
        '/admin/reports/schedule',
        data: {
          'type': type.name,
          'frequency': frequency,
          'recipients': recipients,
          'filters': {
            'routes': _selectedRoutes,
            'statuses': _selectedStatuses,
          },
        },
      );

      if (response != null && response['success'] == true) {
        AppSnackbar.show('Success', 'Report scheduled successfully');
      }
    } catch (e) {
      print('Error scheduling report: $e');
      AppSnackbar.show('Error', 'Failed to schedule report');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Report'),
          content: const Text('Are you sure you want to delete this report?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await _apiClient.delete('/admin/reports/$reportId');

      _reports.removeWhere((r) => r.id == reportId);

      AppSnackbar.show('Success', 'Report deleted successfully');
    } catch (e) {
      print('Error deleting report: $e');
      AppSnackbar.show('Error', 'Failed to delete report');
    }
  }

  void setReportType(ReportType type) {
    _selectedReportType.value = type;
  }

  void setDateRange(DateTimeRange? range) {
    if (range != null) {
      _startDate.value = range.start;
      _endDate.value = range.end;
    }
  }

  void setFormat(ReportFormat format) {
    _selectedFormat.value = format;
  }

  void toggleRoute(String routeId) {
    if (_selectedRoutes.contains(routeId)) {
      _selectedRoutes.remove(routeId);
    } else {
      _selectedRoutes.add(routeId);
    }
  }

  void toggleStatus(String status) {
    if (_selectedStatuses.contains(status)) {
      _selectedStatuses.remove(status);
    } else {
      _selectedStatuses.add(status);
    }
  }

  void clearFilters() {
    _selectedRoutes.clear();
    _selectedStatuses.clear();
  }

  Future<void> refreshReports() async {
    await fetchReports(refresh: true);
  }

  @override
  void onClose() {
    super.onClose();
  }
}

enum ReportType {
  revenue,
  trips,
  bookings,
  cargo,
  users,
  performance,
}

enum ReportFormat {
  pdf,
  csv,
  excel,
}

class ReportTypeInfo {
  final ReportType type;
  final String title;
  final IconData icon;
  final String description;

  const ReportTypeInfo({
    required this.type,
    required this.title,
    required this.icon,
    required this.description,
  });
}

extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.revenue:
        return 'Revenue Report';
      case ReportType.trips:
        return 'Trip Report';
      case ReportType.bookings:
        return 'Booking Report';
      case ReportType.cargo:
        return 'Cargo Report';
      case ReportType.users:
        return 'User Report';
      case ReportType.performance:
        return 'Performance Report';
    }
  }
}