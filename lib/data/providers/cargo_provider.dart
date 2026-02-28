// lib/data/providers/cargo_provider.dart

import 'package:get/get.dart';
import 'package:menahariya/core/constants/api_endpoints.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/data/models/cargo/cargo_model.dart';
import 'package:menahariya/data/models/cargo/cargo_request.dart';
import 'package:menahariya/data/models/common/api_response.dart';

class CargoProvider extends GetxController {
  static CargoProvider get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Register Cargo
  Future<ApiResponse<Map<String, dynamic>>> registerCargo(CargoRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.cargoRegister,
        data: request.toJson(),
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

  // Track Cargo
  Future<ApiResponse<CargoModel>> trackCargo(String trackingCode) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.cargoTrack}?code=$trackingCode',
      );

      return ApiResponse<CargoModel>.fromJson(
        response,
            (data) => CargoModel.fromJson(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Calculate Cargo Fee
  Future<ApiResponse<Map<String, dynamic>>> calculateFee({
    required String tripId,
    required String cargoTypeId,
    required double weight,
    String? dimensions,
    bool isFragile = false,
    bool isPerishable = false,
    bool needsRefrigeration = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.cargoCalculate,
        data: {
          'tripId': tripId,
          'cargoTypeId': cargoTypeId,
          'weight': weight,
          'dimensions': dimensions,
          'isFragile': isFragile,
          'isPerishable': isPerishable,
          'needsRefrigeration': needsRefrigeration,
        },
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

  // Get Cargo Types
  Future<ApiResponse<List<Map<String, dynamic>>>> getCargoTypes() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.cargoTypes);

      return ApiResponse<List<Map<String, dynamic>>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Cargo History
  Future<ApiResponse<List<CargoModel>>> getCargoHistory({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.cargoHistory,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );

      return ApiResponse<List<CargoModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => CargoModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Cargo Details
  Future<ApiResponse<CargoModel>> getCargoDetails(String cargoId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.cargo}/$cargoId',
      );

      return ApiResponse<CargoModel>.fromJson(
        response,
            (data) => CargoModel.fromJson(data),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Get Cargo Receipt
  Future<ApiResponse<Map<String, dynamic>>> getCargoReceipt(String cargoId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.cargoReceipt}/$cargoId',
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

  // Driver: Get Cargo List for Trip
  Future<ApiResponse<List<CargoModel>>> getTripCargoList(String tripId) async {
    try {
      final response = await _apiClient.get(
        '/driver/cargo-list/$tripId',
      );

      return ApiResponse<List<CargoModel>>.fromJson(
        response,
            (data) => (data as List)
            .map((item) => CargoModel.fromJson(item))
            .toList(),
      );
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Driver: Mark Cargo as Loaded
  Future<ApiResponse<dynamic>> markCargoLoaded(String cargoId, String tripId) async {
    try {
      final response = await _apiClient.post(
        '/driver/mark-cargo-loaded',
        data: {
          'cargoId': cargoId,
          'tripId': tripId,
        },
      );

      return ApiResponse<dynamic>.fromJson(response, (data) => data);
    } on ApiException catch (e) {
      throw e;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Driver: Update Cargo Status
  Future<ApiResponse<dynamic>> updateCargoStatus({
    required String cargoId,
    required String status,
    String? location,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/driver/update-cargo-status',
        data: {
          'cargoId': cargoId,
          'status': status,
          'location': location,
          'notes': notes,
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