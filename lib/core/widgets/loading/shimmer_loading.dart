// lib/core/widgets/loading/shimmer_loading.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!enabled) return child;

    return Shimmer.fromColors(
      baseColor: baseColor ?? (isDark ? AppColors.grey700 : AppColors.grey300),
      highlightColor: highlightColor ?? (isDark ? AppColors.grey600 : AppColors.grey100),
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

// Specific shimmer widgets
class TripCardShimmer extends StatelessWidget {
  const TripCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin12),
        padding: const EdgeInsets.all(AppDimens.padding16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 20,
                  color: Colors.white,
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.margin16),
            Row(
              children: List.generate(3, (index) => Expanded(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppDimens.margin4),
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              )),
            ),
            const SizedBox(height: AppDimens.margin16),
            Container(
              width: double.infinity,
              height: 50,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class TicketCardShimmer extends StatelessWidget {
  const TicketCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.padding16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.radius16),
                  topRight: Radius.circular(AppDimens.radius16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 20,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  Container(
                    width: 80,
                    height: 24,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding16),
              child: Row(
                children: [
                  Container(
                    width: 2,
                    height: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppDimens.margin16),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: AppDimens.margin4),
                                  Container(
                                    width: double.infinity,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 30,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.margin12),
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: AppDimens.margin4),
                            Expanded(
                              child: Container(
                                height: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CargoCardShimmer extends StatelessWidget {
  const CargoCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin12),
        padding: const EdgeInsets.all(AppDimens.padding16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppDimens.margin12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: AppDimens.margin4),
                      Container(
                        width: 150,
                        height: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 24,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.margin16),
            Row(
              children: List.generate(3, (index) => Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: AppDimens.margin4),
                    Container(
                      width: 60,
                      height: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppDimens.margin2),
                    Container(
                      width: 40,
                      height: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCardShimmer extends StatelessWidget {
  const NotificationCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.margin12),
        padding: const EdgeInsets.all(AppDimens.padding16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimens.margin12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: AppDimens.margin8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: AppDimens.margin8),
                  Container(
                    width: 80,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListViewShimmer extends StatelessWidget {
  final int itemCount;
  final Widget Function(int) itemBuilder;

  const ListViewShimmer({
    Key? key,
    this.itemCount = 5,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(index),
    );
  }
}