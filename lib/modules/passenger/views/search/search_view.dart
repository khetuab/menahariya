// lib/modules/passenger/views/search/search_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/widgets/buttons/icon_button_widget.dart';
import 'package:menahariya/modules/passenger/controllers/search_controller.dart' as search;
import 'package:menahariya/core/utils/formatters/date_formatter.dart';

class PassengerSearchView extends GetView<search.PassengerSearchController> {
  const PassengerSearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Trips'),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // From Field
              CustomTextField(
                label: 'From',
                controller: controller.fromController,
                focusNode: controller.fromFocusNode,
                onChanged: controller.getSuggestions,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.trip_origin_rounded,
                suffixIcon: Icons.location_on_rounded,
              ),

              const SizedBox(height: AppDimens.margin8),

              // Swap Button
              Align(
                alignment: Alignment.centerRight,
                child: IconButtonWidget(
                  icon: Icons.swap_vert_rounded,
                  onPressed: controller.swapLocations,
                  backgroundColor: isDark ? AppColors.grey800 : AppColors.grey100,
                  iconColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
              ),

              const SizedBox(height: AppDimens.margin8),

              // To Field
              CustomTextField(
                label: 'To',
                controller: controller.toController,
                focusNode: controller.toFocusNode,
                onChanged: controller.getSuggestions,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.location_on_rounded,
              ),

              const SizedBox(height: AppDimens.margin16),

              // Date Selection
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          label: 'Departure',
                          controller: controller.dateController,
                          focusNode: controller.dateFocusNode,
                          prefixIcon: Icons.calendar_today_rounded,
                          readOnly: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.margin12),
                  // Round Trip Toggle
                  Obx(() => ChoiceChip(
                    label: const Text('Round Trip'),
                    selected: controller.isRoundTrip,
                    onSelected: controller.toggleRoundTrip,
                    selectedColor: isDark ? AppColors.primaryGreen.withOpacity(0.3) : AppColors.primaryGreen.withOpacity(0.1),
                  )),
                ],
              ),

              const SizedBox(height: AppDimens.margin16),

              // Return Date (if round trip)
              Obx(() {
                if (!controller.isRoundTrip) return const SizedBox();
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => _selectReturnDate(context),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          label: 'Return',
                          controller: TextEditingController(
                            text: controller.returnDate != null
                                ? DateFormatter.toCompactDate(controller.returnDate!)
                                : '',
                          ),
                          prefixIcon: Icons.calendar_today_rounded,
                          readOnly: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.margin16),
                  ],
                );
              }),

              // Passengers
              Obx(() => Container(
                padding: const EdgeInsets.all(AppDimens.padding12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey800 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_rounded),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Passengers',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            '${controller.passengerCount} passenger${controller.passengerCount > 1 ? 's' : ''}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: controller.decrementPassengers,
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: controller.incrementPassengers,
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                        ),
                      ],
                    ),
                  ],
                ),
              )),

              const SizedBox(height: AppDimens.margin24),

              // Search Button
              Obx(() => PrimaryButton(
                text: 'Search Trips',
                onPressed: controller.isValidSearch ? _performSearch : null,
                isDisabled: !controller.isValidSearch,
                icon: Icons.search_rounded,
              )),

              const SizedBox(height: AppDimens.margin24),

              // Suggestions
              Obx(() {
                if (controller.suggestions.isEmpty) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggestions',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                    const SizedBox(height: AppDimens.margin12),
                    ...controller.suggestions.map((suggestion) {
                      return ListTile(
                        leading: const Icon(Icons.location_on_rounded),
                        title: Text(suggestion),
                        onTap: () {
                          if (controller.fromFocusNode.hasFocus) {
                            controller.fromController.text = suggestion;
                          } else if (controller.toFocusNode.hasFocus) {
                            controller.toController.text = suggestion;
                          }
                          controller.suggestions.clear();
                        },
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      controller.setDate(picked);
    }
  }

  Future<void> _selectReturnDate(BuildContext context) async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.returnDate ?? controller.selectedDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 2)),
      firstDate: controller.selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      controller.setReturnDate(picked);
    }
  }

  void _performSearch() {
    FocusScope.of(Get.context!).unfocus();
    controller.searchTrips();
    Get.toNamed('/passenger/search/results');
  }
}