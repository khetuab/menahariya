import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/buttons/secondary_button.dart';

class TermsConditionsView extends StatefulWidget {
  final Function(bool)? onAgreed;
  final bool isModal;

  const TermsConditionsView({
    Key? key,
    this.onAgreed,
    this.isModal = true,
  }) : super(key: key);

  @override
  State<TermsConditionsView> createState() => _TermsConditionsViewState();
}

class _TermsConditionsViewState extends State<TermsConditionsView> {
  bool _isScrolledToBottom = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_isScrolledToBottom) {
        setState(() {
          _isScrolledToBottom = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.white,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Get.back(result: false),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimens.padding20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLastUpdated(theme, isDark),
                  const SizedBox(height: AppDimens.margin24),
                  _buildIntroduction(theme, isDark),
                  const SizedBox(height: AppDimens.margin24),
                  _buildSection(
                    theme,
                    '1. Booking and Payment',
                    '• All bookings are subject to availability\n'
                        '• Payment must be completed within 15 minutes to secure your booking\n'
                        '• Prices are inclusive of applicable taxes unless stated otherwise\n'
                        '• We accept various payment methods including credit/debit cards, mobile money, and wallet balance',
                  ),
                  const SizedBox(height: AppDimens.margin20),
                  _buildSection(
                    theme,
                    '2. Cancellation and Refund Policy',
                    '• Cancellations made 24 hours before departure: 90% refund\n'
                        '• Cancellations made 12-24 hours before departure: 50% refund\n'
                        '• Cancellations made less than 12 hours before departure: No refund\n'
                        '• No-shows are not eligible for any refund\n'
                        '• Refunds will be processed within 5-7 business days',
                  ),
                  const SizedBox(height: AppDimens.margin20),
                  _buildSection(
                    theme,
                    '3. Schedule Changes and Delays',
                    '• MenaHariya reserves the right to modify schedules, routes, or fares\n'
                        '• In case of delays exceeding 2 hours, passengers may request a full refund\n'
                        '• We will notify you of significant schedule changes via SMS/Email\n'
                        '• Force majeure events (weather, strikes, etc.) are not eligible for compensation',
                  ),
                  const SizedBox(height: AppDimens.margin20),
                  _buildSection(
                    theme,
                    '4. Passenger Responsibilities',
                    '• Arrive at the boarding point at least 30 minutes before departure\n'
                        '• Carry a valid ID for verification\n'
                        '• Ensure luggage complies with weight/size limits (max 20kg per passenger)\n'
                        '• Prohibited items: flammable materials, weapons, illegal substances\n'
                        '• Maintain appropriate behavior; disruptive passengers may be removed without refund',
                  ),
                  const SizedBox(height: AppDimens.margin20),
                  _buildSection(
                    theme,
                    '5. Luggage Policy',
                    '• Each passenger is allowed: 1 large suitcase (20kg) + 1 carry-on (7kg)\n'
                        '• Excess luggage: EGP 50 per additional 5kg\n'
                        '• We are not responsible for valuable items (cash, electronics, documents)\n'
                        '• Label your luggage with name and contact number',
                  ),
                  const SizedBox(height: AppDimens.margin20),
                  _buildSection(
                    theme,
                    '6. Travel Insurance',
                    '• Travel insurance is optional but highly recommended\n'
                        '• Insurance covers: trip cancellation, medical emergencies, lost luggage\n'
                        '• Insurance fee: 5% of ticket price\n'
                        '• Claims must be filed within 7 days of the incident',
                  ),
                  const SizedBox(height: AppDimens.margin20),
                  _buildSection(
                    theme,
                    '7. Privacy Policy',
                    '• We collect and process your data in accordance with applicable laws\n'
                        '• Your information is used for booking, communication, and service improvement\n'
                        '• We do not share your data with third parties without consent\n'
                        '• You may request data deletion by contacting support',
                  ),
                  const SizedBox(height: AppDimens.margin20),
                  _buildSection(
                    theme,
                    '8. Limitation of Liability',
                    '• Maximum liability is limited to the ticket price paid\n'
                        '• We are not liable for indirect or consequential damages\n'
                        '• Personal belongings are your sole responsibility\n'
                        '• Claims must be submitted within 48 hours of journey completion',
                  ),
                  const SizedBox(height: AppDimens.margin20),
                  _buildSection(
                    theme,
                    '9. Changes to Terms',
                    '• We reserve the right to update these terms at any time\n'
                        '• Continued use of our services constitutes acceptance of updated terms\n'
                        '• Material changes will be notified via email or in-app notification',
                  ),
                  const SizedBox(height: AppDimens.margin20),
                  _buildSection(
                    theme,
                    '10. Contact Information',
                    '• Customer Support: support@menahariya.com\n'
                        '• Phone: +20 XXX XXX XXX\n'
                        '• Working Hours: 24/7\n'
                        '• Complaints: complaints@menahariya.com',
                  ),
                  const SizedBox(height: AppDimens.margin32),
                  _buildAcknowledgement(theme, isDark),
                  const SizedBox(height: AppDimens.margin20),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding12,
        vertical: AppDimens.padding6,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.update_rounded,
            size: 16,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
          const SizedBox(width: AppDimens.margin4),
          Text(
            'Last Updated: January 1, 2024',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to MenaHariya!',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: AppFonts.bold,
          ),
        ),
        const SizedBox(height: AppDimens.margin12),
        Text(
          'These Terms and Conditions govern your use of MenaHariya\'s transportation services. '
              'By booking a ticket with us, you agree to be bound by these terms. '
              'Please read them carefully before proceeding with your booking.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: AppDimens.margin8),
        Text(
          content,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildAcknowledgement(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.primaryGreen : AppColors.primaryGreen)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(
          color: (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
          ),
          const SizedBox(width: AppDimens.margin12),
          Expanded(
            child: Text(
              'By tapping "I Agree", you confirm that you have read, understood, '
                  'and agree to be bound by these Terms & Conditions.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Decline',
                onPressed: () => Get.back(result: false),
              ),
            ),
            const SizedBox(width: AppDimens.margin12),
            Expanded(
              child: PrimaryButton(
                text: 'I Agree',
                onPressed: _isScrolledToBottom
                    ? () => Get.back(result: true)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}