// lib/modules/promotion/controllers/promotion_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/data/models/promotion/promotion_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PromotionController extends GetxController {
  static PromotionController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  final _promotions = <PromotionModel>[].obs;
  final _isLoading = false.obs;

  List<PromotionModel> get promotions => _promotions;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadPromotions();
  }

  Future<void> loadPromotions() async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.get('/active');
      if (response != null && response['data'] != null) {
        _promotions.value = (response['data'] as List)
            .map((p) => PromotionModel.fromJson(p))
            .toList();
        print('✅ Loaded ${_promotions.length} promotions');
      }
    } catch (e) {
      print('❌ Error loading promotions: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> trackView(String promotionId) async {
    try {
      await _apiClient.post('/$promotionId/view');
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> handlePromotionTap(PromotionModel promotion) async {
    try {
      final response = await _apiClient.post('/${promotion.id}/click');
      if (response != null && response['data'] != null) {
        final linkUrl = response['data']['linkUrl'];
        await _launchUrl(linkUrl);
      }
    } catch (e) {
      print('Error tracking click: $e');
      await _launchUrl(promotion.linkUrl);
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;

    // Handle email addresses
    if (url.contains('@') && !url.startsWith('http') && !url.startsWith('mailto:')) {
      final emailUri = Uri.parse('mailto:$url');
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        //Get.snackbar('Error', 'Cannot open email', backgroundColor: Colors.red, colorText: Colors.white);
      }
      return;
    }

    // Ensure URL has https:// prefix for web links
    String finalUrl = url;
    if (!url.startsWith('http') && !url.startsWith('https') &&
        !url.startsWith('mailto:') && !url.startsWith('tel:')) {
      finalUrl = 'https://$url';
    }

    try {
      final uri = Uri.parse(finalUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        //Get.snackbar('Error', 'Cannot open link', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error launching URL: $e');
      //Get.snackbar('Error', 'Invalid link', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void showDiscountDialog(PromotionModel promotion) {
    if (!promotion.hasDiscount) return;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.local_offer_rounded, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Special Offer!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(promotion.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(promotion.description),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  Text(
                    '${promotion.discountPercentage.toStringAsFixed(0)}% OFF',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use Code: ${promotion.discountCode}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/passenger/search');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }
}