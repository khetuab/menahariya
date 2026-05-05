// lib/modules/passenger/controllers/cargo_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/cargo/cargo_model.dart';
import 'package:menahariya/data/models/cargo/cargo_request.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/core/utils/formatters/currency_formatter.dart';
import 'package:menahariya/modules/passenger/controllers/search_controller.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/formatters/date_formatter.dart';

class PassengerCargoController extends GetxController {
  static PassengerCargoController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Form controllers
  late final TextEditingController senderNameController;
  late final TextEditingController senderPhoneController;
  late final TextEditingController receiverNameController;
  late final TextEditingController receiverPhoneController;
  late final TextEditingController cargoTypeController;
  late final TextEditingController weightController;
  late final TextEditingController dimensionsController;
  late final TextEditingController descriptionController;
  late final TextEditingController declaredValueController;
  late final TextEditingController trackingCodeController;
  late final TextEditingController originController;
  late final TextEditingController destinationController;

  // Focus nodes
  late final FocusNode senderNameFocusNode;
  late final FocusNode senderPhoneFocusNode;
  late final FocusNode receiverNameFocusNode;
  late final FocusNode receiverPhoneFocusNode;
  late final FocusNode weightFocusNode;

  final origin = ''.obs;
  final destination = ''.obs;
  final selectedDate = Rxn<DateTime>();
  final availableTrips = <TripModel>[].obs;
  final _isLoadingTrips = false.obs;
  final cargoSuggestions = <Place>[].obs;
  final originFocusNode = FocusNode();
  final destinationFocusNode = FocusNode();
  final showOriginSuggestions = false.obs;
  final showDestinationSuggestions = false.obs;


  bool get isLoadingTrips => _isLoadingTrips.value;


  final _isLoading = false.obs;
  final _isCalculating = false.obs;
  final _cargoList = <CargoModel>[].obs;
  final _activeCargo = <CargoModel>[].obs;
  final _pastCargo = <CargoModel>[].obs;
  final _selectedCargo = Rxn<CargoModel>();
  final _selectedTrip = Rxn<TripModel>();
  final _cargoTypes = <CargoType>[].obs;
  final _selectedCargoType = Rxn<CargoType>();
  final _isFragile = false.obs;
  final _isPerishable = false.obs;
  final _needsRefrigeration = false.obs;
  final _estimatedFee = 0.0.obs;
  final _calculatedFee = 0.0.obs;
  final _trackingCode = ''.obs;
  final _currentStep = 0.obs;


  void _setupCargoFocusListeners() {
    originFocusNode.addListener(() {
      showOriginSuggestions.value = originFocusNode.hasFocus;
    });

    destinationFocusNode.addListener(() {
      showDestinationSuggestions.value = destinationFocusNode.hasFocus;
    });
  }

  void selectTripForCargo(TripModel trip) {
    print('✅ Selecting trip: ${trip.origin} → ${trip.destination}');
    _selectedTrip.value = trip;
  }
  // Getters
  bool get isLoading => _isLoading.value;
  bool get isCalculating => _isCalculating.value;
  List<CargoModel> get cargoList => _cargoList;
  List<CargoModel> get activeCargo => _activeCargo;
  List<CargoModel> get pastCargo => _pastCargo;
  CargoModel? get selectedCargo => _selectedCargo.value;
  TripModel? get selectedTrip => _selectedTrip.value;
  List<CargoType> get cargoTypes => _cargoTypes;
  CargoType? get selectedCargoType => _selectedCargoType.value;
  bool get isFragile => _isFragile.value;
  bool get isPerishable => _isPerishable.value;
  bool get needsRefrigeration => _needsRefrigeration.value;
  double get estimatedFee => _estimatedFee.value;
  double get calculatedFee => _calculatedFee.value;
  String get trackingCode => _trackingCode.value;
  int get currentStep => _currentStep.value;

  // Computed getters
  String get formattedEstimatedFee => CurrencyFormatter.forCargoFee(_estimatedFee.value);
  String get formattedCalculatedFee => CurrencyFormatter.forCargoFee(_calculatedFee.value);

