// lib/modules/admin/views/admin_users_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_dialogs.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_filter_chip.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_sidebar.dart';
import 'package:menahariya/modules/admin/views/widgets/admin_status_badge.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/inputs/custom_textfield.dart';
import '../controllers/admin_user_controller.dart';

class AdminUsersView extends GetView<AdminUserController> {
  const AdminUsersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const AdminDrawer(currentIndex: 3),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateUserDialog(context),
            tooltip: 'Add User',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Search and Filter Bar
            _buildSearchBar(context),
            // Stats Row
            _buildStatsRow(context),
            // Active Filters
            _buildActiveFilters(context),
            // Users List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshUsers,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimens.padding16),
                  itemCount: controller.users.length + (controller.hasMorePages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.users.length && controller.hasMorePages) {
                      return _buildLoadMoreIndicator();
                    }
                    if (index >= controller.users.length) {
                      return const SizedBox();
                    }
                    final user = controller.users[index];
                    return _buildUserCard(context, user);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or email...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                    ? GestureDetector(
                  onTap: () => controller.searchController.clear(),
                  child: const Icon(Icons.clear_rounded, size: 18),
                )
                    : const SizedBox.shrink()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding16,
                  vertical: AppDimens.padding12,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.margin8),
          GestureDetector(
            onTap: () => _showFilterBottomSheet(context),
            child: Container(
              padding: const EdgeInsets.all(AppDimens.padding12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : AppColors.grey100,
                borderRadius: BorderRadius.circular(AppDimens.radius12),
              ),
              child: Icon(
                Icons.filter_list_rounded,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
      child: Row(
        children: [
          _buildStatChip('Total', controller.totalUsers.toString(), Colors.blue),
          const SizedBox(width: AppDimens.margin8),
          _buildStatChip('Passengers', controller.totalPassengers.toString(), Colors.green),
          const SizedBox(width: AppDimens.margin8),
          _buildStatChip('Drivers', controller.totalDrivers.toString(), Colors.orange),
          const SizedBox(width: AppDimens.margin8),
          _buildStatChip('Staff', controller.totalStaff.toString(), Colors.purple),
          const SizedBox(width: AppDimens.margin8),
          _buildStatChip('Admins', controller.totalAdmins.toString(), Colors.red),
          const SizedBox(width: AppDimens.margin8),
          _buildStatChip('Active', controller.activeUsers.toString(), Colors.teal),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding12, vertical: AppDimens.padding6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radius20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: AppFonts.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(BuildContext context) {
    if (!_hasActiveFilters()) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16, vertical: AppDimens.padding8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (controller.roleFilter.isNotEmpty)
              _buildFilterChip(
                label: 'Role: ${_getRoleDisplayName(controller.roleFilter)}',
                onClear: () => controller.setRoleFilter(''),
              ),
            _buildFilterChip(
              label: 'Status: ${controller.statusFilter ? 'Active' : 'Inactive'}',
              onClear: () => controller.setStatusFilter(true),
            ),
            _buildFilterChip(
              label: 'Clear All',
              onClear: controller.clearFilters,
              isClearAll: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onClear,
    bool isClearAll = false,
  }) {
    final isDark = Get.context!.theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(right: AppDimens.margin8),
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding8, vertical: AppDimens.padding4),
      decoration: BoxDecoration(
        color: isClearAll
            ? (isDark ? AppColors.error.withOpacity(0.2) : AppColors.error.withOpacity(0.1))
            : (isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(
          color: isClearAll
              ? (isDark ? AppColors.errorLight : AppColors.error)
              : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isClearAll
                  ? (isDark ? AppColors.errorLight : AppColors.error)
                  : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: AppDimens.margin4),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: isClearAll
                  ? (isDark ? AppColors.errorLight : AppColors.error)
                  : (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.margin12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: _getRoleColor(user.role),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.margin12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppFonts.semiBold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimens.margin2),
                      Text(
                        user.phone,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                AdminStatusBadge(status: user.isActive ? 'Active' : 'Inactive'),
              ],
            ),
            const SizedBox(height: AppDimens.margin12),
            // Email
            if (user.email != null && user.email!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.margin8),
                child: Row(
                  children: [
                    Icon(Icons.email_rounded, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    const SizedBox(width: AppDimens.margin8),
                    Expanded(
                      child: Text(
                        user.email!,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            // Role and Join Date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding8, vertical: AppDimens.padding4),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                  ),
                  child: Text(
                    _getRoleDisplayName(user.role),
                    style: TextStyle(
                      color: _getRoleColor(user.role),
                      fontSize: 12,
                      fontWeight: AppFonts.medium,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? AppColors.textHintDark : AppColors.textHintLight),
                const SizedBox(width: AppDimens.margin4),
                Text(
                  _formatDate(user.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.margin12),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_rounded, color: Colors.blue),
                  onPressed: () => _showUserDetailsDialog(user),
                  tooltip: 'View Details',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.orange),
                  onPressed: () => _showEditUserDialog(user),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: Icon(
                    user.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                    color: user.isActive ? Colors.red : Colors.green,
                  ),
                  onPressed: () => _showToggleStatusDialog(user),
                  tooltip: user.isActive ? 'Deactivate' : 'Activate',
                ),
                IconButton(
                  icon: const Icon(Icons.lock_reset_rounded, color: Colors.purple),
                  onPressed: () => _showResetPasswordDialog(user),
                  tooltip: 'Reset Password',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _showRemoveUserDialog(user),
                  tooltip: 'Remove user',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(AppDimens.padding16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Users',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin24),
                // Role Filter
                Text(
                  'Role',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin12),
                // ✅ Wrap the role chips in Obx
                Obx(() => Wrap(
                  spacing: AppDimens.margin8,
                  runSpacing: AppDimens.margin8,
                  children: [
                    AdminFilterChip(
                      label: 'All',
                      value: '',
                      selectedValue: controller.roleFilter,
                      onSelected: (value) {
                        controller.setRoleFilter(value);
                        // Don't close immediately to allow multiple selections
                      },
                    ),
                    ...controller.availableRoles.map((role) {
                      return AdminFilterChip(
                        label: _getRoleDisplayName(role),
                        value: role,
                        selectedValue: controller.roleFilter,
                        onSelected: (value) {
                          controller.setRoleFilter(value);
                        },
                      );
                    }),
                  ],
                )),
                const SizedBox(height: AppDimens.margin24),
                // Status Filter
                Text(
                  'Status',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin12),
                // ✅ Wrap the status chips in Obx
                Obx(() => Wrap(
                  spacing: AppDimens.margin8,
                  runSpacing: AppDimens.margin8,
                  children: [
                    AdminFilterChip(
                      label: 'Active',
                      value: 'true',
                      selectedValue: controller.statusFilter ? 'true' : null,
                      onSelected: (value) {
                        controller.setStatusFilter(value == 'true');
                      },
                    ),
                    AdminFilterChip(
                      label: 'Inactive',
                      value: 'false',
                      selectedValue: !controller.statusFilter ? 'false' : null,
                      onSelected: (value) {
                        controller.setStatusFilter(value == 'true');
                      },
                    ),
                  ],
                )),
                const SizedBox(height: AppDimens.margin24),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Reset',
                        onPressed: () {
                          controller.clearFilters();
                          Get.back();
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimens.margin12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Apply',
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Reset form
    controller.fullNameController.clear();
    controller.phoneController.clear();
    controller.emailController.clear();
    controller.passwordController.clear();
    controller.confirmPasswordController.clear();
    controller.licenseNumberController.clear();
    controller.licenseExpiryController.clear();
    controller.setSelectedRole('passenger');

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New User',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin24),
                // Full Name
                CustomTextField(
                  label: 'Full Name',
                  controller: controller.fullNameController,
                  hint: 'Enter full name',
                ),
                const SizedBox(height: AppDimens.margin16),
                // Phone
                CustomTextField(
                  label: 'Phone Number',
                  controller: controller.phoneController,
                  hint: '09xxxxxxxx',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppDimens.margin16),
                // Email
                CustomTextField(
                  label: 'Email (Optional)',
                  controller: controller.emailController,
                  hint: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppDimens.margin16),
                // Role
                DropdownButtonFormField<String>(
                  value: controller.selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: controller.availableRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(_getRoleDisplayName(role)),
                    );
                  }).toList(),
                  onChanged: (value) => controller.setSelectedRole(value ?? 'passenger'),
                ),
                const SizedBox(height: AppDimens.margin16),
                // Password
                CustomTextField(
                  label: 'Password',
                  controller: controller.passwordController,
                  obscureText: true,
                  hint: 'Minimum 6 characters',
                ),
                const SizedBox(height: AppDimens.margin16),
                // Confirm Password
                CustomTextField(
                  label: 'Confirm Password',
                  controller: controller.confirmPasswordController,
                  obscureText: true,
                ),
                // Driver specific fields
                Obx(() {
                  if (controller.selectedRole == 'driver') {
                    return Column(
                      children: [
                        const SizedBox(height: AppDimens.margin16),
                        CustomTextField(
                          label: 'License Number',
                          controller: controller.licenseNumberController,
                          hint: 'Enter license number',
                        ),
                        const SizedBox(height: AppDimens.margin16),
                        CustomTextField(
                          label: 'License Expiry',
                          controller: controller.licenseExpiryController,
                          hint: 'YYYY-MM-DD',
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                            );
                            if (date != null) {
                              controller.licenseExpiryController.text =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                            }
                          },
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                }),
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
                        text: 'Create User',
                        onPressed: () async {
                          if (controller.passwordController.text != controller.confirmPasswordController.text) {
                            Get.snackbar('Error', 'Passwords do not match');
                            return;
                          }
                          final success = await controller.createUser({
                            'fullName': controller.fullNameController.text.trim(),
                            'phone': controller.phoneController.text.trim(),
                            'email': controller.emailController.text.trim().isEmpty ? null : controller.emailController.text.trim(),
                            'password': controller.passwordController.text,
                            'role': controller.selectedRole,
                            'licenseNumber': controller.licenseNumberController.text.trim().isEmpty ? null : controller.licenseNumberController.text.trim(),
                            'licenseExpiry': controller.licenseExpiryController.text.trim().isEmpty ? null : controller.licenseExpiryController.text.trim(),
                          });
                          if (success) Get.back();
                        },
                        isLoading: controller.isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserDetailsDialog(dynamic user) async {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    await controller.getUserDetails(user.id);
    final fullUser = controller.selectedUser;
    if (fullUser == null) return;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'User Details',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin16),
                // User Info
                _buildDetailSection(
                  title: 'Personal Information',
                  children: [
                    _buildDetailRow('Full Name', fullUser.fullName),
                    _buildDetailRow('Phone', fullUser.phone),
                    _buildDetailRow('Email', fullUser.email ?? 'Not provided'),
                    _buildDetailRow('Role', _getRoleDisplayName(fullUser.role)),
                    _buildDetailRow('Status', fullUser.isActive ? 'Active' : 'Inactive'),
                    _buildDetailRow('Joined', _formatDate(fullUser.createdAt)),
                  ],
                ),
                if (fullUser.role == 'driver') ...[
                  const SizedBox(height: AppDimens.margin16),
                  _buildDetailSection(
                    title: 'Driver Information',
                    children: [
                      _buildDetailRow('License Number', fullUser.licenseNumber ?? 'N/A'),
                      _buildDetailRow('License Expiry', fullUser.licenseExpiry != null ? _formatDate(fullUser.licenseExpiry!) : 'N/A'),
                      _buildDetailRow('Rating', fullUser.rating?.toString() ?? 'N/A'),
                      _buildDetailRow('Total Trips', fullUser.totalTrips?.toString() ?? '0'),
                    ],
                  ),
                ],
                if (fullUser.role == 'passenger') ...[
                  const SizedBox(height: AppDimens.margin16),
                  _buildDetailSection(
                    title: 'Passenger Information',
                    children: [
                      _buildDetailRow('Wallet Balance', 'ETB ${fullUser.walletBalance?.toStringAsFixed(2) ?? '0'}'),
                      _buildDetailRow('Loyalty Points', fullUser.loyaltyPoints?.toString() ?? '0'),
                      _buildDetailRow('Loyalty Tier', fullUser.loyaltyTier ?? 'Bronze'),
                    ],
                  ),
                ],
                const SizedBox(height: AppDimens.margin24),
                PrimaryButton(
                  text: 'Close',
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditUserDialog(dynamic user) {
    final theme = Get.context!.theme;
    final isDark = theme.brightness == Brightness.dark;

    // Pre-fill controllers
    controller.fullNameController.text = user.fullName;
    controller.phoneController.text = user.phone;
    controller.emailController.text = user.email ?? '';
    controller.setSelectedRole(user.role);

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit User',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.margin24),
                CustomTextField(
                  label: 'Full Name',
                  controller: controller.fullNameController,
                ),
                const SizedBox(height: AppDimens.margin16),
                CustomTextField(
                  label: 'Phone',
                  controller: controller.phoneController,
                ),
                const SizedBox(height: AppDimens.margin16),
                CustomTextField(
                  label: 'Email',
                  controller: controller.emailController,
                ),
                const SizedBox(height: AppDimens.margin16),
                DropdownButtonFormField<String>(
                  value: controller.selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: controller.availableRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(_getRoleDisplayName(role)),
                    );
                  }).toList(),
                  onChanged: (value) => controller.setSelectedRole(value ?? 'passenger'),
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
                        onPressed: () async {
                          final success = await controller.updateUser(user.id, {
                            'fullName': controller.fullNameController.text.trim(),
                            'phone': controller.phoneController.text.trim(),
                            'email': controller.emailController.text.trim().isEmpty ? null : controller.emailController.text.trim(),
                            'role': controller.selectedRole,
                          });
                          if (success) Get.back();
                        },
                        isLoading: controller.isSaving,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showToggleStatusDialog(dynamic user) async {
    final confirmed = await AdminConfirmationDialog.show(
      title: user.isActive ? 'Deactivate User' : 'Activate User',
      message: 'Are you sure you want to ${user.isActive ? 'deactivate' : 'activate'} "${user.fullName}"?',
      confirmText: user.isActive ? 'Deactivate' : 'Activate',
      confirmColor: user.isActive ? Colors.red : Colors.green,
    );

    if (confirmed) {
      final success = await controller.toggleUserStatus(user.id, !user.isActive);
      if (success) {
        Get.snackbar('Success', 'User ${user.isActive ? 'deactivated' : 'activated'} successfully');
      }
    }
  }

  void _showResetPasswordDialog(dynamic user) {
    final newPasswordController = TextEditingController();

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Password',
                  style: Get.context!.textTheme.headlineSmall?.copyWith(
                    fontWeight: AppFonts.bold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin16),
                Text('Reset password for ${user.fullName}'),
                const SizedBox(height: AppDimens.margin16),
                CustomTextField(
                  label: 'New Password',
                  controller: newPasswordController,
                  obscureText: true,
                  hint: 'Minimum 6 characters',
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
                        text: 'Reset Password',
                        onPressed: () async {
                          if (newPasswordController.text.length < 6) {
                            Get.snackbar('Error', 'Password must be at least 6 characters');
                            return;
                          }
                          Get.back();
                          final success = await controller.resetUserPassword(user.id, newPasswordController.text);
                          if (success) {
                            Get.snackbar('Success', 'Password reset successfully');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveUserDialog(dynamic user) {

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radius16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remove User',
                  style: Get.context!.textTheme.headlineSmall?.copyWith(
                    fontWeight: AppFonts.bold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin16),
                Text('Remove User ${user.fullName}'),
                const SizedBox(height: AppDimens.margin16),
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
                        text: 'Remove',
                        onPressed: () async {
                          Get.back();
                          final success = await controller.deleteUser(user.id);
                          if (success) {
                            Get.snackbar('Success', 'Password reset successfully');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDetailSection({required String title, required List<Widget> children}) {
    final theme = Get.context!.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: AppDimens.margin8),
        Container(
          padding: const EdgeInsets.all(AppDimens.padding12),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Get.context!.theme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: AppFonts.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return controller.roleFilter.isNotEmpty || controller.statusFilter != true;
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'passenger': return 'Passenger';
      case 'driver': return 'Driver';
      case 'ticketing_staff': return 'Ticketing Staff';
      case 'cargo_staff': return 'Cargo Staff';
      case 'admin': return 'Administrator';
      default: return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'passenger': return Colors.green;
      case 'driver': return Colors.orange;
      case 'ticketing_staff': return Colors.blue;
      case 'cargo_staff': return Colors.teal;
      case 'admin': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}