// lib/core/routes/app_pages.dart

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/routes/app_routes.dart';
import 'package:menahariya/modules/driver/trips/trip_detail_view.dart';
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

// ==================== ADMIN IMPORTS ====================
import 'package:menahariya/modules/admin/bindings/admin_binding.dart';
import 'package:menahariya/modules/admin/views/admin_dashboard_view.dart';
import 'package:menahariya/modules/admin/views/admin_trips_view.dart';
import 'package:menahariya/modules/admin/views/admin_bookings_view.dart';
import 'package:menahariya/modules/admin/views/admin_cargo_view.dart';
import 'package:menahariya/modules/admin/views/admin_users_view.dart';
import 'package:menahariya/modules/admin/views/admin_routes_view.dart';
import 'package:menahariya/modules/admin/views/admin_vehicles_view.dart';
import 'package:menahariya/modules/admin/views/admin_reports_view.dart';
import 'package:menahariya/modules/admin/views/admin_payments_view.dart';
import 'package:menahariya/modules/admin/views/admin_notifications_view.dart';
import 'package:menahariya/modules/admin/views/admin_settings_view.dart';

// ==================== OTHER IMPORTS ====================
import '../../modules/admin/controllers/admin_support_controller.dart';
import '../../modules/admin/views/admin_profile_view.dart';
import '../../modules/admin/views/admin_support_view.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/auth/views/change_password_view.dart';
import '../../modules/auth/views/forgot_password_view.dart';
import '../../modules/auth/views/two_factor_verify_view.dart';
import '../../modules/cargo/views/cargo_dashboard_view.dart';
import '../../modules/cargo/views/cargo_list_view.dart';
import '../../modules/cargo/views/cargo_update_view.dart';
import '../../modules/driver/trips/assigned_trips_view.dart';
import '../../modules/driver/views/boarding/trip_selection_view.dart';
import '../../modules/driver/views/profile/edit_profile_view.dart';
import '../../modules/driver/views/support/support_view.dart';
import '../../modules/driver/views/trip/trip_history_view.dart';
import '../../modules/driver/views/trip/update_trip_status_view.dart';
import '../../modules/legal/view/privacy_view.dart';
import '../../modules/legal/view/terms_view.dart';
import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/views/onboarding_view.dart';
import '../../modules/passenger/views/cargo/cargo_trip_select_view.dart';
import '../../modules/passenger/views/payment/payment_detail_view.dart';
import '../../modules/passenger/views/support/my_support_tickets_view.dart';
import '../../modules/passenger/views/support/privacy_security_view.dart';
import '../../modules/passenger/views/support/about_view.dart';
import '../../modules/passenger/views/support/help_support_view.dart';
import '../../modules/passenger/views/support/ticket_detail_view.dart';
import '../../modules/passenger/views/tickets/ticket_trip_select_view.dart';
import '../../modules/promotion/views/admin_promotions_view.dart';
import '../../modules/ticketing/views/bookings_view.dart';
import '../../modules/ticketing/views/ticketing_boarding_view.dart';
import '../../modules/ticketing/views/ticketing_dashboard_view.dart';
import '../../modules/ticketing/views/ticketing_payments_view.dart';
import '../../modules/ticketing/views/ticketing_trips_view.dart';

// ==================== CUSTOM TRANSITIONS ====================

/// 1. Zoom Transition - Smooth zoom in/out effect (No slide)
class ZoomTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final curveAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    final scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(curveAnimation);

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curveAnimation);

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: opacityAnimation,
        child: child,
      ),
    );
  }
}

/// 2. Elastic Zoom Transition - With bounce effect (Very smooth)
class ElasticZoomTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final curveAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.elasticOut,
    );

    final scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(curveAnimation);

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOut),
    );

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: opacityAnimation,
        child: child,
      ),
    );
  }
}

/// 3. Fade Scale Transition - Professional fade with subtle scale
class FadeScaleTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
    );

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeInOut),
    );

    return FadeTransition(
      opacity: opacityAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: child,
      ),
    );
  }
}

/// 4. Circular Reveal Transition (Modern material design)
class CircularRevealTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return ClipPath(
      clipper: _CircleRevealClipper(animation),
      child: child,
    );
  }
}

class _CircleRevealClipper extends CustomClipper<Path> {
  final Animation<double> animation;

  _CircleRevealClipper(this.animation);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2 * animation.value;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircleRevealClipper oldClipper) {
    return animation.value != oldClipper.animation.value;
  }
}

/// 5. Fade In Only (Cleanest transition - No movement at all)
class FadeInTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeIn,
      ),
      child: child,
    );
  }
}

