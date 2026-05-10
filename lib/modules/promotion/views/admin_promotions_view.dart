// lib/modules/admin/views/admin_promotions_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/data/models/promotion/promotion_model.dart';

class AdminPromotionsView extends StatefulWidget {
  const AdminPromotionsView({Key? key}) : super(key: key);

  @override
  State<AdminPromotionsView> createState() => _AdminPromotionsViewState();
}

class _AdminPromotionsViewState extends State<AdminPromotionsView> {
  final ApiClient _apiClient = ApiClient.instance;
  List<PromotionModel> _promotions = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/admin/promotions');
      if (response != null && response['data'] != null) {
        _promotions = (response['data'] as List)
            .map((p) => PromotionModel.fromJson(p))
            .toList();
      }
    } catch (e) {
      print('Error loading promotions: $e');
      Get.snackbar('Error', 'Failed to load promotions', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePromotion(String id) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Promotion'),
        content: const Text('Are you sure you want to delete this promotion?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Delete'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _apiClient.delete('/admin/promotions/$id');
      await _loadPromotions();
      Get.snackbar('Success', 'Promotion deleted', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _toggleStatus(PromotionModel promotion) async {
    try {
      await _apiClient.patch('/admin/promotions/${promotion.id}/toggle');
      await _loadPromotions();
      Get.snackbar('Success', promotion.isActive ? 'Promotion deactivated' : 'Promotion activated', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showCreateDialog() {
    _showPromotionDialog();
  }

  void _showEditDialog(PromotionModel promotion) {
    _showPromotionDialog(promotion: promotion);
  }

  void _showPromotionDialog({PromotionModel? promotion}) {
    final isEdit = promotion != null;
    final titleController = TextEditingController(text: promotion?.title ?? '');
    final descriptionController = TextEditingController(text: promotion?.description ?? '');
    final imageUrlController = TextEditingController(text: promotion?.imageUrl ?? '');
    final linkType = (promotion?.linkType ?? 'web').obs;
    final linkUrlController = TextEditingController(text: promotion?.linkUrl ?? '');
    final buttonTextController = TextEditingController(text: promotion?.buttonText ?? 'Learn More');
    final discountCodeController = TextEditingController(text: promotion?.discountCode ?? '');
    final discountPercentageController = TextEditingController(text: promotion?.discountPercentage.toString() ?? '0');
    final validFrom = (promotion?.validFrom ?? DateTime.now()).obs;
    final validUntil = (promotion?.validUntil ?? DateTime.now().add(const Duration(days: 30))).obs;
    final targetAudience = (promotion?.targetAudience ?? ['all']).obs;
    final priority = (promotion?.priority ?? 0).obs;
    final isLoading = false.obs;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(() => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isEdit ? 'Edit Promotion' : 'Create Promotion', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: titleController,
                    label: 'Title',
                    hint: 'Enter promotion title',
                    prefixIcon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: descriptionController,
                    label: 'Description',
                    hint: 'Enter promotion description',
                    maxLines: 3,
                    prefixIcon: Icons.description_rounded,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: imageUrlController,
                    label: 'Image URL',
                    hint: 'https://...',
                    prefixIcon: Icons.image_rounded,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: linkType.value,
                    decoration: const InputDecoration(labelText: 'Link Type', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'web', child: Text('Website')),
                      DropdownMenuItem(value: 'youtube', child: Text('YouTube')),
                      DropdownMenuItem(value: 'telegram', child: Text('Telegram')),
                      DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                      DropdownMenuItem(value: 'facebook', child: Text('Facebook')),
                      DropdownMenuItem(value: 'instagram', child: Text('Instagram')),
                      DropdownMenuItem(value: 'twitter', child: Text('Twitter')),
                      DropdownMenuItem(value: 'none', child: Text('No Link')),
                    ],
                    onChanged: (v) => linkType.value = v!,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: linkUrlController,
                    label: 'Link URL',
                    hint: 'https://...',
                    prefixIcon: Icons.link_rounded,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: buttonTextController,
                    label: 'Button Text',
                    hint: 'Learn More',
                    prefixIcon: Icons.smart_button_rounded,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: discountCodeController,
                          label: 'Discount Code',
                          hint: 'PROMO2024',
                          prefixIcon: Icons.local_offer_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: discountPercentageController,
                          label: 'Discount %',
                          hint: 'Enter value between 0-100',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.percent_rounded,
                          onChanged: (value) {
                            double? val = double.tryParse(value);
                            if (val != null && val > 100) {
                              discountPercentageController.text = '100';
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: validFrom.value,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) validFrom.value = date;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Valid From', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(DateFormat('MMM dd, yyyy').format(validFrom.value)),
                              ],
                            ),
                          ),
                        )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: validUntil.value,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) validUntil.value = date;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Valid Until', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(DateFormat('MMM dd, yyyy').format(validUntil.value)),
                              ],
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: priority.value,
                    decoration: const InputDecoration(labelText: 'Priority (Higher = More Important)', border: OutlineInputBorder()),
                    items: List.generate(11, (i) => DropdownMenuItem(value: i, child: Text('Priority $i'))),
                    onChanged: (v) => priority.value = v!,
                  ),
                  const SizedBox(height: 16),
                  const Text('Target Audience', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['all', 'passenger', 'driver'].map((audience) {
                      return Obx(() => FilterChip(
                        label: Text(audience.toUpperCase()),
                        selected: targetAudience.contains(audience),
                        onSelected: (selected) {
                          if (selected) {
                            if (!targetAudience.contains(audience)) {
                              targetAudience.add(audience);
                            }
                          } else {
                            targetAudience.remove(audience);
                          }
                        },
                      ));
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: isEdit ? 'Update Promotion' : 'Create Promotion',
                    onPressed: () async {
                      isLoading.value = true;
                      final data = {
                        'title': titleController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'imageUrl': imageUrlController.text.trim(),
                        'linkType': linkType.value,
                        'linkUrl': linkUrlController.text.trim(),
                        'buttonText': buttonTextController.text.trim(),
                        'discountCode': discountCodeController.text.trim().isEmpty ? null : discountCodeController.text.trim(),
                        'discountPercentage': double.tryParse(discountPercentageController.text) ?? 0,
                        'validFrom': validFrom.value.toIso8601String(),
                        'validUntil': validUntil.value.toIso8601String(),
                        'targetAudience': targetAudience,
                        'priority': priority.value,
                      };
                      try {
                        if (isEdit) {
                          await _apiClient.put('/admin/promotions/${promotion!.id}', data: data);
                        } else {
                          await _apiClient.post('/admin/promotions', data: data);
                        }
                        Get.back();
                        await _loadPromotions();
                        Get.snackbar('Success', isEdit ? 'Promotion updated' : 'Promotion created', backgroundColor: Colors.green, colorText: Colors.white);
                      } catch (e) {
                        Get.snackbar('Error', 'Failed to save promotion', backgroundColor: Colors.red, colorText: Colors.white);
                      } finally {
                        isLoading.value = false;
                      }
                    },
                    isLoading: isLoading.value,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            if (isLoading.value)
              const Center(child: CircularProgressIndicator()),
          ],
        )),
      ),
      isScrollControlled: true,
    );
  }

  List<PromotionModel> get _filteredPromotions {
    if (_filter == 'all') return _promotions;
    if (_filter == 'active') return _promotions.where((p) => p.isActive && p.validUntil.isAfter(DateTime.now())).toList();
    if (_filter == 'expired') return _promotions.where((p) => p.validUntil.isBefore(DateTime.now())).toList();
    if (_filter == 'inactive') return _promotions.where((p) => !p.isActive).toList();
    return _promotions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Promotions'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: _showCreateDialog,
              tooltip: 'Add Promotion',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadPromotions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips with better styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', Icons.grid_view_rounded),
                  const SizedBox(width: 12),
                  _buildFilterChip('Active', 'active', Icons.check_circle_rounded),
                  const SizedBox(width: 12),
                  _buildFilterChip('Expired', 'expired', Icons.timer_off_rounded),
                  const SizedBox(width: 12),
                  _buildFilterChip('Inactive', 'inactive', Icons.block_rounded),
                ],
              ),
            ),
          ),
          // Promotions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPromotions.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 80,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No promotions found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click the + button to create your first promotion',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredPromotions.length,
              itemBuilder: (context, index) {
                final promo = _filteredPromotions[index];
                final isExpired = promo.validUntil.isBefore(DateTime.now());
                return _buildPromotionCard(context, promo, isExpired);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _filter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[600])),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AppColors.primaryGreen,
      backgroundColor: isDark ? AppColors.grey800 : Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? Colors.transparent : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildPromotionCard(
      BuildContext context,
      PromotionModel promo,
      bool isExpired,
      ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isActive = promo.isActive && !isExpired;

    final Color statusColor = isActive
        ? Colors.green
        : isExpired
        ? Colors.red
        : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER IMAGE =================
          Stack(
            children: [
              Hero(
                tag: 'promo_${promo.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  child: Image.network(
                    promo.imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        height: 220,
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_rounded,
                                size: 54,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Image unavailable',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Dark overlay gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),

              // Status Badge
              Positioned(
                top: 18,
                right: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive
                            ? Icons.check_circle_rounded
                            : isExpired
                            ? Icons.timer_off_rounded
                            : Icons.visibility_off_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isActive
                            ? 'ACTIVE'
                            : isExpired
                            ? 'EXPIRED'
                            : 'INACTIVE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Discount Badge
              if (promo.hasDiscount)
                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF512F),
                          Color(0xFFDD2476),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${promo.discountPercentage.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom title section
              Positioned(
                left: 22,
                right: 22,
                bottom: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: promo.linkColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: promo.linkColor.withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            promo.linkIcon,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            promo.linkType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      promo.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ================= BODY =================
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  promo.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 22),

                // ================= INFO CARDS =================
                Row(
                  children: [
                    Expanded(
                      child: _modernInfoCard(
                        icon: Icons.calendar_month_rounded,
                        title: 'VALID UNTIL',
                        value: DateFormat(
                          'MMM dd, yyyy',
                        ).format(promo.validUntil),
                        color: Colors.blue,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _modernInfoCard(
                        icon: Icons.stars_rounded,
                        title: 'PRIORITY',
                        value: '${promo.priority}',
                        color: Colors.amber,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                // ================= DISCOUNT CODE =================
                if (promo.hasDiscount) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                          Colors.green.shade900.withOpacity(0.45),
                          Colors.green.shade800.withOpacity(0.25),
                        ]
                            : [
                          Colors.green.shade50,
                          Colors.green.shade100.withOpacity(0.5),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.discount_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Discount Code',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                promo.discountCode ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'COPY',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ================= ACTION BUTTONS =================
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleStatus(promo),
                        icon: Icon(
                          promo.isActive
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 18,
                        ),
                        label: Text(
                          promo.isActive ? 'Deactivate' : 'Activate',
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: promo.isActive
                              ? Colors.orange.withOpacity(0.12)
                              : Colors.green.withOpacity(0.12),
                          foregroundColor: promo.isActive
                              ? Colors.orange
                              : Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        onPressed: () => _showEditDialog(promo),
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        onPressed: () => _deletePromotion(promo.id),
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Footer
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
                      child: Icon(
                        Icons.campaign_rounded,
                        size: 18,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Expanded(
                    //   child: Text(
                    //     'Created ${DateFormat('MMM dd, yyyy').format(promo.)}',
                    //     style: TextStyle(
                    //       color: isDark
                    //           ? Colors.grey.shade500
                    //           : Colors.grey.shade600,
                    //       fontSize: 12,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ================= MODERN INFO CARD =================

  Widget _modernInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withOpacity(0.5)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark
                  ? Colors.grey.shade500
                  : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

}