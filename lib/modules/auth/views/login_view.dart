// lib/modules/auth/views/login_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_strings.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/widgets/inputs/phone_field.dart';
import 'package:menahariya/modules/auth/controllers/login_controller.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';
import 'package:menahariya/modules/auth/widgets/auth_header.dart';
import 'package:menahariya/core/utils/app_snackbar.dart';

import '../../../core/widgets/loading/progress_indicator.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LoadingOverlay(
      isLoading: AuthController.instance.isLoading,
      message: 'Logging in...',
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => controller.unfocusFields(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.padding24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header with logo
                  const AuthHeader(
                    title: 'Welcome Back!',
                    subtitle: 'Login to continue your journey',
                  ),

                  const SizedBox(height: AppDimens.margin32),

                  // Form
                  Form(
                    child: Column(
                      children: [
                        // Phone Number Field
                        PhoneField(
                          controller: controller.phoneController,
                          focusNode: controller.phoneFocusNode,
                          onChanged: controller.validatePhone,
                          autoFocus: true,
                        ),
                        if (controller.phoneError != null) ...[
                          const SizedBox(height: AppDimens.margin4),
                          Text(
                            controller.phoneError!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.errorLight : AppColors.error,
                            ),
                          ),
                        ],

                        const SizedBox(height: AppDimens.margin16),
                        Obx(() => CustomTextField(
                          label: AppStrings.password,
                          controller: controller.passwordController,
                          focusNode: controller.passwordFocusNode,
                          obscureText: !controller.isPasswordVisible,
                          onChanged: controller.validatePassword,
                          onSubmitted: (_) => controller.handleLogin(),
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.lock_rounded,
                          suffixIcon: controller.isPasswordVisible
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          onSuffixTap: controller.togglePasswordVisibility,
                          errorText: controller.passwordError,
                        )),
                        const SizedBox(height: AppDimens.margin8),

                        // Remember Me & Forgot Password
                        Row(
                          children: [
                            // Remember Me
                            Row(
                              children: [
                                Obx(() => Checkbox(
                                  value: controller.rememberMe,
                                  onChanged: controller.toggleRememberMe,
                                  activeColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                )),
                                Text(
                                  'Remember Me',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Forgot Password
                            TextButton(
                              onPressed: controller.goToForgotPassword,
                              child: Text(
                                'Forgot Password?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimens.margin32),

                        // Login Button
                        Obx(() => PrimaryButton(
                          text: 'Login',
                          onPressed: controller.isFormValid ? controller.handleLogin : null,
                          isDisabled: !controller.isFormValid,
                          icon: Icons.login_rounded,
                        )),

                        const SizedBox(height: AppDimens.margin16),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: theme.textTheme.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: controller.goToRegister,
                              child: Text(
                                'Sign Up',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimens.margin32),

                        // Or divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
                              child: Text(
                                'OR',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimens.margin24),

                        // Role Cards Section
                        Column(
                          children: [
                            Text(
                              'Explore as',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choose your role to continue',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.margin16),

                        // Passenger Role Card
                        _buildRoleCard(
                          context,
                          role: 'Passenger',
                          icon: Icons.person_rounded,
                          gradientColors: [
                            AppColors.primaryGreen,
                            AppColors.primaryGreenLight,
                          ],
                          features: [
                            '✓ Search & book bus tickets instantly',
                            '✓ Choose your preferred seats',
                            '✓ Track your bookings and tickets',
                            '✓ Register cargo for shipment',
                            '✓ Track cargo in real-time',
                            '✓ Make payments via Telebirr, CBE Birr, or Cash',
                            '✓ Download tickets as PDF with QR code',
                            '✓ Receive instant notifications',
                            '✓ Manage your profile and preferences',
                          ],
                          onExplore: () => _showRoleInfoDialog(
                            context,
                            role: 'Passenger',
                            description: 'As a passenger, you can easily search for trips, book tickets, choose your preferred seats, and track your journeys all in one place.',
                            demoCredentials: {
                              'phone': '0934343434',
                              'password': 'Passerdemo@123',
                            },
                            onLogin: () {
                              controller.phoneController.text = '934343434';
                              controller.passwordController.text = 'Passerdemo@123';
                              controller.handleLogin();
                            },
                          ),
                        ),

                        const SizedBox(height: AppDimens.margin16),

                        // Driver Role Card
                        _buildRoleCard(
                          context,
                          role: 'Driver',
                          icon: Icons.drive_eta_rounded,
                          gradientColors: [
                            AppColors.primaryOrange,
                            Colors.orange.shade300,
                          ],
                          features: [
                            '✓ View assigned trips and schedules',
                            '✓ Manage passenger boarding with QR validation',
                            '✓ Track passenger check-ins',
                            '✓ Manage cargo loading and delivery',
                            '✓ Update trip status (departed, in-transit, completed)',
                            '✓ Report incidents and delays',
                            '✓ View passenger and cargo manifests',
                            '✓ Real-time trip updates',
                            '✓ Manage availability and preferences',
                          ],
                          onExplore: () => _showRoleInfoDialog(
                            context,
                            role: 'Driver',
                            description: 'As a driver, you can manage your assigned trips, validate passenger tickets, track cargo, update trip status, and report incidents in real-time.',
                            demoCredentials: {
                              'phone': '0923232323',
                              'password': 'Driverdemo@123',
                            },
                            onLogin: () {
                              controller.phoneController.text = '923232323';
                              controller.passwordController.text = 'Driverdemo@123';
                              controller.handleLogin();
                            },
                          ),
                        ),

                        const SizedBox(height: AppDimens.margin16),

                        // Admin Role Card
                        _buildRoleCard(
                          context,
                          role: 'Administrator',
                          icon: Icons.admin_panel_settings_rounded,
                          gradientColors: [
                            const Color(0xFF7C3AED),
                            const Color(0xFFA78BFA),
                          ],
                          features: [
                            '✓ Complete system overview dashboard',
                            '✓ Manage trips, routes, and vehicles',
                            '✓ Manage users (passengers, drivers, staff)',
                            '✓ View and manage all bookings',
                            '✓ Track all cargo shipments',
                            '✓ Generate reports and analytics',
                            '✓ Configure system settings',
                            '✓ Manage notifications to all users',
                            '✓ Real-time monitoring of all trips',
                            '✓ Audit logs and activity tracking',
                          ],

                          onExplore: () => _showRoleInfoDialog(
                            context,
                            role: 'Administrator',
                            description: 'As an administrator, you have complete control over the system - manage trips, users, vehicles, routes, and get full analytics and reports.',
                            demoCredentials: {
                              'phone': '0912121212',
                              'password': 'Admindemo@123',
                            },
                            onLogin: () {
                              controller.phoneController.text = '912121212';
                              controller.passwordController.text = 'Admindemo@123';
                              controller.handleLogin();
                            },
                          ),
                        ),

                        const SizedBox(height: AppDimens.margin16),

                        // Guest Mode
                        const SizedBox(height: AppDimens.margin8),
                        SecondaryButton(
                          text: 'Continue as Guest',
                          onPressed: () {
                            AuthController.instance.enterGuestMode();

                            Get.offAllNamed('/passenger/home');

                            AppSnackbar.show(
                              'Guest Mode',
                              'Browsing only. Login required for booking.',
                            );
                          },
                          icon: Icons.person_outline_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
      BuildContext context, {
        required String role,
        required IconData icon,
        required List<Color> gradientColors,
        required List<String> features,
        required VoidCallback onExplore,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: AppDimens.shadowBlurMedium,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onExplore,
          borderRadius: BorderRadius.circular(AppDimens.radius16),
          child: Container(
            padding: const EdgeInsets.all(AppDimens.padding16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppDimens.padding12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppDimens.margin16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimens.margin4),
                      Text(
                        'Tap to explore features',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Container(
                  padding: const EdgeInsets.all(AppDimens.padding8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRoleInfoDialog(
      BuildContext context, {
        required String role,
        required String description,
        required Map<String, String> demoCredentials,
        required VoidCallback onLogin,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimens.radius24),
            topRight: Radius.circular(AppDimens.radius24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: AppDimens.margin12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey600 : AppColors.grey300,
                  borderRadius: BorderRadius.circular(AppDimens.radius2),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.padding20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimens.padding12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.grey800 : AppColors.grey100,
                            borderRadius: BorderRadius.circular(AppDimens.radius12),
                          ),
                          child: Icon(
                            _getRoleIcon(role),
                            color: _getRoleColor(role),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppDimens.margin16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Role Overview',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimens.margin24),

                    // Description
                    Container(
                      padding: const EdgeInsets.all(AppDimens.padding16),
                      decoration: BoxDecoration(
                        color: _getRoleColor(role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimens.radius12),
                      ),
                      child: Text(
                        description,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),

                    const SizedBox(height: AppDimens.margin24),

                    // Features
                    Text(
                      'Key Features',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimens.margin12),

                    ..._getFeaturesForRole(role).map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.margin8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: _getRoleColor(role),
                            size: 20,
                          ),
                          const SizedBox(width: AppDimens.margin8),
                          Expanded(
                            child: Text(
                              feature,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),

                    const SizedBox(height: AppDimens.margin24),

                    // Demo Credentials
                    Container(
                      padding: const EdgeInsets.all(AppDimens.padding16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey800 : AppColors.grey50,
                        borderRadius: BorderRadius.circular(AppDimens.radius12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.code_rounded,
                                color: _getRoleColor(role),
                                size: 20,
                              ),
                              const SizedBox(width: AppDimens.margin8),
                              Text(
                                'Demo Credentials',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.margin12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Phone:',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                demoCredentials['phone']!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.margin4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Password:',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                demoCredentials['password']!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimens.margin24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            text: 'Close',
                            onPressed: () => Get.back(),
                            icon: Icons.close_rounded,
                          ),
                        ),
                        const SizedBox(width: AppDimens.margin12),
                        Expanded(
                          child: PrimaryButton(
                            text: 'Try Demo',
                            onPressed: () {
                              Get.back();
                              onLogin();
                            },
                            icon: Icons.play_arrow_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'passenger':
        return Icons.person_rounded;
      case 'driver':
        return Icons.drive_eta_rounded;
      case 'administrator':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'passenger':
        return AppColors.primaryGreen;
      case 'driver':
        return AppColors.primaryOrange;
      case 'administrator':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.primaryGreen;
    }
  }

  List<String> _getFeaturesForRole(String role) {
    switch (role.toLowerCase()) {
      case 'passenger':
        return [
          'Search and book bus tickets',
          'Select your preferred seats',
          'Track bookings and tickets',
          'Register and track cargo',
          'Pay with Telebirr, CBE Birr, or Cash',
          'Download PDF tickets with QR codes',
          'Receive instant notifications',
          'Manage profile and preferences',
        ];
      case 'driver':
        return [
          'View assigned trips and schedules',
          'Validate passenger tickets with QR scanner',
          'Manage passenger check-ins',
          'Track cargo loading and delivery',
          'Update trip status in real-time',
          'Report incidents and delays',
          'View passenger and cargo manifests',
          'Manage availability preferences',
        ];
      case 'administrator':
        return [
          'Complete dashboard with analytics',
          'Manage trips, routes, and vehicles',
          'Manage all users and roles',
          'View all bookings and cargo shipments',
          'Generate reports and analytics',
          'Configure system settings',
          'Send notifications to users',
          'Real-time monitoring and audit logs',
        ];
      default:
        return [];
    }
  }
}