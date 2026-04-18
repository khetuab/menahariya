//  lib/modules/admin/controllers/admin_settings_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/utils/app_snackbar.dart';
import '../models/admin_models.dart';

class AdminSettingsController extends GetxController {
  static AdminSettingsController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Observables
  final _isLoading = false.obs;
  final _isSaving = false.obs;
  final _settings = Rxn<SystemSettings>();
  final _activeTab = SettingsTab.general.obs;

  // Form controllers for each settings section
  // Booking Settings
  late final TextEditingController maxSeatsPerBookingController;
  late final TextEditingController seatLockDurationController;
  late final TextEditingController cancellationWindowController;
  late final TextEditingController cancellationFeeController;
  late final TextEditingController insuranceRateController;

  // Cargo Settings
  late final TextEditingController baseRatePerKgController;
  late final TextEditingController fragileSurchargeController;
  late final TextEditingController perishableSurchargeController;
  late final TextEditingController refrigerationSurchargeController;
  late final TextEditingController minFeeController;
  late final TextEditingController maxWeightPerTripController;

  // Payment Settings
  late final TextEditingController walletMinBalanceController;
  late final TextEditingController walletMaxBalanceController;
  late final TextEditingController paymentTimeoutController;
  late final TextEditingController refundProcessingDaysController;

  // Security Settings
  late final TextEditingController sessionTimeoutController;
  late final TextEditingController maxLoginAttemptsController;
  late final TextEditingController passwordExpiryDaysController;

  // Maintenance Settings
  late final TextEditingController maintenanceMessageController;
  late final TextEditingController estimatedDurationController;

  // Toggle switches - Using RxBool
  final RxBool _enableInsurance = true.obs;
  final RxBool _requireDimensions = false.obs;
  final RxBool _autoConfirmPayments = true.obs;
  final RxBool _enableSms = true.obs;
  final RxBool _enableEmail = false.obs;
  final RxBool _enablePush = true.obs;
  final RxBool _requireMfaForAdmin = false.obs;
  final RxBool _enableAuditLogging = true.obs;
  final RxBool _maintenanceMode = false.obs;

  // Enabled payment methods
  final RxList<String> _enabledPaymentMethods = <String>[].obs;

  // Available payment methods
  final List<String> availablePaymentMethods = [
    'telebirr',
    'cbe_birr',
    'card',
    'wallet',
    'cash',
  ];

  // Getters - Return RxBool for Obx compatibility
  RxBool get enableInsurance => _enableInsurance;
  RxBool get requireDimensions => _requireDimensions;
  RxBool get autoConfirmPayments => _autoConfirmPayments;
  RxBool get enableSms => _enableSms;
  RxBool get enableEmail => _enableEmail;
  RxBool get enablePush => _enablePush;
  RxBool get requireMfaForAdmin => _requireMfaForAdmin;
  RxBool get enableAuditLogging => _enableAuditLogging;
  RxBool get maintenanceMode => _maintenanceMode;

