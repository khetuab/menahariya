// lib/core/bindings/global_bindings.dart

import 'package:get/get.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';
import 'package:menahariya/modules/passenger/controllers/dashboard_controller.dart';
import 'package:menahariya/modules/passenger/controllers/home_controller.dart';
import 'package:menahariya/modules/passenger/controllers/search_controller.dart';
import 'package:menahariya/modules/passenger/controllers/trip_detail_controller.dart';
import 'package:menahariya/modules/passenger/controllers/booking_controller.dart';
import 'package:menahariya/modules/passenger/controllers/payment_controller.dart';
import 'package:menahariya/modules/passenger/controllers/ticket_controller.dart';
import 'package:menahariya/modules/passenger/controllers/cargo_controller.dart';
import 'package:menahariya/modules/passenger/controllers/history_controller.dart';
import 'package:menahariya/modules/passenger/controllers/profile_controller.dart';
import 'package:menahariya/modules/passenger/controllers/notification_controller.dart';
import 'package:menahariya/modules/driver/controllers/dashboard_controller.dart' as driver;
import 'package:menahariya/modules/driver/controllers/trip_detail_controller.dart' as driver_trip;
import 'package:menahariya/modules/driver/controllers/boarding_controller.dart';
import 'package:menahariya/modules/driver/controllers/validation_controller.dart';
import 'package:menahariya/modules/driver/controllers/profile_controller.dart' as driver_profile;

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    // Auth Controller (Lazy)
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    // Passenger Controllers (Lazy)
    Get.lazyPut<PassengerDashboardController>(() => PassengerDashboardController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<PassengerSearchController>(() => PassengerSearchController(), fenix: true);
    Get.lazyPut<PassengerTripDetailController>(() => PassengerTripDetailController(), fenix: true);
    Get.lazyPut<PassengerBookingController>(() => PassengerBookingController(), fenix: true);
    Get.lazyPut<PassengerPaymentController>(() => PassengerPaymentController(), fenix: true);
    Get.lazyPut<PassengerTicketController>(() => PassengerTicketController(), fenix: true);
    Get.lazyPut<PassengerCargoController>(() => PassengerCargoController(), fenix: true);
    Get.lazyPut<PassengerHistoryController>(() => PassengerHistoryController(), fenix: true);
    Get.lazyPut<PassengerProfileController>(() => PassengerProfileController(), fenix: true);
    Get.lazyPut<PassengerNotificationController>(() => PassengerNotificationController(), fenix: true);

    // Driver Controllers (Lazy)
    Get.lazyPut<driver.DriverDashboardController>(() => driver.DriverDashboardController(), fenix: true);
    Get.lazyPut<driver_trip.DriverTripDetailController>(() => driver_trip.DriverTripDetailController(), fenix: true);
    Get.lazyPut<BoardingController>(() => BoardingController(), fenix: true);
    Get.lazyPut<ValidationController>(() => ValidationController(), fenix: true);
    Get.lazyPut<driver_profile.DriverProfileController>(() => driver_profile.DriverProfileController(), fenix: true);

    // Permanent Controllers (stay in memory)
    _initPermanentControllers();
  }

  void _initPermanentControllers() {
    // These controllers are needed throughout the app lifecycle
    Get.put(PassengerTripDetailController(), permanent: true);
    Get.put(PassengerPaymentController(), permanent: true);
    Get.put(PassengerNotificationController(), permanent: true);
  }
}

// Extension for easier controller access
extension ControllerExtensions on GetInterface {
  // Auth
  AuthController get auth => find<AuthController>();

  // Passenger
  PassengerDashboardController get passengerDashboard => find<PassengerDashboardController>();
  HomeController get passengerHome => find<HomeController>();
  PassengerSearchController get passengerSearch => find<PassengerSearchController>();
  PassengerTripDetailController get passengerTrip => find<PassengerTripDetailController>();
  PassengerBookingController get passengerBooking => find<PassengerBookingController>();
  PassengerPaymentController get passengerPayment => find<PassengerPaymentController>();
  PassengerTicketController get passengerTicket => find<PassengerTicketController>();
  PassengerCargoController get passengerCargo => find<PassengerCargoController>();
  PassengerHistoryController get passengerHistory => find<PassengerHistoryController>();
  PassengerProfileController get passengerProfile => find<PassengerProfileController>();
  PassengerNotificationController get passengerNotifications => find<PassengerNotificationController>();

  // Driver
  driver.DriverDashboardController get driverDashboard => find<driver.DriverDashboardController>();
  driver_trip.DriverTripDetailController get driverTrip => find<driver_trip.DriverTripDetailController>();
  BoardingController get driverBoarding => find<BoardingController>();
  ValidationController get driverValidation => find<ValidationController>();
  driver_profile.DriverProfileController get driverProfile => find<driver_profile.DriverProfileController>();
}

// Bindings for specific modules
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class PassengerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerDashboardController>(() => PassengerDashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<PassengerSearchController>(() => PassengerSearchController());
    Get.lazyPut<PassengerTripDetailController>(() => PassengerTripDetailController());
    Get.lazyPut<PassengerBookingController>(() => PassengerBookingController());
    Get.lazyPut<PassengerPaymentController>(() => PassengerPaymentController());
    Get.lazyPut<PassengerTicketController>(() => PassengerTicketController());
    Get.lazyPut<PassengerCargoController>(() => PassengerCargoController());
    Get.lazyPut<PassengerHistoryController>(() => PassengerHistoryController());
    Get.lazyPut<PassengerProfileController>(() => PassengerProfileController());
    Get.lazyPut<PassengerNotificationController>(() => PassengerNotificationController());
  }
}

class DriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<driver.DriverDashboardController>(() => driver.DriverDashboardController());
    Get.lazyPut<driver_trip.DriverTripDetailController>(() => driver_trip.DriverTripDetailController());
    Get.lazyPut<BoardingController>(() => BoardingController());
    Get.lazyPut<ValidationController>(() => ValidationController());
    Get.lazyPut<driver_profile.DriverProfileController>(() => driver_profile.DriverProfileController());
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Only load what's needed for splash screen
    Get.lazyPut<AuthController>(() => AuthController());
  }
}