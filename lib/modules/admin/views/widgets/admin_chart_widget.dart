// lib/modules/admin/widgets/admin_chart_widget.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';

class AdminChartWidget extends StatelessWidget {
  final List<String> labels;
  final List<double> revenue;
  final List<double> expenses;
  final List<double> profit;

  const AdminChartWidget({
    Key? key,
    required this.labels,
    required this.revenue,
    required this.expenses,
    required this.profit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SizedBox(
      height: 300,
      child: Column(
        children: [
          // Legend - Wrap on small screens
          Wrap(
            spacing: AppDimens.margin16,
            runSpacing: AppDimens.margin8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('Revenue', Colors.green),
              _buildLegendItem('Expenses', Colors.red),
              _buildLegendItem('Profit', Colors.blue),
            ],
          ),
          const SizedBox(height: AppDimens.margin16),

          // Chart - Make it scrollable horizontally on small screens
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: isSmallScreen ? Axis.horizontal : Axis.vertical,
              child: SizedBox(
                width: isSmallScreen ? screenWidth * 1.5 : double.infinity,
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxValue(),
                    barGroups: _getBarGroups(),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        left: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
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
                                  angle: isSmallScreen ? -0.5 : 0,
                                  child: Text(
                                    labels[index],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: isSmallScreen ? 10 : 12,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: isSmallScreen ? 60 : 40,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}K',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
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
                          return BarTooltipItem(
                            '${rod.toY.toInt()}K\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: _getLabelForRod(rodIndex),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    final theme = Theme.of(Get.context!);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimens.margin4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  List<BarChartGroupData> _getBarGroups() {
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

  double _getMaxValue() {
    double max = 0;
    for (int i = 0; i < revenue.length; i++) {
      max = revenue[i] > max ? revenue[i] : max;
      max = expenses[i] > max ? expenses[i] : max;
      max = profit[i] > max ? profit[i] : max;
    }
    return (max / 1000) + 10;
  }

  String _getLabelForRod(int index) {
    switch (index) {
      case 0: return 'Revenue';
      case 1: return 'Expenses';
      case 2: return 'Profit';
      default: return '';
    }
  }
}