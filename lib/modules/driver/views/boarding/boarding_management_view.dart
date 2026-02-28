// lib/modules/driver/views/boarding/boarding_management_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';
import 'package:menahariya/core/widgets/loading/shimmer_loading.dart';
import 'package:menahariya/modules/driver/controllers/boarding_controller.dart';

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
        if (controller.isLoading) {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Scanner placeholder (actual scanner will be implemented with camera)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryGreen,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(AppDimens.radius12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.margin24),
                Text(
                  'Align QR code within frame',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Manual Entry Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => controller.setBoardingMethod(BoardingMethod.manual),
                icon: const Icon(Icons.keyboard_rounded),
                label: const Text('Enter Code Manually'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: isDark ? AppColors.primaryGreen : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.padding16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Ticket Code',
              hintText: 'Enter ticket code',
              prefixIcon: const Icon(Icons.confirmation_number_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radius8),
              ),
            ),
            onSubmitted: (value) => controller.validateTicket(value),
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
              hintText: 'Search passenger...',
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
                      child: Text(passenger.name[0]),
                    ),
                    title: Text(passenger.name),
                    subtitle: Text('Seat ${passenger.seatNumber}'),
                    trailing: ElevatedButton(
                      onPressed: () => controller.markPassengerCheckedIn(passenger.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
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