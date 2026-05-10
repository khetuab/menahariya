// lib/modules/auth/widgets/auth_header.dart

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/constants/app_images.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogo;
  final double logoSize;

  const AuthHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
    this.logoSize = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // App Logo
        if (showLogo) ...[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              border: Border.all(width: 2,color: Colors.white),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.blue,blurRadius: 5)]
            ),
            child: SizedBox(
              width: 120,
              height: 120,
              child: Image.asset(
                'assets/logos/applogot.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.margin16),
        ],

        // App Name
        // Text(
        //   'MENAHARIYA',
        //   style: theme.textTheme.headlineSmall?.copyWith(
        //     color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
        //     fontWeight: FontWeight.bold,
        //     letterSpacing: 2,
        //   ),
        // ),
        // Text(
        //   'SMART',
        //   style: theme.textTheme.titleLarge?.copyWith(
        //     color: isDark ? AppColors.primaryYellow : AppColors.primaryYellowDark,
        //     fontWeight: FontWeight.w600,
        //     letterSpacing: 4,
        //   ),
        // ),

        const SizedBox(height: AppDimens.margin24),

        // Title
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppDimens.margin8),

        // Subtitle
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Alternative header with image
class AuthHeaderWithImage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final double imageHeight;

  const AuthHeaderWithImage({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.imageHeight = 180,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Illustration
        Container(
          height: imageHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
                isDark ? AppColors.primaryYellow.withOpacity(0.2) : AppColors.primaryYellow.withOpacity(0.1),
                isDark ? AppColors.primaryRed.withOpacity(0.2) : AppColors.primaryRed.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimens.radius16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radius16),
            child: Image.asset(
              imagePath ?? AppImages.busIllustration,
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(height: AppDimens.margin24),

        // Title
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppDimens.margin8),

        // Subtitle
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Welcome back header with user info
class WelcomeBackHeader extends StatelessWidget {
  final String userName;
  final String? profileImage;
  final VoidCallback? onProfileTap;

  const WelcomeBackHeader({
    Key? key,
    required this.userName,
    this.profileImage,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Profile Image
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  isDark ? AppColors.primaryGreen : AppColors.primaryGreenDark,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: profileImage != null
                  ? Image.asset(
                profileImage!,
                fit: BoxFit.cover,
              )
                  : Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),

        const SizedBox(width: AppDimens.margin12),

        // Welcome Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                userName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Notification Icon
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                size: AppDimens.iconSize28,
              ),
              onPressed: () {
                // Navigate to notifications
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Password strength indicator widget
class PasswordStrengthIndicator extends StatelessWidget {
  final double strength;
  final Color strengthColor;
  final String strengthText;

  const PasswordStrengthIndicator({
    Key? key,
    required this.strength,
    required this.strengthColor,
    required this.strengthText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimens.margin8),

        // Strength bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radius4),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 4,
            backgroundColor: isDark ? AppColors.grey700 : AppColors.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          ),
        ),

        const SizedBox(height: AppDimens.margin4),

        // Strength text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password strength:',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              strengthText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: strengthColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // Requirements
        Container(
          margin: const EdgeInsets.only(top: AppDimens.margin8),
          padding: const EdgeInsets.all(AppDimens.padding12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey800 : AppColors.grey50,
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password must contain:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimens.margin4),
              _buildRequirement(
                context,
                'At least 8 characters',
                strength >= 0.25,
              ),
              _buildRequirement(
                context,
                'At least 1 uppercase letter',
                strength >= 0.4,
              ),
              _buildRequirement(
                context,
                'At least 1 lowercase letter',
                strength >= 0.55,
              ),
              _buildRequirement(
                context,
                'At least 1 number',
                strength >= 0.7,
              ),
              _buildRequirement(
                context,
                'At least 1 special character',
                strength >= 0.85,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirement(BuildContext context, String text, bool met) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: AppDimens.iconSize14,
            color: met ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: AppDimens.margin4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: met ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Social login buttons widget
class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;
  final VoidCallback? onApplePressed;

  const SocialLoginButtons({
    Key? key,
    this.onGooglePressed,
    this.onFacebookPressed,
    this.onApplePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google
        _buildSocialButton(
          icon: Icons.g_mobiledata_rounded,
          color: Colors.red,
          onPressed: onGooglePressed,
          isDark: isDark,
        ),
        const SizedBox(width: AppDimens.margin16),

        // Facebook
        _buildSocialButton(
          icon: Icons.facebook_rounded,
          color: const Color(0xFF1877F2),
          onPressed: onFacebookPressed,
          isDark: isDark,
        ),
        const SizedBox(width: AppDimens.margin16),

        // Apple (only on iOS)
        if (GetPlatform.isIOS)
          _buildSocialButton(
            icon: Icons.apple_rounded,
            color: isDark ? Colors.white : Colors.black,
            onPressed: onApplePressed,
            isDark: isDark,
          ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey800 : Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: AppDimens.shadowBlurSmall,
              spreadRadius: AppDimens.shadowSpreadNone,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: AppDimens.iconSize28,
        ),
      ),
    );
  }
}

// Language selector widget
class LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageSelected;

  const LanguageSelector({
    Key? key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey100,
        borderRadius: BorderRadius.circular(AppDimens.radius30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption('EN', 'en'),
          _buildLanguageOption('አማ', 'am'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String text, String code) {
    final isSelected = currentLanguage == code;

    return GestureDetector(
      onTap: () => onLanguageSelected(code),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding12,
          vertical: AppDimens.padding6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radius20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}