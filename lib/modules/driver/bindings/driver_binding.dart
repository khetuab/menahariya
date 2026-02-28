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

class DriverBinding extends Bindings {
  @override
  void dependencies() {
    // Main Dashboard Controller
    Get.lazyPut<DriverDashboardController>(() => DriverDashboardController(), fenix: true);

    // Trip Management Controllers
    Get.lazyPut<AssignedTripsController>(() => AssignedTripsController(), fenix: true);
    Get.lazyPut<DriverTripDetailController>(() => DriverTripDetailController(), fenix: true);

    // Boarding & Validation Controllers
    Get.lazyPut<BoardingController>(() => BoardingController(), fenix: true);
    Get.lazyPut<ValidationController>(() => ValidationController(), fenix: true);

    // Manifest Controllers
    Get.lazyPut<PassengerListController>(() => PassengerListController(), fenix: true);
    Get.lazyPut<CargoListController>(() => CargoListController(), fenix: true);

    // Status & Incident Controllers
    Get.lazyPut<TripStatusController>(() => TripStatusController(), fenix: true);
    Get.lazyPut<IncidentController>(() => IncidentController(), fenix: true);

    // Profile & Notification Controllers
    Get.lazyPut<DriverProfileController>(() => DriverProfileController(), fenix: true);
    Get.lazyPut<DriverNotificationController>(() => DriverNotificationController(), fenix: true);
  }
}

// Individual screen bindings for better performance and lazy loading

class DriverDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverDashboardController>(() => DriverDashboardController());
  }
}

class AssignedTripsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssignedTripsController>(() => AssignedTripsController());
  }
}

class DriverTripDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverTripDetailController>(() => DriverTripDetailController());
  }
}

class BoardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BoardingController>(() => BoardingController());
  }
}

class ValidationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ValidationController>(() => ValidationController());
  }
}

class PassengerManifestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerListController>(() => PassengerListController());
  }
}

class CargoManifestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CargoListController>(() => CargoListController());
  }
}

class TripStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripStatusController>(() => TripStatusController());
  }
}

class IncidentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncidentController>(() => IncidentController());
  }
}

class DriverProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverProfileController>(() => DriverProfileController());
  }
}

class DriverAvailabilityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverProfileController>(() => DriverProfileController());
  }
}

class DriverSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverProfileController>(() => DriverProfileController());
  }
}

class DriverNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverNotificationController>(() => DriverNotificationController());
  }
}

// Extension for easier controller access
extension DriverControllerExtensions on GetInterface {
  // Dashboard
  DriverDashboardController get driverDashboard => find<DriverDashboardController>();

  // Trip Management
  AssignedTripsController get assignedTrips => find<AssignedTripsController>();
  DriverTripDetailController get driverTripDetail => find<DriverTripDetailController>();

  // Boarding & Validation
  BoardingController get boarding => find<BoardingController>();
  ValidationController get validation => find<ValidationController>();

  // Manifests
  PassengerListController get passengerList => find<PassengerListController>();
  CargoListController get cargoList => find<CargoListController>();

  // Status & Incident
  TripStatusController get tripStatus => find<TripStatusController>();
  IncidentController get incident => find<IncidentController>();

  // Profile & Notifications
  DriverProfileController get driverProfile => find<DriverProfileController>();
  DriverNotificationController get driverNotifications => find<DriverNotificationController>();
}

// Initial binding for driver module (loads essential controllers)
class DriverInitialBinding extends Bindings {
  @override
  void dependencies() {
    // Load only essential controllers for dashboard
    Get.put(DriverDashboardController(), permanent: true);
    Get.put(AssignedTripsController(), permanent: true);
    Get.put(DriverNotificationController(), permanent: true);

    // Other controllers will be lazy loaded when needed
    Get.lazyPut<DriverTripDetailController>(() => DriverTripDetailController());
    Get.lazyPut<BoardingController>(() => BoardingController());
    Get.lazyPut<ValidationController>(() => ValidationController());
    Get.lazyPut<PassengerListController>(() => PassengerListController());
    Get.lazyPut<CargoListController>(() => CargoListController());
    Get.lazyPut<TripStatusController>(() => TripStatusController());
    Get.lazyPut<IncidentController>(() => IncidentController());
    Get.lazyPut<DriverProfileController>(() => DriverProfileController());
  }
}