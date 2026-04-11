import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void show(
      String title,
      String message, {
        SnackPosition position = SnackPosition.BOTTOM,
      }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: position,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }
}