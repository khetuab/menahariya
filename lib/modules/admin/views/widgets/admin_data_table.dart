// lib/modules/admin/widgets/admin_data_table.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_fonts.dart';

class AdminDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<dynamic>> rows;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final bool useCards; // Use card layout on mobile

  const AdminDataTable({
    Key? key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.useCards = true, // Default to card view on mobile
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Use card layout for mobile screens
    if (useCards && isSmallScreen) {
      return _buildCardView(context);
    }

    // Use table layout for larger screens
    return _buildTableView(context);
  }

  Widget _buildTableView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: AppDimens.margin16,
        horizontalMargin: AppDimens.margin12,
        headingRowColor: MaterialStateProperty.all(
          isDark ? AppColors.grey800 : AppColors.grey50,
        ),
        headingTextStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: AppFonts.semiBold,
        ),
        dataTextStyle: theme.textTheme.bodyMedium,
        columns: columns.map((column) {
          return DataColumn(
            label: Text(column),
          );
        }).toList(),
        rows: [
          ...rows.map((row) {
            return DataRow(
              cells: row.asMap().entries.map((entry) {
                return DataCell(
                  entry.value is Widget
                      ? entry.value
                      : Text(entry.value.toString()),
                );
              }).toList(),
            );
          }).toList(),
          if (hasMore)
            DataRow(
              cells: [
                DataCell(
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.padding16),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : TextButton(
                        onPressed: onLoadMore,
                        child: const Text('Load More'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCardView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (rows.isEmpty && !isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding32),
          child: Text(
            'No data available',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.padding12),
      itemCount: rows.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == rows.length) {
          return Padding(
            padding: const EdgeInsets.all(AppDimens.padding16),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : TextButton(
                onPressed: onLoadMore,
                child: const Text('Load More'),
              ),
            ),
          );
        }

        final row = rows[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimens.margin12),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.padding12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(columns.length, (colIndex) {
                final value = row[colIndex];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.padding8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          '${columns[colIndex]}:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: AppFonts.semiBold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: value is Widget
                            ? value
                            : Text(
                          value.toString(),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}