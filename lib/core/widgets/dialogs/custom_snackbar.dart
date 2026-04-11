// lib/core/widgets/dialogs/custom_snackbar.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';

class CustomSnackbar {
  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  static void _removeCurrent() {
    _timer?.cancel();
    if (_currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry = null;
    }
  }

  static void show({
    required String title,
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Ensure we're on the main thread and after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _removeCurrent();

      final overlayState = Overlay.of(Get.overlayContext!);

      _currentEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(AppDimens.padding16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: AppDimens.iconSize24),
                      const SizedBox(width: AppDimens.margin12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: _removeCurrent,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      overlayState.insert(_currentEntry!);

      _timer = Timer(duration, _removeCurrent);
    });
  }

  static void showSuccess(String message) {
    show(
      title: 'Success',
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(String message) {
    show(
      title: 'Error',
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error_rounded,
    );
  }

  static void showWarning(String message) {
    show(
      title: 'Warning',
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning_rounded,
    );
  }

  static void showInfo(String message) {
    show(
      title: 'Information',
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info_rounded,
    );
  }
}