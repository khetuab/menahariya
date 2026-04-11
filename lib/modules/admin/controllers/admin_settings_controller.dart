// lib/modules/admin/controllers/admin_settings_controller.dart

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

  // Notification Settings
  late final RxMap<String, TextEditingController> notificationTypeControllers = <String, TextEditingController>{}.obs;

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
      }
    } catch (e) {
      print('Error fetching settings: $e');
      AppSnackbar.show('Error', 'Failed to load settings');
    } finally {
      _isLoading.value = false;
    }
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
      }
    } catch (e) {
      print('Error saving settings: $e');
      AppSnackbar.show('Error', 'Failed to save settings');
    } finally {
      _isSaving.value = false;
    }
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
        'refundProcessingDays': double.tryParse(refundProcessingDaysController.text) ?? 3,
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
    _enabledPaymentMethods.refresh(); // Force UI update
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

      if (response != null && response['data'] != null) {
        final backupUrl = response['data']['url'];
        await downloadBackup(backupUrl);
      }
    } catch (e) {
      print('Error backing up database: $e');
      AppSnackbar.show('Error', 'Failed to create backup');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> downloadBackup(String url) async {
    try {
      // Implementation for downloading backup
      AppSnackbar.show('Success', 'Backup created successfully');
    } catch (e) {
      print('Error downloading backup: $e');
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