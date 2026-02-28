// lib/modules/passenger/controllers/dashboard_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/socket/socket_service.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/data/models/ticket/ticket_model.dart';
import 'package:menahariya/data/models/notification/notification_model.dart';
import 'package:menahariya/modules/auth/controllers/auth_controller.dart';
import 'package:menahariya/modules/passenger/controllers/home_controller.dart';
import 'package:menahariya/modules/passenger/controllers/search_controller.dart';
import 'package:menahariya/modules/passenger/controllers/ticket_controller.dart';
import 'package:menahariya/modules/passenger/controllers/cargo_controller.dart';
import 'package:menahariya/modules/passenger/controllers/history_controller.dart';
import 'package:menahariya/modules/passenger/controllers/profile_controller.dart';
import 'package:menahariya/modules/passenger/controllers/notification_controller.dart';

class PassengerDashboardController extends GetxController {
  static PassengerDashboardController get instance => Get.find();

  // Core services
  final ApiClient _apiClient = ApiClient.instance;
  final SocketService _socketService = SocketService.instance;
  final AuthController _authController = AuthController.instance;

  // Child controllers (lazy loaded)
  late final HomeController homeController;
  late final PassengerSearchController searchController;
  late final PassengerTicketController ticketController;
  late final PassengerCargoController cargoController;
  late final PassengerHistoryController historyController;
  late final PassengerProfileController profileController;
  late final PassengerNotificationController notificationController;

  // Observables
  final _currentIndex = 0.obs;
  final _isLoading = false.obs;
  final _unreadNotifications = 0.obs;
  final _upcomingTrips = <TripModel>[].obs;
  final _recentTickets = <TicketModel>[].obs;
  final _greetingMessage = ''.obs;

  // Getters
  int get currentIndex => _currentIndex.value;
  bool get isLoading => _isLoading.value;
  int get unreadNotifications => _unreadNotifications.value;
  List<TripModel> get upcomingTrips => _upcomingTrips;
  List<TicketModel> get recentTickets => _recentTickets;
  String get greetingMessage => _greetingMessage.value;

  // Screen titles
  final List<String> screenTitles = [
    'Home',
    'Search',
    'My Tickets',
    'Cargo',
    'Profile',
  ];

  // Screen icons
  final List<IconData> screenIcons = const [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.confirmation_number_rounded,
    Icons.inventory_2_rounded,
    Icons.person_rounded,
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadDashboardData();
    _setupGreeting();
    _setupSocketListeners();
  }

  void _initializeControllers() {
    homeController = Get.find<HomeController>();
    searchController = Get.find<PassengerSearchController>();
    ticketController = Get.find<PassengerTicketController>();
    cargoController = Get.find<PassengerCargoController>();
    historyController = Get.find<PassengerHistoryController>();
    profileController = Get.find<PassengerProfileController>();
    notificationController = Get.find<PassengerNotificationController>();
  }

  void _setupGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greetingMessage.value = 'Good Morning';
    } else if (hour < 17) {
      _greetingMessage.value = 'Good Afternoon';
    } else {
      _greetingMessage.value = 'Good Evening';
    }
  }

  void _setupSocketListeners() {
    // Listen for real-time updates
    _socketService.on('ticket_update', _handleTicketUpdate);
    _socketService.on('cargo_update', _handleCargoUpdate);
    _socketService.on('notification_new', _handleNewNotification);
  }

  Future<void> _loadDashboardData() async {
    try {
      _isLoading.value = true;

      // Load dashboard data in parallel
      await Future.wait([
        _loadUpcomingTrips(),
        _loadRecentTickets(),
        _loadUnreadNotifications(),
      ]);
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadUpcomingTrips() async {
    try {
      final response = await _apiClient.get(
        '/passenger/upcoming-trips',
        queryParameters: {'limit': 5},
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> trips = response['data'];
        _upcomingTrips.value = trips.map((t) => TripModel.fromJson(t)).toList();
      }
    } catch (e) {
      print('Error loading upcoming trips: $e');
    }
  }

  Future<void> _loadRecentTickets() async {
    try {
      final response = await _apiClient.get(
        '/passenger/recent-tickets',
        queryParameters: {'limit': 3},
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> tickets = response['data'];
        _recentTickets.value = tickets.map((t) => TicketModel.fromJson(t)).toList();
      }
    } catch (e) {
      print('Error loading recent tickets: $e');
    }
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final response = await _apiClient.get(
        '/notifications/unread/count',
      );

      if (response != null && response['data'] != null) {
        _unreadNotifications.value = response['data']['count'] ?? 0;
      }
    } catch (e) {
      print('Error loading unread notifications: $e');
    }
  }

  void changeTab(int index) {
    if (_currentIndex.value == index) return;
    _currentIndex.value = index;
  }

  void _handleTicketUpdate(dynamic data) {
    // Refresh tickets when updated
    _loadRecentTickets();
  }

  void _handleCargoUpdate(dynamic data) {
    // Refresh cargo when updated
    cargoController.loadCargoList();
  }

  void _handleNewNotification(dynamic data) {
    _unreadNotifications.value++;
    notificationController.addNotification(NotificationModel.fromJson(data));
  }

  void markNotificationsAsRead() {
    _unreadNotifications.value = 0;
  }

  @override
  void onClose() {
    // Remove socket listeners
    _socketService.off('ticket_update', _handleTicketUpdate);
    _socketService.off('cargo_update', _handleCargoUpdate);
    _socketService.off('notification_new', _handleNewNotification);
    super.onClose();
  }
}