// lib/modules/admin/views/admin_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_activity_tile.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_empty_state.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_sidebar.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_stats_card.dart';
import '../../../config/environment/env_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/loading/shimmer_loading.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authController = Get.find<AuthController>();

    return Scaffold(
      drawer: const AdminDrawer(currentIndex: 0),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshDashboard,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return _buildLoadingShimmer();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshDashboard();
          },
          child: CustomScrollView(
            slivers: [
              // Welcome Header Sliver
              SliverToBoxAdapter(
                child: Obx(
                      () => _buildWelcomeHeader(context, authController),
                ),
              ),
              // Stats Grid Sliver
              SliverPadding(
                padding: const EdgeInsets.all(AppDimens.padding16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimens.margin12,
                    mainAxisSpacing: AppDimens.margin12,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildStatsCard(context, index),
                    childCount: 8,
                  ),
                ),
              ),
              // Revenue Chart Sliver
              SliverToBoxAdapter(
                child: _buildRevenueChart(context),
              ),
              // Analytics Section Sliver
              SliverToBoxAdapter(
                child: _buildAnalyticsSection(context),
              ),
              // Recent Activities Sliver
              SliverToBoxAdapter(
                child: _buildRecentActivities(context),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimens.padding16),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, AuthController authController) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
            isDark ? AppColors.primaryGreen : AppColors.primaryGreenDark,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimens.radius24),
          bottomRight: Radius.circular(AppDimens.radius24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                backgroundImage: authController.currentUser?.profileImage != null &&
                    authController.currentUser!.profileImage!.isNotEmpty
                    ? NetworkImage(
                    '${EnvConfig.instance.apiBaseUrl.replaceAll('/api', '')}${authController.currentUser!.profileImage}'
                )
                    : null,
                child: authController.currentUser?.profileImage == null ||
                    authController.currentUser!.profileImage!.isEmpty
                    ? Text(
                  authController.currentUser?.fullName?.substring(0, 1).toUpperCase() ?? 'A',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: AppDimens.margin12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      authController.currentUser?.fullName ?? 'Admin',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding12,
                  vertical: AppDimens.padding6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimens.radius20),
                ),
                child: Text(
                  authController.currentUser?.role?.toUpperCase() ?? 'ADMIN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.margin20),
          Row(
            children: [
              _buildWelcomeStat(
                context,
                'Today\'s Revenue',
                'ETB ${controller.stats?.todayRevenue.toStringAsFixed(0) ?? '0'}',
                Icons.today_rounded,
              ),
              const SizedBox(width: AppDimens.margin16),
              _buildWelcomeStat(
                context,
                'Active Trips',
                controller.stats?.activeTrips.toString() ?? '0',
                Icons.directions_bus_rounded,
              ),
              const SizedBox(width: AppDimens.margin16),
              _buildWelcomeStat(
                context,
                'Completion Rate',
                '${controller.stats?.occupancyRate.toStringAsFixed(0) ?? '0'}%',
                Icons.percent_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStat(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.padding8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimens.radius8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, int index) {
    final stats = controller.stats;
    if (stats == null) return const SizedBox();

    final items = [
      {'title': 'Total Revenue', 'value': 'ETB ${stats.totalRevenue.toStringAsFixed(0)}', 'subtitle': '${stats.todayRevenue.toStringAsFixed(0)} today', 'icon': Icons.attach_money_rounded, 'color': Colors.green},
      {'title': 'Total Bookings', 'value': stats.totalBookings.toString(), 'subtitle': '${stats.confirmedBookings} confirmed', 'icon': Icons.confirmation_number_rounded, 'color': Colors.blue},
      {'title': 'Active Trips', 'value': stats.activeTrips.toString(), 'subtitle': '${stats.completedTrips} completed', 'icon': Icons.directions_bus_rounded, 'color': Colors.orange},
      {'title': 'Total Users', 'value': stats.totalUsers.toString(), 'subtitle': '${stats.totalDrivers} drivers', 'icon': Icons.people_rounded, 'color': Colors.purple},
      {'title': 'Cargo', 'value': stats.totalCargo.toString(), 'subtitle': 'shipments', 'icon': Icons.inventory_2_rounded, 'color': Colors.teal},
      {'title': 'Occupancy', 'value': '${stats.occupancyRate.toStringAsFixed(0)}%', 'subtitle': '${stats.availableSeats} seats left', 'icon': Icons.chair_rounded, 'color': Colors.indigo},
      {'title': 'Pending Payments', 'value': stats.pendingPayments.toString(), 'subtitle': 'need attention', 'icon': Icons.pending_actions_rounded, 'color': Colors.red},
      {'title': 'Vehicles', 'value': stats.vehiclesInService.toString(), 'subtitle': '${stats.vehiclesInMaintenance} in maintenance', 'icon': Icons.local_shipping_rounded, 'color': Colors.cyan},
    ];

    final item = items[index];
    return AdminStatsCard(
      title: item['title'].toString(),
      value: item['value'].toString(),
      subtitle: item['subtitle'].toString(),
      icon: item['icon'] as IconData,
      color: item['color'] as Color,
      onTap: () => _navigateToSection(index),
    );
  }

  void _navigateToSection(int index) {
    switch (index) {
      case 0:
        Get.toNamed('/admin/payments');
        break;
      case 1:
        Get.toNamed('/admin/bookings');
        break;
      case 2:
        Get.toNamed('/admin/trips');
        break;
      case 3:
        Get.toNamed('/admin/users');
        break;
      case 4:
        Get.toNamed('/admin/cargo');
        break;
      case 5:
      // Stay on dashboard
        break;
      case 6:
        Get.toNamed('/admin/payments');
        break;
      case 7:
        Get.toNamed('/admin/vehicles');
        break;
    }
  }

  Widget _buildRevenueChart(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final revenueChart = controller.revenueChart;

    return Container(
      margin: const EdgeInsets.all(AppDimens.margin16),
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Revenue Overview ',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                _buildPeriodSelector(),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.margin20),
          SizedBox(
            height: 250,
            child: revenueChart != null && revenueChart.revenue.isNotEmpty
                ? _buildBarChart(
                revenueChart.labels,
                revenueChart.revenue,
                revenueChart.expenses,
                revenueChart.profit
            )
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: AppDimens.margin16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Revenue', Colors.green),
              const SizedBox(width: AppDimens.margin16),
              _buildLegendItem('Expenses', Colors.red),
              const SizedBox(width: AppDimens.margin16),
              _buildLegendItem('Profit', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildPeriodSelector() {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimens.radius30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: DashboardPeriod.values.map((period) {
          final isSelected = controller.selectedPeriod == period;
          return GestureDetector(
            onTap: () => controller.setPeriod(period),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.padding12,
                vertical: AppDimens.padding6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimens.radius20),
              ),
              child: Text(
                period.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? AppFonts.medium : AppFonts.regular,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(List<String> labels, List<dynamic> revenue, List<dynamic> expenses, List<dynamic> profit) {
    final isDark = Get.context!.theme.brightness == Brightness.dark;

    // Handle empty data
    if (labels.isEmpty || revenue.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Convert to double safely
    final List<double> revenueDouble = revenue.map((e) => (e as num).toDouble()).toList();
    final List<double> expensesDouble = expenses.map((e) => (e as num).toDouble()).toList();
    final List<double> profitDouble = profit.map((e) => (e as num).toDouble()).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxY(revenueDouble, expensesDouble, profitDouble),
        barGroups: _buildBarGroups(labels, revenueDouble, expensesDouble, profitDouble),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            left: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppDimens.padding8),
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        labels[index],
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 50,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}K',
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 35,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              strokeWidth: 1,
            );
          },
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String label;
              switch (rodIndex) {
                case 0: label = 'Revenue'; break;
                case 1: label = 'Expenses'; break;
                case 2: label = 'Profit'; break;
                default: label = '';
              }
              return BarTooltipItem(
                '${rod.toY.toInt()}K\n$label',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  double _calculateMaxY(List<double> revenue, List<double> expenses, List<double> profit) {
    if (revenue.isEmpty) return 100;

    double maxValue = 0;

    for (int i = 0; i < revenue.length; i++) {
      maxValue = maxValue > revenue[i] ? maxValue : revenue[i];
      maxValue = maxValue > expenses[i] ? maxValue : expenses[i];
      maxValue = maxValue > profit[i] ? maxValue : profit[i];
    }

    // Add 20% padding and convert to thousands (divide by 1000)
    final result = (maxValue / 1000) * 1.2;
    return result < 10 ? 10 : result; // Ensure minimum value
  }


  List<BarChartGroupData> _buildBarGroups(List<String> labels, List<double> revenue, List<double> expenses, List<double> profit) {
    List<BarChartGroupData> groups = [];

    for (int i = 0; i < labels.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: revenue[i] / 1000,
              color: Colors.green,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: expenses[i] / 1000,
              color: Colors.red,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: profit[i] / 1000,
              color: Colors.blue,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
          barsSpace: 4,
        ),
      );
    }

    return groups;
  }

  double _getMaxValue(List<double> revenue, List<double> expenses, List<double> profit) {
    double max = 0;

    // Safely handle the lists, converting to double if needed
    for (int i = 0; i < revenue.length; i++) {
      final rev = revenue[i].toDouble();
      final exp = expenses[i].toDouble();
      final prof = profit[i].toDouble();

      max = rev > max ? rev : max;
      max = exp > max ? exp : max;
      max = prof > max ? prof : max;
    }

    // If max is 0, return a default value to avoid issues
    if (max == 0) return 100; // Default max value

    return (max / 1000) + 10;
  }

  Widget _buildLegendItem(String label, Color color) {
    final theme = Get.context!.theme;

    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppDimens.margin4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tripAnalytics = controller.tripAnalytics;
    final bookingAnalytics = controller.bookingAnalytics;

    return Container(
      margin: const EdgeInsets.all(AppDimens.margin16),
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Analytics',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin16),
          if (tripAnalytics != null)
            _buildAnalyticsCard(
              context,
              title: 'Trip Performance',
              value: '${tripAnalytics.onTimeRate.toStringAsFixed(0)}%',
              subtitle: 'on-time rate',
              icon: Icons.timer_rounded,
              color: Colors.green,
              extra: '${tripAnalytics.completedTrips}/${tripAnalytics.totalTrips} trips completed',
            ),
          const SizedBox(height: AppDimens.margin12),
          if (bookingAnalytics != null)
            _buildAnalyticsCard(
              context,
              title: 'Booking Value',
              value: 'ETB ${bookingAnalytics.averageBookingValue.toStringAsFixed(0)}',
              subtitle: 'average per booking',
              icon: Icons.trending_up_rounded,
              color: Colors.blue,
              extra: '${bookingAnalytics.totalBookings} total bookings',
            ),
          const SizedBox(height: AppDimens.margin12),
          if (controller.cargoAnalytics != null)
            _buildAnalyticsCard(
              context,
              title: 'Cargo Revenue',
              value: 'ETB ${controller.cargoAnalytics!.totalRevenue.toStringAsFixed(0)}',
              subtitle: 'from ${controller.cargoAnalytics!.totalCargo} shipments',
              icon: Icons.local_shipping_rounded,
              color: Colors.orange,
              extra: '${controller.cargoAnalytics!.totalWeight.toStringAsFixed(0)} kg shipped',
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
      BuildContext context, {
        required String title,
        required String value,
        required String subtitle,
        required IconData icon,
        required Color color,
        String? extra,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppDimens.margin12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppDimens.margin2),
                Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppFonts.bold, color: color)),
                if (extra != null) Text(extra, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text(subtitle, style: theme.textTheme.bodySmall, textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(AppDimens.margin16),
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              // TextButton(
              //   onPressed: () {},
              //   child: const Text('View All'),
              // ),
            ],
          ),
          const SizedBox(height: AppDimens.margin16),
          if (controller.recentActivities.isEmpty)
            AdminEmptyState(
              title: 'No Activities',
              message: 'No recent activities to display',
              icon: Icons.history_rounded,
            )
          else
            ...controller.recentActivities.take(5).map((activity) => AdminActivityTile(activity: activity)),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ShimmerLoading(
            child: Container(
              height: 180,
              margin: const EdgeInsets.all(AppDimens.margin16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.radius16),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimens.margin12,
              mainAxisSpacing: AppDimens.margin12,
              childAspectRatio: 1.5,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) => ShimmerLoading(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                  ),
                ),
              ),
              childCount: 8,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ShimmerLoading(
            child: Container(
              height: 300,
              margin: const EdgeInsets.all(AppDimens.margin16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.radius16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}