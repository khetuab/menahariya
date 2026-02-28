// lib/modules/common/widgets/network_aware_widget.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/services/connectivity/connectivity_service.dart';
import 'package:menahariya/modules/common/views/no_internet_view.dart';

class NetworkAwareWidget extends StatelessWidget {
  final Widget onlineChild;
  final Widget? offlineChild;
  final bool showBanner;
  final bool fullScreenOffline;

  const NetworkAwareWidget({
    Key? key,
    required this.onlineChild,
    this.offlineChild,
    this.showBanner = true,
    this.fullScreenOffline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService.instance;

    return Obx(() {
      if (connectivityService.isConnected) {
        return onlineChild;
      } else {
        if (fullScreenOffline) {
          return const NoInternetView();
        }
        return offlineChild ?? _buildOfflinePlaceholder(context);
      }
    });
  }

  Widget _buildOfflinePlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        if (showBanner) _buildOfflineBanner(context),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
                ),
                const SizedBox(height: AppDimens.margin16),
                Text(
                  'No Internet Connection',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(height: AppDimens.margin8),
                Text(
                  'Please check your connection',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding16,
        vertical: AppDimens.padding8,
      ),
      color: Colors.orange,
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: AppDimens.margin8),
          Expanded(
            child: Text(
              'You are offline',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: AppFonts.medium,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed('/no-internet'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// Network Sensitive Button
class NetworkSensitiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final VoidCallback? onOfflinePressed;
  final IconData? icon;
  final bool requiresNetwork;

  const NetworkSensitiveButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.onOfflinePressed,
    this.icon,
    this.requiresNetwork = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService.instance;

    return Obx(() {
      final bool hasConnection = connectivityService.isConnected;

      if (requiresNetwork && !hasConnection) {
        return ElevatedButton(
          onPressed: () {
            if (onOfflinePressed != null) {
              onOfflinePressed!();
            } else {
              _showOfflineDialog(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 18),
              const SizedBox(width: AppDimens.margin8),
              Text('Offline - Tap to retry'),
            ],
          ),
        );
      }

      return ElevatedButton(
        onPressed: onPressed,
        child: icon != null
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: AppDimens.margin8),
            Text(text),
          ],
        )
            : Text(text),
      );
    });
  }

  void _showOfflineDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('This action requires an internet connection. Please check your network and try again.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onPressed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// Network Status Indicator
class NetworkStatusIndicator extends StatelessWidget {
  final bool showText;
  final double size;

  const NetworkStatusIndicator({
    Key? key,
    this.showText = false,
    this.size = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService.instance;

    return Obx(() {
      final bool isConnected = connectivityService.isConnected;

      if (showText) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.padding8,
            vertical: AppDimens.padding4,
          ),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(AppDimens.radius20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimens.margin4),
              Text(
                isConnected ? 'Online' : 'Offline',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isConnected ? Colors.green : Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      );
    });
  }
}

// Offline First Image
class OfflineFirstImage extends StatelessWidget {
  final String imageUrl;
  final String? placeholderAsset;
  final double? width;
  final double? height;
  final BoxFit fit;

  const OfflineFirstImage({
    Key? key,
    required this.imageUrl,
    this.placeholderAsset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService.instance;

    return Obx(() {
      if (!connectivityService.isConnected && placeholderAsset != null) {
        return Image.asset(
          placeholderAsset!,
          width: width,
          height: height,
          fit: fit,
        );
      }

      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (placeholderAsset != null) {
            return Image.asset(
              placeholderAsset!,
              width: width,
              height: height,
              fit: fit,
            );
          }
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image_rounded),
          );
        },
      );
    });
  }
}

