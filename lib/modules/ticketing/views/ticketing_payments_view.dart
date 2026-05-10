// lib/modules/ticketing/views/ticketing_payments_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';

class TicketingPaymentsView extends StatefulWidget {
  const TicketingPaymentsView({Key? key}) : super(key: key);

  @override
  State<TicketingPaymentsView> createState() => _TicketingPaymentsViewState();
}

class _TicketingPaymentsViewState extends State<TicketingPaymentsView> {
  final ApiClient _apiClient = ApiClient.instance;
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingPayments();
  }

  Future<void> _loadPendingPayments() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/staff/ticketing/bookings');
      if (response != null && response['data'] != null) {
        setState(() => _bookings = (response['data'] as List).where((b) => b['paymentStatus'] == 'pending').toList());
      }
    } catch (e) {
      print('Error loading payments: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmPayment(String bookingId) async {
    final amountController = TextEditingController();
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter payment amount:'),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Amount'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final response = await _apiClient.patch(
        '/staff/ticketing/bookings/$bookingId/payment',
        data: {'paymentStatus': 'paid', 'paymentMethod': 'cash'},
      );
      if (response != null && response['success'] == true) {
        Get.snackbar('Success', 'Payment confirmed', backgroundColor: Colors.green, colorText: Colors.white);
        _loadPendingPayments();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to confirm payment', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Payments'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPendingPayments),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
          ? const Center(child: Text('No pending payments'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          final passengerDetails = booking['passengerDetails'] as List? ?? [];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Booking #${booking['id'].toString().substring(0, 8)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('ETB ${booking['totalAmount']}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Passengers: ${passengerDetails.map((p) => p['name']).join(', ')}'),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: 'Confirm Payment',
                    onPressed: () => _confirmPayment(booking['id']),
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}