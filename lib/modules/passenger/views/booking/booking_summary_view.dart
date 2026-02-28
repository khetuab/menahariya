// lib/modules/passenger/views/booking/booking_summary_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/modules/passenger/controllers/booking_controller.dart';

import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../data/models/ticket/booking_request.dart';

class BookingSummaryView extends GetView<PassengerBookingController> {
  const BookingSummaryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Summary'),
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
                      text: details.currentStep == 2 ? 'Confirm Booking' : 'Continue',
                      onPressed: details.onStepContinue,
                      isDisabled: !controller.canProceedToPayment,
                    ),
                  ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: Passenger Details
            Step(
              title: const Text('Passenger Details'),
              content: _buildPassengerDetails(context),
              isActive: controller.currentStep >= 0,
              state: controller.currentStep > 0 ? StepState.complete : StepState.indexed,
            ),

            // Step 2: Additional Services
            Step(
              title: const Text('Additional Services'),
              content: _buildAdditionalServices(context),
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

  Widget _buildPassengerDetails(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Passenger
        Text(
          'Primary Passenger',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: AppDimens.margin12),

        CustomTextField(
          label: 'Full Name',
          controller: controller.passengerNameController,
          onChanged: (_) {},
          prefixIcon: Icons.person_rounded,
        ),
        const SizedBox(height: AppDimens.margin12),

        CustomTextField(
          label: 'Phone Number',
          controller: controller.passengerPhoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_rounded,
        ),
        const SizedBox(height: AppDimens.margin12),

        CustomTextField(
          label: 'Email (Optional)',
          controller: controller.passengerEmailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_rounded,
        ),

        // Additional Passengers
        if (controller.additionalPassengers.isNotEmpty) ...[
          const SizedBox(height: AppDimens.margin24),
          Text(
            'Additional Passengers',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin12),
          ...List.generate(controller.additionalPassengers.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimens.margin12),
              padding: const EdgeInsets.all(AppDimens.padding12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : AppColors.grey50,
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppDimens.padding4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimens.radius4),
                        ),
                        child: Text(
                          'Seat ${controller.selectedSeats[index + 1].number}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: AppDimens.margin8),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Passenger Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final detail = controller.additionalPassengers[index];
                      controller.updatePassengerDetail(
                        index,
                        PassengerDetail(
                          name: value,
                          phone: detail.phone,
                          email: detail.email,
                          seatNumber: detail.seatNumber,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: AppDimens.margin16),

        // Terms Checkbox
        Row(
          children: [
            Obx(() => Checkbox(
              value: controller.agreeToTerms,
              onChanged: controller.toggleTermsAgreement,
              activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            )),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleTermsAgreement(!controller.agreeToTerms),
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalServices(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Travel Insurance
        Obx(() => Container(
          margin: const EdgeInsets.only(bottom: AppDimens.margin12),
          padding: const EdgeInsets.all(AppDimens.padding12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius8),
            border: Border.all(
              color: controller.insuranceSelected
                  ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Travel Insurance',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                    Text(
                      'Protect your trip with insurance',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(controller.insuranceFee),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  Switch(
                    value: controller.insuranceSelected,
                    onChanged: controller.toggleInsurance,
                    activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  ),
                ],
              ),
            ],
          ),
        )),

        // Meal Preferences (if available)
        if (controller.mealPreferences.isNotEmpty) ...[
          Text(
            'Meal Preferences',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin12),
          Wrap(
            spacing: AppDimens.margin8,
            runSpacing: AppDimens.margin8,
            children: [
              'Vegetarian',
              'Vegan',
              'Halal',
              'Gluten-Free',
            ].map((meal) {
              return Obx(() => FilterChip(
                label: Text(meal),
                selected: controller.mealPreferences.contains(meal),
                onSelected: (selected) => controller.toggleMealPreference(meal, selected),
                selectedColor: isDark ? AppColors.primaryGreen.withOpacity(0.3) : AppColors.primaryGreen.withOpacity(0.1),
                checkmarkColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ));
            }).toList(),
          ),
        ],

        const SizedBox(height: AppDimens.margin16),

        // Special Requests
        CustomTextField(
          label: 'Special Requests (Optional)',
          controller: controller.specialRequestsController,
          maxLines: 3,
          hint: 'Any special requirements?',
        ),
      ],
    );
  }

  Widget _buildReview(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trip Summary
        Container(
          padding: const EdgeInsets.all(AppDimens.padding16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.trip.origin,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                        Text(
                          controller.trip.destination,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.padding8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_bus_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Departure:'),
                  Text(
                    DateFormatter.toDisplayDate(controller.trip.departureTime),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Selected Seats:'),
                  Text(
                    controller.selectedSeats.map((s) => s.number).join(', '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimens.margin16),

        // Price Breakdown
        Container(
          padding: const EdgeInsets.all(AppDimens.padding16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal'),
                  Text(controller.formattedSubtotal),
                ],
              ),
              const SizedBox(height: AppDimens.margin8),
              if (controller.insuranceSelected) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Insurance Fee'),
                    Text(controller.formattedInsurance),
                  ],
                ),
                const SizedBox(height: AppDimens.margin8),
              ],
              if (controller.useWalletBalance) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Wallet Balance'),
                    Text('-${controller.formattedWalletDeduction}'),
                  ],
                ),
                const SizedBox(height: AppDimens.margin8),
              ],
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  Text(
                    controller.formattedFinalTotal,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimens.margin16),

        // Passenger Summary
        Container(
          padding: const EdgeInsets.all(AppDimens.padding16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Passenger Details',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              const SizedBox(height: AppDimens.margin8),
              Text('Primary: ${controller.passengerNameController.text}'),
              Text('Phone: ${controller.passengerPhoneController.text}'),
              if (controller.passengerEmailController.text.isNotEmpty)
                Text('Email: ${controller.passengerEmailController.text}'),
              if (controller.additionalPassengers.isNotEmpty) ...[
                const SizedBox(height: AppDimens.margin8),
                Text(
                  'Additional Passengers: ${controller.additionalPassengers.length}',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}