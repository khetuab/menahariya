// lib/modules/common/views/no_internet_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/services/connectivity/connectivity_service.dart';

class NoInternetView extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool autoRetry;

  const NoInternetView({
    Key? key,
    this.onRetry,
    this.autoRetry = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // FIXED: Use Worker with a custom approach instead of ever
    if (autoRetry) {
      // Use a periodic timer to check connectivity instead of ever
      _startConnectivityCheck();
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated illustration
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 100,
                        color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                      ),
                      Positioned(
                        bottom: 40,
                        right: 40,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.errorLight : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.margin40),

              // Title
              Text(
                'No Internet Connection',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppFonts.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimens.margin16),

              // Message
              Text(
                'Please check your internet connection and try again.\n\nThe app will automatically reconnect when internet is available.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimens.margin40),

              // Retry button
              PrimaryButton(
                text: 'Try Again',
                onPressed: onRetry ?? () => _checkAndRetry(context),
                icon: Icons.refresh_rounded,
              ),

              const SizedBox(height: AppDimens.margin16),

              // Offline mode option
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    'Offline Mode',
                    'You can continue with limited functionality',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: Text(
                  'Continue in Offline Mode',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FIXED: Use timer-based approach instead of ever
  void _startConnectivityCheck() {
    const checkInterval = Duration(seconds: 2);

    Future.delayed(checkInterval, () async {
      if (!Get.isSnackbarOpen) {
        final connectivityService = ConnectivityService.instance;
        final hasConnection = await connectivityService.hasInternetConnection();

        if (hasConnection) {
          Get.back();
        } else {
          // Continue checking
          _startConnectivityCheck();
        }
      }
    });
  }

  Future<void> _checkAndRetry(BuildContext context) async {
    final connectivityService = ConnectivityService.instance;
    final hasConnection = await connectivityService.hasInternetConnection();

    if (hasConnection) {
      Get.back();
    } else {
      Get.snackbar(
        'Still No Connection',
        'Unable to connect to the internet. Please check your network settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
}

// Alternative solution using StatefulWidget with listener
class NoInternetViewAlt extends StatefulWidget {
  final VoidCallback? onRetry;
  final bool autoRetry;

  const NoInternetViewAlt({
    Key? key,
    this.onRetry,
    this.autoRetry = true,
  }) : super(key: key);

  @override
  State<NoInternetViewAlt> createState() => _NoInternetViewAltState();
}

class _NoInternetViewAltState extends State<NoInternetViewAlt> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;

  @override
  void initState() {
    super.initState();
    if (widget.autoRetry) {
      _setupConnectivityListener();
    }
  }

  // FIXED: Use proper listener pattern
  void _setupConnectivityListener() {
    // Use a periodic check or add listener if ConnectivityService supports it
    _checkConnectivityPeriodically();
  }

  void _checkConnectivityPeriodically() {
    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        final hasConnection = await _connectivityService.hasInternetConnection();

        if (hasConnection) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else {
          // Continue checking
          _checkConnectivityPeriodically();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated illustration
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 100,
                        color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                      ),
                      Positioned(
                        bottom: 40,
                        right: 40,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.errorLight : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.margin40),

              // Title
              Text(
                'No Internet Connection',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppFonts.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimens.margin16),

              // Message
              Text(
                'Please check your internet connection and try again.\n\nThe app will automatically reconnect when internet is available.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimens.margin40),

              // Retry button
              PrimaryButton(
                text: 'Try Again',
                onPressed: widget.onRetry ?? _checkAndRetry,
                icon: Icons.refresh_rounded,
              ),

              const SizedBox(height: AppDimens.margin16),

              // Offline mode option
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  Get.snackbar(
                    'Offline Mode',
                    'You can continue with limited functionality',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: Text(
                  'Continue in Offline Mode',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkAndRetry() async {
    final hasConnection = await _connectivityService.hasInternetConnection();

    if (hasConnection) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      Get.snackbar(
        'Still No Connection',
        'Unable to connect to the internet. Please check your network settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
}

// No Internet Banner (for use in screens)
class NoInternetBanner extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetBanner({Key? key, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.padding12),
      color: Colors.orange,
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: AppDimens.margin8),
          Expanded(
            child: Text(
              'No internet connection',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: AppFonts.medium,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}