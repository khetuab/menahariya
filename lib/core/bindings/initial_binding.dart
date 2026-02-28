// lib/core/bindings/initial_binding.dart

import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/connectivity/connectivity_service.dart';
import 'package:menahariya/core/services/notification/local_notification.dart';
import 'package:menahariya/core/services/notification/notification_service.dart';
import 'package:menahariya/core/services/payment/payment_service.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/core/services/storage/local_storage.dart';
import 'package:menahariya/core/services/storage/secure_storage.dart';
import 'package:menahariya/core/services/storage/shared_prefs.dart';
import 'package:menahariya/core/theme/theme_controller.dart';

import '../../modules/auth/controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Storage Services (Singleton)
    Get.put(SecureStorage(), permanent: true);
    Get.put(SharedPrefs(), permanent: true);
    Get.put(LocalStorage(), permanent: true);

    // Core Services
    Get.put(ApiClient(), permanent: true);
    Get.put(ConnectivityService(), permanent: true);
    Get.put(SocketService(), permanent: true);
    Get.put(LocalNotificationService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(PaymentService(), permanent: true);

    Get.put(ThemeController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    _initStorageServices();
  }

  Future<void> _initStorageServices() async {
    await Get.find<SharedPrefs>().init();
    await Get.find<LocalStorage>().init();
  }
}