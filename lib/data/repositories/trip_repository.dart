// lib/data/repositories/trip_repository.dart

import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/core/services/storage/local_storage.dart';
import 'package:menahariya/data/providers/trip_provider.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/data/models/trip/route_model.dart';
import 'package:menahariya/data/models/trip/schedule_model.dart';

class TripRepository extends GetxController {
  static TripRepository get instance => Get.find();

  final TripProvider _tripProvider = TripProvider.instance;
  final LocalStorage _localStorage = LocalStorage();

  // Cache keys
  static const String _cachePopularRoutes = 'popular_routes';
  static const String _cacheFeaturedTrips = 'featured_trips';
  static const Duration _cacheDuration = Duration(hours: 1);

  // Search Trips
  Future<List<TripModel>> searchTrips(Map<String, dynamic> filters) async {
    try {
      final response = await _tripProvider.searchTrips(filters);

      if (response.success) {
        return response.data ?? [];
      }

      throw ApiException(
        message: response.message ?? 'Failed to search trips',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleTripError(e);
    }
  }

  // Get Trip Details with Caching
  Future<TripModel> getTripDetails(String tripId, {bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _localStorage.getCachedData('trip_$tripId');
        if (cached != null) {
          return TripModel.fromJson(cached);
        }
      }

      final response = await _tripProvider.getTripDetails(tripId);

      if (response.success && response.data != null) {
        // Cache the result
        await _localStorage.cacheData(
          'trip_$tripId',
          response.data!.toJson(),
          expiry: _cacheDuration,
        );

        return response.data!;
      }

      throw ApiException(
        message: response.message ?? 'Failed to get trip details',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleTripError(e);
    }
  }

  // Get Popular Routes with Caching
  Future<List<RouteModel>> getPopularRoutes({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _localStorage.getCachedData(_cachePopularRoutes);
        if (cached != null) {
          return (cached as List)
              .map((item) => RouteModel.fromJson(item))
              .toList();
        }
      }

      final response = await _tripProvider.getPopularRoutes();

      if (response.success) {
        final routes = response.data ?? [];

        // Cache the result
        await _localStorage.cacheData(
          _cachePopularRoutes,
          routes.map((r) => r.toJson()).toList(),
          expiry: _cacheDuration,
        );

        return routes;
      }

      return [];
    } on ApiException catch (e) {
      print('Error getting popular routes: ${e.message}');
      return [];
    }
  }

  // Get Featured Trips with Caching
  Future<List<TripModel>> getFeaturedTrips({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _localStorage.getCachedData(_cacheFeaturedTrips);
        if (cached != null) {
          return (cached as List)
              .map((item) => TripModel.fromJson(item))
              .toList();
        }
      }

      final response = await _tripProvider.getFeaturedTrips();

      if (response.success) {
        final trips = response.data ?? [];

        // Cache the result
        await _localStorage.cacheData(
          _cacheFeaturedTrips,
          trips.map((t) => t.toJson()).toList(),
          expiry: _cacheDuration,
        );

        return trips;
      }

      return [];
    } on ApiException catch (e) {
      print('Error getting featured trips: ${e.message}');
      return [];
    }
  }

  // Get Available Trips
  Future<List<TripModel>> getAvailableTrips({
    required String from,
    required String to,
    required DateTime date,
  }) async {
    try {
      final response = await _tripProvider.getAvailableTrips(
        from: from,
        to: to,
        date: date,
      );

      if (response.success) {
        return response.data ?? [];
      }

      return [];
    } on ApiException catch (e) {
      throw _handleTripError(e);
    }
  }

  // Get Upcoming Trips
  Future<List<TripModel>> getUpcomingTrips({int limit = 10}) async {
    try {
      final response = await _tripProvider.getUpcomingTrips(limit: limit);

      if (response.success) {
        return response.data ?? [];
      }

      return [];
    } on ApiException catch (e) {
      throw _handleTripError(e);
    }
  }

  // Get Schedules
  Future<List<ScheduleModel>> getSchedules(String routeId) async {
    try {
      final response = await _tripProvider.getSchedules(routeId);

      if (response.success) {
        return response.data ?? [];
      }

      return [];
    } on ApiException catch (e) {
      throw _handleTripError(e);
    }
  }

  // Check Seat Availability
  Future<Map<String, dynamic>> checkSeatAvailability(String tripId) async {
    try {
      final response = await _tripProvider.checkSeatAvailability(tripId);

      if (response.success) {
        return response.data ?? {};
      }

      throw ApiException(
        message: response.message ?? 'Failed to check seat availability',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleTripError(e);
    }
  }

  // Get Seat Map
  Future<Map<String, dynamic>> getSeatMap(String tripId) async {
    try {
      final response = await _tripProvider.getSeatMap(tripId);

      if (response.success) {
        return response.data ?? {};
      }

      throw ApiException(
        message: response.message ?? 'Failed to get seat map',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleTripError(e);
    }
  }

  // Lock Seat
  Future<bool> lockSeat(String tripId, String seatNumber, int duration) async {
    try {
      final response = await _tripProvider.lockSeat(tripId, seatNumber, duration);
      return response.success;
    } on ApiException catch (e) {
      print('Error locking seat: ${e.message}');
      return false;
    }
  }

  // Release Seat
  Future<bool> releaseSeat(String tripId, String seatNumber) async {
    try {
      final response = await _tripProvider.releaseSeat(tripId, seatNumber);
      return response.success;
    } on ApiException catch (e) {
      print('Error releasing seat: ${e.message}');
      return false;
    }
  }

  // Clear Cache
  Future<void> clearCache() async {
    await _localStorage.clearCache();
  }

  // Handle Trip Errors
  ApiException _handleTripError(ApiException e) {
    switch (e.statusCode) {
      case 404:
        return ApiException(
          message: 'Trip not found',
          statusCode: 404,
        );
      case 410:
        return ApiException(
          message: 'Trip is no longer available',
          statusCode: 410,
        );
      default:
        return e;
    }
  }
}