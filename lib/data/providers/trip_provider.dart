// lib/data/providers/trip_provider.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/data/models/trip/route_model.dart';
import 'package:menahariya/data/models/trip/schedule_model.dart';
import 'package:menahariya/data/models/common/api_response.dart';

class TripProvider extends GetxController {
  static TripProvider get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Search Trips
  Future<ApiResponse<List<TripModel>>> searchTrips(Map<String, dynamic> filters) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.tripsSearch,
        queryParameters: filters,
      );

      return ApiResponse<List<TripModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => TripModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Trip Details
  Future<ApiResponse<TripModel>> getTripDetails(String tripId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.tripsDetails}/$tripId',
      );

      return ApiResponse<TripModel>.fromJson(
        response,
            (data) => TripModel.fromJson(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Popular Routes
  Future<ApiResponse<List<RouteModel>>> getPopularRoutes({int limit = 5}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.routesPopular,
        queryParameters: {'limit': limit},
      );

      return ApiResponse<List<RouteModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => RouteModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get All Routes
  Future<ApiResponse<List<RouteModel>>> getAllRoutes() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.routesAll);

      return ApiResponse<List<RouteModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => RouteModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Featured Trips
  Future<ApiResponse<List<TripModel>>> getFeaturedTrips({int limit = 5}) async {
    try {
      final response = await _apiClient.get(
        '/trips/featured',
        queryParameters: {'limit': limit},
      );

      return ApiResponse<List<TripModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => TripModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Available Trips
  Future<ApiResponse<List<TripModel>>> getAvailableTrips({
    required String from,
    required String to,
    required DateTime date,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.tripsAvailable,
        queryParameters: {
          'from': from,
          'to': to,
          'date': date.toIso8601String().split('T')[0],
        },
      );

      return ApiResponse<List<TripModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => TripModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Upcoming Trips
  Future<ApiResponse<List<TripModel>>> getUpcomingTrips({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.tripsUpcoming,
        queryParameters: {'limit': limit},
      );

      return ApiResponse<List<TripModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => TripModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Schedules
  Future<ApiResponse<List<ScheduleModel>>> getSchedules(String routeId) async {
    try {
      final response = await _apiClient.get(
        '/schedules/$routeId',
      );

      return ApiResponse<List<ScheduleModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => ScheduleModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Check Seat Availability
  Future<ApiResponse<Map<String, dynamic>>> checkSeatAvailability(String tripId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.seatsAvailable,
        queryParameters: {'trip_id': tripId},
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
            (data) => Map<String, dynamic>.from(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Seat Map
  Future<ApiResponse<Map<String, dynamic>>> getSeatMap(String tripId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.seatsMap}?trip_id=$tripId',
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
            (data) => Map<String, dynamic>.from(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Lock Seat
  Future<ApiResponse<dynamic>> lockSeat(String tripId, String seatNumber, int duration) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.seatsLock,
        data: {
          'tripId': tripId,
          'seatNumber': seatNumber,
          'duration': duration,
        },
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Release Seat
  Future<ApiResponse<dynamic>> releaseSeat(String tripId, String seatNumber) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.seatsRelease,
        data: {
          'tripId': tripId,
          'seatNumber': seatNumber,
        },
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}