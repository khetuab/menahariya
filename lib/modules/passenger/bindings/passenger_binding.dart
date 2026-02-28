// lib/modules/passenger/bindings/passenger_binding.dart

import 'package:get/get.dart';
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

class PassengerBinding extends Bindings {
  @override
  void dependencies() {
    // Dashboard Controller (main controller)
    Get.lazyPut<PassengerDashboardController>(() => PassengerDashboardController(), fenix: true);

    // Feature Controllers
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
  }
}

// Individual screen bindings for better performance
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerSearchController>(() => PassengerSearchController());
  }
}

class TripDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerTripDetailController>(() => PassengerTripDetailController());
  }
}

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerBookingController>(() => PassengerBookingController());
  }
}

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerPaymentController>(() => PassengerPaymentController());
  }
}

class TicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerTicketController>(() => PassengerTicketController());
  }
}

class CargoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerCargoController>(() => PassengerCargoController());
  }
}

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerHistoryController>(() => PassengerHistoryController());
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerProfileController>(() => PassengerProfileController());
  }
}

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerNotificationController>(() => PassengerNotificationController());
  }
}