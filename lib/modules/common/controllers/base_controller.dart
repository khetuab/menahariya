// lib/modules/common/controllers/base_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_exception.dart';
import 'package:menahariya/core/services/connectivity/connectivity_service.dart';
import 'package:menahariya/core/widgets/dialogs/custom_snackbar.dart';

abstract class BaseController extends GetxController {
  // Loading states
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _errorMessage = Rxn<String>();
  final _hasError = false.obs;

  // Pagination
  final _currentPage = 1.obs;
  final _hasMorePages = true.obs;
  final _totalItems = 0.obs;

  // Connectivity
  final ConnectivityService _connectivityService = ConnectivityService.instance;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  String? get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasMorePages => _hasMorePages.value;
  int get currentPage => _currentPage.value;
  int get totalItems => _totalItems.value;
  bool get isConnected => _connectivityService.isConnected;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    // _connectivityService.isConnected is already an RxBool
    ever(_connectivityService.isConnectedRx, (connected) {
      if (connected && _hasError.value) {
        retry();
      }
    });
  }

  // Loading management
  void showLoading() => _isLoading.value = true;
  void hideLoading() => _isLoading.value = false;

  void showRefreshing() => _isRefreshing.value = true;
  void hideRefreshing() => _isRefreshing.value = false;

  // Error handling - NO GETX SNACKBARS USED
  void handleError(dynamic error) {
    hideLoading();
    hideRefreshing();

    if (error is ApiException) {
      _errorMessage.value = error.message;

      switch (error.statusCode) {
        case 401:
          _handleUnauthorized();
          break;
        case 403:
          _handleForbidden();
          break;
        case 404:
          _handleNotFound();
          break;
        case 500:
          _handleServerError();
          break;
        default:
          _handleGenericError(error.message);
      }
    } else {
      _errorMessage.value = error.toString();
      _handleGenericError(error.toString());
    }

    _hasError.value = true;
  }

  void _handleUnauthorized() {
    CustomSnackbar.showError('Session expired. Please login again.');
    Get.offAllNamed('/auth/login');
  }

  void _handleForbidden() {
    CustomSnackbar.showError('You do not have permission to perform this action');
  }

  void _handleNotFound() {
    CustomSnackbar.showError('The requested resource was not found');
  }

  void _handleServerError() {
    CustomSnackbar.showError('Server error. Please try again later.');
  }

  void _handleGenericError(String message) {
    if (!_connectivityService.isConnected) {
      CustomSnackbar.showWarning('No internet connection');
    } else {
      CustomSnackbar.showError(message);
    }
  }

  void clearError() {
    _errorMessage.value = null;
    _hasError.value = false;
  }

  // Pagination
  void resetPagination() {
    _currentPage.value = 1;
    _hasMorePages.value = true;
  }

  void incrementPage() {
    _currentPage.value++;
  }

  void setNoMorePages() {
    _hasMorePages.value = false;
  }

  void setTotalItems(int total) {
    _totalItems.value = total;
  }

  // Retry logic
  Future<void> retry() async {
    clearError();
    resetPagination();
    await fetchData();
  }

  // Abstract methods
  Future<void> fetchData({bool refresh = false}) async {}

  Future<void> refreshData() async {
    _isRefreshing.value = true;
    resetPagination();
    await fetchData(refresh: true);
    _isRefreshing.value = false;
  }

  // Network checks
  Future<bool> ensureConnectivity() async {
    if (!_connectivityService.isConnected) {
      final hasConnection = await _connectivityService.hasInternetConnection();
      if (!hasConnection) {
        CustomSnackbar.showWarning('No internet connection');
        return false;
      }
    }
    return true;
  }

  // Success messages
  void showSuccess(String message) {
    CustomSnackbar.showSuccess(message);
  }

  void showWarning(String message) {
    CustomSnackbar.showWarning(message);
  }

  void showInfo(String message) {
    CustomSnackbar.showInfo(message);
  }

  // Confirmation dialog
  Future<bool> showConfirmation({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    ) ??
        false;
  }

  // Loading overlay
  void showLoadingOverlay({String message = 'Loading...'}) {
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideLoadingOverlay() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}

// Pagination Mixin
mixin PaginationMixin<T> on BaseController {
  final _items = <T>[].obs;
  final _filteredItems = <T>[].obs;

  List<T> get items => _filteredItems.value;
  List<T> get allItems => _items;

  void setItems(List<T> newItems, {bool replace = false}) {
    if (replace) {
      _items.value = newItems;
    } else {
      _items.addAll(newItems);
    }
    applyFilter();
  }

  void addItem(T item) {
    _items.add(item);
    applyFilter();
  }

  void updateItem(int index, T item) {
    _items[index] = item;
    applyFilter();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    applyFilter();
  }

  void clearItems() {
    _items.clear();
    _filteredItems.clear();
  }

  @protected
  void applyFilter() {
    _filteredItems.value = _items;
  }

  @protected
  List<T> filterItems(List<T> items) => items;
}

// Search Mixin
mixin SearchMixin<T> on BaseController {
  final _searchQuery = ''.obs;
  final _isSearching = false.obs;

  String get searchQuery => _searchQuery.value;
  bool get isSearching => _isSearching.value;

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _isSearching.value = query.isNotEmpty;
    performSearch(query);
  }

  void clearSearch() {
    _searchQuery.value = '';
    _isSearching.value = false;
    performSearch('');
  }

  @protected
  void performSearch(String query) {}

  List<T> filterByQuery(List<T> items, String query, String Function(T) getSearchableText) {
    if (query.isEmpty) return items;
    return items.where((item) {
      final searchText = getSearchableText(item).toLowerCase();
      return searchText.contains(query.toLowerCase());
    }).toList();
  }
}

// Refresh Mixin
mixin RefreshMixin on BaseController {
  Future<void> onRefresh() async {
    if (!isConnected) {
      CustomSnackbar.showWarning('No internet connection');
      return;
    }
    await refreshData();
  }
}