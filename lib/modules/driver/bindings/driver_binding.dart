// lib/modules/driver/bindings/driver_binding.dart

import 'package:get/get.dart';
import 'package:menahariya/modules/driver/controllers/dashboard_controller.dart';
import 'package:menahariya/modules/driver/controllers/assigned_trips_controller.dart';
import 'package:menahariya/modules/driver/controllers/trip_detail_controller.dart';
import 'package:menahariya/modules/driver/controllers/boarding_controller.dart';
import 'package:menahariya/modules/driver/controllers/validation_controller.dart';
import 'package:menahariya/modules/driver/controllers/passenger_list_controller.dart';
import 'package:menahariya/modules/driver/controllers/cargo_list_controller.dart';
import 'package:menahariya/modules/driver/controllers/trip_status_controller.dart';
import 'package:menahariya/modules/driver/controllers/incident_controller.dart';
import 'package:menahariya/modules/driver/controllers/profile_controller.dart';
import 'package:menahariya/modules/driver/controllers/notification_controller.dart';

import '../../promotion/controllers/promotion_controller.dart';
import '../controllers/driver_state_controller.dart';
import '../controllers/driver_support_controller.dart';
import '../controllers/trip_history_controller.dart';

class DriverBinding extends Bindings {
  @override
  void dependencies() {
    // Use lazyPut for all controllers to avoid duplicate registration
    Get.lazyPut<DriverDashboardController>(() => DriverDashboardController(), fenix: true);
    Get.lazyPut<AssignedTripsController>(() => AssignedTripsController(), fenix: true);
    Get.lazyPut<DriverTripDetailController>(() => DriverTripDetailController(), fenix: true);
    Get.lazyPut<BoardingController>(() => BoardingController(), fenix: true);
    Get.lazyPut<ValidationController>(() => ValidationController(), fenix: true);
    Get.lazyPut<DriverStateController>(() => DriverStateController(), fenix: true);
    Get.lazyPut<DriverTripHistoryController>(() => DriverTripHistoryController(), fenix: true);
    Get.lazyPut<DriverSupportController>(() => DriverSupportController(), fenix: true);
    Get.lazyPut<PromotionController>(() => PromotionController(), fenix: true);
    // Get.lazyPut<PassengerListController>(() => PassengerListController(), fenix: true);
    // Get.lazyPut<CargoListController>(() => CargoListController(), fenix: true);
    Get.lazyPut<TripStatusController>(() => TripStatusController(), fenix: true);
    Get.lazyPut<IncidentController>(() => IncidentController(), fenix: true);
    Get.lazyPut<DriverProfileController>(() => DriverProfileController(), fenix: true);
    Get.lazyPut<DriverNotificationController>(() => DriverNotificationController(), fenix: true);
  }
}
