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
        actions: [
          Obx(() => controller.isAvailabilitySaving
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadAvailabilitySettings(),
            tooltip: 'Refresh',
          ),
          ),
        ],
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
                isLoading: controller.isAvailabilitySaving,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: controller.isOnline ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (controller.isOnline ? Colors.green : Colors.red).withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )),
              const SizedBox(width: AppDimens.margin8),
              Obx(() => Text(
                controller.isOnline ? 'You are online' : 'You are offline',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: AppFonts.semiBold,
                ),
              )),
              const Spacer(),
              Obx(() => Switch(
                value: controller.isOnline,
                onChanged: controller.toggleDriverStatus, // This now updates centralized state
                activeColor: Colors.white,
                activeTrackColor: Colors.green,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.red,
              )),
            ],
          ),
          Obx(() => !controller.isOnline
              ? Padding(
            padding: const EdgeInsets.only(top: AppDimens.margin8),
            child: Text(
              'You will not receive new trip assignments while offline',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          )
              : const SizedBox.shrink()),
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

        // Regular Working Hours
        Obx(() => Column(
          children: controller.workingHours.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.margin8),
              child: _buildTimeRangeTile(
                context,
                day: entry.key,
                startTime: entry.value.startTime,
                endTime: entry.value.endTime,
                isClosed: entry.value.isClosed,
                isCustom: false,
              ),
            );
          }).toList(),
        )),

        // Custom Working Hours
        Obx(() => controller.customWorkingHours.isNotEmpty
            ? Column(
          children: [
            const Divider(),
            const SizedBox(height: AppDimens.margin8),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
                const SizedBox(width: AppDimens.margin4),
                Text(
                  'Custom Hours',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: AppFonts.medium,
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.margin8),
            ...controller.customWorkingHours.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.margin8),
                child: _buildTimeRangeTile(
                  context,
                  day: entry.key,
                  startTime: entry.value.startTime,
                  endTime: entry.value.endTime,
                  isClosed: entry.value.isClosed,
                  isCustom: true,
                ),
              );
            }).toList(),
          ],
        )
            : const SizedBox.shrink()),

        const SizedBox(height: AppDimens.margin8),

        // Custom Hours Button
        OutlinedButton.icon(
          onPressed: () => _showAddCustomHoursDialog(context),
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
        bool isCustom = false,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        border: isCustom
            ? Border.all(
          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          width: 1,
        )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (isCustom)
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    day,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isCustom ? AppFonts.medium : AppFonts.regular,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isClosed ? null : () => _selectTime(context, day, true, isCustom),
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
                        isClosed ? 'Closed' : startTime,
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
                if (!isClosed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding4),
                    child: Text(
                      'to',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                if (!isClosed)
                  Expanded(
                    child: GestureDetector(
                      onTap: isClosed ? null : () => _selectTime(context, day, false, isCustom),
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
          if (!isClosed || isCustom)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () => _showRemoveTimeDialog(day, isCustom),
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
        Obx(() => Container(
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
                children: controller.preferredTripTypes.entries.map((entry) {
                  return _buildPreferenceChip(context, entry.key, entry.value);
                }).toList(),
              ),
            ],
          ),
        )),
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
        controller.updateTripPreference(label, selected);
      },
      selectedColor: isDark ? AppColors.primaryGreen.withOpacity(0.3) : AppColors.primaryGreen.withOpacity(0.1),
      checkmarkColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
      backgroundColor: isDark ? AppColors.grey700 : Colors.white,
    );
  }

  Widget _buildRestDaysSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

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
          child: Obx(() => Column(
            children: days.map((day) {
              return _buildRestDayTile(context, day, controller.restDays[day] ?? false);
            }).toList(),
          )),
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
              controller.updateRestDay(day, value);
            },
            activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, String day, bool isStart, bool isCustom) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime = picked.format(context);
      String currentStartTime = '';
      String currentEndTime = '';

      if (isCustom) {
        if (controller.customWorkingHours.containsKey(day)) {
          currentStartTime = controller.customWorkingHours[day]!.startTime;
          currentEndTime = controller.customWorkingHours[day]!.endTime;
        }
      } else {
        if (controller.workingHours.containsKey(day)) {
          currentStartTime = controller.workingHours[day]!.startTime;
          currentEndTime = controller.workingHours[day]!.endTime;
        }
      }

      if (isStart) {
        controller.updateWorkingHours(day, formattedTime, currentEndTime);
      } else {
        controller.updateWorkingHours(day, currentStartTime, formattedTime);
      }

      Get.snackbar(
        'Time Updated',
        '$day ${isStart ? 'start' : 'end'} time set to $formattedTime',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void _showAddCustomHoursDialog(BuildContext context) {
    String selectedDay = 'Monday';
    String selectedStartTime = '09:00';
    String selectedEndTime = '17:00';

    Get.dialog(
      AlertDialog(
        title: const Text('Add Custom Hours'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Day',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedDay,
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
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedDay = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppDimens.margin12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        controller: TextEditingController(text: selectedStartTime),
                        readOnly: true,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              selectedStartTime = time.format(context);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin8),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        controller: TextEditingController(text: selectedEndTime),
                        readOnly: true,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              selectedEndTime = time.format(context);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin8),
                if (controller.workingHours.containsKey(selectedDay) ||
                    controller.customWorkingHours.containsKey(selectedDay))
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This day already has working hours. Adding custom hours will override them.',
                            style: TextStyle(fontSize: 12, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addCustomWorkingHours(selectedDay, selectedStartTime, selectedEndTime);
              Get.back();
              Get.snackbar(
                'Success',
                'Custom hours added for $selectedDay',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
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

  void _showRemoveTimeDialog(String day, bool isCustom) {
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
              if (isCustom) {
                controller.removeCustomWorkingHours(day);
              } else {
                // For default hours, mark as closed instead of removing
                controller.updateWorkingHours(day, '00:00', '00:00');
              }
              Get.back();
              Get.snackbar(
                'Removed',
                'Working hours removed for $day',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
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

  void _saveAvailabilitySettings() async {
    final success = await controller.saveAvailabilitySettings();
    if (success) {
      // Optionally navigate back
      Get.back();
    }
  }
}