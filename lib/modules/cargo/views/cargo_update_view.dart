// lib/modules/cargo/views/cargo_update_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';

class CargoUpdateView extends StatefulWidget {
  const CargoUpdateView({Key? key}) : super(key: key);

  @override
  State<CargoUpdateView> createState() => _CargoUpdateViewState();
}

class _CargoUpdateViewState extends State<CargoUpdateView> {
  final ApiClient _apiClient = ApiClient.instance;
  final TextEditingController _trackingController = TextEditingController();
  dynamic _cargo;
  bool _isLoading = false;
  String _selectedStatus = '';

  Future<void> _searchCargo() async {
    if (_trackingController.text.isEmpty) {
      Get.snackbar('Error', 'Enter tracking code', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/staff/cargo/all');
      if (response != null && response['data'] != null) {
        final found = (response['data'] as List).firstWhere(
              (c) {
            final tracking = c['trackingCode']?.toString() ?? '';
            return tracking.toLowerCase() == _trackingController.text.toLowerCase();
          },
          orElse: () => null,
        );
        setState(() {
          _cargo = found;
          _selectedStatus = _cargo != null ? (_cargo['status']?.toString() ?? 'registered') : '';
        });
        if (_cargo == null) {
          Get.snackbar('Not Found', 'Cargo not found', backgroundColor: Colors.orange, colorText: Colors.white);
        }
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Failed to search cargo', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus() async {
    if (_cargo == null) return;
    final cargoId = _cargo['id']?.toString() ?? _cargo['_id']?.toString();
    if (cargoId == null) {
      Get.snackbar('Error', 'Invalid cargo ID', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final response = await _apiClient.patch(
        '/staff/cargo/$cargoId/status',
        data: {'status': _selectedStatus},
      );
      if (response != null && response['success'] == true) {
        Get.snackbar('Success', 'Status updated', backgroundColor: Colors.green, colorText: Colors.white);
        _trackingController.clear();
        setState(() => _cargo = null);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Cargo Status')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _trackingController,
              decoration: InputDecoration(
                hintText: 'Enter Tracking Code',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search),
                  onPressed: _searchCargo,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_cargo != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tracking: ${_cargo['trackingCode'] ?? 'N/A'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Sender: ${_cargo['senderName'] ?? 'N/A'}'),
                      Text('Receiver: ${_cargo['receiverName'] ?? 'N/A'}'),
                      Text('Weight: ${_cargo['weight'] ?? 0} kg'),
                      Text('Fee: ETB ${_cargo['fee'] ?? 0}'),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: ['registered', 'loaded', 'in_transit', 'delivered', 'cancelled']
                            .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.replaceAll('_', ' ').toUpperCase())
                        ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedStatus = v!),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        text: 'Update Status',
                        onPressed: _updateStatus,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}