  // Getters for regular bool values (for conditions)
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  SystemSettings? get settings => _settings.value;
  SettingsTab get activeTab => _activeTab.value;
  List<String> get enabledPaymentMethodsList => _enabledPaymentMethods.toList();

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchSettings();
  }

  void _initializeControllers() {
    // Booking controllers
    maxSeatsPerBookingController = TextEditingController();
    seatLockDurationController = TextEditingController();
    cancellationWindowController = TextEditingController();
    cancellationFeeController = TextEditingController();
    insuranceRateController = TextEditingController();

    // Cargo controllers
    baseRatePerKgController = TextEditingController();
    fragileSurchargeController = TextEditingController();
    perishableSurchargeController = TextEditingController();
    refrigerationSurchargeController = TextEditingController();
    minFeeController = TextEditingController();
    maxWeightPerTripController = TextEditingController();

    // Payment controllers
    walletMinBalanceController = TextEditingController();
    walletMaxBalanceController = TextEditingController();
    paymentTimeoutController = TextEditingController();
    refundProcessingDaysController = TextEditingController();

    // Security controllers
    sessionTimeoutController = TextEditingController();
    maxLoginAttemptsController = TextEditingController();
    passwordExpiryDaysController = TextEditingController();

    // Maintenance controllers
    maintenanceMessageController = TextEditingController();
    estimatedDurationController = TextEditingController();
  }

  Future<void> fetchSettings() async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get('/admin/settings');

      if (response != null && response['data'] != null) {
        _settings.value = SystemSettings.fromJson(response['data']);
        _populateFormFields();
      } else {
        // Load default settings if API returns nothing
        _loadDefaultSettings();
      }
    } catch (e) {
      print('Error fetching settings: $e');
      AppSnackbar.show('Error', 'Failed to load settings. Loading defaults.');
      _loadDefaultSettings();
    } finally {
      _isLoading.value = false;
    }
  }

  void _loadDefaultSettings() {
    final defaultSettings = SystemSettings(
      booking: BookingSettings(
        maxSeatsPerBooking: 10,
        seatLockDurationMinutes: 5,
        cancellationWindowHours: 2,
        cancellationFeePercentage: 10,
        enableInsurance: true,
        insuranceRate: 0.05,
      ),
      cargo: CargoSettings(
        baseRatePerKg: 5,
        fragileSurcharge: 0.2,
        perishableSurcharge: 0.15,
        refrigerationSurcharge: 0.25,
        minFee: 50,
        maxWeightPerTrip: 500,
        requireDimensions: false,
      ),
      payment: PaymentSettings(
        enabledMethods: ['telebirr', 'cbe_birr', 'wallet', 'cash'],
        walletMinBalance: 0,
        walletMaxBalance: 10000,
        paymentTimeoutMinutes: 30,
        autoConfirmPayments: true,
        refundProcessingDays: 3,
      ),
      notification: NotificationSettingsConfig(
        enableSms: true,
        enableEmail: false,
        enablePush: true,
      ),
      security: SecuritySettings(
        sessionTimeoutMinutes: 30,
        maxLoginAttempts: 5,
        passwordExpiryDays: 90,
        requireMfaForAdmin: false,
        enableAuditLogging: true,
      ),
      maintenance: MaintenanceSettings(
        maintenanceMode: false,
        maintenanceMessage: null,
        estimatedDurationMinutes: 60,
      ),
    );
    _settings.value = defaultSettings;
    _populateFormFields();
  }

  void _populateFormFields() {
    final settings = _settings.value;
    if (settings == null) return;

    // Booking settings
    maxSeatsPerBookingController.text = settings.booking.maxSeatsPerBooking.toString();
    seatLockDurationController.text = settings.booking.seatLockDurationMinutes.toString();
    cancellationWindowController.text = settings.booking.cancellationWindowHours.toString();
    cancellationFeeController.text = settings.booking.cancellationFeePercentage.toString();
    insuranceRateController.text = settings.booking.insuranceRate.toString();
    _enableInsurance.value = settings.booking.enableInsurance;

    // Cargo settings
    baseRatePerKgController.text = settings.cargo.baseRatePerKg.toString();
    fragileSurchargeController.text = settings.cargo.fragileSurcharge.toString();
    perishableSurchargeController.text = settings.cargo.perishableSurcharge.toString();
    refrigerationSurchargeController.text = settings.cargo.refrigerationSurcharge.toString();
    minFeeController.text = settings.cargo.minFee.toString();
    maxWeightPerTripController.text = settings.cargo.maxWeightPerTrip.toString();
    _requireDimensions.value = settings.cargo.requireDimensions;

    // Payment settings
    walletMinBalanceController.text = settings.payment.walletMinBalance.toString();
    walletMaxBalanceController.text = settings.payment.walletMaxBalance.toString();
    paymentTimeoutController.text = settings.payment.paymentTimeoutMinutes.toString();
    refundProcessingDaysController.text = settings.payment.refundProcessingDays.toString();
    _autoConfirmPayments.value = settings.payment.autoConfirmPayments;
    _enabledPaymentMethods.value = List.from(settings.payment.enabledMethods);

    // Notification settings
    _enableSms.value = settings.notification.enableSms;
    _enableEmail.value = settings.notification.enableEmail;
    _enablePush.value = settings.notification.enablePush;

    // Security settings
    sessionTimeoutController.text = settings.security.sessionTimeoutMinutes.toString();
    maxLoginAttemptsController.text = settings.security.maxLoginAttempts.toString();
    passwordExpiryDaysController.text = settings.security.passwordExpiryDays.toString();
    _requireMfaForAdmin.value = settings.security.requireMfaForAdmin;
    _enableAuditLogging.value = settings.security.enableAuditLogging;

    // Maintenance settings
    maintenanceMessageController.text = settings.maintenance.maintenanceMessage ?? '';
    estimatedDurationController.text = settings.maintenance.estimatedDurationMinutes.toString();
    _maintenanceMode.value = settings.maintenance.maintenanceMode;
  }

  Future<void> saveSettings() async {
    // Validate inputs
    if (!_validateSettings()) return;

    try {
      _isSaving.value = true;

      final updates = _buildSettingsUpdate();

      final response = await _apiClient.put(
        '/admin/settings',
        data: updates,
      );

      if (response != null && response['success'] == true) {
        await fetchSettings();
        AppSnackbar.show('Success', 'Settings saved successfully');
      } else {
        AppSnackbar.show('Error', response?['message'] ?? 'Failed to save settings');
      }
    } catch (e) {
      print('Error saving settings: $e');
      AppSnackbar.show('Error', 'Failed to save settings');
    } finally {
      _isSaving.value = false;
    }
  }

  bool _validateSettings() {
    // Validate booking settings
    final maxSeats = int.tryParse(maxSeatsPerBookingController.text);
    if (maxSeats == null || maxSeats < 1 || maxSeats > 20) {
      AppSnackbar.show('Error', 'Max seats per booking must be between 1 and 20');
      return false;
    }

    final seatLockDuration = int.tryParse(seatLockDurationController.text);
    if (seatLockDuration == null || seatLockDuration < 1 || seatLockDuration > 30) {
      AppSnackbar.show('Error', 'Seat lock duration must be between 1 and 30 minutes');
      return false;
    }

    final cancellationFee = double.tryParse(cancellationFeeController.text);
    if (cancellationFee == null || cancellationFee < 0 || cancellationFee > 100) {
      AppSnackbar.show('Error', 'Cancellation fee must be between 0 and 100 percent');
      return false;
    }

    // Validate cargo settings
    final baseRate = double.tryParse(baseRatePerKgController.text);
    if (baseRate == null || baseRate < 0) {
      AppSnackbar.show('Error', 'Base rate must be a positive number');
      return false;
    }

    // Validate payment settings
    final walletMin = double.tryParse(walletMinBalanceController.text);
    final walletMax = double.tryParse(walletMaxBalanceController.text);
    if (walletMin == null || walletMax == null || walletMin < 0 || walletMax < walletMin) {
      AppSnackbar.show('Error', 'Wallet balance settings are invalid');
      return false;
    }

    // Validate security settings
    final sessionTimeout = int.tryParse(sessionTimeoutController.text);
    if (sessionTimeout == null || sessionTimeout < 5 || sessionTimeout > 480) {
      AppSnackbar.show('Error', 'Session timeout must be between 5 and 480 minutes');
      return false;
    }

    return true;
  }

  Map<String, dynamic> _buildSettingsUpdate() {
    return {
      'booking': {
        'maxSeatsPerBooking': int.tryParse(maxSeatsPerBookingController.text) ?? 10,
        'seatLockDurationMinutes': int.tryParse(seatLockDurationController.text) ?? 5,
        'cancellationWindowHours': int.tryParse(cancellationWindowController.text) ?? 2,
        'cancellationFeePercentage': double.tryParse(cancellationFeeController.text) ?? 10,
        'enableInsurance': _enableInsurance.value,
        'insuranceRate': double.tryParse(insuranceRateController.text) ?? 0.05,
      },
      'cargo': {
        'baseRatePerKg': double.tryParse(baseRatePerKgController.text) ?? 5,
        'fragileSurcharge': double.tryParse(fragileSurchargeController.text) ?? 0.2,
        'perishableSurcharge': double.tryParse(perishableSurchargeController.text) ?? 0.15,
        'refrigerationSurcharge': double.tryParse(refrigerationSurchargeController.text) ?? 0.25,
        'minFee': double.tryParse(minFeeController.text) ?? 50,
        'maxWeightPerTrip': double.tryParse(maxWeightPerTripController.text) ?? 500,
        'requireDimensions': _requireDimensions.value,
      },
      'payment': {
        'enabledMethods': _enabledPaymentMethods.toList(),
        'walletMinBalance': double.tryParse(walletMinBalanceController.text) ?? 0,
        'walletMaxBalance': double.tryParse(walletMaxBalanceController.text) ?? 10000,
        'paymentTimeoutMinutes': int.tryParse(paymentTimeoutController.text) ?? 30,
        'autoConfirmPayments': _autoConfirmPayments.value,
        'refundProcessingDays': int.tryParse(refundProcessingDaysController.text) ?? 3,
      },
      'notification': {
        'enableSms': _enableSms.value,
        'enableEmail': _enableEmail.value,
        'enablePush': _enablePush.value,
      },
      'security': {
        'sessionTimeoutMinutes': int.tryParse(sessionTimeoutController.text) ?? 30,
        'maxLoginAttempts': int.tryParse(maxLoginAttemptsController.text) ?? 5,
        'passwordExpiryDays': int.tryParse(passwordExpiryDaysController.text) ?? 90,
        'requireMfaForAdmin': _requireMfaForAdmin.value,
        'enableAuditLogging': _enableAuditLogging.value,
      },
      'maintenance': {
        'maintenanceMode': _maintenanceMode.value,
        'maintenanceMessage': maintenanceMessageController.text.isEmpty ? null : maintenanceMessageController.text,
        'estimatedDurationMinutes': int.tryParse(estimatedDurationController.text) ?? 60,
      },
    };
  }

  void togglePaymentMethod(String method, bool enabled) {
    if (enabled) {
      if (!_enabledPaymentMethods.contains(method)) {
        _enabledPaymentMethods.add(method);
      }
    } else {
      _enabledPaymentMethods.remove(method);
    }
    _enabledPaymentMethods.refresh();
  }

  void toggleEnableInsurance(bool value) => _enableInsurance.value = value;
  void toggleRequireDimensions(bool value) => _requireDimensions.value = value;
  void toggleAutoConfirmPayments(bool value) => _autoConfirmPayments.value = value;
  void toggleEnableSms(bool value) => _enableSms.value = value;
  void toggleEnableEmail(bool value) => _enableEmail.value = value;
  void toggleEnablePush(bool value) => _enablePush.value = value;
  void toggleRequireMfaForAdmin(bool value) => _requireMfaForAdmin.value = value;
  void toggleEnableAuditLogging(bool value) => _enableAuditLogging.value = value;
  void toggleMaintenanceMode(bool value) => _maintenanceMode.value = value;

  void setActiveTab(SettingsTab tab) {
    _activeTab.value = tab;
  }

  Future<void> clearCache() async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text('Are you sure you want to clear all system cache?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await _apiClient.post('/admin/system/clear-cache');
      AppSnackbar.show('Success', 'Cache cleared successfully');
    } catch (e) {
      print('Error clearing cache: $e');
      AppSnackbar.show('Error', 'Failed to clear cache');
    }
  }

  Future<void> backupDatabase() async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.post('/admin/system/backup');

      if (response != null && response['success'] == true) {
        AppSnackbar.show('Success', 'Backup created successfully');
      }
    } catch (e) {
      print('Error backing up database: $e');
      AppSnackbar.show('Error', 'Failed to create backup');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    maxSeatsPerBookingController.dispose();
    seatLockDurationController.dispose();
    cancellationWindowController.dispose();
    cancellationFeeController.dispose();
    insuranceRateController.dispose();
    baseRatePerKgController.dispose();
    fragileSurchargeController.dispose();
    perishableSurchargeController.dispose();
    refrigerationSurchargeController.dispose();
    minFeeController.dispose();
    maxWeightPerTripController.dispose();
    walletMinBalanceController.dispose();
    walletMaxBalanceController.dispose();
    paymentTimeoutController.dispose();
    refundProcessingDaysController.dispose();
    sessionTimeoutController.dispose();
    maxLoginAttemptsController.dispose();
    passwordExpiryDaysController.dispose();
    maintenanceMessageController.dispose();
    estimatedDurationController.dispose();
    super.onClose();
  }
}

enum SettingsTab {
  general,
  booking,
  cargo,
  payment,
  notification,
  security,
  maintenance,
}