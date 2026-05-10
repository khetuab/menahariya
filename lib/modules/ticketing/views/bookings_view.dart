// lib/modules/ticketing/views/bookings_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/services/api/api_client.dart';

class TicketingBookingsView extends StatefulWidget {
  const TicketingBookingsView({Key? key}) : super(key: key);

  @override
  State<TicketingBookingsView> createState() => _TicketingBookingsViewState();
}

class _TicketingBookingsViewState extends State<TicketingBookingsView> {
  final ApiClient _apiClient = ApiClient.instance;
  List<dynamic> _bookings = [];
  bool _isLoading = true;

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
    } finally {
      setState(() => _isLoading = false);
    }
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No bookings found'),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('Booking #${booking['id'].toString().substring(0, 8)}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount: ETB ${booking['totalAmount']}'),
                  Text('Status: ${booking['bookingStatus']}'),
                ],
              ),
              trailing: Chip(
                label: Text(booking['paymentStatus'] ?? 'pending'),
                backgroundColor: booking['paymentStatus'] == 'paid'
                    ? Colors.green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
              ),
            ),
          );
        },
      ),
    );
  }
}