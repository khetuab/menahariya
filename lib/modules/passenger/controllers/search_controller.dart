// lib/modules/passenger/controllers/search_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';

class PassengerSearchController extends GetxController {
  static PassengerSearchController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Search form controllers
  late final TextEditingController fromController;
  late final TextEditingController toController;
  late final TextEditingController dateController;
  late final TextEditingController passengersController;

  // Focus nodes
  late final FocusNode fromFocusNode;
  late final FocusNode toFocusNode;
  late final FocusNode dateFocusNode;
  late final FocusNode passengersFocusNode;

  // Observables
  final _isLoading = false.obs;
  final _searchResults = <TripModel>[].obs;
  final _suggestions = <String>[].obs;
  final _recentSearches = <RecentSearch>[].obs;
  final _selectedFrom = Rxn<Place>();
  final _selectedTo = Rxn<Place>();
  final _selectedDate = Rxn<DateTime>();
  final _passengerCount = 1.obs;
  final _isRoundTrip = false.obs;
  final _returnDate = Rxn<DateTime>();
  final _showFilters = false.obs;
  final _appliedFilters = FilterOptions().obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<TripModel> get searchResults => _searchResults;
  List<String> get suggestions => _suggestions;
  List<RecentSearch> get recentSearches => _recentSearches;
  Place? get selectedFrom => _selectedFrom.value;
  Place? get selectedTo => _selectedTo.value;
  DateTime? get selectedDate => _selectedDate.value;
  int get passengerCount => _passengerCount.value;
  bool get isRoundTrip => _isRoundTrip.value;
  DateTime? get returnDate => _returnDate.value;
  bool get showFilters => _showFilters.value;
  FilterOptions get appliedFilters => _appliedFilters.value;

  // Computed getters
  bool get isValidSearch {
    return _selectedFrom.value != null &&
        _selectedTo.value != null &&
        _selectedDate.value != null &&
        _selectedFrom.value?.id != _selectedTo.value?.id;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadRecentSearches();
  }

  void _initializeControllers() {
    fromController = TextEditingController();
    toController = TextEditingController();
    dateController = TextEditingController();
    passengersController = TextEditingController(text: '1');

    fromFocusNode = FocusNode();
    toFocusNode = FocusNode();
    dateFocusNode = FocusNode();
    passengersFocusNode = FocusNode();

    // Set initial date to tomorrow
    _selectedDate.value = DateTime.now().add(const Duration(days: 1));
    dateController.text = DateFormatter.toCompactDate(_selectedDate.value!);

    passengersController.text = _passengerCount.value.toString();
  }

  void swapLocations() {
    final tempFrom = _selectedFrom.value;
    final tempFromText = fromController.text;

    _selectedFrom.value = _selectedTo.value;
    fromController.text = toController.text;

    _selectedTo.value = tempFrom;
    toController.text = tempFromText;
  }

  void setFromLocation(Place place) {
    _selectedFrom.value = place;
    fromController.text = place.name;
  }

  void setToLocation(Place place) {
    _selectedTo.value = place;
    toController.text = place.name;
  }

  void setDate(DateTime date) {
    _selectedDate.value = date;
    dateController.text = DateFormatter.toCompactDate(date);
  }

  void setReturnDate(DateTime date) {
    _returnDate.value = date;
  }

  void incrementPassengers() {
    if (_passengerCount.value < 10) {
      _passengerCount.value++;
      passengersController.text = _passengerCount.value.toString();
    }
  }

  void decrementPassengers() {
    if (_passengerCount.value > 1) {
      _passengerCount.value--;
      passengersController.text = _passengerCount.value.toString();
    }
  }

  void toggleRoundTrip(bool? value) {
    _isRoundTrip.value = value ?? false;
    if (!_isRoundTrip.value) {
      _returnDate.value = null;
    }
  }

  Future<void> searchTrips() async {
    if (!isValidSearch) return;

    try {
      _isLoading.value = true;
      _searchResults.clear();

      final response = await _apiClient.get(
        ApiEndpoints.tripsSearch,
        queryParameters: {
          'from': _selectedFrom.value?.id,
          'to': _selectedTo.value?.id,
          'date': DateFormatter.toApiDate(_selectedDate.value!),
          'passengers': _passengerCount.value,
          ..._appliedFilters.value.toQueryParams(),
        },
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> trips = response['data'];
        _searchResults.value = trips.map((t) => TripModel.fromJson(t)).toList();

        // Save to recent searches
        _saveRecentSearch();
      }
    } catch (e) {
      print('Search error: $e');
      Get.snackbar(
        'Search Failed',
        'An error occurred while searching. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> getSuggestions(String query) async {
    if (query.length < 2) {
      _suggestions.clear();
      return;
    }

    try {
      final response = await _apiClient.get(
        '/places/suggest',
        queryParameters: {'q': query},
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> places = response['data'];
        _suggestions.value = places.map((p) => p['name'].toString()).toList();
      }
    } catch (e) {
      print('Error getting suggestions: $e');
    }
  }

  void _saveRecentSearch() {
    final search = RecentSearch(
      from: _selectedFrom.value!,
      to: _selectedTo.value!,
      date: _selectedDate.value!,
      timestamp: DateTime.now(),
    );

    _recentSearches.insert(0, search);
    if (_recentSearches.length > 5) {
      _recentSearches.removeLast();
    }

    // Save to local storage
  }

  void _loadRecentSearches() {
    // Load from local storage
  }

  void applyFilters(FilterOptions filters) {
    _appliedFilters.value = filters;
    if (_searchResults.isNotEmpty) {
      searchTrips();
    }
  }

  void toggleFilters() {
    _showFilters.value = !_showFilters.value;
  }

  void clearFilters() {
    _appliedFilters.value = FilterOptions();
    if (_searchResults.isNotEmpty) {
      searchTrips();
    }
  }

  void clearSearch() {
    _selectedFrom.value = null;
    _selectedTo.value = null;
    fromController.clear();
    toController.clear();
    _searchResults.clear();
    _suggestions.clear();
  }

  @override
  void onClose() {
    fromController.dispose();
    toController.dispose();
    dateController.dispose();
    passengersController.dispose();
    fromFocusNode.dispose();
    toFocusNode.dispose();
    dateFocusNode.dispose();
    passengersFocusNode.dispose();
    super.onClose();
  }
}

class Place {
  final String id;
  final String name;
  final String? city;
  final String? station;

  Place({
    required this.id,
    required this.name,
    this.city,
    this.station,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      station: json['station'],
    );
  }
}

class RecentSearch {
  final Place from;
  final Place to;
  final DateTime date;
  final DateTime timestamp;

  RecentSearch({
    required this.from,
    required this.to,
    required this.date,
    required this.timestamp,
  });
}

class FilterOptions {
  final double? minPrice;
  final double? maxPrice;
  final List<String> busTypes;
  final List<String> amenities;
  final String? sortBy;
  final String? departureTimeRange;

  FilterOptions({
    this.minPrice,
    this.maxPrice,
    this.busTypes = const [],
    this.amenities = const [],
    this.sortBy,
    this.departureTimeRange,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (minPrice != null) params['min_price'] = minPrice;
    if (maxPrice != null) params['max_price'] = maxPrice;
    if (busTypes.isNotEmpty) params['bus_types'] = busTypes.join(',');
    if (amenities.isNotEmpty) params['amenities'] = amenities.join(',');
    if (sortBy != null) params['sort_by'] = sortBy;
    if (departureTimeRange != null) params['time_range'] = departureTimeRange;

    return params;
  }
}