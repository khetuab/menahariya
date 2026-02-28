// lib/modules/passenger/widgets/trip_filters.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';

class TripFilters extends StatelessWidget {
  final Function(FilterOptions) onApply;
  final VoidCallback onClose;

  const TripFilters({
    Key? key,
    required this.onApply,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimens.radius20),
              topRight: Radius.circular(AppDimens.radius20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: AppDimens.margin8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey700 : AppColors.grey300,
                  borderRadius: BorderRadius.circular(AppDimens.radius2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppDimens.padding16),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                    const SizedBox(width: AppDimens.margin8),
                    Text(
                      'Filter Trips',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Filter Options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  children: [
                    _buildFilterSection(
                      title: 'Price Range',
                      child: Column(
                        children: [
                          RangeSlider(
                            values: const RangeValues(0, 1000),
                            min: 0,
                            max: 2000,
                            divisions: 20,
                            activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                            onChanged: (values) {},
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('ETB 0'),
                              Text('ETB 2000+'),
                            ],
                          ),
                        ],
                      ),
                      context: context,
                    ),

                    const SizedBox(height: AppDimens.margin20),

                    _buildFilterSection(
                      context: context,
                      title: 'Departure Time',
                      child: Wrap(
                        spacing: AppDimens.margin8,
                        runSpacing: AppDimens.margin8,
                        children: [
                          'Early Morning (00-06)',
                          'Morning (06-12)',
                          'Afternoon (12-18)',
                          'Evening (18-24)',
                        ].map((time) {
                          return FilterChip(
                            label: Text(time),
                            selected: false,
                            onSelected: (value) {},
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: AppDimens.margin20),

                    _buildFilterSection(
                      context: context,
                      title: 'Bus Type',
                      child: Wrap(
                        spacing: AppDimens.margin8,
                        runSpacing: AppDimens.margin8,
                        children: [
                          'Standard',
                          'Executive',
                          'VIP',
                          'Luxury',
                        ].map((type) {
                          return FilterChip(
                            label: Text(type),
                            selected: false,
                            onSelected: (value) {},
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: AppDimens.margin20),

                    _buildFilterSection(
                      context: context,
                      title: 'Amenities',
                      child: Wrap(
                        spacing: AppDimens.margin8,
                        runSpacing: AppDimens.margin8,
                        children: [
                          'AC',
                          'WiFi',
                          'USB Charging',
                          'Restroom',
                          'TV',
                          'Snacks',
                        ].map((amenity) {
                          return FilterChip(
                            label: Text(amenity),
                            selected: false,
                            onSelected: (value) {},
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: AppDimens.margin30),
                  ],
                ),
              ),

              // Apply Button
              Container(
                padding: const EdgeInsets.all(AppDimens.padding16),
                child: ElevatedButton(
                  onPressed: () {
                    onApply(FilterOptions());
                    onClose();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                    ),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: AppDimens.margin12),
        child,
      ],
    );
  }
}

class FilterOptions {
  // Add filter properties as needed
  FilterOptions();
}