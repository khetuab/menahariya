import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';
import 'package:menahariya/core/utils/app_snackbar.dart';

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
  final showFromSuggestions = false.obs;
  final showToSuggestions = false.obs;
  final _isLoading = false.obs;
  final _searchResults = <TripModel>[].obs;
  final _suggestions = <Place>[].obs;
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
  List<Place> get suggestions => _suggestions;
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
    _setupFocusListeners();
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

  void _setupFocusListeners() {
    fromFocusNode.addListener(() {
      showFromSuggestions.value = fromFocusNode.hasFocus;
      if (fromFocusNode.hasFocus && fromController.text.isNotEmpty) {
        getSuggestions(fromController.text);
      }
    });

    toFocusNode.addListener(() {
      showToSuggestions.value = toFocusNode.hasFocus;
      if (toFocusNode.hasFocus && toController.text.isNotEmpty) {
        getSuggestions(toController.text);
      }
    });
  }

  void setFromLocation(Place place) {
    _selectedFrom.value = place;
    fromController.text = place.name;
    _suggestions.clear();
    showFromSuggestions.value = false;
    fromFocusNode.unfocus();
  }

  void setToLocation(Place place) {
    _selectedTo.value = place;
    toController.text = place.name;
    _suggestions.clear();
    showToSuggestions.value = false;
    toFocusNode.unfocus();
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
    if (!isValidSearch) {
      AppSnackbar.show('Error', 'Please select origin and destination');
      return;
    }

    try {
      _isLoading.value = true;
      _searchResults.clear();

      // Build query parameters correctly
      final Map<String, dynamic> params = {
        'origin': _selectedFrom.value?.name,
        'destination': _selectedTo.value?.name,
        'date': DateFormatter.toApiDate(_selectedDate.value!),
        'passengers': _passengerCount.value,
      };

      // Add filter parameters
      params.addAll(_appliedFilters.value.toQueryParams());

      // Remove null values
      params.removeWhere((key, value) => value == null || value == '');

      print('🔍 Search params: $params');

      final response = await _apiClient.get(
        ApiEndpoints.tripsSearch,
        queryParameters: params,
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> trips = response['data'];
        _searchResults.value = trips.map((t) => TripModel.fromJson(t)).toList();

        if (_searchResults.isNotEmpty) {
          _saveRecentSearch();
        } else {
          AppSnackbar.show('Info', 'No trips found for your search');
        }
      }
    } catch (e) {
      print('❌ Search error: $e');
      AppSnackbar.show('Error', 'Failed to search trips. Please try again. ');
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
      print('🔍 Getting suggestions for: $query');

      final response = await _apiClient.get(
        '/places/suggest',
        queryParameters: {'q': query},
      );

      print('📥 Suggestions response: $response');

      // FIX: response is already the parsed body, not the raw HTTP response
      // So response['data'] contains the places array
      if (response != null && response['data'] != null) {
        final List<dynamic> placesData = response['data'];
        if (placesData.isNotEmpty) {
          _suggestions.value = placesData
              .map((p) => Place.fromJson(p as Map<String, dynamic>))
              .toList();
          print('✅ Loaded ${_suggestions.length} suggestions');
        } else {
          _suggestions.clear();
          print('⚠️ No suggestions found');
        }
      } else {
        _suggestions.clear();
      }
    } catch (e, stackTrace) {
      print('❌ Error getting suggestions: $e');
      print('📚 Stack trace: $stackTrace');
      _suggestions.clear();
    }
  }
  void _saveRecentSearch() {
    if (_selectedFrom.value == null || _selectedTo.value == null) return;

    final search = RecentSearch(
      from: _selectedFrom.value!,
      to: _selectedTo.value!,
      date: _selectedDate.value!,
      timestamp: DateTime.now(),
    );

    // Remove duplicate if exists
    _recentSearches.removeWhere((s) =>
    s.from.id == search.from.id &&
        s.to.id == search.to.id &&
        s.date.year == search.date.year &&
        s.date.month == search.date.month &&
        s.date.day == search.date.day
    );

    _recentSearches.insert(0, search);

    // Keep only last 5
    if (_recentSearches.length > 5) {
      _recentSearches.removeLast();
    }
  }

  void _loadRecentSearches() {
    _recentSearches.clear();
  }

  void applyFilters(FilterOptions filters) {
    _appliedFilters.value = filters;
    searchTrips();
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

  void useRecentSearch(RecentSearch search) {
    setFromLocation(search.from);
    setToLocation(search.to);
    setDate(search.date);
    searchTrips();
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
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString(),
      station: json['station']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'station': station,
    };
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

    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (busTypes.isNotEmpty) params['busTypes'] = busTypes.join(',');
    if (amenities.isNotEmpty) params['amenities'] = amenities.join(',');
    if (sortBy != null) params['sortBy'] = sortBy;
    if (departureTimeRange != null) params['timeRange'] = departureTimeRange;

    return params;
  }

  FilterOptions copyWith({
    double? minPrice,
    double? maxPrice,
    List<String>? busTypes,
    List<String>? amenities,
    String? sortBy,
    String? departureTimeRange,
  }) {
    return FilterOptions(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      busTypes: busTypes ?? this.busTypes,
      amenities: amenities ?? this.amenities,
      sortBy: sortBy ?? this.sortBy,
      departureTimeRange: departureTimeRange ?? this.departureTimeRange,
    );
  }
}