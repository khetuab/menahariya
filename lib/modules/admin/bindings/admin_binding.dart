// lib/modules/admin/bindings/admin_binding.dart

import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/admin_profile_controller.dart';
import '../controllers/admin_trip_controller.dart';
import '../controllers/admin_booking_controller.dart';
import '../controllers/admin_cargo_controller.dart';
import '../controllers/admin_user_controller.dart';
import '../controllers/admin_route_controller.dart';
import '../controllers/admin_vehicle_controller.dart';
import '../controllers/admin_report_controller.dart';
import '../controllers/admin_payment_controller.dart';
import '../controllers/admin_notification_controller.dart';
import '../controllers/admin_settings_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // Auth Controller (must be first)
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    // Dashboard & Analytics
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController(), fenix: true);

    // Core Management Controllers
    Get.lazyPut<AdminTripController>(() => AdminTripController(), fenix: true);
    Get.lazyPut<AdminBookingController>(() => AdminBookingController(), fenix: true);
    Get.lazyPut<AdminCargoController>(() => AdminCargoController(), fenix: true);
    Get.lazyPut<AdminUserController>(() => AdminUserController(), fenix: true);
    Get.lazyPut<AdminRouteController>(() => AdminRouteController(), fenix: true);
    Get.lazyPut<AdminVehicleController>(() => AdminVehicleController(), fenix: true);
    Get.lazyPut<AdminProfileController>(() => AdminProfileController(), fenix: true);

    // Finance & Reports
    Get.lazyPut<AdminPaymentController>(() => AdminPaymentController(), fenix: true);
    Get.lazyPut<AdminReportController>(() => AdminReportController(), fenix: true);

    // System Management
    Get.lazyPut<AdminNotificationController>(() => AdminNotificationController(), fenix: true);
    Get.lazyPut<AdminSettingsController>(() => AdminSettingsController(), fenix: true);
  }
}

// Individual bindings for better performance
class AdminLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
    Get.lazyPut<AdminTripController>(() => AdminTripController());
    Get.lazyPut<AdminBookingController>(() => AdminBookingController());
    Get.lazyPut<AdminCargoController>(() => AdminCargoController());
    Get.lazyPut<AdminUserController>(() => AdminUserController());
  }
}