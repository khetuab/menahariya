// lib/modules/splash/views/splash_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/constants/app_strings.dart';
import 'package:menahariya/core/routes/app_routes.dart';
import 'package:menahariya/modules/splash/controllers/splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late final SplashController controller;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SplashController>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Pass animations to controller
    controller.setAnimations(
      controller: _animationController,
      fade: _fadeAnimation,
      scale: _scaleAnimation,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Set system UI mode
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              AppColors.black,
              AppColors.black,
            ]
                : [
              AppColors.white,
              AppColors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated Background Pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: SplashBackgroundPainter(
                    color: isDark ? AppColors.black : AppColors.white,
                    isDark: isDark,
                  ),
                ),
              ),

              // Main Content
              Center(
                child: Obx(() {
                  if (controller.hasError) {
                    return _buildErrorContent(context);
                  }
                  return _buildSplashContent(context);
                }),
              ),

              // Version Info
              Positioned(
                bottom: AppDimens.padding20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Version ${AppConstants.appVersion}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplashContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated Logo
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.asset(
                    'assets/logos/applogot.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
        ),


        const SizedBox(height: AppDimens.margin48),

        // Loading Progress
        Container(
          width: 200,
          margin: const EdgeInsets.symmetric(horizontal: AppDimens.padding32),
          child: Column(
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radius4),
                child: LinearProgressIndicator(
                  value: controller.loadingProgress,
                  minHeight: 4,
                  backgroundColor: isDark ? AppColors.grey700 : AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.margin12),

              // Loading Message
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.margin12),
                  Expanded(
                    child: Text(
                      controller.loadingMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimens.margin48),

        // University Info
        Column(
          children: [
            Text(
              AppStrings.appTitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
              ),
            ),
            Text(
              AppStrings.appSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Error Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isDark ? AppColors.error.withOpacity(0.2) : AppColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: 50,
            color: isDark ? AppColors.errorLight : AppColors.error,
          ),
        ),

        const SizedBox(height: AppDimens.margin24),

        // Error Title
        Text(
          'Oops! Something went wrong',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppDimens.margin12),

        // Error Message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding32),
          child: Text(
            controller.errorMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AppDimens.margin32),

        // Retry Button
        ElevatedButton.icon(
          onPressed: controller.retryInitialization,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radius30),
            ),
          ),
        ),

        const SizedBox(height: AppDimens.margin16),

        // Offline Mode Button
        TextButton(
          onPressed: () {
            Get.offNamed(AppRoutes.passengerDashboard);
          },
          child: Text(
            'Continue in Offline Mode',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom background painter for splash screen
class SplashBackgroundPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  SplashBackgroundPainter({
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw decorative circles
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 1; i <= 5; i++) {
      final radius = size.width * 0.2 * i;
      canvas.drawCircle(center, radius, paint);
    }

    // Draw diagonal lines
    final linePaint = Paint()
      ..color = color.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= 8; i++) {
      final offset = size.width * 0.15 * i;
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset + size.width * 0.5, size.height),
        linePaint,
      );
      canvas.drawLine(
        Offset(size.width - offset, 0),
        Offset(size.width - offset - size.width * 0.5, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}