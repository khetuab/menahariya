// lib/modules/ticketing/views/ticketing_bookings_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';

class TicketingBookingsView extends StatefulWidget {
  const TicketingBookingsView({Key? key}) : super(key: key);

  @override
  State<TicketingBookingsView> createState() => _TicketingBookingsViewState();
}

class _TicketingBookingsViewState extends State<TicketingBookingsView> {
  final ApiClient _apiClient = ApiClient.instance;
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/staff/ticketing/bookings');
      if (response != null && response['data'] != null) {
        setState(() => _bookings = response['data']);
      }
    } catch (e) {
      print('Error loading bookings: $e');
      _showError('Failed to load bookings');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePaymentStatus(String bookingId, String status) async {
    try {
      final response = await _apiClient.patch(
        '/staff/ticketing/bookings/$bookingId/payment',
        data: {'paymentStatus': status, 'paymentMethod': 'cash'},
      );
      if (response != null && response['success'] == true) {
        _showSuccess('Payment status updated');
        _loadBookings();
      }
    } catch (e) {
      _showError('Failed to update payment');
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('No')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Yes')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final response = await _apiClient.post(
        '/staff/ticketing/bookings/$bookingId/cancel',
        data: {'reason': 'Cancelled by staff'},
      );
      if (response != null && response['success'] == true) {
        _showSuccess('Booking cancelled');
        _loadBookings();
      }
    } catch (e) {
      _showError('Failed to cancel booking');
    }
  }

  void _showBookingDetails(dynamic booking) {
    final passengerDetails = booking['passengerDetails'] as List? ?? [];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Booking Details', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Booking ID', booking['id'].toString().substring(0, 8)),
                _buildDetailRow('Total Amount', 'ETB ${booking['totalAmount']}'),
                _buildDetailRow('Status', booking['bookingStatus'] ?? 'pending'),
                _buildDetailRow('Payment', booking['paymentStatus'] ?? 'pending'),
                const SizedBox(height: 16),
                const Text('Passengers', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...passengerDetails.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('• ${p['name']} - Seat ${p['seatNumber']}'),
                )),
                const SizedBox(height: 24),
                if (booking['paymentStatus'] == 'pending')
                  PrimaryButton(
                    text: 'Confirm Payment',
                    onPressed: () {
                      Get.back();
                      _updatePaymentStatus(booking['id'], 'paid');
                    },
                  ),
                const SizedBox(height: 12),
                if (booking['bookingStatus'] == 'pending')
                  SecondaryButton(
                    text: 'Cancel Booking',
                    onPressed: () {
                      Get.back();
                      _cancelBooking(booking['id']);
                    },
                    textColor: Colors.red,
                    borderColor: Colors.red,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar('Success', message, backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  void _showError(String message) {
    Get.snackbar('Error', message, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  List<dynamic> get _filteredBookings {
    var filtered = _bookings;
    if (_selectedStatus != 'all') {
      filtered = filtered.where((b) => b['bookingStatus'] == _selectedStatus).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((b) {
        final details = b['passengerDetails'] as List? ?? [];
        return details.any((p) =>
        p['name']?.toLowerCase().contains(_searchQuery.toLowerCase()) == true);
      }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBookings),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by passenger name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          // Status Filter - Horizontal scroll to avoid overflow
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['all', 'pending', 'confirmed', 'cancelled'].map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status.toUpperCase()),
                    selected: _selectedStatus == status,
                    onSelected: (_) => setState(() => _selectedStatus = status),
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(color: _selectedStatus == status ? Colors.white : null),
                  ),
                );
              }).toList(),
            ),
          ),
          // Bookings List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                ? const Center(child: Text('No bookings found'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredBookings.length,
              itemBuilder: (context, index) {
                final booking = _filteredBookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _showBookingDetails(booking),
                    title: Text('Booking #${booking['id'].toString().substring(0, 8)}'),
                    subtitle: Text('ETB ${booking['totalAmount']}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: booking['paymentStatus'] == 'paid'
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking['paymentStatus'] ?? 'pending',
                        style: TextStyle(
                          color: booking['paymentStatus'] == 'paid'
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}