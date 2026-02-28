// lib/core/routes/app_pages.dart

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/routes/app_routes.dart';
import 'package:menahariya/modules/splash/bindings/splash_binding.dart';
import 'package:menahariya/modules/splash/views/splash_view.dart';
import 'package:menahariya/modules/auth/bindings/auth_binding.dart';
import 'package:menahariya/modules/auth/views/login_view.dart';
import 'package:menahariya/modules/auth/views/register_view.dart';
import 'package:menahariya/modules/auth/views/otp_verification_view.dart';
import 'package:menahariya/modules/auth/views/reset_password_view.dart';
import 'package:menahariya/modules/passenger/bindings/passenger_binding.dart';
import 'package:menahariya/modules/passenger/views/dashboard_view.dart';
import 'package:menahariya/modules/passenger/views/home/home_view.dart';
import 'package:menahariya/modules/passenger/views/search/search_view.dart';
import 'package:menahariya/modules/passenger/views/search/search_results_view.dart';
import 'package:menahariya/modules/passenger/views/trip/trip_detail_view.dart';
import 'package:menahariya/modules/passenger/views/booking/seat_selection_view.dart';
import 'package:menahariya/modules/passenger/views/booking/booking_summary_view.dart';
import 'package:menahariya/modules/passenger/views/payment/payment_view.dart';
import 'package:menahariya/modules/passenger/views/payment/payment_success_view.dart';
import 'package:menahariya/modules/passenger/views/tickets/my_tickets_view.dart';
import 'package:menahariya/modules/passenger/views/tickets/ticket_detail_view.dart';
import 'package:menahariya/modules/passenger/views/tickets/ticket_qr_view.dart';
import 'package:menahariya/modules/passenger/views/cargo/cargo_registration_view.dart';
import 'package:menahariya/modules/passenger/views/cargo/cargo_tracking_view.dart';
import 'package:menahariya/modules/passenger/views/cargo/cargo_receipt_view.dart';
import 'package:menahariya/modules/passenger/views/history/booking_history_view.dart';
import 'package:menahariya/modules/passenger/views/history/cargo_history_view.dart';
import 'package:menahariya/modules/passenger/views/profile/profile_view.dart';
import 'package:menahariya/modules/passenger/views/profile/edit_profile_view.dart';
import 'package:menahariya/modules/passenger/views/profile/settings_view.dart';
import 'package:menahariya/modules/passenger/views/notifications/notifications_view.dart';
import 'package:menahariya/modules/driver/bindings/driver_binding.dart';
import 'package:menahariya/modules/driver/views/dashboard_view.dart';
import 'package:menahariya/modules/driver/views/boarding/boarding_management_view.dart';
import 'package:menahariya/modules/driver/views/boarding/validation_view.dart';
import 'package:menahariya/modules/driver/views/manifests/passenger_manifest_view.dart';
import 'package:menahariya/modules/driver/views/manifests/cargo_manifest_view.dart';
import 'package:menahariya/modules/driver/views/incidents/report_incident_view.dart';
import 'package:menahariya/modules/driver/views/profile/profile_view.dart';
import 'package:menahariya/modules/driver/views/profile/availability_view.dart';
import 'package:menahariya/modules/driver/views/profile/settings_view.dart';
import 'package:menahariya/modules/driver/views/notifications/notifications_view.dart';
import 'package:menahariya/modules/common/views/no_internet_view.dart';
import 'package:menahariya/modules/common/views/server_error_view.dart';
import 'package:menahariya/modules/common/views/not_found_view.dart';
import 'package:menahariya/modules/common/views/under_construction_view.dart';

import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/auth/views/forgot_password_view.dart';
import '../../modules/driver/trips/assigned_trips_view.dart';
import '../../modules/driver/views/trip/update_trip_status_view.dart';
import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/views/onboarding_view.dart';

class AppPages {
  // Private constructor
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    // Auth Routes
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView( ),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Passenger Routes
    GetPage(
      name: AppRoutes.passengerDashboard,
      page: () => const PassengerDashboardView(),
      binding: PassengerBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerHome,
      page: () => const HomeView(),
      binding: PassengerBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerSearch,
      page: () => const PassengerSearchView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerSearchResults,
      page: () => const SearchResultsView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerTripDetail,
      page: () => const TripDetailView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerSeatSelection,
      page: () => const SeatSelectionView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerBookingSummary,
      page: () => const BookingSummaryView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerPayment,
      page: () => const PaymentView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerPaymentSuccess,
      page: () => const PaymentSuccessView(),
      binding: PassengerBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerMyTickets,
      page: () => const MyTicketsView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerTicketDetail,
      page: () => const TicketDetailView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerTicketQR,
      page: () => const TicketQRView(),
      binding: PassengerBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerCargoRegistration,
      page: () => const CargoRegistrationView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerCargoTracking,
      page: () => const CargoTrackingView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerCargoReceipt,
      page: () => const CargoReceiptView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerBookingHistory,
      page: () => const BookingHistoryView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerCargoHistory,
      page: () => const CargoHistoryView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerProfile,
      page: () => const ProfileView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerEditProfile,
      page: () => const EditProfileView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerSettings,
      page: () => const SettingsView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerNotifications,
      page: () => const PassengerNotificationsView(),
      binding: PassengerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),

    // Driver Routes
    GetPage(
      name: AppRoutes.driverDashboard,
      page: () => const DriverDashboardView(),
      binding: DriverBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverAssignedTrips,
      page: () => const AssignedTripsView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverTripDetail,
      page: () => const TripDetailView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverBoardingManagement,
      page: () => const BoardingManagementView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverTicketValidation,
      page: () => const ValidationView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverPassengerManifest,
      page: () => const PassengerManifestView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverCargoManifest,
      page: () => const CargoManifestView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverUpdateTripStatus,
      page: () => const UpdateTripStatusView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverReportIncident,
      page: () => const ReportIncidentView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverProfile,
      page: () => const DriverProfileView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverAvailability,
      page: () => const AvailabilityView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverSettings,
      page: () => const DriverSettingsView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverNotifications,
      page: () => const DriverNotificationsView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),

    // Common Routes
    GetPage(
      name: AppRoutes.noInternet,
      page: () => const NoInternetView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.serverError,
      page: () => const ServerErrorView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.notFound,
      page: () => const NotFoundView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.underConstruction,
      page: () => const UnderConstructionView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}

// Auth Middleware for role-based access control
class AuthMiddleware extends GetMiddleware {
  final String? role;

  AuthMiddleware({this.role});

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // Check if user is logged in
    if (!authController.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // Check role-based access
    if (role != null && authController.userRole != role) {
      // Redirect to appropriate dashboard based on role
      if (authController.userRole == 'passenger') {
        return const RouteSettings(name: AppRoutes.passengerDashboard);
      } else if (authController.userRole == 'driver') {
        return const RouteSettings(name: AppRoutes.driverDashboard);
      }
    }

    return null;
  }
}