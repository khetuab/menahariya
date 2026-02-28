// lib/config/translations/app_translations.dart

import 'dart:ui';

import 'package:get/get.dart';
import 'package:menahariya/config/translations/en_us.dart';
import 'package:menahariya/config/translations/am_et.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': EnUs.translations,
    'am': AmEt.translations,
  };

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('am', 'ET'),
  ];

  // Default locale
  static const Locale defaultLocale = Locale('en', 'US');

  // Get locale from string
  static Locale getLocaleFromString(String languageCode) {
    switch (languageCode) {
      case 'am':
        return const Locale('am', 'ET');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  // Get string from locale
  static String getStringFromLocale(Locale locale) {
    if (locale.languageCode == 'am') {
      return 'am';
    }
    return 'en';
  }

  // Check if RTL language
  static bool isRTL(String languageCode) {
    return languageCode == 'ar' || languageCode == 'he';
  }

  // Get alignment based on RTL
  static TextAlign getTextAlign(String languageCode) {
    return isRTL(languageCode) ? TextAlign.right : TextAlign.left;
  }

  // Get directionality based on RTL
  static TextDirection getTextDirection(String languageCode) {
    return isRTL(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }
}

// Translation keys
abstract class TranslationKeys {
  // Common
  static const String appName = 'appName';
  static const String loading = 'loading';
  static const String error = 'error';
  static const String success = 'success';
  static const String warning = 'warning';
  static const String info = 'info';
  static const String confirm = 'confirm';
  static const String cancel = 'cancel';
  static const String ok = 'ok';
  static const String yes = 'yes';
  static const String no = 'no';
  static const String save = 'save';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String edit = 'edit';
  static const String back = 'back';
  static const String next = 'next';
  static const String done = 'done';
  static const String retry = 'retry';
  static const String tryAgain = 'tryAgain';
  static const String networkError = 'networkError';
  static const String serverError = 'serverError';
  static const String unknownError = 'unknownError';

  // Auth
  static const String login = 'login';
  static const String register = 'register';
  static const String logout = 'logout';
  static const String email = 'email';
  static const String password = 'password';
  static const String confirmPassword = 'confirmPassword';
  static const String forgotPassword = 'forgotPassword';
  static const String resetPassword = 'resetPassword';
  static const String changePassword = 'changePassword';
  static const String phoneNumber = 'phoneNumber';
  static const String fullName = 'fullName';
  static const String rememberMe = 'rememberMe';
  static const String termsAndConditions = 'termsAndConditions';

  // Home
  static const String home = 'home';
  static const String search = 'search';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String notifications = 'notifications';
  static const String bookTrip = 'bookTrip';
  static const String trackCargo = 'trackCargo';
  static const String myTickets = 'myTickets';
  static const String myCargo = 'myCargo';

  // Trip
  static const String from = 'from';
  static const String to = 'to';
  static const String departure = 'departure';
  static const String arrival = 'arrival';
  static const String date = 'date';
  static const String time = 'time';
  static const String passengers = 'passengers';
  static const String seatNumber = 'seatNumber';
  static const String busType = 'busType';
  static const String amenities = 'amenities';
  static const String price = 'price';
  static const String totalPrice = 'totalPrice';
  static const String availableSeats = 'availableSeats';
  static const String selectSeats = 'selectSeats';

  // Booking
  static const String bookNow = 'bookNow';
  static const String bookingConfirmed = 'bookingConfirmed';
  static const String bookingFailed = 'bookingFailed';
  static const String bookingCancelled = 'bookingCancelled';
  static const String payment = 'payment';
  static const String paymentMethod = 'paymentMethod';
  static const String paymentSuccess = 'paymentSuccess';
  static const String paymentFailed = 'paymentFailed';
  static const String payNow = 'payNow';

  // Cargo
  static const String cargoRegistration = 'cargoRegistration';
  static const String senderInfo = 'senderInfo';
  static const String receiverInfo = 'receiverInfo';
  static const String cargoType = 'cargoType';
  static const String weight = 'weight';
  static const String dimensions = 'dimensions';
  static const String fragile = 'fragile';
  static const String perishable = 'perishable';
  static const String refrigeration = 'refrigeration';
  static const String cargoFee = 'cargoFee';
  static const String trackingCode = 'trackingCode';

  // Driver
  static const String driverDashboard = 'driverDashboard';
  static const String assignedTrips = 'assignedTrips';
  static const String currentTrip = 'currentTrip';
  static const String boarding = 'boarding';
  static const String validateTicket = 'validateTicket';
  static const String passengerManifest = 'passengerManifest';
  static const String cargoManifest = 'cargoManifest';
  static const String reportIncident = 'reportIncident';
  static const String updateStatus = 'updateStatus';

  // Profile
  static const String editProfile = 'editProfile';
  static const String changePhoto = 'changePhoto';
  static const String language = 'language';
  static const String darkMode = 'darkMode';
  static const String privacyPolicy = 'privacyPolicy';
  static const String helpSupport = 'helpSupport';
  static const String about = 'about';
  static const String version = 'version';
}

// Translation helper
class TranslationHelper {
  static String tr(String key, {List<String>? args}) {
    final translation = key.tr;
    if (args != null && args.isNotEmpty) {
      return _formatString(translation, args);
    }
    return translation;
  }

  static String _formatString(String text, List<String> args) {
    String result = text;
    for (int i = 0; i < args.length; i++) {
      result = result.replaceAll('{$i}', args[i]);
    }
    return result;
  }
}

// Language codes
class LanguageCodes {
  static const String english = 'en';
  static const String amharic = 'am';

  static const List<String> supported = [english, amharic];
}