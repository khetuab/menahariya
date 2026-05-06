// lib/core/constants/api_endpoints.dart

class ApiEndpoints {
  // // Base URL - Will be replaced by environment config
  // static const String baseUrl = 'http://10.194.117.58/api/v1';
  // static const String socketUrl = 'https://10.194.117.58:3000';

  static const String baseUrl = 'https://menahariya-backend.onrender.com/api';
  static const String socketUrl = 'https://menahariya-backend.onrender.com';

  // Auth Endpoints
  static const String auth = '/auth';
  static const String authLogin = '$auth/login';
  static const String authRegister = '$auth/register';
  static const String authVerifyOTP = '$auth/verify-otp';
  static const String authResendOTP = '$auth/resend-otp';
  static const String authForgotPassword = '$auth/forgot-password';
  static const String authResetPassword = '$auth/reset-password';
  static const String authRefreshToken = '$auth/refresh-token';
  static const String authLogout = '$auth/logout';
  static const String authChangePassword = '$auth/change-password';

  // User Endpoints
  static const String users = '/users';
  static const String usersProfile = '$users/profile';
  static const String usersUpdateProfile = '$users/update-profile';
  static const String usersUpdateAvatar = '$users/update-avatar';

  // Trip Endpoints
  static const String trips = '/trips';
  static const String tripsSearch = '$trips/search';
  static const String tripsAvailable = '$trips/available';
  static const String tripsUpcoming = '$trips/upcoming';
  static const String tripsActive = '$trips/active';
  static const String tripsHistory = '$trips/history';
  static const String tripsDetails = '$trips/'; // + id
  static const String placeSuggestions = '/places/suggest';

  // Route Endpoints
  static const String routes = '/trips/routes';
  static const String routesPopular = '$routes/popular';
  static const String routesAll = '$routes/all';

  // Booking Endpoints
  static const String bookings = '/bookings';
  static const String bookingsCreate = '$bookings/create';
  static const String bookingsConfirm = '$bookings/confirm';
  static const String bookingsCancel = '$bookings/cancel';
  static const String bookingsRefund = '$bookings/refund';
  static const String bookingsHistory = '$bookings/history';
  static const String bookingsDetails = '$bookings/'; // + id

  // Seat Endpoints
  static const String seats = '/seats';
  static const String seatsLock = '$seats/lock';
  static const String seatsRelease = '$seats/release';
  static const String seatsAvailable = '$seats/available';
  static const String seatsMap = '$seats/map'; // ?trip_id=

  // Ticket Endpoints
  static const String tickets = '/tickets';
  static const String ticketsValidate = '$tickets/validate';
  static const String ticketsGenerateQR = '$tickets/generate-qr';
  static const String ticketsVerifyQR = '$tickets/verify-qr';
  static const String ticketsMyTickets = '$tickets/my-tickets';
  static const String ticketsDownload = '$tickets/download'; // + id

  // Payment Endpoints
  static const String payments = '/payments';
  static const String paymentsInitiate = '$payments/initiate';
  static const String paymentsVerify = '$payments/verify';
  static const String paymentsStatus = '$payments/status'; // + id
  static const String paymentsRefund = '$payments/refund';
  static const String paymentsMethods = '$payments/methods';
  static const String paymentsTelebirr = '$payments/telebirr';
  static const String paymentsCBE = '$payments/cbe';
  static const String paymentsHistory = '$payments/history';

  // Cargo Endpoints
  static const String cargo = '/cargo';
  static const String cargoRegister = '$cargo/register';
  static const String cargoTrack = '$cargo/track'; // ?code=
  static const String cargoCalculate = '$cargo/calculate-fee';
  static const String cargoReceipt = '$cargo/receipt'; // + id
  static const String cargoHistory = '$cargo/history';
  static const String cargoTypes = '$cargo/types';

  // ==================== VEHICLE ENDPOINTS ====================
  static const String vehicles = '/vehicles';
  static const String vehiclesActive = '$vehicles/active';
  static const String vehiclesAvailable = '$vehicles/available';
  static const String vehiclesMaintenance = '$vehicles/maintenance';
  static const String vehiclesDetails = '$vehicles/'; // + id

  // Driver Endpoints
  static const String driver = '/driver';
  static const String driverTrips = '$driver/trips';
  static const String driverAssignedTrips = '$driver/assigned-trips';
  static const String driverUpdateTripStatus = '$driver/update-trip-status';
  static const String driverPassengerManifest = '$driver/passenger-manifest'; // ?trip_id=
  static const String driverCargoManifest = '$driver/cargo-manifest'; // ?trip_id=
  static const String driverReportIncident = '$driver/report-incident';
  static const String driverUpdateAvailability = '$driver/update-availability';