  bool get canProceed {
    if (_currentStep.value == 0) {
      // Clean phones for validation
      String cleanSenderPhone = senderPhoneController.text.replaceAll(RegExp(r'\D'), '');
      String cleanReceiverPhone = receiverPhoneController.text.replaceAll(RegExp(r'\D'), '');

      return senderNameController.text.trim().isNotEmpty &&
          cleanSenderPhone.length >= 9 && // At least 9 digits
          receiverNameController.text.trim().isNotEmpty &&
          cleanReceiverPhone.length >= 9 &&
          _selectedTrip.value != null;
    } else if (_currentStep.value == 1) {
      return _selectedCargoType.value != null &&
          weightController.text.isNotEmpty &&
          double.tryParse(weightController.text) != null &&
          double.parse(weightController.text) > 0;
    }
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadCargoTypes();
    loadCargoList();
    _setupCargoFocusListeners();

  }

  void _initializeControllers() {
    senderNameController = TextEditingController();
    senderPhoneController = TextEditingController();
    receiverNameController = TextEditingController();
    receiverPhoneController = TextEditingController();
    cargoTypeController = TextEditingController();
    weightController = TextEditingController();
    dimensionsController = TextEditingController();
    descriptionController = TextEditingController();
    declaredValueController = TextEditingController();
    trackingCodeController = TextEditingController();
    originController = TextEditingController();
    destinationController = TextEditingController();

    senderNameFocusNode = FocusNode();
    senderPhoneFocusNode = FocusNode();
    receiverNameFocusNode = FocusNode();
    receiverPhoneFocusNode = FocusNode();
    weightFocusNode = FocusNode();

    // Add listeners for fee calculation
    weightController.addListener(_calculateEstimatedFee);
    dimensionsController.addListener(_calculateEstimatedFee);
  }

  void clearSearch() {
    originController.clear();
    destinationController.clear();
    origin.value = '';
    destination.value = '';
    selectedDate.value = null;
    availableTrips.clear();
    cargoSuggestions.clear();
  }


