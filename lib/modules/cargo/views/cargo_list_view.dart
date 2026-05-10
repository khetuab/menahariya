// lib/modules/cargo/views/cargo_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';

class CargoListView extends StatefulWidget {
  const CargoListView({Key? key}) : super(key: key);

  @override
  State<CargoListView> createState() => _CargoListViewState();
}

class _CargoListViewState extends State<CargoListView> {
  final ApiClient _apiClient = ApiClient.instance;
  List<dynamic> _cargoList = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCargo();
  }

  Future<void> _loadCargo() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/staff/cargo/all');
      if (response != null && response['data'] != null) {
        // Debug: Print first item to see structure
        if (response['data'].isNotEmpty) {
          print('📦 Cargo data structure: ${response['data'][0]}');
        }
        setState(() => _cargoList = response['data']);
      } else {
        setState(() => _cargoList = []);
      }
    } catch (e) {
      print('Error loading cargo: $e');
      Get.snackbar('Error', 'Failed to load cargo', backgroundColor: Colors.red, colorText: Colors.white);
      setState(() => _cargoList = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String cargoId, String newStatus) async {
    try {
      final response = await _apiClient.patch(
        '/staff/cargo/$cargoId/status',
        data: {'status': newStatus},
      );
      if (response != null && response['success'] == true) {
        Get.snackbar('Success', 'Status updated to $newStatus', backgroundColor: Colors.green, colorText: Colors.white);
        _loadCargo();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Helper method to safely get cargo property
  String _getCargoValue(dynamic cargo, String key, {String defaultValue = 'N/A'}) {
    try {
      if (cargo == null) return defaultValue;
      if (cargo[key] != null && cargo[key].toString().isNotEmpty) {
        return cargo[key].toString();
      }
      // Try alternative keys
      if (key == 'trackingCode') {
        if (cargo['trackingCode'] != null) return cargo['trackingCode'].toString();
        if (cargo['tracking_code'] != null) return cargo['tracking_code'].toString();
        if (cargo['code'] != null) return cargo['code'].toString();
      }
      if (key == 'senderName') {
        if (cargo['senderName'] != null) return cargo['senderName'].toString();
        if (cargo['sender_name'] != null) return cargo['sender_name'].toString();
      }
      if (key == 'receiverName') {
        if (cargo['receiverName'] != null) return cargo['receiverName'].toString();
        if (cargo['receiver_name'] != null) return cargo['receiver_name'].toString();
      }
      if (key == 'status') {
        if (cargo['status'] != null) return cargo['status'].toString();
        if (cargo['cargoStatus'] != null) return cargo['cargoStatus'].toString();
      }
      if (key == 'weight') {
        if (cargo['weight'] != null) return cargo['weight'].toString();
      }
      if (key == 'fee') {
        if (cargo['fee'] != null) return cargo['fee'].toString();
        if (cargo['totalFee'] != null) return cargo['totalFee'].toString();
      }
      if (key == 'id') {
        if (cargo['id'] != null) return cargo['id'].toString();
        if (cargo['_id'] != null) return cargo['_id'].toString();
      }
      return defaultValue;
    } catch (e) {
      print('Error getting cargo value for $key: $e');
      return defaultValue;
    }
  }

  Future<void> _generateReceipt(dynamic cargo) async {
    final cargoId = _getCargoValue(cargo, 'id');
    if (cargoId == 'N/A') {
      Get.snackbar('Error', 'Invalid cargo ID', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final response = await _apiClient.get('/staff/cargo/$cargoId/receipt');
      if (response != null && response['data'] != null) {
        final receipt = response['data'];
        Get.dialog(
          AlertDialog(
            title: const Text('Cargo Receipt'),
            content: Container(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Receipt #: ${receipt['receiptNumber'] ?? 'N/A'}'),
                  const Divider(),
                  Text('Tracking: ${receipt['trackingCode'] ?? _getCargoValue(cargo, 'trackingCode')}'),
                  Text('From: ${receipt['senderName'] ?? _getCargoValue(cargo, 'senderName')}'),
                  Text('To: ${receipt['receiverName'] ?? _getCargoValue(cargo, 'receiverName')}'),
                  Text('Weight: ${receipt['weight'] ?? _getCargoValue(cargo, 'weight')} kg'),
                  Text('Fee: ETB ${receipt['fee'] ?? _getCargoValue(cargo, 'fee')}'),
                  Text('Status: ${receipt['status'] ?? _getCargoValue(cargo, 'status')}'),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Close')),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error generating receipt: $e');
      Get.snackbar('Error', 'Failed to generate receipt', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  List<dynamic> get _filteredCargo {
    if (_cargoList.isEmpty) return [];
    var filtered = List.from(_cargoList);
    if (_selectedStatus != 'all') {
      filtered = filtered.where((c) => _getCargoValue(c, 'status') == _selectedStatus).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        final tracking = _getCargoValue(c, 'trackingCode').toLowerCase();
        final sender = _getCargoValue(c, 'senderName').toLowerCase();
        final receiver = _getCargoValue(c, 'receiverName').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return tracking.contains(query) || sender.contains(query) || receiver.contains(query);
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
        title: const Text('Cargo Shipments'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCargo),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by tracking code, sender, receiver...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['all', 'registered', 'loaded', 'in_transit', 'delivered', 'cancelled'].map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status.replaceAll('_', ' ').toUpperCase()),
                    selected: _selectedStatus == status,
                    onSelected: (_) => setState(() => _selectedStatus = status),
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(color: _selectedStatus == status ? Colors.white : null),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCargo.isEmpty
                ? const Center(child: Text('No cargo found'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredCargo.length,
              itemBuilder: (context, index) {
                final cargo = _filteredCargo[index];
                final trackingCode = _getCargoValue(cargo, 'trackingCode');
                final senderName = _getCargoValue(cargo, 'senderName');
                final receiverName = _getCargoValue(cargo, 'receiverName');
                final weight = _getCargoValue(cargo, 'weight');
                final fee = _getCargoValue(cargo, 'fee');
                final status = _getCargoValue(cargo, 'status');
                final cargoId = _getCargoValue(cargo, 'id');

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
                            Expanded(
                              child: Text(
                                trackingCode,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status.replaceAll('_', ' '),
                                style: TextStyle(color: _getStatusColor(status), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$senderName → $receiverName'),
                        Text('$weight kg - ETB $fee'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (status != 'delivered' && status != 'cancelled')
                              SizedBox(
                                width: 120,
                                height: 50,
                                child: PrimaryButton(
                                  text: 'Update Status',
                                  onPressed: () => _showStatusDialog(cargoId, status),
                                  fontSize: 12,
                                  height: 36,
                                ),
                              ),
                            SizedBox(
                              width: 100,
                              height: 50,
                              child: PrimaryButton(
                                text: 'Receipt',
                                onPressed: () => _generateReceipt(cargo),
                                fontSize: 12,
                                height: 36,
                                backgroundColor: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  void _showStatusDialog(String cargoId, String currentStatus) {
    final newStatus = (currentStatus == 'registered')
        ? 'loaded'
        : (currentStatus == 'loaded')
        ? 'in_transit'
        : (currentStatus == 'in_transit')
        ? 'delivered'
        : null;
    if (newStatus == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Update Status'),
        content: Text('Update status to ${newStatus.replaceAll('_', ' ')}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              _updateStatus(cargoId, newStatus);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'registered': return Colors.orange;
      case 'loaded': return Colors.blue;
      case 'in_transit': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}