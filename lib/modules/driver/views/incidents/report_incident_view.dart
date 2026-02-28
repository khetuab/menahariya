// lib/modules/driver/views/incidents/report_incident_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/modules/driver/controllers/incident_controller.dart';

class ReportIncidentView extends GetView<IncidentController> {
  const ReportIncidentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
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
              // Incident Type Selection
              Text(
                'Incident Type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              const SizedBox(height: AppDimens.margin12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: AppDimens.gridSpacingSmall,
                  mainAxisSpacing: AppDimens.gridSpacingSmall,
                  childAspectRatio: 0.8,
                ),
                itemCount: controller.incidentTypes.length,
                itemBuilder: (context, index) {
                  final type = controller.incidentTypes[index];
                  return _buildIncidentTypeCard(context, type);
                },
              ),

              const SizedBox(height: AppDimens.margin24),

              // Severity Selection
              Text(
                'Severity Level',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              const SizedBox(height: AppDimens.margin12),
              Row(
                children: [
                  _buildSeverityChip(context, 'Low', IncidentSeverity.low, Colors.green),
                  const SizedBox(width: AppDimens.margin8),
                  _buildSeverityChip(context, 'Medium', IncidentSeverity.medium, Colors.orange),
                  const SizedBox(width: AppDimens.margin8),
                  _buildSeverityChip(context, 'High', IncidentSeverity.high, Colors.red),
                  const SizedBox(width: AppDimens.margin8),
                  _buildSeverityChip(context, 'Critical', IncidentSeverity.critical, Colors.purple),
                ],
              ),

              const SizedBox(height: AppDimens.margin24),

              // Incident Details
              Text(
                'Incident Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              const SizedBox(height: AppDimens.margin12),

              TextField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radius8),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.margin12),

              TextField(
                controller: controller.descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe what happened...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radius8),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.margin12),

              TextField(
                controller: controller.locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'Where did this happen?',
                  prefixIcon: const Icon(Icons.location_on_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radius8),
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.margin24),

              // Attachments
              Text(
                'Attachments',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              const SizedBox(height: AppDimens.margin12),

              Obx(() {
                if (controller.attachments.isEmpty) {
                  return _buildAddPhotoButton(context);
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.attachments.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.margin8),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                                  image: DecorationImage(
                                    image: FileImage(controller.attachments[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => controller.removeAttachment(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppDimens.margin12),
                    _buildAddPhotoButton(context),
                  ],
                );
              }),

              const SizedBox(height: AppDimens.margin32),

              // Submit Button
              PrimaryButton(
                text: 'Report Incident',
                onPressed: controller.submitIncident,
                isLoading: controller.isUploading,
                icon: Icons.warning_rounded,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildIncidentTypeCard(BuildContext context, IncidentTypeInfo type) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = controller.incidentType == type.type;

    Color getColor() {
      switch (type.color) {
        case 'red':
          return isDark ? AppColors.errorLight : AppColors.error;
        case 'orange':
          return isDark ? AppColors.secondaryOrangeLight : AppColors.primaryOrange;
        case 'yellow':
          return isDark ? AppColors.warningLight : AppColors.warning;
        case 'purple':
          return isDark ? AppColors.secondaryPurpleLight : AppColors.secondaryPurple;
        case 'blue':
          return isDark ? AppColors.infoLight : AppColors.info;
        default:
          return isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen;
      }
    }

    return GestureDetector(
      onTap: () => controller.setIncidentType(type.type),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.padding8),
        decoration: BoxDecoration(
          color: isSelected
              ? getColor().withOpacity(0.2)
              : (isDark ? AppColors.grey800 : AppColors.grey50),
          borderRadius: BorderRadius.circular(AppDimens.radius8),
          border: Border.all(
            color: isSelected ? getColor() : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type.icon,
              color: isSelected ? getColor() : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(height: AppDimens.margin4),
            Text(
              type.title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? getColor() : null,
                fontWeight: isSelected ? AppFonts.medium : AppFonts.regular,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityChip(BuildContext context, String label, IncidentSeverity severity, Color color) {
    final isSelected = controller.severity == severity;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setSeverity(severity),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.padding8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.2)
                : (isDark ? AppColors.grey800 : AppColors.grey50),
            borderRadius: BorderRadius.circular(AppDimens.radius8),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected ? color : null,
              fontWeight: isSelected ? AppFonts.semiBold : AppFonts.regular,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.pickImage,
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Take Photo'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
            ),
          ),
        ),
        const SizedBox(width: AppDimens.margin12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.pickImageFromGallery,
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Choose Photo'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
            ),
          ),
        ),
      ],
    );
  }
}