  Future<void> _loadCargoTypes() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.cargoTypes);
      if (response != null && response['data'] != null) {
        final List<dynamic> types = response['data'];
        _cargoTypes.value = types.map((t) => CargoType.fromJson(t)).toList();
      }
    } catch (e) {
      print('Error loading cargo types: $e');
    }
  }

  // In CargoTripSelectView, update the search method:

  Future<void> searchTrips() async {
    final originText = originController.text.trim();
    final destinationText = destinationController.text.trim();

    if (originText.isEmpty || destinationText.isEmpty || selectedDate.value == null) {
      Get.snackbar(
        'Missing Information',
        'Please fill all search fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      _isLoadingTrips.value = true;

      final response = await _apiClient.get(
        '/trips/search',
        queryParameters: {
          'origin': originText,
          'destination': destinationText,
          'date': DateFormatter.toApiDate(selectedDate.value!),
          'hasCargoSpace': 'true',
        },
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> tripsData = response['data'];
        availableTrips.value = tripsData.map((t) => TripModel.fromJson(t)).toList();

        if (availableTrips.isEmpty) {
          Get.snackbar(
            'No Trips Found',
            'No trips available for the selected route',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print('Error searching trips: $e');
      Get.snackbar(
        'Error',
        'Failed to search trips',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingTrips.value = false;
    }
  }


  // In PassengerCargoController, add this method:

  Future<void> getCargoPlaceSuggestions(String query, String type) async {
    if (query.length < 2) {
      cargoSuggestions.clear();
      return;
    }

    try {
      final response = await _apiClient.get(
        '/places/suggest',
        queryParameters: {'q': query},
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> placesData = response['data'];
        cargoSuggestions.value = placesData
            .map((p) => Place.fromJson(p))
            .toList();
      }
    } catch (e) {
      print('❌ Error getting suggestions: $e');
      cargoSuggestions.clear();
    }
  }

  Future<void> loadCargoList() async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get(ApiEndpoints.cargoHistory);

      if (response != null && response['data'] != null) {
        final List<dynamic> cargoData = response['data'];
        _cargoList.value = cargoData.map((c) => CargoModel.fromJson(c)).toList();
        _categorizeCargo();
      }
    } catch (e) {
      print('Error loading cargo list: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _categorizeCargo() {
    final now = DateTime.now();

    _activeCargo.value = _cargoList.where((c) {
      return c.status == 'registered' ||
          c.status == 'loaded' ||
          c.status == 'in_transit';
    }).toList();

    _pastCargo.value = _cargoList.where((c) {
      return c.status == 'delivered' || c.status == 'cancelled';
    }).toList();

    // Sort by date
    _activeCargo.sort((a, b) => b.registeredDate.compareTo(a.registeredDate));
    _pastCargo.sort((a, b) => b.registeredDate.compareTo(a.registeredDate));
  }

  void setSelectedTrip(TripModel trip) {
    _selectedTrip.value = trip;
  }

  void setCargoType(CargoType type) {
    _selectedCargoType.value = type;
    cargoTypeController.text = type.name;
    _calculateEstimatedFee();
  }

  void toggleFragile(bool? value) {
    _isFragile.value = value ?? false;
    _calculateEstimatedFee();
  }

  void togglePerishable(bool? value) {
    _isPerishable.value = value ?? false;
    _calculateEstimatedFee();
  }

  void toggleRefrigeration(bool? value) {
    _needsRefrigeration.value = value ?? false;
    _calculateEstimatedFee();
  }

  void _calculateEstimatedFee() {
    if (_selectedCargoType.value == null) return;

    final weight = double.tryParse(weightController.text) ?? 0;
    if (weight <= 0) {
      _estimatedFee.value = 0;
      return;
    }

    double baseRate = _selectedCargoType.value?.baseRate ?? 0;
    double fee = weight * baseRate;

    // Add surcharges
    if (_isFragile.value) fee *= 1.2;
    if (_isPerishable.value) fee *= 1.15;
    if (_needsRefrigeration.value) fee *= 1.25;

    // Apply minimum fee
    final minFee = _selectedCargoType.value?.minFee ?? 50;
    if (fee < minFee) fee = minFee;

    _estimatedFee.value = fee;
  }

  Future<void> calculateExactFee() async {
    if (!canProceed) return;

    try {
      _isCalculating.value = true;

      final response = await _apiClient.post(
        ApiEndpoints.cargoCalculate,
        data: {
          'tripId': _selectedTrip.value?.id,
          'cargoTypeId': _selectedCargoType.value?.id,
          'weight': double.parse(weightController.text),
          'dimensions': dimensionsController.text,
          'isFragile': _isFragile.value,
          'isPerishable': _isPerishable.value,
          'needsRefrigeration': _needsRefrigeration.value,
        },
      );

      if (response != null && response['data'] != null) {
        _calculatedFee.value = response['data']['fee']?.toDouble() ?? 0;

        // Get.snackbar(
        //   'Fee Calculated',
        //   'Estimated fee: ${CurrencyFormatter.format(_calculatedFee.value)}',
        //   snackPosition: SnackPosition.BOTTOM,
        // );
      }
    } catch (e) {
      print('Error calculating fee: $e');
      Get.snackbar(
        'Error',
        'Failed to calculate fee',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isCalculating.value = false;
    }
  }

  // In PassengerCargoController, update the registerCargo method:

  Future<void> registerCargo() async {
    if (!canProceed) return;

    try {
      _isLoading.value = true;

      // Clean phone numbers - remove all spaces and non-digit characters
      String cleanSenderPhone = senderPhoneController.text.replaceAll(RegExp(r'\D'), '');
      String cleanReceiverPhone = receiverPhoneController.text.replaceAll(RegExp(r'\D'), '');

      print('📞 Original sender phone: ${senderPhoneController.text}');
      print('📞 Cleaned sender phone: $cleanSenderPhone');
      print('📞 Original receiver phone: ${receiverPhoneController.text}');
      print('📞 Cleaned receiver phone: $cleanReceiverPhone');

      // Validate phone numbers after cleaning
      if (cleanSenderPhone.length < 9 || cleanReceiverPhone.length < 9) {
        Get.snackbar(
          'Validation Error',
          'Please enter valid phone numbers',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        _isLoading.value = false;
        return;
      }

      final request = CargoRequest(
        senderName: senderNameController.text.trim(),
        senderPhone: cleanSenderPhone, // Use cleaned phone
        receiverName: receiverNameController.text.trim(),
        receiverPhone: cleanReceiverPhone, // Use cleaned phone
        tripId: _selectedTrip.value!.id,
        cargoTypeId: _selectedCargoType.value!.id,
        weight: double.parse(weightController.text),
        dimensions: dimensionsController.text.isEmpty
            ? null
            : dimensionsController.text.trim(),
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text.trim(),
        declaredValue: declaredValueController.text.isEmpty
            ? null
            : double.parse(declaredValueController.text),
        isFragile: _isFragile.value,
        isPerishable: _isPerishable.value,
        needsRefrigeration: _needsRefrigeration.value,
      );

      print('📤 Sending cleaned request: ${request.toJson()}');

      final response = await _apiClient.post(
        ApiEndpoints.cargoRegister,
        data: request.toJson(),
      );

      if (response != null && response['data'] != null) {
        final cargo = CargoModel.fromJson(response['data']);
        _trackingCode.value = cargo.trackingCode;

        // Navigate to success page
        Get.toNamed(
          AppRoutes.passengerCargoReceipt,
          arguments: {'cargo': cargo},
        );

        // Refresh cargo list
        loadCargoList();
      }
    } catch (e) {
      print('Error registering cargo: $e');
      Get.snackbar(
        'Error',
        'Failed to register cargo',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<CargoModel?> trackCargo(String trackingCode) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '${ApiEndpoints.cargoTrack}?code=$trackingCode',
      );

      if (response != null && response['data'] != null) {
        final cargo = CargoModel.fromJson(response['data']);
        _selectedCargo.value = cargo;
        return cargo;
      }
      return null;
    } catch (e) {
      print('Error tracking cargo: $e');
      Get.snackbar(
        'Error',
        'Cargo not found',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<CargoModel?> getCargoDetails(String cargoId) async {
    try {
      _isLoading.value = true;

      final response = await _apiClient.get(
        '${ApiEndpoints.cargo}/$cargoId',
      );

      if (response != null && response['data'] != null) {
        final cargo = CargoModel.fromJson(response['data']);
        _selectedCargo.value = cargo;
        return cargo;
      }
      return null;
    } catch (e) {
      print('Error fetching cargo details: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  void nextStep() {
    if (_currentStep.value < 2 && canProceed) {
      _currentStep.value++;
    }
  }

  void previousStep() {
    if (_currentStep.value > 0) {
      _currentStep.value--;
    }
  }

  void resetForm() {
    senderNameController.clear();
    senderPhoneController.clear();
    receiverNameController.clear();
    receiverPhoneController.clear();
    weightController.clear();
    dimensionsController.clear();
    descriptionController.clear();
    declaredValueController.clear();
    _selectedTrip.value = null;
    _selectedCargoType.value = null;
    _isFragile.value = false;
    _isPerishable.value = false;
    _needsRefrigeration.value = false;
    _estimatedFee.value = 0;
    _calculatedFee.value = 0;
    _currentStep.value = 0;
  }

  @override
  void onClose() {
    senderNameController.dispose();
    senderPhoneController.dispose();
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    cargoTypeController.dispose();
    weightController.dispose();
    dimensionsController.dispose();
    descriptionController.dispose();
    declaredValueController.dispose();
    senderNameFocusNode.dispose();
    senderPhoneFocusNode.dispose();
    receiverNameFocusNode.dispose();
    receiverPhoneFocusNode.dispose();
    trackingCodeController.dispose();
    weightFocusNode.dispose();
    originController.dispose();
    destinationController.dispose();
    super.onClose();
  }
}

class CargoType {
  final String id;
  final String name;
  final double baseRate;
  final double minFee;
  final String? icon;
  final String? description;

  CargoType({
    required this.id,
    required this.name,
    required this.baseRate,
    required this.minFee,
    this.icon,
    this.description,
  });

  factory CargoType.fromJson(Map<String, dynamic> json) {
    return CargoType(
      id: json['id'],
      name: json['name'],
      baseRate: json['baseRate'].toDouble(),
      minFee: json['minFee'].toDouble(),
      icon: json['icon'],
      description: json['description'],
    );
  }
}