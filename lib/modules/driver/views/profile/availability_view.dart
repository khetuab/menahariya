// lib/modules/driver/views/profile/availability_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/modules/driver/controllers/profile_controller.dart';

class AvailabilityView extends GetView<DriverProfileController> {
  const AvailabilityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Settings'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Status Card
              _buildCurrentStatusCard(context),

              const SizedBox(height: AppDimens.margin24),

              // Working Hours Section
              _buildWorkingHoursSection(context),

              const SizedBox(height: AppDimens.margin24),

              // Trip Preferences Section
              _buildTripPreferencesSection(context),

              const SizedBox(height: AppDimens.margin24),

              // Rest Days Section
              _buildRestDaysSection(context),

              const SizedBox(height: AppDimens.margin24),

              // Save Button
              PrimaryButton(
                text: 'Save Availability Settings',
                onPressed: _saveAvailabilitySettings,
                icon: Icons.save_rounded,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
            isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Status',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: controller.isOnline
                      ? Colors.green
                      : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimens.margin8),
              Text(
                controller.isOnline ? 'You are online' : 'You are offline',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              const Spacer(),
              Switch(
                value: controller.isOnline,
                onChanged: controller.toggleDriverStatus,
                activeColor: Colors.white,
                activeTrackColor: Colors.green,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.red,
              ),
            ],
          ),
          if (!controller.isOnline)
            Padding(
              padding: const EdgeInsets.only(top: AppDimens.margin8),
              child: Text(
                'You will not receive new trip assignments while offline',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            const SizedBox(width: AppDimens.margin8),
            Text(
              'Working Hours',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.margin16),

        // Monday - Friday
        _buildTimeRangeTile(
          context,
          day: 'Monday - Friday',
          startTime: '08:00',
          endTime: '18:00',
        ),

        const SizedBox(height: AppDimens.margin8),

        // Saturday
        _buildTimeRangeTile(
          context,
          day: 'Saturday',
          startTime: '09:00',
          endTime: '16:00',
        ),

        const SizedBox(height: AppDimens.margin8),

        // Sunday
        _buildTimeRangeTile(
          context,
          day: 'Sunday',
          startTime: 'Closed',
          endTime: 'Closed',
          isClosed: true,
        ),

        const SizedBox(height: AppDimens.margin8),

        // Custom Hours Button
        OutlinedButton.icon(
          onPressed : ()=> _showAddCustomHoursDialog(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Custom Hours'),
          style: OutlinedButton.styleFrom(
            foregroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            side: BorderSide(
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeTile(
      BuildContext context, {
        required String day,
        required String startTime,
        required String endTime,
        bool isClosed = false,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: AppFonts.medium,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isClosed ? null : () => _selectTime(context, day, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.padding8,
                        vertical: AppDimens.padding6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey700 : Colors.white,
                        borderRadius: BorderRadius.circular(AppDimens.radius4),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Text(
                        startTime,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isClosed
                              ? (isDark ? AppColors.textHintDark : AppColors.textHintLight)
                              : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding4),
                  child: Text(
                    'to',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: isClosed ? null : () => _selectTime(context, day, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.padding8,
                        vertical: AppDimens.padding6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey700 : Colors.white,
                        borderRadius: BorderRadius.circular(AppDimens.radius4),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Text(
                        endTime,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isClosed
                              ? (isDark ? AppColors.textHintDark : AppColors.textHintLight)
                              : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isClosed)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () => _showRemoveTimeDialog(day),
              color: isDark ? AppColors.errorLight : AppColors.error,
            ),
        ],
      ),
    );
  }

  Widget _buildTripPreferencesSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.route_rounded,
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            const SizedBox(width: AppDimens.margin8),
            Text(
              'Trip Preferences',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.margin16),

        // Auto-accept trips
        Obx(() => Container(
          padding: const EdgeInsets.all(AppDimens.padding12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-accept trips',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                    Text(
                      'Automatically accept assigned trips within your preferences',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: controller.autoAcceptTrips,
                onChanged: controller.toggleAutoAcceptTrips,
                activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
            ],
          ),
        )),

        const SizedBox(height: AppDimens.margin12),

        // Maximum trip distance
        Obx(() => Container(
          padding: const EdgeInsets.all(AppDimens.padding12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Maximum trip distance',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppFonts.semiBold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.padding8,
                      vertical: AppDimens.padding4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radius4),
                    ),
                    child: Text(
                      '${controller.maxTripDistance} km',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin8),
              Slider(
                value: controller.maxTripDistance.toDouble(),
                min: 10,
                max: 500,
                divisions: 49,
                activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                inactiveColor: isDark ? AppColors.grey700 : AppColors.grey300,
                onChanged: (value) {
                  controller.setMaxTripDistance(value.round());
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '10 km',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '500 km',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        )),

        const SizedBox(height: AppDimens.margin12),

        // Preferred trip types
        Container(
          padding: const EdgeInsets.all(AppDimens.padding12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preferred trip types',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              const SizedBox(height: AppDimens.margin8),
              Wrap(
                spacing: AppDimens.margin8,
                runSpacing: AppDimens.margin8,
                children: [
                  _buildPreferenceChip(context, 'Standard', true),
                  _buildPreferenceChip(context, 'Executive', false),
                  _buildPreferenceChip(context, 'VIP', true),
                  _buildPreferenceChip(context, 'Luxury', false),
                  _buildPreferenceChip(context, 'Night trips', true),
                  _buildPreferenceChip(context, 'Long distance', false),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceChip(BuildContext context, String label, bool isSelected) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // Toggle preference
      },
      selectedColor: isDark ? AppColors.primaryGreen.withOpacity(0.3) : AppColors.primaryGreen.withOpacity(0.1),
      checkmarkColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
    );
  }

  Widget _buildRestDaysSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.weekend_rounded,
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
            const SizedBox(width: AppDimens.margin8),
            Text(
              'Rest Days',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppFonts.semiBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.margin16),

        Container(
          padding: const EdgeInsets.all(AppDimens.padding12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
          child: Column(
            children: [
              _buildRestDayTile(context, 'Monday', false),
              _buildRestDayTile(context, 'Tuesday', false),
              _buildRestDayTile(context, 'Wednesday', true),
              _buildRestDayTile(context, 'Thursday', false),
              _buildRestDayTile(context, 'Friday', false),
              _buildRestDayTile(context, 'Saturday', false),
              _buildRestDayTile(context, 'Sunday', true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestDayTile(BuildContext context, String day, bool isRestDay) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Switch(
            value: isRestDay,
            onChanged: (value) {
              // Toggle rest day
            },
            activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, String day, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Update the time
      Get.snackbar(
        'Time Updated',
        '$day ${isStart ? 'start' : 'end'} time set to ${picked.format(context)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showAddCustomHoursDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Add Custom Hours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Day',
                border: OutlineInputBorder(),
              ),
              items: [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
              ]
                  .map((day) => DropdownMenuItem(
                value: day,
                child: Text(day),
              ))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: AppDimens.margin12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(context, '', true),
                  ),
                ),
                const SizedBox(width: AppDimens.margin8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(context, '', false),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Custom hours added',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  void _showRemoveTimeDialog(String day) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Time'),
        content: Text('Are you sure you want to remove working hours for $day?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Removed',
                'Working hours removed for $day',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _saveAvailabilitySettings() {
    Get.back();
    Get.snackbar(
      'Success',
      'Availability settings saved successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}