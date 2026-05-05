// lib/modules/passenger/views/cargo/cargo_registration_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/widgets/inputs/phone_field.dart';
import 'package:menahariya/modules/passenger/controllers/cargo_controller.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/trip/trip_model.dart';
import 'cargo_trip_select_view.dart';

class CargoRegistrationView extends GetView<PassengerCargoController> {
  const CargoRegistrationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Cargo'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stepper(
          type: StepperType.horizontal,
          currentStep: controller.currentStep,
          onStepContinue: controller.nextStep,
          onStepCancel: controller.previousStep,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.padding16),
              child: Row(
                children: [
                  if (details.currentStep > 0)
                    Expanded(
                      child: SecondaryButton(
                        text: 'Back',
                        onPressed: details.onStepCancel,
                      ),
                    ),
                  if (details.currentStep > 0) const SizedBox(width: AppDimens.margin12),
                  Expanded(
                    child: PrimaryButton(
                      text: details.currentStep == 2 ? 'Register Cargo' : 'Continue',
                      onPressed: details.currentStep == 2
                          ? controller.registerCargo
                          : details.onStepContinue,
                      isDisabled: !controller.canProceed,
                      isLoading: details.currentStep == 2 && controller.isLoading,
                    ),
                  ),
                  SizedBox(height: 100,)
                ],
              ),
            );
          },
          steps: [
            // Step 1: Sender & Receiver Details
            Step(
              title: const Text('Contacts'),
              content: _buildContactDetails(context),
              isActive: controller.currentStep >= 0,
              state: controller.currentStep > 0 ? StepState.complete : StepState.indexed,
            ),

            // Step 2: Cargo Details
            Step(
              title: const Text('Cargo'),
              content: _buildCargoDetails(context),
              isActive: controller.currentStep >= 1,
              state: controller.currentStep > 1 ? StepState.complete : StepState.indexed,
            ),

            // Step 3: Review & Confirm
            Step(
              title: const Text('Review'),
              content: _buildReview(context),
              isActive: controller.currentStep >= 2,
              state: controller.currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildContactDetails(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sender Information
        Text(
          'Sender Information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: AppDimens.margin12),

        CustomTextField(
          label: 'Sender Name',
          controller: controller.senderNameController,
          prefixIcon: Icons.person_rounded,
        ),
        const SizedBox(height: AppDimens.margin12),

        PhoneField(
          controller: controller.senderPhoneController,
          label: 'Sender Phone',
        ),

        const SizedBox(height: AppDimens.margin24),

        // Receiver Information
        Text(
          'Receiver Information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: AppDimens.margin12),

        CustomTextField(
          label: 'Receiver Name',
          controller: controller.receiverNameController,
          prefixIcon: Icons.person_rounded,
        ),
        const SizedBox(height: AppDimens.margin12),

        PhoneField(
          controller: controller.receiverPhoneController,
          label: 'Receiver Phone',
        ),

        const SizedBox(height: AppDimens.margin16),

        // Trip Selection (you can add a trip selection field here)
        GestureDetector(
          onTap: () => _selectTrip(context),
          child: Container(
            padding: const EdgeInsets.all(AppDimens.padding16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : AppColors.grey50,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_bus_rounded,
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
                const SizedBox(width: AppDimens.margin12),
                Expanded(
                  child: Obx(() {
                    if (controller.selectedTrip == null) {
                      return Text(
                        'Select Trip',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.selectedTrip!.origin} → ${controller.selectedTrip!.destination}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: AppFonts.medium,
                          ),
                        ),
                        Text(
                          'Departure: ${controller.selectedTrip!.departureTime.toString().substring(0, 16)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    );
                  }),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCargoDetails(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cargo Type Selection
        Text(
          'Cargo Type',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: AppFonts.medium,
          ),
        ),
        const SizedBox(height: AppDimens.margin8),

        Obx(() => Wrap(
          spacing: AppDimens.margin8,
          runSpacing: AppDimens.margin8,
          children: controller.cargoTypes.map((type) {
            final isSelected = controller.selectedCargoType?.id == type.id;
            return ChoiceChip(
              label: Text(type.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) controller.setCargoType(type);
              },
              selectedColor: isDark ? AppColors.primaryGreen.withOpacity(0.3) : AppColors.primaryGreen.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected
                    ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                    : null,
              ),
            );
          }).toList(),
        )),

        const SizedBox(height: AppDimens.margin20),

        // Weight & Dimensions
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Weight (kg)',
                controller: controller.weightController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.monitor_weight_rounded,
                onChanged: (_) => controller.calculateExactFee(),
              ),
            ),
            const SizedBox(width: AppDimens.margin12),
            Expanded(
              child: CustomTextField(
                label: 'Dimensions',
                controller: controller.dimensionsController,
                hint: 'LxWxH (cm)',
                prefixIcon: Icons.straighten_rounded,
                onChanged: (_) => controller.calculateExactFee(),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimens.margin16),

        // Special Handling Options
        Text(
          'Special Handling',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: AppFonts.medium,
          ),
        ),
        const SizedBox(height: AppDimens.margin8),

        Obx(() => Column(
          children: [
            _buildCheckboxTile(
              context,
              title: 'Fragile',
              subtitle: 'Handle with care (+20%)',
              value: controller.isFragile.obs,
              onChanged: controller.toggleFragile,
            ),
            _buildCheckboxTile(
              context,
              title: 'Perishable',
              subtitle: 'Requires quick delivery (+15%)',
              value: controller.isPerishable.obs,
              onChanged: controller.togglePerishable,
            ),
            _buildCheckboxTile(
              context,
              title: 'Refrigeration',
              subtitle: 'Temperature controlled (+25%)',
              value: controller.needsRefrigeration.obs,
              onChanged: controller.toggleRefrigeration,
            ),
          ],
        )),

        const SizedBox(height: AppDimens.margin16),

        // Description
        CustomTextField(
          label: 'Description (Optional)',
          controller: controller.descriptionController,
          maxLines: 3,
          hint: 'Describe the cargo contents',
        ),

        const SizedBox(height: AppDimens.margin16),

        // Declared Value
        CustomTextField(
          label: 'Declared Value (Optional)',
          controller: controller.declaredValueController,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.attach_money_rounded,
          hint: 'For insurance purposes',
        ),

        const SizedBox(height: AppDimens.margin20),

        // Estimated Fee
        Obx(() {
          if (controller.estimatedFee == 0) return const SizedBox();

          return Container(
            padding: const EdgeInsets.all(AppDimens.padding16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : AppColors.grey50,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
              border: Border.all(
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calculate_rounded,
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
                const SizedBox(width: AppDimens.margin12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated Fee',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        controller.formattedEstimatedFee,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.isCalculating)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReview(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sender Info
        _buildReviewSection(
          context,
          title: 'Sender',
          icon: Icons.person_rounded,
          content: [
            'Name: ${controller.senderNameController.text}',
            'Phone: ${controller.senderPhoneController.text}',
          ],
        ),

        const SizedBox(height: AppDimens.margin16),

        // Receiver Info
        _buildReviewSection(
          context,
          title: 'Receiver',
          icon: Icons.person_rounded,
          content: [
            'Name: ${controller.receiverNameController.text}',
            'Phone: ${controller.receiverPhoneController.text}',
          ],
        ),

        const SizedBox(height: AppDimens.margin16),

        // Cargo Details
        _buildReviewSection(
          context,
          title: 'Cargo Details',
          icon: Icons.inventory_2_rounded,
          content: [
            'Type: ${controller.selectedCargoType?.name ?? ''}',
            'Weight: ${controller.weightController.text} kg',
            if (controller.dimensionsController.text.isNotEmpty)
              'Dimensions: ${controller.dimensionsController.text}',
            if (controller.isFragile) '• Fragile (+20%)',
            if (controller.isPerishable) '• Perishable (+15%)',
            if (controller.needsRefrigeration) '• Refrigerated (+25%)',
          ],
        ),

        const SizedBox(height: AppDimens.margin16),

        // Trip Info
        _buildReviewSection(
          context,
          title: 'Trip Details',
          icon: Icons.directions_bus_rounded,
          content: [
            'Route: ${controller.selectedTrip?.origin} → ${controller.selectedTrip?.destination}',
            'Departure: ${controller.selectedTrip?.departureTime.toString().substring(0, 16)}',
          ],
        ),

        const SizedBox(height: AppDimens.margin24),

        // Total Fee
        Container(
          padding: const EdgeInsets.all(AppDimens.padding16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Fee',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.bold,
                ),
              ),
              Text(
                controller.formattedEstimatedFee,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  fontWeight: AppFonts.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required RxBool value,
        required Function(bool?) onChanged,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.margin8),
      child: Row(
        children: [
          Obx(() => Checkbox(
            value: value.value,
            onChanged: onChanged,
            activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          )),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<String> content,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
              const SizedBox(width: AppDimens.margin8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.margin8),
          ...content.map((line) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.padding4),
            child: Text(
              line,
              style: theme.textTheme.bodyMedium,
            ),
          )),
        ],
      ),
    );
  }



  void _selectTrip(BuildContext context) async {
    // Hide keyboard before navigation
    FocusScope.of(context).unfocus();

    // Use Navigator.push instead of Get.toNamed for better result handling
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CargoTripSelectView(),
      ),
    );

    print('🔙 Returned from trip selection with result: $result');

    if (result != null && result is TripModel) {
      controller.setSelectedTrip(result);
      print('✅ Trip received back: ${result.origin} → ${result.destination}');

      // Show confirmation
      Get.snackbar(
        'Trip Selected',
        '${result.origin} → ${result.destination}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        colorText: Colors.white,
      );
    } else {
      print('❌ No trip selected or invalid result');
    }
  }
}