// Retry Widget
class RetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData? icon;

  const RetryWidget({
    Key? key,
    required this.message,
    required this.onRetry,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: 64,
              color: isDark ? AppColors.errorLight : AppColors.error,
            ),
            const SizedBox(height: AppDimens.margin16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.margin24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding24,
                  vertical: AppDimens.padding12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectivityListener extends StatefulWidget {
  final Widget child;
  final VoidCallback? onOnline;
  final VoidCallback? onOffline;
  final bool showBanner;

  const ConnectivityListener({
    Key? key,
    required this.child,
    this.onOnline,
    this.onOffline,
    this.showBanner = false,
  }) : super(key: key);

  @override
  State<ConnectivityListener> createState() => _ConnectivityListenerState();
}

class _ConnectivityListenerState extends State<ConnectivityListener> {
  bool _wasOffline = false;
  bool _previousConnectionStatus = true;
  late ConnectivityService _connectivityService;

  // Timer for periodic checking
  late Timer _checkTimer;

  // Flag to track if banner is showing
  bool _isBannerShowing = false;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService.instance;
    _previousConnectionStatus = _connectivityService.isConnected;
    _setupListener();
    _startPeriodicCheck();
  }

  // FIXED: Use timer-based approach instead of ever
  void _setupListener() {
    // Initial check
    _checkConnectivity();

    // No need for ever - we'll use periodic checks
  }

  void _startPeriodicCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    // Get current connection status
    final isConnected = _connectivityService.isConnected;

    // Check if status changed
    if (isConnected != _previousConnectionStatus) {
      setState(() {
        _previousConnectionStatus = isConnected;
      });

      if (isConnected) {
        // We're now online
        if (_wasOffline) {
          widget.onOnline?.call();
          _showOnlineSnackbar();
          _wasOffline = false;

          // Dismiss banner if showing
          if (_isBannerShowing && Get.isSnackbarOpen) {
            Get.back();
            _isBannerShowing = false;
          }
        }
      } else {
        // We're now offline
        widget.onOffline?.call();
        _wasOffline = true;

        if (widget.showBanner && !_isBannerShowing) {
          _showOfflineBanner();
        }
      }
    }
  }

  void _showOnlineSnackbar() {
    if (!mounted) return;

    Get.snackbar(
      'Back Online',
      'Internet connection restored',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showOfflineBanner() {
    if (!mounted || _isBannerShowing) return;

    _isBannerShowing = true;

    Get.rawSnackbar(
      message: 'No internet connection',
      isDismissible: false,
      duration: const Duration(days: 1),
      backgroundColor: Colors.orange,
      margin: EdgeInsets.zero,
      borderRadius: 0,
      onTap: (snack) {
        // Optional: handle tap on banner
      },
    );
  }

  @override
  void dispose() {
    _checkTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Alternative version using ValueListenableBuilder if ConnectivityService supports it
class ConnectivityListenerAlt extends StatefulWidget {
  final Widget child;
  final VoidCallback? onOnline;
  final VoidCallback? onOffline;
  final bool showBanner;

  const ConnectivityListenerAlt({
    Key? key,
    required this.child,
    this.onOnline,
    this.onOffline,
    this.showBanner = false,
  }) : super(key: key);

  @override
  State<ConnectivityListenerAlt> createState() => _ConnectivityListenerAltState();
}

class _ConnectivityListenerAltState extends State<ConnectivityListenerAlt> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  late bool _wasOffline;

  @override
  void initState() {
    super.initState();
    _wasOffline = !_connectivityService.isConnected;
  }

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder or FutureBuilder to react to connectivity changes
    return StreamBuilder<bool>(
      stream: _connectivityStream(),
      initialData: _connectivityService.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        // Handle state changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleConnectivityChange(isConnected);
        });

        return widget.child;
      },
    );
  }

  Stream<bool> _connectivityStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      yield _connectivityService.isConnected;
    }
  }

  void _handleConnectivityChange(bool isConnected) {
    if (isConnected && _wasOffline) {
      widget.onOnline?.call();
      _showOnlineSnackbar();
      _wasOffline = false;

      // Dismiss offline banner if showing
      if (Get.isSnackbarOpen) {
        Get.back();
      }
    } else if (!isConnected && !_wasOffline) {
      widget.onOffline?.call();
      _wasOffline = true;

      if (widget.showBanner) {
        _showOfflineBanner();
      }
    }
  }

  void _showOnlineSnackbar() {
    Get.snackbar(
      'Back Online',
      'Internet connection restored',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showOfflineBanner() {
    Get.rawSnackbar(
      message: 'No internet connection',
      isDismissible: false,
      duration: const Duration(days: 1),
      backgroundColor: Colors.orange,
      margin: EdgeInsets.zero,
      borderRadius: 0,
    );
  }
}

// Simple wrapper using Obx if ConnectivityService exposes an RxBool
class ConnectivityListenerSimple extends StatelessWidget {
  final Widget child;
  final VoidCallback? onOnline;
  final VoidCallback? onOffline;
  final bool showBanner;

  const ConnectivityListenerSimple({
    Key? key,
    required this.child,
    this.onOnline,
    this.onOffline,
    this.showBanner = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This assumes ConnectivityService has an RxBool connection status
    // You would need to modify ConnectivityService to expose one
    return Obx(() {
      final isConnected = ConnectivityService.instance.isConnected;

      // Handle callbacks (this would need to be more sophisticated to prevent multiple calls)
      Future.microtask(() {
        // This is simplified - you'd need to track previous state
      });

      return child;
    });
  }
}