/// 6. Fade Out In (Classic crossfade)
class CrossFadeTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return Stack(
      children: [
        FadeTransition(
          opacity: CurvedAnimation(
            parent: secondaryAnimation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
          child: secondaryAnimation.status == AnimationStatus.reverse
              ? null
              : const SizedBox.shrink(),
        ),
        FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
          ),
          child: child,
        ),
      ],
    );
  }
}

/// 7. Size Transition (Expands from center - Modern)
class SizeExpandTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final sizeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: sizeAnimation,
      builder: (context, child) {
        return ClipRect(
          child: Transform.scale(
            scale: sizeAnimation.value,
            child: Opacity(
              opacity: sizeAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// 8. Rotate + Scale Transition (3D like effect)
class RotateScaleTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    );

    final scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
    );

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOut),
    );

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateX(rotationAnimation.value),
      child: ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(
          opacity: opacityAnimation,
          child: child,
        ),
      ),
    );
  }
}

/// 9. Blur Transition (iOS-like, very smooth)
class BlurTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final blurAnimation = Tween<double>(
      begin: 8.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    );

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: blurAnimation,
      builder: (context, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAnimation.value, sigmaY: blurAnimation.value),
          child: FadeTransition(
            opacity: opacityAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// 10. Material Shared Axis (Modern Google design)
class SharedAxisTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    );

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOut),
    );

    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      ),
    );
  }
}

class AppPages {
  // Private constructor
  AppPages._();

  static const initial = AppRoutes.splash;
  static const transitionDuration = Duration(milliseconds: 450);

  static final routes = [
    // ==================== SPLASH & ONBOARDING ====================
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      customTransition: FadeInTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      customTransition: ZoomTransition(),
      transitionDuration: transitionDuration,
    ),

