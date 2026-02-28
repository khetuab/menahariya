// lib/core/widgets/bottom_sheets/filter_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterOptions initialOptions;
  final Function(FilterOptions) onApply;

  const FilterBottomSheet({
    Key? key,
    required this.initialOptions,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterOptions _options;
  final RangeValues _priceRange = const RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    _options = widget.initialOptions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radius20),
          topRight: Radius.circular(AppDimens.radius20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
                const SizedBox(width: AppDimens.margin12),
                Expanded(
                  child: Text(
                    'Filter Trips',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: AppFonts.semiBold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  Text(
                    'Price Range',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                  const SizedBox(height: AppDimens.margin8),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    inactiveColor: isDark ? AppColors.grey700 : AppColors.grey300,
                    labels: RangeLabels(
                      'ETB ${_priceRange.start.round()}',
                      'ETB ${_priceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _options.priceRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ETB ${_priceRange.start.round()}',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        'ETB ${_priceRange.end.round()}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.margin20),

                  // Departure Time
                  Text(
                    'Departure Time',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                  const SizedBox(height: AppDimens.margin12),
                  Wrap(
                    spacing: AppDimens.margin8,
                    runSpacing: AppDimens.margin8,
                    children: [
                      _buildTimeChip('Early Morning', '00:00 - 06:00'),
                      _buildTimeChip('Morning', '06:00 - 12:00'),
                      _buildTimeChip('Afternoon', '12:00 - 18:00'),
                      _buildTimeChip('Evening', '18:00 - 00:00'),
                    ],
                  ),

                  const SizedBox(height: AppDimens.margin20),

                  // Bus Type
                  Text(
                    'Bus Type',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                  const SizedBox(height: AppDimens.margin12),
                  Wrap(
                    spacing: AppDimens.margin8,
                    runSpacing: AppDimens.margin8,
                    children: [
                      _buildFilterChip('Standard'),
                      _buildFilterChip('Executive'),
                      _buildFilterChip('VIP'),
                      _buildFilterChip('Luxury'),
                    ],
                  ),

                  const SizedBox(height: AppDimens.margin20),

                  // Amenities
                  Text(
                    'Amenities',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                  const SizedBox(height: AppDimens.margin12),
                  Wrap(
                    spacing: AppDimens.margin8,
                    runSpacing: AppDimens.margin8,
                    children: [
                      _buildAmenityChip('AC', Icons.ac_unit_rounded),
                      _buildAmenityChip('WiFi', Icons.wifi_rounded),
                      _buildAmenityChip('USB', Icons.usb_rounded),
                      _buildAmenityChip('Restroom', Icons.wc_rounded),
                      _buildAmenityChip('TV', Icons.tv_rounded),
                      _buildAmenityChip('Snacks', Icons.fastfood_rounded),
                    ],
                  ),

                  const SizedBox(height: AppDimens.margin20),

                  // Sort By
                  Text(
                    'Sort By',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                  const SizedBox(height: AppDimens.margin12),
                  _buildSortOption('Price: Low to High', Icons.attach_money),
                  _buildSortOption('Price: High to Low', Icons.attach_money),
                  _buildSortOption('Earliest Departure', Icons.access_time_rounded),
                  _buildSortOption('Latest Departure', Icons.access_time_rounded),
                  _buildSortOption('Duration: Shortest', Icons.timer_rounded),
                  _buildSortOption('Duration: Longest', Icons.timer_rounded),

                  const SizedBox(height: AppDimens.margin30),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(AppDimens.padding20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Cancel',
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: AppDimens.margin12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Apply Filters',
                    onPressed: () {
                      widget.onApply(_options);
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String label, String time) {
    return FilterChip(
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(time, style: const TextStyle(fontSize: 10)),
        ],
      ),
      selected: _options.selectedTimes.contains(label),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _options.selectedTimes.add(label);
          } else {
            _options.selectedTimes.remove(label);
          }
        });
      },
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _options.selectedBusTypes.contains(label),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _options.selectedBusTypes.add(label);
          } else {
            _options.selectedBusTypes.remove(label);
          }
        });
      },
    );
  }

  Widget _buildAmenityChip(String label, IconData icon) {
    return FilterChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      selected: _options.selectedAmenities.contains(label),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _options.selectedAmenities.add(label);
          } else {
            _options.selectedAmenities.remove(label);
          }
        });
      },
    );
  }

  Widget _buildSortOption(String label, IconData icon) {
    final isSelected = _options.sortBy == label;

    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppDimens.margin8),
          Text(label),
        ],
      ),
      value: label,
      groupValue: _options.sortBy,
      onChanged: (value) {
        setState(() {
          _options.sortBy = value;
        });
      },
      activeColor: Theme.of(context).primaryColor,
      dense: true,
    );
  }

  void _resetFilters() {
    setState(() {
      _options = FilterOptions();
    });
  }
}

class FilterOptions {
  RangeValues priceRange;
  List<String> selectedTimes;
  List<String> selectedBusTypes;
  List<String> selectedAmenities;
  String? sortBy;

  FilterOptions({
    this.priceRange = const RangeValues(0, 1000),
    this.selectedTimes = const [],
    this.selectedBusTypes = const [],
    this.selectedAmenities = const [],
    this.sortBy,
  });

  FilterOptions copyWith({
    RangeValues? priceRange,
    List<String>? selectedTimes,
    List<String>? selectedBusTypes,
    List<String>? selectedAmenities,
    String? sortBy,
  }) {
    return FilterOptions(
      priceRange: priceRange ?? this.priceRange,
      selectedTimes: selectedTimes ?? this.selectedTimes,
      selectedBusTypes: selectedBusTypes ?? this.selectedBusTypes,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}