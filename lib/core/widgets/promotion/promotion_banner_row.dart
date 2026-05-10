// lib/core/widgets/promotion/promotion_banner_row.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/widgets/promotion/promotion_banner.dart';
import 'package:menahariya/modules/promotion/controllers/promotion_controller.dart';

class PromotionBannerRow extends StatefulWidget {
  const PromotionBannerRow({Key? key}) : super(key: key);

  @override
  State<PromotionBannerRow> createState() => _PromotionBannerRowState();
}

class _PromotionBannerRowState extends State<PromotionBannerRow> {
  late PageController _controller;
  late Timer _timer;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Full width page
    _controller = PageController(
      viewportFraction: 1.0,
      initialPage: 0,
    );

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final promoCount = Get.find<PromotionController>().promotions.length;

      if (promoCount == 0) return;

      if (_currentIndex < promoCount - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      _controller.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PromotionController>();


    final screenWidth = MediaQuery.of(context).size.width;

    // Height = half of screen width
    final bannerHeight = screenWidth / 2;

    return Obx(() {
      if (controller.isLoading) {
        return SizedBox(
          height: bannerHeight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.promotions.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          SizedBox(
            height: bannerHeight,
            width: screenWidth,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: controller.promotions.length,
              itemBuilder: (context, index) {
                final promotion = controller.promotions[index];

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double value = 1.0;

                    if (_controller.position.haveDimensions) {
                      value = (_controller.page! - index).abs();
                      value = (1 - value).clamp(0.0, 1.0);
                    }

                    return Transform.scale(
                      scale: 0.96 + (value * 0.04),
                      child: child,
                    );
                  },
                  child: PromotionBanner(
                    promotion: promotion,
                    width: screenWidth,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.promotions.length,
                  (index) {
                final isActive = _currentIndex == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.green)
                        : Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}