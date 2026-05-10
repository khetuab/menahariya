import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/modules/driver/controllers/boarding_controller.dart';
import 'package:menahariya/data/models/trip/trip_model.dart';
import 'package:menahariya/core/widgets/qr_scanner_widget.dart';

class BoardingManagementView extends GetView<BoardingController> {
  const BoardingManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Load trips when view is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.tripId.isEmpty) {
        controller.loadAvailableTrips();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.tripId.isEmpty ? 'Boarding Management' : 'Boarding - ${controller.currentTripRoute}',
          overflow: TextOverflow.ellipsis,
        )),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          if (controller.tripId.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded),
              onPressed: () {
                controller.clearSelectedTrip();
                controller.loadAvailableTrips();
              },
              tooltip: 'Change Trip',
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (controller.tripId.isEmpty) {
                controller.loadAvailableTrips();
              } else {
                controller.refreshBoardingStatus();
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        // Show loading state
        if (controller.isLoadingTrips && controller.availableTrips.isEmpty) {
          return _buildLoadingShimmer();
        }

        // If no trip selected, show trip selection UI
        if (controller.tripId.isEmpty) {
          return _buildTripSelectionView(context);
        }

        // Show boarding UI for selected trip
        return _buildBoardingUI(context);
      }),
    );
  }

  // Trip Selection View - Show when no trip is selected
  Widget _buildTripSelectionView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (controller.availableTrips.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: controller.loadAvailableTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimens.padding16),
        itemCount: controller.availableTrips.length,
        itemBuilder: (context, index) {
          final trip = controller.availableTrips[index];
          final isCurrentTrip = controller.currentTripId == trip.id;
          return _buildTripSelectionCard(context, trip, isCurrentTrip);
        },
      ),
    );
  }

  Widget _buildTripSelectionCard(BuildContext context, TripModel trip, bool isCurrentTrip) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.margin12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        side: BorderSide(
          color: isCurrentTrip
              ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isCurrentTrip ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => controller.selectTripForBoarding(trip),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Route and Status - Responsive
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Route - Flexible to wrap
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${trip.origin} → ${trip.destination}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: AppFonts.semiBold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        if (isCurrentTrip) ...[
                          const SizedBox(height: AppDimens.margin4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.padding8,
                              vertical: AppDimens.padding4,
                            ),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppDimens.radius20),
                            ),
                            child: Text(
                              'Current Trip',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.margin8),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.padding12,
                      vertical: AppDimens.padding6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(trip.status, isDark).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radius20),
                    ),
                    child: Text(
                      _getStatusText(trip.status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(trip.status, isDark),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin12),
              // Row 2: Trip ID
              Text(
                'Trip ID: ${trip.id.substring(0, 8).toUpperCase()}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppDimens.margin12),
              // Row 3: Date, Time, Seats - Responsive
              Wrap(
                spacing: AppDimens.margin16,
                runSpacing: AppDimens.margin8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: AppDimens.margin4),
                      Text(
                        _formatDate(trip.departureTime),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: AppDimens.margin4),
                      Text(
                        _formatTime(trip.departureTime),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chair_rounded,
                        size: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: AppDimens.margin4),
                      Text(
                        '${trip.availableSeats}/${trip.totalSeats} seats',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.margin12),
              // Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => controller.selectTripForBoarding(trip),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radius8),
                    ),
                  ),
                  child: const Text('Start Boarding'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Boarding UI - Show when a trip is selected
  Widget _buildBoardingUI(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (controller.isLoading && controller.boardingList.isEmpty) {
      return _buildLoadingShimmer();
    }

    return Column(
      children: [
        // Progress Header
        _buildProgressHeader(context),

        // Tab Bar for different boarding methods
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
          child: Row(
            children: [
              _buildMethodTab(context, 'Scan', BoardingMethod.scan),
              _buildMethodTab(context, 'Manual', BoardingMethod.manual),
              _buildMethodTab(context, 'List', BoardingMethod.list),
            ],
          ),
        ),

        // Content based on selected method
        Expanded(
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildMethodTab(BuildContext context, String title, BoardingMethod method) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = controller.selectedMethod == method;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setBoardingMethod(method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.padding12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Boarding Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              Obx(() => Text(
                '${controller.checkedInCount}/${controller.totalPassengers}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                  fontWeight: AppFonts.bold,
                ),
              )),
            ],
          ),
          const SizedBox(height: AppDimens.margin8),
          Obx(() => ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radius4),
            child: LinearProgressIndicator(
              value: controller.boardingProgress,
              minHeight: 8,
              backgroundColor: isDark ? AppColors.grey700 : AppColors.grey300,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.successLight : AppColors.success,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (controller.selectedMethod) {
      case BoardingMethod.scan:
        return _buildScanView(context);
      case BoardingMethod.manual:
        return _buildManualView(context);
      case BoardingMethod.list:
        return _buildListView(context);
      default:
        return _buildScanView(context);
    }
  }

  Widget _buildScanView(BuildContext context) {
    return QRScannerWidget(
      onCodeScanned: (code) async {
        print('📷 Scanned QR code: $code');
        await Future.delayed(const Duration(milliseconds: 100));
        await controller.validateTicket(code);
      },
    );
  }

  Widget _buildManualView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final TextEditingController ticketCodeController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.padding16),
      child: Column(
        children: [
          TextField(
            controller: ticketCodeController,
            decoration: InputDecoration(
              labelText: 'Ticket Code / QR Code',
              hintText: 'Enter ticket code from ticket or QR',
              prefixIcon: const Icon(Icons.confirmation_number_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
              helperText: 'Enter the Ticket ID or scan QR code',
            ),
            onSubmitted: (value) async {
              await controller.validateTicket(value);
              ticketCodeController.clear();
            },
          ),
          const SizedBox(height: AppDimens.margin16),

          Obx(() {
            final passenger = controller.currentPassenger;
            if (passenger == null) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(AppDimens.padding16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.success.withOpacity(0.2) : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimens.radius12),
                border: Border.all(color: isDark ? AppColors.successLight : AppColors.success),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: isDark ? AppColors.successLight : AppColors.success,
                        size: 32,
                      ),
                      const SizedBox(width: AppDimens.margin12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Passenger Verified!',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDark ? AppColors.successLight : AppColors.success,
                                fontWeight: AppFonts.bold,
                              ),
                            ),
                            Text(passenger.name),
                            Text('Seat: ${passenger.seatNumber}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.margin16),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Cancel',
                          onPressed: controller.clearCurrentPassenger,
                        ),
                      ),
                      const SizedBox(width: AppDimens.margin12),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Confirm Check-in',
                          onPressed: () {
                            controller.markPassengerCheckedIn(passenger.id);
                            controller.clearCurrentPassenger();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search passenger by name, seat, or ticket...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
            ),
            onChanged: controller.searchPassenger,
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.pendingPassengers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 64,
                      color: isDark ? AppColors.successLight : AppColors.success,
                    ),
                    const SizedBox(height: AppDimens.margin16),
                    Text(
                      'All passengers checked in!',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppDimens.padding16),
              itemCount: controller.pendingPassengers.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDimens.margin8),
              itemBuilder: (context, index) {
                final passenger = controller.pendingPassengers[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(AppDimens.padding12),
                    leading: CircleAvatar(
                      backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                      child: Text(
                        passenger.name.isNotEmpty ? passenger.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      passenger.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppFonts.semiBold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seat: ${passenger.seatNumber}'),
                        Text('Ticket: ${passenger.ticketNumber.length > 8 ? passenger.ticketNumber.substring(0, 8) : passenger.ticketNumber}...'),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () => controller.markPassengerCheckedIn(passenger.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radius8),
                          ),
                        ),
                        child: const Text('Check In'),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus_rounded,
            size: 80,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          const SizedBox(height: AppDimens.margin16),
          Text(
            'No Trips Available',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            'You don\'t have any upcoming trips for boarding',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status) {
      case 'scheduled':
        return isDark ? AppColors.infoLight : AppColors.info;
      case 'in_progress':
        return isDark ? AppColors.warningLight : AppColors.warning;
      case 'completed':
        return isDark ? AppColors.successLight : AppColors.success;
      case 'cancelled':
        return isDark ? AppColors.errorLight : AppColors.error;
      default:
        return isDark ? AppColors.grey400 : AppColors.grey600;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}