  // ==================== ADMIN ENDPOINTS ====================
  static const String admin = '/admin';

  // Dashboard
  static const String adminDashboard = '$admin/dashboard';
  static const String adminStats = '$admin/dashboard/stats';
  static const String adminRevenueChart = '$admin/dashboard/revenue-chart';
  static const String adminTripAnalytics = '$admin/dashboard/trip-analytics';
  static const String adminBookingAnalytics = '$admin/dashboard/booking-analytics';
  static const String adminCargoAnalytics = '$admin/dashboard/cargo-analytics';

  // User Management
  static const String adminUsers = '$admin/users';
  static const String adminDrivers = '$admin/users/drivers';
  static const String adminUsersCreate = '$admin/users/create';
  static const String adminUsersUpdate = '$admin/users'; // + /id
  static const String adminUsersDelete = '$admin/users'; // + /id
  static const String adminUsersStatus = '$admin/users'; // + /id/status

  // Trip Management
  static const String adminTrips = '$admin/trips';
  static const String adminTripsCreate = '$admin/trips/create';
  static const String adminTripsUpdate = '$admin/trips'; // + /id
  static const String adminTripsDelete = '$admin/trips'; // + /id
  static const String adminTripsCancel = '$admin/trips'; // + /id/cancel

  // Vehicle Management
  static const String adminVehicles = '$admin/vehicles';
  static const String adminVehiclesCreate = '$admin/vehicles/create';
  static const String adminVehiclesUpdate = '$admin/vehicles'; // + /id
  static const String adminVehiclesDelete = '$admin/vehicles'; // + /id

  // Route Management
  static const String adminRoutes = '$admin/routes';
  static const String adminRoutesCreate = '$admin/routes/create';
  static const String adminRoutesUpdate = '$admin/routes'; // + /id
  static const String adminRoutesDelete = '$admin/routes'; // + /id

  // Reports
  static const String adminReports = '$admin/reports';
  static const String adminReportsList = '$admin/reports/list';
  static const String adminReportsGenerate = '$admin/reports/generate';
  static const String adminReportsDelete = '$admin/reports'; // + /id
  static const String adminReportsDownload = '$admin/reports/download'; // + /id

  // Notifications
  static const String adminNotifications = '$admin/notifications';
  static const String adminNotificationsSend = '$admin/notifications/send';
  static const String adminNotificationsHistory = '$admin/notifications/history';
  static const String adminNotificationsDelete = '$admin/notifications'; // + /id

  // Admin Notification endpoints
  static const String adminNotificationsAll = '/admin/notifications/all';

  // User Notification endpoints (existing)
  static const String notificationsAll = '/notifications/all';
  static const String notificationsMarkRead = '/notifications/mark-read';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  static const String notificationsDelete = '/notifications';
  static const String notificationsUnread = '/notifications/unread';  // Add this
   // Settings
  static const String adminSettings = '$admin/settings';
  static const String adminSettingsUpdate = '$admin/settings/update';

  // Audit Logs
  static const String adminAuditLogs = '$admin/audit/logs';
  static const String adminAuditLogsExport = '$admin/audit/logs/export';

  // System
  static const String adminSystemClearCache = '$admin/system/clear-cache';
  static const String adminSystemBackup = '$admin/system/backup';
  static const String adminSystemHealth = '$admin/system/health';

  // Notification Endpoints
  static const String notifications = '/notifications';
  //static const String notificationsAll = '$notifications/all';
  //static const String notificationsMarkRead = '$notifications/mark-read'; // + id
  //static const String notificationsMarkAllRead = '$notifications/mark-all-read';
  //static const String notificationsDelete = '$notifications/'; // + id

  // Report Endpoints (Admin)
  static const String reports = '/reports';
  static const String reportsRevenue = '$reports/revenue';
  static const String reportsPassengerFlow = '$reports/passenger-flow';
  static const String reportsTripPerformance = '$reports/trip-performance';
  static const String reportsCargoSummary = '$reports/cargo-summary';
  static const String reportsDailySummary = '$reports/daily-summary';
  // Add these endpoints
  static const String adminProfile = '/admin/profile';
  static const String adminProfileUpdate = '/admin/profile/update';
  static const String adminChangePassword = '/admin/profile/change-password';
  static const String adminActivityLogs = '/admin/activity-logs';

  // WebSocket Events
  static const String wsSeatUpdate = 'seat:update';
  static const String wsTripUpdate = 'trip:update';
  static const String wsNotification = 'notification:new';
  static const String wsPaymentConfirm = 'payment:confirm';
  static const String wsDriverLocation = 'driver:location';
}