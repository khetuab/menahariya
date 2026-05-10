// lib/core/widgets/promotion/promotion_banner.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/data/models/promotion/promotion_model.dart';
import 'package:menahariya/modules/promotion/controllers/promotion_controller.dart';

class PromotionBanner extends StatelessWidget {
  final PromotionModel promotion;
  final double? width;

  const PromotionBanner({
    Key? key,
    required this.promotion,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Full screen width
    final bannerWidth = width ?? screenWidth;

    // Height = half of screen width
    final bannerHeight = screenWidth / 2;

    return GestureDetector(
      onTap: () => Get.find<PromotionController>().handlePromotionTap(promotion),
      child: Container(
        width: bannerWidth,
        height: bannerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.network(
                promotion.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;

                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.45),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.3, 0.65, 1.0],
                  ),
                ),
              ),

              // Discount Badge
              if (promotion.hasDiscount)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_offer_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${promotion.discountPercentage.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom Content
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Text(
                    //   promotion.description,
                    //   style: const TextStyle(
                    //     color: Colors.white70,
                    //     fontSize: 12,
                    //     height: 1.3,
                    //     shadows: [
                    //       Shadow(
                    //         blurRadius: 2,
                    //         color: Colors.black,
                    //         offset: Offset(0, 1),
                    //       ),
                    //     ],
                    //   ),
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: promotion.linkColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                promotion.linkIcon,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                promotion.linkType.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Tap to learn more',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}