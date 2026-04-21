// lib/core/routes/app_routes.dart

class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Initial route
  static const String initial = '/';

  // Splash
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // Auth Routes
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String otpVerification = '/auth/otp-verification';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String adminProfile = '/admin/profile';

  // Passenger Routes
  static const String passenger = '/passenger';
  static const String passengerDashboard = '/passenger/dashboard';
  static const String passengerHome = '/passenger/home';
  static const String passengerSearch = '/passenger/search';
  static const String passengerSearchResults = '/passenger/search-results';
  static const String passengerTripDetail = '/passenger/trip-detail';
  static const String passengerSeatSelection = '/passenger/seat-selection';
  static const String passengerBookingSummary = '/passenger/booking-summary';
  static const String passengerPayment = '/passenger/payment';
  static const String passengerPaymentSuccess = '/passenger/payment/success';
  static const String passengerMyTickets = '/passenger/my-tickets';
  static const String passengerTicketDetail = '/passenger/ticket-detail';
  static const String passengerTicketQR = '/passenger/ticket-qr';
  static const String passengerCargoRegistration = '/passenger/cargo-registration';
  static const String passengerCargoTracking = '/passenger/cargo-tracking';
  static const String passengerCargoReceipt = '/passenger/cargo-receipt';
  static const String passengerBookingHistory = '/passenger/booking-history';
  static const String passengerCargoHistory = '/passenger/cargo-history';
  static const String passengerProfile = '/passenger/profile';
  static const String passengerEditProfile = '/passenger/edit-profile';
  static const String passengerSettings = '/passenger/settings';
  static const String passengerNotifications = '/passenger/notifications';
  static const String passengerCargoSelectTrip = '/passenger/cargo/select-trip';
  static const String passengerCargoSuccess = '/passenger/cargo/success';
  static const String passengerTicketSelectTrip = '/passenger/tickets/select-trip';

  static const String privacySecurity = '/passenger/privacy-security';
  static const String helpSupport = '/passenger/help-support';
  static const String about = '/passenger/about';
  static const String faqs = '/passenger/faqs';
  static const String terms = '/passenger/terms';
  static const String privacy = '/passenger/privacy';


  // Driver Routes
  static const String driverTripDetail = '/driver/trip/:tripId';  // Add this
  static const String driverTripStatus = '/driver/trip/:tripId/status';  // Add this
  static const String driverBoarding = '/driver/boarding/:tripId';  // Add this
  static const String driver = '/driver';
  static const String driverDashboard = '/driver/dashboard';
  static const String driverAssignedTrips = '/driver/assigned-trips';
  static const String driverBoardingManagement = '/driver/boarding-management';
  static const String driverTicketValidation = '/driver/ticket-validation';
  static const String driverPassengerManifest = '/driver/passenger-manifest';
  static const String driverCargoManifest = '/driver/cargo-manifest';
  static const String driverUpdateTripStatus = '/driver/update-trip-status';
  static const String driverReportIncident = '/driver/report-incident';
  static const String driverProfile = '/driver/profile';
  static const String driverAvailability = '/driver/availability';
  static const String driverSettings = '/driver/settings';
  static const String driverNotifications = '/driver/notifications';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminTrips = '/admin/trips';
  static const String adminBookings = '/admin/bookings';
  static const String adminCargo = '/admin/cargo';
  static const String adminUsers = '/admin/users';
  static const String adminRoutes = '/admin/routes';
  static const String adminVehicles = '/admin/vehicles';
  static const String adminReports = '/admin/reports';
  static const String adminPayments = '/admin/payments';
  static const String adminNotifications = '/admin/notifications';
  static const String adminSettings = '/admin/settings';
  // Common Routes
  static const String notFound = '/404';
  static const String noInternet = '/no-internet';
  static const String serverError = '/server-error';
  static const String underConstruction = '/under-construction';

  // Route names with parameters (for navigation with arguments)
  static String getPassengerTripDetail(String tripId) => '$passengerTripDetail?tripId=$tripId';
  static String getPassengerTicketDetail(String ticketId) => '$passengerTicketDetail?ticketId=$ticketId';
  static String getPassengerCargoTracking(String trackingCode) => '$passengerCargoTracking?code=$trackingCode';
  static String getPassengerCargoReceipt(String cargoId) => '$passengerCargoReceipt?cargoId=$cargoId';

  static String getDriverTripDetail(String tripId) => '$driverTripDetail?tripId=$tripId';
  static String getDriverPassengerManifest(String tripId) => '$driverPassengerManifest?tripId=$tripId';
  static String getDriverCargoManifest(String tripId) => '$driverCargoManifest?tripId=$tripId';

  // Helper method to check if route is auth protected
  static bool isAuthRoute(String route) {
    return route.startsWith('/passenger') || route.startsWith('/driver');
  }

  // Helper method to check if route is passenger route
  static bool isPassengerRoute(String route) {
    return route.startsWith('/passenger');
  }

  // Helper method to check if route is driver route
  static bool isDriverRoute(String route) {
    return route.startsWith('/driver');
  }

  // Get role from route
  static String? getRoleFromRoute(String route) {
    if (route.startsWith('/passenger')) return 'passenger';
    if (route.startsWith('/driver')) return 'driver';
    return null;
  }
}