// lib/data/repositories/cargo_repository.dart

import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/core/services/storage/local_storage.dart';
import 'package:menahariya/data/providers/cargo_provider.dart';
import 'package:menahariya/data/models/cargo/cargo_model.dart';
import 'package:menahariya/data/models/cargo/cargo_request.dart';
import 'package:menahariya/data/models/cargo/cargo_receipt_model.dart';

class CargoRepository extends GetxController {
  static CargoRepository get instance => Get.find();

  final CargoProvider _cargoProvider = CargoProvider.instance;
  final LocalStorage _localStorage = LocalStorage();

  // Cache keys
  static const String _cacheCargoTypes = 'cargo_types';
  static const String _cacheCargoHistory = 'cargo_history';
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Register Cargo
  Future<CargoModel> registerCargo(CargoRequest request) async {
    try {
      final response = await _cargoProvider.registerCargo(request);

      if (response.success && response.data != null) {
        // Clear cached history as it's now outdated
        await _localStorage.clear(_cacheCargoHistory);

        return CargoModel.fromJson(response.data!);
      }

      throw ApiException(
        message: response.message ?? 'Failed to register cargo',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleCargoError(e);
    }
  }

  // Track Cargo
  Future<CargoModel?> trackCargo(String trackingCode) async {
    try {
      final response = await _cargoProvider.trackCargo(trackingCode);

      if (response.success) {
        return response.data;
      }

      return null;
    } on ApiException catch (e) {
      print('Error tracking cargo: ${e.message}');
      return null;
    }
  }

  // Calculate Cargo Fee
  Future<Map<String, dynamic>> calculateFee({
    required String tripId,
    required String cargoTypeId,
    required double weight,
    String? dimensions,
    bool isFragile = false,
    bool isPerishable = false,
    bool needsRefrigeration = false,
  }) async {
    try {
      final response = await _cargoProvider.calculateFee(
        tripId: tripId,
        cargoTypeId: cargoTypeId,
        weight: weight,
        dimensions: dimensions,
        isFragile: isFragile,
        isPerishable: isPerishable,
        needsRefrigeration: needsRefrigeration,
      );

      if (response.success) {
        return response.data ?? {};
      }

      throw ApiException(
        message: response.message ?? 'Fee calculation failed',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      throw _handleCargoError(e);
    }
  }

  // Get Cargo Types with Caching
  Future<List<CargoType>> getCargoTypes({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _localStorage.getCachedData(_cacheCargoTypes);
        if (cached != null) {
          return (cached as List)
              .map((item) => CargoType.fromJson(item))
              .toList();
        }
      }

      final response = await _cargoProvider.getCargoTypes();

      if (response.success) {
        final types = (response.data ?? [])
            .map((item) => CargoType.fromJson(item))
            .toList();

        // Cache the result
        await _localStorage.cacheData(
          _cacheCargoTypes,
          types.map((t) => t.toJson()).toList(),
          expiry: _cacheDuration,
        );

        return types;
      }

      return [];
    } catch (e) {
      print('Error getting cargo types: $e');
      return [];
    }
  }

  // Get Cargo History with Pagination
  Future<List<CargoModel>> getCargoHistory({
    int page = 1,
    int limit = 10,
    String? status,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache for first page only
      if (!forceRefresh && page == 1 && status == null) {
        final cached = await _localStorage.getCachedData(_cacheCargoHistory);
        if (cached != null) {
          return (cached as List)
              .map((item) => CargoModel.fromJson(item))
              .toList();
        }
      }

      final response = await _cargoProvider.getCargoHistory(
        page: page,
        limit: limit,
        status: status,
      );

      if (response.success) {
        final cargoList = response.data ?? [];

        // Cache first page results
        if (page == 1 && status == null) {
          await _localStorage.cacheData(
            _cacheCargoHistory,
            cargoList.map((c) => c.toJson()).toList(),
            expiry: _cacheDuration,
          );
        }

        return cargoList;
      }

      return [];
    } on ApiException catch (e) {
      print('Error getting cargo history: ${e.message}');
      return [];
    }
  }

  // Get Cargo Details
  Future<CargoModel?> getCargoDetails(String cargoId) async {
    try {
      final response = await _cargoProvider.getCargoDetails(cargoId);

      if (response.success) {
        return response.data;
      }

      return null;
    } catch (e) {
      print('Error getting cargo details: $e');
      return null;
    }
  }

  // Get Cargo Receipt
  Future<CargoReceipt?> getCargoReceipt(String cargoId) async {
    try {
      final response = await _cargoProvider.getCargoReceipt(cargoId);

      if (response.success && response.data != null) {
        return CargoReceipt.fromJson(response.data!);
      }

      return null;
    } catch (e) {
      print('Error getting cargo receipt: $e');
      return null;
    }
  }

  // Driver: Get Trip Cargo List
  Future<List<CargoModel>> getTripCargoList(String tripId) async {
    try {
      final response = await _cargoProvider.getTripCargoList(tripId);

      if (response.success) {
        return response.data ?? [];
      }

      return [];
    } catch (e) {
      print('Error getting trip cargo list: $e');
      return [];
    }
  }

  // Driver: Mark Cargo as Loaded
  Future<bool> markCargoLoaded(String cargoId, String tripId) async {
    try {
      final response = await _cargoProvider.markCargoLoaded(cargoId, tripId);
      return response.success;
    } catch (e) {
      print('Error marking cargo loaded: $e');
      return false;
    }
  }

  // Driver: Update Cargo Status
  Future<bool> updateCargoStatus({
    required String cargoId,
    required String status,
    String? location,
    String? notes,
  }) async {
    try {
      final response = await _cargoProvider.updateCargoStatus(
        cargoId: cargoId,
        status: status,
        location: location,
        notes: notes,
      );
      return response.success;
    } catch (e) {
      print('Error updating cargo status: $e');
      return false;
    }
  }

  // Handle Cargo Errors
  ApiException _handleCargoError(ApiException e) {
    switch (e.statusCode) {
      case 400:
        return ApiException(
          message: 'Invalid cargo details',
          statusCode: 400,
        );
      case 413:
        return ApiException(
          message: 'Cargo weight exceeds limit',
          statusCode: 413,
        );
      default:
        return e;
    }
  }
}