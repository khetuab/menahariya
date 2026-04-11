// lib/modules/admin/views/admin_profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/admin_profile_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/inputs/custom_textfield.dart';

class AdminProfileView extends GetView<AdminProfileController> {
  const AdminProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Admin Profile'),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          elevation: 0,
          centerTitle: false,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Profile', icon: Icon(Icons.person_rounded)),
              Tab(text: 'Security', icon: Icon(Icons.security_rounded)),
              Tab(text: 'Activity', icon: Icon(Icons.history_rounded)),
            ],
            labelColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            indicatorColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          ),
        ),
        body: Obx(() {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            children: [
              _buildProfileTab(context),
              _buildSecurityTab(context),
              _buildActivityTab(context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.padding16),
      child: Column(
        children: [
          // Profile Image
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      width: 3,
                    ),
                    image: controller.profileImage != null
                        ? DecorationImage(
                      image: FileImage(controller.profileImage!),
                      fit: BoxFit.cover,
                    )
                        : (controller.profileImageUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(controller.profileImageUrl),
                      fit: BoxFit.cover,
                    )
                        : null),
                  ),
                  child: controller.profileImage == null && controller.profileImageUrl.isEmpty
                      ? CircleAvatar(
                    radius: 60,
                    backgroundColor: isDark ? AppColors.grey800 : AppColors.grey200,
                    child: Text(
                      controller.profile?.fullName[0].toUpperCase() ?? 'A',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                      onPressed: () => _showImagePickerOptions(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.margin24),

          // Profile Form
          Container(
            padding: const EdgeInsets.all(AppDimens.padding16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
            child: Column(
              children: [
                CustomTextField(
                  label: 'Full Name',
                  controller: controller.fullNameController,
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_rounded,
                ),
                const SizedBox(height: AppDimens.margin16),
                CustomTextField(
                  label: 'Phone Number',
                  controller: controller.phoneController,
                  hint: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_rounded,
                ),
                const SizedBox(height: AppDimens.margin16),
                CustomTextField(
                  label: 'Email Address',
                  controller: controller.emailController,
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_rounded,
                ),
                const SizedBox(height: AppDimens.margin24),
                Row(
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
                        text: 'Save Changes',
                        onPressed: controller.updateProfile,
                        isLoading: controller.isSaving,
                        icon: Icons.save_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.margin16),

          // Info Card
          Container(
            padding: const EdgeInsets.all(AppDimens.padding16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_rounded,
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                    const SizedBox(width: AppDimens.margin8),
                    Text('Account Information',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppFonts.semiBold)),
                  ],
                ),
                const SizedBox(height: AppDimens.margin12),
                _buildInfoRow('Role', controller.profile?.role?.toUpperCase() ?? 'Admin'),
                _buildInfoRow('Member Since',
                    controller.profile != null
                        ? controller.formatDate(controller.profile!.createdAt)
                        : 'N/A'),
                _buildInfoRow('Last Login',
                    controller.profile != null
                        ? controller.formatDate(controller.profile!.lastLogin)
                        : 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.padding16),
      child: Column(
        children: [
          // Change Password Card
          Container(
            padding: const EdgeInsets.all(AppDimens.padding16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_rounded,
                        color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
                    const SizedBox(width: AppDimens.margin8),
                    Text('Change Password',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppFonts.semiBold)),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                CustomTextField(
                  label: 'Current Password',
                  controller: controller.currentPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_rounded,
                ),
                const SizedBox(height: AppDimens.margin16),
                CustomTextField(
                  label: 'New Password',
                  controller: controller.newPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_open_rounded,
                  hint: 'Minimum 6 characters',
                ),
                const SizedBox(height: AppDimens.margin16),
                CustomTextField(
                  label: 'Confirm New Password',
                  controller: controller.confirmPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_rounded,
                ),
                const SizedBox(height: AppDimens.margin24),
                PrimaryButton(
                  text: 'Change Password',
                  onPressed: controller.changePassword,
                  isLoading: controller.isSaving,
                  icon: Icons.key_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.margin16),

          // Security Tips Card
          Container(
            padding: const EdgeInsets.all(AppDimens.padding16),
            decoration: BoxDecoration(
              color: (isDark ? Colors.orange : Colors.blue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radius12),
              border: Border.all(
                color: (isDark ? Colors.orange : Colors.blue).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates_rounded,
                        color: isDark ? Colors.orange : Colors.blue),
                    const SizedBox(width: AppDimens.margin8),
                    Text('Security Tips',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: AppFonts.semiBold,
                          color: isDark ? Colors.orange : Colors.blue,
                        )),
                  ],
                ),
                const SizedBox(height: AppDimens.margin12),
                _buildTipTile('Use a strong password with at least 8 characters'),
                _buildTipTile('Enable two-factor authentication for extra security'),
                _buildTipTile('Never share your password with anyone'),
                _buildTipTile('Change your password regularly'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (controller.activityLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 80,
                color: isDark ? AppColors.textHintDark : AppColors.textHintLight),
            const SizedBox(height: AppDimens.margin16),
            Text('No activity logs found.',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.padding16),
      itemCount: controller.activityLogs.length,
      itemBuilder: (context, index) {
        final log = controller.activityLogs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimens.margin12),
          padding: const EdgeInsets.all(AppDimens.padding12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getActionColor(log.action).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                ),
                child: Icon(_getActionIcon(log.action),
                    color: _getActionColor(log.action), size: 20),
              ),
              const SizedBox(width: AppDimens.margin12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log.action,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: AppFonts.medium)),
                    Text(log.details,
                        style: theme.textTheme.bodySmall),
                    Text(controller.formatDate(log.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                          fontSize: 11,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.margin8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: AppFonts.medium),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipTile(String tip) {
    final theme = Get.context!.theme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.margin8),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
          const SizedBox(width: AppDimens.margin8),
          Expanded(child: Text(tip, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimens.padding16),
        decoration: BoxDecoration(
          color: Get.context!.theme.brightness == Brightness.dark
              ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Take Photo'),
                onTap: () {
                  Get.back();
                  controller.takeProfilePhoto(); // Use this method
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Get.back();
                  controller.pickProfileImage(); // Use this method
                },
              ),
              if (controller.profileImage != null || controller.profileImageUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Get.back();
                    controller.removeProfileImage();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getActionColor(String action) {
    if (action.contains('login')) return Colors.blue;
    if (action.contains('update') || action.contains('edit')) return Colors.orange;
    if (action.contains('delete')) return Colors.red;
    if (action.contains('create')) return Colors.green;
    return Colors.grey;
  }

  IconData _getActionIcon(String action) {
    if (action.contains('login')) return Icons.login_rounded;
    if (action.contains('update') || action.contains('edit')) return Icons.edit_rounded;
    if (action.contains('delete')) return Icons.delete_rounded;
    if (action.contains('create')) return Icons.add_rounded;
    return Icons.info_rounded;
  }
}