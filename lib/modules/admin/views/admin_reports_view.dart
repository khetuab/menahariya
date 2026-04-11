// lib/modules/admin/views/admin_reports_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_dialogs.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_empty_state.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_sidebar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/inputs/custom_textfield.dart';
import '../../../core/widgets/loading/shimmer_loading.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/admin_report_controller.dart';

class AdminReportsView extends GetView<AdminReportController> {
  const AdminReportsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AdminDrawer(currentIndex: 5),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showGenerateReportSheet(context),
            tooltip: 'Generate Report',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshReports,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.reports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Report Types Quick Access
            _buildReportTypesRow(context),
            // Recent Reports List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshReports,
                child: controller.reports.isEmpty
                    ? AdminEmptyState(
                  title: 'No Reports',
                  message: 'No reports have been generated yet',
                  icon: Icons.description_rounded,
                  onAction: () => _showGenerateReportSheet(context),
                  actionText: 'Generate First Report',
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  itemCount: controller.reports.length,
                  itemBuilder: (context, index) {
                    final report = controller.reports[index];
                    return _buildReportCard(context, report);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildReportTypesRow(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 114,
      padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
        itemCount: controller.reportTypes.length,
        itemBuilder: (context, index) {
          final reportType = controller.reportTypes[index];
          final isSelected = controller.selectedReportType == reportType.type;
          return GestureDetector(
            onTap: () => controller.setReportType(reportType.type),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: AppDimens.margin12),
              padding: const EdgeInsets.all(AppDimens.padding8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.primaryGreenLight.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1))
                    : (isDark ? AppColors.grey800 : AppColors.grey50),
                borderRadius: BorderRadius.circular(AppDimens.radius12),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    reportType.icon,
                    size: 28,
                    color: isSelected
                        ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: AppDimens.margin4),
                  Text(
                    reportType.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected ? AppFonts.medium : AppFonts.regular,
                      color: isSelected
                          ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                          : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, dynamic report) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.margin12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getReportColor(report.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimens.radius12),
              ),
              child: Icon(
                _getReportIcon(report.type),
                color: _getReportColor(report.type),
                size: 28,
              ),
            ),
            const SizedBox(width: AppDimens.margin12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppFonts.semiBold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimens.margin4),
                  Text(
                    'Generated on ${DateFormat('MMM dd, yyyy HH:mm').format(report.generatedAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppDimens.margin2),
                  Text(
                    '${(report.fileSize / 1024).toStringAsFixed(1)} KB • ${report.format.toUpperCase()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: Colors.blue),
                  onPressed: () => controller.downloadReport(report),
                  tooltip: 'Download',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                  onPressed: () => _showDeleteDialog(report.id),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGenerateReportSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Reset form
    controller.clearFilters();
    controller.setDateRange(DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    ));

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Generate Report',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin24),
                // Date Range
                Text(
                  'Date Range',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin8),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _buildDatePickerField(
                        context,
                        label: 'Start Date',
                        date: controller.startDate,
                        onTap: () => _selectDate(context, isStart: true),
                      )),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: Obx(() => _buildDatePickerField(
                        context,
                        label: 'End Date',
                        date: controller.endDate,
                        onTap: () => _selectDate(context, isStart: false),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin20),
                // Format
                Text(
                  'Format',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin8),
                Obx(() => Row(
                  children: ReportFormat.values.map((format) {
                    final isSelected = controller.selectedFormat == format;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => controller.setFormat(format),
                        child: Container(
                          margin: const EdgeInsets.only(right: AppDimens.margin8),
                          padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                                : (isDark ? AppColors.grey800 : AppColors.grey50),
                            borderRadius: BorderRadius.circular(AppDimens.radius8),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              format.name.toUpperCase(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected ? Colors.white : null,
                                fontWeight: isSelected ? AppFonts.medium : AppFonts.regular,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
                const SizedBox(height: AppDimens.margin20),
                // Additional Filters (for trips report)
                Obx(() {
                  if (controller.selectedReportType == ReportType.trips) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filters',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: AppFonts.semiBold,
                          ),
                        ),
                        const SizedBox(height: AppDimens.margin8),
                        Wrap(
                          spacing: AppDimens.margin8,
                          runSpacing: AppDimens.margin8,
                          children: controller.statusOptions.map((status) {
                            final isSelected = controller.selectedStatuses.contains(status);
                            return FilterChip(
                              label: Text(status == 'all' ? 'All Status' : status.capitalize ?? status),
                              selected: isSelected,
                              onSelected: (_) => controller.toggleStatus(status),
                              selectedColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                              checkmarkColor: Colors.white,
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                }),
                const SizedBox(height: AppDimens.margin24),
                Obx(() => PrimaryButton(
                  text: controller.isGenerating ? 'Generating...' : 'Generate Report',
                  onPressed: controller.generateReport,
                  isLoading: controller.isGenerating,
                  icon: Icons.file_download_rounded,
                )),
                const SizedBox(height: AppDimens.margin16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(
      BuildContext context, {
        required String label,
        required DateTime? date,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.padding12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey800 : AppColors.grey50,
          borderRadius: BorderRadius.circular(AppDimens.radius8),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppDimens.margin4),
            Text(
              date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Select',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: AppFonts.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStart}) async {
    final initialDate = isStart
        ? (controller.startDate ?? DateTime.now().subtract(const Duration(days: 30)))
        : (controller.endDate ?? DateTime.now());

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryGreenLight
                  : AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      if (isStart) {
        controller.setDateRange(DateTimeRange(
          start: date,
          end: controller.endDate ?? DateTime.now(),
        ));
      } else {
        controller.setDateRange(DateTimeRange(
          start: controller.startDate ?? DateTime.now().subtract(const Duration(days: 30)),
          end: date,
        ));
      }
    }
  }

  void _showDeleteDialog(String reportId) async {
    final confirmed = await AdminConfirmationDialog.show(
      title: 'Delete Report',
      message: 'Are you sure you want to delete this report?',
      confirmText: 'Delete',
    );

    if (confirmed) {
      await controller.deleteReport(reportId);
    }
  }

  Color _getReportColor(String type) {
    switch (type) {
      case 'revenue': return Colors.green;
      case 'trips': return Colors.blue;
      case 'bookings': return Colors.purple;
      case 'cargo': return Colors.orange;
      case 'users': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getReportIcon(String type) {
    switch (type) {
      case 'revenue': return Icons.attach_money_rounded;
      case 'trips': return Icons.directions_bus_rounded;
      case 'bookings': return Icons.confirmation_number_rounded;
      case 'cargo': return Icons.inventory_2_rounded;
      case 'users': return Icons.people_rounded;
      default: return Icons.description_rounded;
    }
  }
}