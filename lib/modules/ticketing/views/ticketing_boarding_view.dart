// lib/modules/ticketing/views/ticketing_boarding_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/services/api/api_client.dart';

class TicketingBoardingView extends StatefulWidget {
  const TicketingBoardingView({Key? key}) : super(key: key);

  @override
  State<TicketingBoardingView> createState() => _TicketingBoardingViewState();
}

class _TicketingBoardingViewState extends State<TicketingBoardingView> {
  final ApiClient _apiClient = ApiClient.instance;

  List<dynamic> _trips = [];
  dynamic _selectedTrip;
  List<dynamic> _passengers = [];

  bool _isLoadingTrips = true;
  bool _isLoadingPassengers = false;
  String _searchQuery = '';

  // QR Scanner
  bool _isScanning = false;
  final MobileScannerController _scannerController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoadingTrips = true);
    try {
      final response = await _apiClient.get('/staff/ticketing/trips/all');
      if (response != null && response['data'] != null) {
        setState(() => _trips = response['data']);
        if (_trips.isNotEmpty && _selectedTrip == null) {
          await _selectTrip(_trips.first);
        }
      }
    } catch (e) {
      print('Error loading trips: $e');
      Get.snackbar('Error', 'Failed to load trips', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoadingTrips = false);
    }
  }

  Future<void> _selectTrip(dynamic trip) async {
    setState(() {
      _selectedTrip = trip;
      _passengers = [];
      _searchQuery = '';
    });
    await _loadPassengers(trip['id']);
  }

  Future<void> _loadPassengers(String tripId) async {
    setState(() => _isLoadingPassengers = true);
    try {
      final response = await _apiClient.get('/staff/ticketing/boarding-list/$tripId');
      if (response != null && response['data'] != null) {
        setState(() => _passengers = response['data']);
        print('✅ Loaded ${_passengers.length} passengers for trip');
      } else {
        setState(() => _passengers = []);
      }
    } catch (e) {
      print('Error loading passengers: $e');
      setState(() => _passengers = []);
    } finally {
      setState(() => _isLoadingPassengers = false);
    }
  }

  Future<void> _checkInPassenger(String passengerId) async {
    if (_selectedTrip == null) return;

    try {
      final response = await _apiClient.post(
        '/staff/ticketing/mark-checked-in',
        data: {
          'tripId': _selectedTrip['id'],
          'passengerId': passengerId,
        },
      );

      if (response != null && response['success'] == true) {
        setState(() {
          final index = _passengers.indexWhere((p) =>
          p['id'].toString() == passengerId || p['ticketId'].toString() == passengerId);
          if (index != -1) {
            _passengers[index]['checkedIn'] = true;
            _passengers[index]['checkedInTime'] = DateTime.now().toIso8601String();
          }
        });
        Get.snackbar('Success', 'Passenger checked in', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Check-in failed', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showQRScanner() async {
    setState(() => _isScanning = true);

    await Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => _isScanning = false);
                      Get.back();
                    },
                  ),
                ],
              ),
            ),

            // Camera Preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGreen, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        final String? code = barcode.rawValue;
                        if (code != null && code.isNotEmpty) {
                          _scannerController.stop();
                          Get.back();
                          setState(() => _isScanning = false);
                          _validateAndCheckIn(code);
                          break;
                        }
                      }
                    },
                  ),
                ),
              ),
            ),

            // Manual Entry Option
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Or enter ticket code manually',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.back();
                            _showManualEntryDialog();
                          },
                          icon: const Icon(Icons.keyboard_rounded),
                          label: const Text('Enter Code'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    ).whenComplete(() {
      _scannerController.stop();
    });
  }

  void _showManualEntryDialog() {
    final codeController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.confirmation_number_rounded, size: 60, color: AppColors.primaryGreen),
              const SizedBox(height: 16),
              const Text('Enter Ticket Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  hintText: 'Enter ticket code',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.qr_code_rounded),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _validateAndCheckIn(codeController.text.trim());
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      child: const Text('Verify'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _validateAndCheckIn(String ticketCode) async {
    if (ticketCode.isEmpty) {
      Get.snackbar('Error', 'Enter ticket code', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (_selectedTrip == null) {
      Get.snackbar('Error', 'Select a trip first', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final response = await _apiClient.post(
        '/staff/ticketing/validate-ticket',
        data: {'ticketCode': ticketCode, 'tripId': _selectedTrip['id']},
      );

      if (response != null && response['data'] != null) {
        final data = response['data'];
        if (data['valid'] == true) {
          final passenger = data['passenger'];
          if (passenger != null) {
            await _checkInPassenger(passenger['id']);
          }
        } else {
          Get.snackbar('Invalid', data['message'] ?? 'Ticket not valid', backgroundColor: Colors.orange, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Validation failed', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Filter passengers only when searching
  List<dynamic> get _displayedPassengers {
    if (_searchQuery.isEmpty) return _passengers;
    return _passengers.where((p) {
      final name = (p['name'] ?? '').toLowerCase();
      final seat = (p['seatNumber'] ?? '').toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || seat.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  int get _checkedInCount => _passengers.where((p) => p['checkedIn'] == true).length;
  int get _pendingCount => _passengers.length - _checkedInCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Boarding'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: _showQRScanner,
            tooltip: 'Scan QR',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (_selectedTrip != null) {
                _loadPassengers(_selectedTrip['id']);
              } else {
                _loadTrips();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Trip Selection Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Trip', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _isLoadingTrips
                    ? const Center(child: CircularProgressIndicator())
                    : _trips.isEmpty
                    ? const Center(child: Text('No trips available'))
                    : SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _trips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final trip = _trips[index];
                      final isSelected = _selectedTrip?['id'] == trip['id'];
                      return GestureDetector(
                        onTap: () => _selectTrip(trip),
                        child: Container(
                          width: 180,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : (isDark ? AppColors.grey800 : AppColors.grey100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${trip['routeId']?['origin'] ?? 'N/A'} → ${trip['routeId']?['destination'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, HH:mm').format(DateTime.parse(trip['departureTime'])),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected ? Colors.white70 : Colors.grey,
                                ),
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
          ),

          // Selected Trip Info & Stats
          if (_selectedTrip != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? AppColors.primaryGreen.withOpacity(0.1) : AppColors.primaryGreen.withOpacity(0.05),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedTrip['routeId']?['origin'] ?? 'N/A'} → ${_selectedTrip['routeId']?['destination'] ?? 'N/A'}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Departure: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(_selectedTrip['departureTime']))}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedTrip['status'] == 'scheduled' ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _selectedTrip['status']?.toUpperCase() ?? 'N/A',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatBox('Total', _passengers.length.toString(), Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatBox('Checked In', _checkedInCount.toString(), Colors.green),
                      const SizedBox(width: 12),
                      _buildStatBox('Pending', _pendingCount.toString(), Colors.orange),
                    ],
                  ),
                ],
              ),
            ),

          // Search Bar
          if (_selectedTrip != null && _passengers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search passenger by name or seat number...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () => setState(() => _searchQuery = ''),
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),

          // Passengers List
          Expanded(
            child: _isLoadingPassengers
                ? const Center(child: CircularProgressIndicator())
                : _selectedTrip == null
                ? const Center(child: Text('Select a trip to start boarding'))
                : _passengers.isEmpty
                ? const Center(child: Text('No passengers found for this trip'))
                : _displayedPassengers.isEmpty
                ? const Center(child: Text('No matching passengers'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _displayedPassengers.length,
              itemBuilder: (context, index) {
                final p = _displayedPassengers[index];
                final isCheckedIn = p['checkedIn'] == true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCheckedIn ? Colors.green : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isCheckedIn ? Colors.green : (isDark ? Colors.grey : Colors.grey.shade300),
                        child: Text(
                          (p['name'] ?? '?')[0].toUpperCase(),
                          style: TextStyle(color: isCheckedIn ? Colors.white : null),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: isCheckedIn ? FontWeight.normal : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Seat ${p['seatNumber'] ?? 'N/A'}'),
                            if (p['checkedInTime'] != null)
                              Text(
                                '✓ Checked in at ${DateFormat('HH:mm').format(DateTime.parse(p['checkedInTime']))}',
                                style: const TextStyle(fontSize: 11, color: Colors.green),
                              ),
                          ],
                        ),
                      ),
                      if (isCheckedIn)
                        const Icon(Icons.check_circle, color: Colors.green, size: 28)
                      else
                        ElevatedButton(
                          onPressed: () => _checkInPassenger(p['id'] ?? p['ticketId']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            minimumSize: const Size(90, 36),
                          ),
                          child: const Text('Check In'),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}