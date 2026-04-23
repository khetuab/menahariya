import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/driver/controllers/boarding_controller.dart';

import '../../../../core/widgets/qr_scanner_widget.dart';

class BoardingManagementView extends GetView<BoardingController> {
  const BoardingManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boarding Management'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        bottom: TabBar(
          controller: TabController(length: 3, vsync: Scaffold.of(context)),
          tabs: const [
            Tab(text: 'Scan'),
            Tab(text: 'Manual'),
            Tab(text: 'List'),
          ],
          labelColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          indicatorColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          onTap: (index) {
            switch (index) {
              case 0:
                controller.setBoardingMethod(BoardingMethod.scan);
                break;
              case 1:
                controller.setBoardingMethod(BoardingMethod.manual);
                break;
              case 2:
                controller.setBoardingMethod(BoardingMethod.list);
                break;
            }
          },
        ),
      ),
      body: Obx(() {
        if (controller.isLoading && controller.boardingList.isEmpty) {
          return _buildLoadingShimmer();
        }

        return Column(
          children: [
            // Progress Header
            _buildProgressHeader(context),

            // Content based on selected method
            Expanded(
              child: _buildContent(context),
            ),
          ],
        );
      }),
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
        // Add a small delay to ensure UI is ready
        await Future.delayed(const Duration(milliseconds: 100));
        await controller.validateTicket(code);
      },
    );
  }

  Widget _buildManualView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final TextEditingController ticketCodeController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(AppDimens.padding16),
      child: Column(
        children: [
          TextField(
            controller: ticketCodeController,
            decoration: InputDecoration(
              labelText: 'Ticket Code',
              hintText: 'Enter ticket code (Ticket ID or QR Code)',
              prefixIcon: const Icon(Icons.confirmation_number_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
              helperText: 'You can enter the Ticket ID shown on the ticket',
            ),
            onSubmitted: (value) async {
              await controller.validateTicket(value);
              ticketCodeController.clear();
            },
            autofocus: true,
          ),
          const SizedBox(height: AppDimens.margin16),
          Obx(() {
            if (controller.currentPassenger != null) {
              return _buildPassengerConfirmation(context);
            }
            return const SizedBox();
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
        // Search Bar
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

        // Pending Passengers
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
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seat: ${passenger.seatNumber}'),
                        Text('Ticket: ${passenger.ticketNumber.substring(0, 8)}...'),
                      ],
                    ),
                    trailing: ElevatedButton(
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
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPassengerConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final passenger = controller.currentPassenger!;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.success.withOpacity(0.2) : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(color: isDark ? AppColors.successLight : AppColors.success),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: isDark ? AppColors.successLight : AppColors.success,
            size: 48,
          ),
          const SizedBox(height: AppDimens.margin12),
          Text(
            'Passenger Verified!',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppColors.successLight : AppColors.success,
              fontWeight: AppFonts.bold,
            ),
          ),
          const SizedBox(height: AppDimens.margin8),
          Text(
            passenger.name,
            style: theme.textTheme.bodyLarge,
          ),
          Text('Seat ${passenger.seatNumber}'),
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
  }

  Widget _buildLoadingShimmer() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}