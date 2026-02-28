// lib/modules/passenger/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';

import '../../../data/models/trip/route_model.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Observables
  final _isLoading = false.obs;
  final _popularRoutes = <RouteModel>[].obs;
  final _featuredTrips = <TripModel>[].obs;
  final _recentSearches = <String>[].obs;
  final _quickActions = <QuickAction>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<RouteModel> get popularRoutes => _popularRoutes;
  List<TripModel> get featuredTrips => _featuredTrips;
  List<String> get recentSearches => _recentSearches;
  List<QuickAction> get quickActions => _quickActions;

  @override
  void onInit() {
    super.onInit();
    _loadHomeData();
    _initQuickActions();
    _loadRecentSearches();
  }

  void _initQuickActions() {
    _quickActions.value = [
      QuickAction(
        title: 'Book Ticket',
        icon: Icons.confirmation_number_rounded,
        color: const Color(0xFF4CAF50),
        route: '/passenger/search',
      ),
      QuickAction(
        title: 'Send Cargo',
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFF2196F3),
        route: '/passenger/cargo/register',
      ),
      QuickAction(
        title: 'Track Cargo',
        icon: Icons.track_changes_rounded,
        color: const Color(0xFFFF9800),
        route: '/passenger/cargo/track',
      ),
      QuickAction(
        title: 'My Tickets',
        icon: Icons.confirmation_number_rounded,
        color: const Color(0xFF9C27B0),
        route: '/passenger/tickets',
      ),
    ];
  }

  Future<void> _loadHomeData() async {
    try {
      _isLoading.value = true;

      await Future.wait([
        _loadPopularRoutes(),
        _loadFeaturedTrips(),
      ]);
    } catch (e) {
      print('Error loading home data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadPopularRoutes() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.routesPopular,
        queryParameters: {'limit': 5},
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> routes = response['data'];
        _popularRoutes.value = routes.map((r) => RouteModel.fromJson(r)).toList();
      }
    } catch (e) {
      print('Error loading popular routes: $e');
    }
  }

  Future<void> _loadFeaturedTrips() async {
    try {
      final response = await _apiClient.get(
        '/trips/featured',
        queryParameters: {'limit': 3},
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> trips = response['data'];
        _featuredTrips.value = trips.map((t) => TripModel.fromJson(t)).toList();
      }
    } catch (e) {
      print('Error loading featured trips: $e');
    }
  }

  void _loadRecentSearches() {
    // Load from local storage
    // This will be implemented with SharedPrefs
  }

  void addRecentSearch(String query) {
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
      // Save to local storage
    }
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    // Clear from local storage
  }

  Future<void> refreshHome() async {
    _loadHomeData();
  }
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}