// lib/modules/passenger/widgets/cargo_form.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/widgets/inputs/phone_field.dart';

class CargoForm extends StatelessWidget {
  final VoidCallback onSubmit;
  final bool isLoading;

  // Form Controllers
  final TextEditingController senderNameController;
  final TextEditingController senderPhoneController;
  final TextEditingController receiverNameController;
  final TextEditingController receiverPhoneController;
  final TextEditingController cargoTypeController;
  final TextEditingController weightController;
  final TextEditingController dimensionsController;
  final TextEditingController descriptionController;

  // Callbacks
  final Function(String) onCargoTypeSelected;
  final VoidCallback onCalculateFee;

  const CargoForm({
    Key? key,
    required this.onSubmit,
    required this.isLoading,
    required this.senderNameController,
    required this.senderPhoneController,
    required this.receiverNameController,
    required this.receiverPhoneController,
    required this.cargoTypeController,
    required this.weightController,
    required this.dimensionsController,
    required this.descriptionController,
    required this.onCargoTypeSelected,
    required this.onCalculateFee,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      child: Column(
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
            controller: senderNameController,
            prefixIcon: Icons.person_rounded,
          ),
          const SizedBox(height: AppDimens.margin12),

          PhoneField(
            controller: senderPhoneController,
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
            controller: receiverNameController,
            prefixIcon: Icons.person_rounded,
          ),
          const SizedBox(height: AppDimens.margin12),

          PhoneField(
            controller: receiverPhoneController,
            label: 'Receiver Phone',
          ),

          const SizedBox(height: AppDimens.margin24),

          // Cargo Details
          Text(
            'Cargo Details',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin12),

          // Cargo Type Selection
          GestureDetector(
            onTap: () => _showCargoTypeSelector(context),
            child: Container(
              padding: const EdgeInsets.all(AppDimens.padding12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : AppColors.grey50,
                borderRadius: BorderRadius.circular(AppDimens.radius12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.category_rounded),
                  const SizedBox(width: AppDimens.margin12),
                  Expanded(
                    child: Text(
                      cargoTypeController.text.isEmpty
                          ? 'Select Cargo Type'
                          : cargoTypeController.text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cargoTypeController.text.isEmpty
                            ? (isDark ? AppColors.textHintDark : AppColors.textHintLight)
                            : null,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimens.margin12),

          // Weight and Dimensions
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Weight (kg)',
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.monitor_weight_rounded,
                  onChanged: (_) => onCalculateFee(),
                ),
              ),
              const SizedBox(width: AppDimens.margin12),
              Expanded(
                child: CustomTextField(
                  label: 'Dimensions (cm)',
                  controller: dimensionsController,
                  hint: 'LxWxH',
                  prefixIcon: Icons.straighten_rounded,
                  onChanged: (_) => onCalculateFee(),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimens.margin12),

          // Description
          CustomTextField(
            label: 'Description (Optional)',
            controller: descriptionController,
            maxLines: 3,
            hint: 'Describe the cargo contents',
          ),

          const SizedBox(height: AppDimens.margin24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: AppDimens.buttonHeightLarge,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Register Cargo'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCargoTypeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimens.padding16),
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
            const Text(
              'Select Cargo Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimens.margin16),
            _buildCargoTypeItem(context, 'General Goods'),
            _buildCargoTypeItem(context, 'Electronics'),
            _buildCargoTypeItem(context, 'Furniture'),
            _buildCargoTypeItem(context, 'Perishables'),
            _buildCargoTypeItem(context, 'Documents'),
            _buildCargoTypeItem(context, 'Clothing'),
          ],
        ),
      ),
    );
  }

  Widget _buildCargoTypeItem(BuildContext context, String type) {
    return ListTile(
      title: Text(type),
      onTap: () {
        onCargoTypeSelected(type);
        Get.back();
      },
    );
  }
}