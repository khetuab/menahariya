// lib/modules/ticketing/views/ticketing_trips_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/services/api/api_client.dart';

class TicketingTripsView extends StatefulWidget {
  const TicketingTripsView({Key? key}) : super(key: key);

  @override
  State<TicketingTripsView> createState() => _TicketingTripsViewState();
}

class _TicketingTripsViewState extends State<TicketingTripsView> {
  final ApiClient _apiClient = ApiClient.instance;
  List<dynamic> _trips = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> params = {};
      if (_selectedStatus != 'all') params['status'] = _selectedStatus;
      if (_selectedDate != null) params['date'] = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      final response = await _apiClient.get('/staff/ticketing/trips', queryParameters: params);
      if (response != null && response['data'] != null) {
        setState(() => _trips = response['data']);
      }
    } catch (e) {
      print('Error loading trips: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showTripDetails(dynamic trip) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trip Details', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Route', '${trip['routeId']?['origin'] ?? 'N/A'} → ${trip['routeId']?['destination'] ?? 'N/A'}'),
              _buildDetailRow('Departure', DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(trip['departureTime']))),
              _buildDetailRow('Price', 'ETB ${trip['price']}'),
              _buildDetailRow('Seats', '${trip['availableSeats']}/${trip['totalSeats']} available'),
              _buildDetailRow('Status', trip['status'] ?? 'scheduled'),
              const SizedBox(height: 16),
              Text('Driver: ${trip['driverId']?['fullName'] ?? 'Not assigned'}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTrips),
        ],
      ),
      body: Column(
        children: [
          // Filter Section - Using Column instead of Row to avoid overflow
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Status Dropdown - Full width
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: ['all', 'scheduled', 'in_progress', 'completed', 'cancelled']
                      .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.toUpperCase().replaceAll('_', ' '))
                  ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedStatus = v);
                      _loadTrips();
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Date Picker Button - Full width
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                      _loadTrips();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedDate != null
                                ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                                : 'Select Date',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Clear filter button
                if (_selectedStatus != 'all' || _selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedStatus = 'all';
                          _selectedDate = null;
                        });
                        _loadTrips();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: const Text('Clear Filters'),
                    ),
                  ),
              ],
            ),
          ),
          // Trips List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _trips.isEmpty
                ? const Center(child: Text('No trips found'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _trips.length,
              itemBuilder: (context, index) {
                final trip = _trips[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _showTripDetails(trip),
                    title: Text(
                      '${trip['routeId']?['origin'] ?? 'N/A'} → ${trip['routeId']?['destination'] ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                        DateFormat('MMM dd, HH:mm').format(DateTime.parse(trip['departureTime']))
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(trip['status']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (trip['status'] ?? 'scheduled').replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(trip['status']),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'scheduled': return Colors.blue;
      case 'in_progress': return Colors.orange;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}