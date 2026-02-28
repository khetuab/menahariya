// lib/modules/driver/widgets/incident_form.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/modules/driver/controllers/incident_controller.dart';

class IncidentForm extends StatelessWidget {
  final IncidentController controller;
  final VoidCallback onSubmit;
  final bool isLoading;

  const IncidentForm({
    Key? key,
    required this.controller,
    required this.onSubmit,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Incident Type Selection
          Text(
            'Incident Type',
            style: theme.textTheme.titleSmall?.copyWith(
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
              childAspectRatio: 0.9,
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
            style: theme.textTheme.titleSmall?.copyWith(
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
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin12),

          TextFormField(
            controller: controller.titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'Brief description of the incident',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
              prefixIcon: const Icon(Icons.title_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),

          const SizedBox(height: AppDimens.margin12),

          TextFormField(
            controller: controller.descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Provide detailed information about what happened...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(Icons.description_rounded),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please provide a description';
              }
              return null;
            },
          ),

          const SizedBox(height: AppDimens.margin12),

          // Location
          TextFormField(
            controller: controller.locationController,
            decoration: InputDecoration(
              labelText: 'Location (Optional)',
              hintText: 'Where did this happen?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
              prefixIcon: const Icon(Icons.location_on_rounded),
            ),
          ),

          const SizedBox(height: AppDimens.margin24),

          // Attachments
          Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
              const SizedBox(width: AppDimens.margin8),
              Text(
                'Attachments',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.margin12),

          Obx(() {
            if (controller.attachments.isEmpty) {
              return _buildAddAttachmentButtons(context);
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
                _buildAddAttachmentButtons(context),
              ],
            );
          }),

          const SizedBox(height: AppDimens.margin32),

          // Submit Button
          PrimaryButton(
            text: 'Report Incident',
            onPressed: onSubmit,
            isLoading: isLoading,
            icon: Icons.warning_rounded,
          ),
        ],
      ),
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
          return isDark ? AppColors.secondaryOrangeLight : AppColors.secondaryOrange;
        case 'yellow':
          return isDark ? AppColors.warningLight : AppColors.warning;
        case 'purple':
          return isDark ? AppColors.secondaryPurpleLight : AppColors.secondaryPurple;
        case 'blue':
          return isDark ? AppColors.infoLight : AppColors.info;
        case 'brown':
          return Colors.brown;
        case 'amber':
          return Colors.amber;
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
              size: AppDimens.iconSize24,
            ),
            const SizedBox(height: AppDimens.margin4),
            Text(
              type.title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? getColor() : null,
                fontWeight: isSelected ? AppFonts.medium : AppFonts.regular,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
              color: isSelected ? color : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              fontWeight: isSelected ? AppFonts.semiBold : AppFonts.regular,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddAttachmentButtons(BuildContext context) {
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
              foregroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              side: BorderSide(
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
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
              foregroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              side: BorderSide(
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
              padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
            ),
          ),
        ),
      ],
    );
  }
}

// Incident History Card
class IncidentHistoryCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;

  const IncidentHistoryCard({
    Key? key,
    required this.incident,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color getSeverityColor() {
      switch (incident.severity) {
        case IncidentSeverity.low:
          return isDark ? AppColors.successLight : AppColors.success;
        case IncidentSeverity.medium:
          return isDark ? AppColors.warningLight : AppColors.warning;
        case IncidentSeverity.high:
          return isDark ? AppColors.secondaryOrangeLight : AppColors.secondaryOrange;
        case IncidentSeverity.critical:
          return isDark ? AppColors.errorLight : AppColors.error;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.margin8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: getSeverityColor(),
                  borderRadius: BorderRadius.circular(AppDimens.radius2),
                ),
              ),
              const SizedBox(width: AppDimens.margin12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            incident.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: AppFonts.semiBold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.padding6,
                            vertical: AppDimens.padding2,
                          ),
                          decoration: BoxDecoration(
                            color: getSeverityColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimens.radius4),
                          ),
                          child: Text(
                            incident.severity.toString().split('.').last,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: getSeverityColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.margin4),
                    Text(
                      incident.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimens.margin4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: AppDimens.iconSize12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: AppDimens.margin4),
                        Text(
                          _formatDate(incident.timestamp),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: AppDimens.margin12),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppDimens.margin8),
                        Icon(
                          Icons.circle_rounded,
                          size: AppDimens.iconSize8,
                          color: incident.status == 'resolved'
                              ? (isDark ? AppColors.successLight : AppColors.success)
                              : (isDark ? AppColors.warningLight : AppColors.warning),
                        ),
                        const SizedBox(width: AppDimens.margin4),
                        Text(
                          incident.status,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}