    // ==================== LEGAL PAGES ====================
    GetPage(
      name: '/terms',
      page: () => const TermsView(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: '/privacy',
      page: () => const PrivacyView(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
    ),

    // ==================== ADMIN PAGES ====================
    GetPage(
      name: AppRoutes.adminProfile,
      page: () => const AdminProfileView(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.adminSettings,
      page: () => const AdminSettingsView(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminBinding(),
      customTransition: ElasticZoomTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),

    GetPage(
      name: AppRoutes.adminTrips,
      page: () => const AdminTripsView(),
      binding: AdminBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),
    GetPage(
      name: AppRoutes.adminBookings,
      page: () => const AdminBookingsView(),
      binding: AdminBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),
    GetPage(
      name: AppRoutes.adminCargo,
      page: () => const AdminCargoView(),
      binding: AdminBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),
    GetPage(
      name: AppRoutes.adminUsers,
      page: () => const AdminUsersView(),
      binding: AdminBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),
    GetPage(
      name: AppRoutes.adminRoutes,
      page: () => const AdminRoutesView(),
      binding: AdminBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),
    GetPage(
      name: AppRoutes.adminVehicles,
      page: () => const AdminVehiclesView(),
      binding: AdminBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),
    GetPage(
      name: AppRoutes.adminReports,
      page: () => const AdminReportsView(),
      binding: AdminBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),
    GetPage(
      name: AppRoutes.adminPayments,
      page: () => const AdminPaymentsView(),
      binding: AdminBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),
    GetPage(
      name: AppRoutes.adminNotifications,
      page: () => const AdminNotificationsView(),
      binding: AdminBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),
    GetPage(
      name: AppRoutes.adminSettings,
      page: () => const AdminSettingsView(),
      binding: AdminBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),

    // ==================== AUTH ROUTES ====================
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      customTransition: ZoomTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationView(),
      binding: AuthBinding(),
      customTransition: ZoomTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.twoFactorVerify,
      page: () => const TwoFactorVerifyView(),
      customTransition: ZoomTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),

    // ==================== PASSENGER ROUTES ====================
    GetPage(
      name: AppRoutes.passengerDashboard,
      page: () => const PassengerDashboardView(),
      binding: PassengerBinding(),
      customTransition: ElasticZoomTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerHome,
      page: () => const HomeView(),
      binding: PassengerBinding(),
      customTransition: FadeInTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerSearch,
      page: () => const PassengerSearchView(),
      binding: PassengerBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerSearchResults,
      page: () => const SearchResultsView(),
      binding: PassengerBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerTripDetail,
      page: () => const TripDetailView(),
      binding: PassengerBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerSeatSelection,
      page: () => const SeatSelectionView(),
      binding: PassengerBinding(),
      customTransition: ZoomTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerBookingSummary,
      page: () => const BookingSummaryView(),
      binding: PassengerBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerPayment,
      page: () => const PaymentView(),
      binding: PassengerBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerPaymentSuccess,
      page: () => const PaymentSuccessView(),
      customTransition: ElasticZoomTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerMyTickets,
      page: () => const MyTicketsView(),
      binding: PassengerBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerTicketDetail,
      page: () => const TicketDetailView(),
      binding: PassengerBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerTicketQR,
      page: () => const TicketQRView(),
      binding: PassengerBinding(),
      customTransition: ZoomTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerTicketSelectTrip,
      page: () => const TicketTripSelectView(),
      binding: PassengerBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerCargoRegistration,
      page: () => const CargoRegistrationView(),
      binding: PassengerBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerCargoTracking,
      page: () => const CargoTrackingView(),
      binding: PassengerBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerCargoReceipt,
      page: () => const CargoReceiptView(),
      binding: PassengerBinding(),
      customTransition: ZoomTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerCargoSelectTrip,
      page: () => const CargoTripSelectView(),
      binding: PassengerBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerBookingHistory,
      page: () => const BookingHistoryView(),
      binding: PassengerBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerCargoHistory,
      page: () => const CargoHistoryView(),
      binding: PassengerBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerProfile,
      page: () => const ProfileView(),
      binding: PassengerBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerEditProfile,
      page: () => const EditProfileView(),
      binding: PassengerBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerSettings,
      page: () => const SettingsView(),
      binding: PassengerBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.passengerNotifications,
      page: () => const PassengerNotificationsView(),
      binding: PassengerBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.privacySecurity,
      page: () => const PrivacySecurityView(),
      binding: PassengerBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.helpSupport,
      page: () => HelpSupportView(),
      binding: PassengerBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.mySupportTickets,
      page: () => const MySupportTicketsView(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.ticketDetail,
      page: () => const TicketDetailView(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutView(),
      binding: PassengerBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'passenger')],
    ),

    // ==================== DRIVER ROUTES ====================
    GetPage(
      name: AppRoutes.driverDashboard,
      page: () => const DriverDashboardView(),
      binding: DriverBinding(),
      customTransition: ElasticZoomTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverAssignedTrips,
      page: () => const AssignedTripsView(),
      binding: DriverBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),

    GetPage(
      name: AppRoutes.passengerNotifications,
      page: () => const PassengerNotificationsView(),
      binding: PassengerBinding()
    ),
    // Add these dynamic routes
    GetPage(
      name: '${AppRoutes.passengerTicketDetails}/:id',
      page: () => const TicketDetailView(),
    ),
    GetPage(
      name: '${AppRoutes.passengerTripDetails}/:id',
      page: () => const TripDetailView(),
    ),
    GetPage(
      name: '${AppRoutes.passengerPaymentDetails}/:id',
      page: () => const PassengerPaymentDetailView(),
    ),
    GetPage(
      name: AppRoutes.passengerCargoTrack,
      page: () => const CargoTrackingView(),
    ),
    GetPage(
      name: '/passenger/support/ticket/:id',
      page: () => const TicketDetailView(),
    ),
    // In app_pages.dart
    GetPage(
      name: '/driver/trip/:tripId',
      page: () => const DriverTripDetailView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: '/driver/support',
      page: () => const SupportView(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.driverTripStatus,
      page: () => const UpdateTripStatusView(),
      binding: DriverBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverBoarding,
      page: () => const BoardingManagementView(),
      binding: DriverBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: '/driver/boarding/trips',
      page: () => const TripSelectionView(),
      binding: DriverBinding(),
      transition: Transition.rightToLeft,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),

    GetPage(
      name: '/driver/trips',
      page: () => const DriverTripHistoryView(),
      binding: DriverBinding(),
      customTransition: SharedAxisTransition(),
      middlewares: [AuthMiddleware(role: 'driver')],
    ),

    GetPage(
      name: AppRoutes.driverBoardingManagement,
      page: () => const BoardingManagementView(),
      binding: DriverBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverTicketValidation,
      page: () => const ValidationView(),
      binding: DriverBinding(),
      customTransition: ZoomTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverUpdateTripStatus,
      page: () => const UpdateTripStatusView(),
      binding: DriverBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverReportIncident,
      page: () => const ReportIncidentView(),
      binding: DriverBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverProfile,
      page: () => const DriverProfileView(),
      binding: DriverBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: '/driver/profile/edit',
      page: () => const DriverEditProfileView(),
      binding: DriverBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverAvailability,
      page: () => const AvailabilityView(),
      binding: DriverBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverSettings,
      page: () => const DriverSettingsView(),
      binding: DriverBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: AppRoutes.driverNotifications,
      page: () => const DriverNotificationsView(),
      binding: DriverBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: '/driver/passenger-manifest/:tripId',
      page: () => const PassengerManifestView(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),
    GetPage(
      name: '/driver/cargo-manifest/:tripId',
      page: () => const CargoManifestView(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'driver')],
    ),

    // ==================== ADMIN SUPPORT ====================
    GetPage(
      name: AppRoutes.adminSupport,
      page: () => AdminSupportView(),
      binding: AdminBinding(),
      customTransition: SharedAxisTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),
    GetPage(
      name: AppRoutes.adminTicketDetail,
      page: () => const AdminTicketDetailView(),
      binding: AdminBinding(),
      customTransition: FadeScaleTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'admin')],
    ),

    // ==================== COMMON ROUTES ====================
    GetPage(
      name: AppRoutes.noInternet,
      page: () => const NoInternetView(),
      customTransition: FadeInTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.serverError,
      page: () => const ServerErrorView(),
      customTransition: FadeInTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.notFound,
      page: () => const NotFoundView(),
      customTransition: FadeInTransition(),
      transitionDuration: transitionDuration,
    ),
    GetPage(
      name: AppRoutes.underConstruction,
      page: () => const UnderConstructionView(),
      customTransition: FadeInTransition(),
      transitionDuration: transitionDuration,
    ),
    // Add these to the routes list in AppPages class:

// ==================== STAFF ROUTES ====================


    // Ticketing Staff Routes
    GetPage(
      name: AppRoutes.ticketingDashboard,
      page: () => const TicketingDashboardView(),
      customTransition: ElasticZoomTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'ticketing_staff')],
    ),
    GetPage(
      name: AppRoutes.ticketingBookings,
      page: () => const TicketingBookingsView(),
      customTransition: FadeScaleTransition(),
      middlewares: [AuthMiddleware(role: 'ticketing_staff')],
    ),
    GetPage(
      name: AppRoutes.ticketingTrips,
      page: () => const TicketingTripsView(),
      customTransition: FadeScaleTransition(),
      middlewares: [AuthMiddleware(role: 'ticketing_staff')],
    ),
    GetPage(
      name: AppRoutes.ticketingPayments,
      page: () => const TicketingPaymentsView(),
      customTransition: FadeScaleTransition(),
      middlewares: [AuthMiddleware(role: 'ticketing_staff')],
    ),

// Cargo Staff Routes
    GetPage(
      name: AppRoutes.cargoDashboard,
      page: () => const CargoDashboardView(),
      customTransition: ElasticZoomTransition(),
      transitionDuration: transitionDuration,
      middlewares: [AuthMiddleware(role: 'cargo_staff')],
    ),
    GetPage(
      name: AppRoutes.cargoList,
      page: () => const CargoListView(),
      customTransition: FadeScaleTransition(),
      middlewares: [AuthMiddleware(role: 'cargo_staff')],
    ),
    GetPage(
      name: AppRoutes.cargoUpdate,
      page: () => const CargoUpdateView(),
      customTransition: FadeScaleTransition(),
      middlewares: [AuthMiddleware(role: 'cargo_staff')],
    ),
    GetPage(
      name: AppRoutes.ticketingBoarding,
      page: () => const TicketingBoardingView(),
      customTransition: FadeScaleTransition(),
      middlewares: [AuthMiddleware(role: 'ticketing_staff')],
    ),
    GetPage(
      name: AppRoutes.adminPromotions,
      page: () => const AdminPromotionsView(),
      binding: AdminBinding(),
      customTransition: FadeScaleTransition(),
      middlewares: [AuthMiddleware(role: 'admin')],
    ),
  ];
}

// ==================== AUTH MIDDLEWARE ====================
class AuthMiddleware extends GetMiddleware {
  final String? role;

  AuthMiddleware({this.role});

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();

      if (!authController.isAuthenticated) {
        return const RouteSettings(name: AppRoutes.login);
      }

      if (role != null && authController.userRole != role) {
        if (authController.userRole == 'passenger') {
          return const RouteSettings(name: AppRoutes.passengerDashboard);
        } else if (authController.userRole == 'driver') {
          return const RouteSettings(name: AppRoutes.driverDashboard);
        } else if (authController.userRole == 'admin') {
          return const RouteSettings(name: AppRoutes.adminDashboard);
        }
        return const RouteSettings(name: AppRoutes.login);
      }

      return null;
    } catch (e) {
      return const RouteSettings(name: AppRoutes.login);
    }
  }
}