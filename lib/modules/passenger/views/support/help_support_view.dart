// lib/modules/passenger/views/support/help_support_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/utils/validators/auth_validator.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.padding16),
        children: [
          // Quick Actions
          _buildQuickActions(context),

          const SizedBox(height: AppDimens.margin16),

          // FAQs Section
          _buildFAQSection(context),

          const SizedBox(height: AppDimens.margin16),

          // Contact Support Form
          _buildContactForm(context),

          const SizedBox(height: AppDimens.margin16),

          // Contact Info
          _buildContactInfo(context),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? AppColors.primaryGreenDark : AppColors.primaryGreen,
            isDark ? AppColors.primaryGreen : AppColors.primaryGreenLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAction(
              context,
              icon: Icons.chat_rounded,
              title: 'Live Chat',
              onTap: () => _startLiveChat(),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildQuickAction(
              context,
              icon: Icons.phone_rounded,
              title: 'Call Us',
              onTap: () => _makePhoneCall(),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildQuickAction(
              context,
              icon: Icons.email_rounded,
              title: 'Email',
              onTap: () => _sendEmail(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: AppDimens.margin8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: AppFonts.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimens.padding16),
            child: Row(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
                ),
                const SizedBox(width: AppDimens.margin8),
                Text(
                  'Frequently Asked Questions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildFAQItem(
            context,
            question: 'How do I book a ticket?',
            answer: 'You can book a ticket by searching for your desired route, selecting available seats, and completing the payment process.',
          ),
          _buildFAQItem(
            context,
            question: 'How can I cancel my booking?',
            answer: 'You can cancel your booking up to 2 hours before departure from the My Tickets section. Cancellation fees may apply.',
          ),
          _buildFAQItem(
            context,
            question: 'What payment methods are accepted?',
            answer: 'We accept Telebirr, CBE Birr, Credit/Debit cards, and wallet balance.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I track my cargo?',
            answer: 'Use the tracking code provided in your cargo receipt to track your shipment in the Cargo Tracking section.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I change my profile picture?',
            answer: 'Go to Profile, tap on your profile picture, and select "Take Photo" or "Choose from Gallery".',
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.padding16),
            child: Center(
              child: TextButton(
                onPressed: () => Get.toNamed('/faqs'),
                child: const Text('View All FAQs'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, {
    required String question,
    required String answer,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ExpansionTile(
      title: Text(
        question,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: AppFonts.medium,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Text(
            answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactForm(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.message_rounded,
                color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
              ),
              const SizedBox(width: AppDimens.margin8),
              Text(
                'Send us a message',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFonts.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.margin16),
          CustomTextField(
            label: 'Your Name',
            controller: nameController,
            prefixIcon: Icons.person_rounded,
          ),
          const SizedBox(height: AppDimens.margin12),
          CustomTextField(
            label: 'Email Address',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_rounded,
          ),
          const SizedBox(height: AppDimens.margin12),
          CustomTextField(
            label: 'Subject',
            controller: subjectController,
            prefixIcon: Icons.title_rounded,
          ),
          const SizedBox(height: AppDimens.margin12),
          CustomTextField(
            label: 'Message',
            controller: messageController,
            maxLines: 4,
            prefixIcon: Icons.message_rounded,
          ),
          const SizedBox(height: AppDimens.margin16),
          PrimaryButton(
            text: 'Send Message',
            onPressed: () => _submitSupportRequest(
              nameController.text,
              emailController.text,
              subjectController.text,
              messageController.text,
            ),
            icon: Icons.send_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          _buildContactItem(
            context,
            icon: Icons.phone_rounded,
            title: 'Phone Support',
            value: '+251-XXX-XXXXXX',
            subtitle: 'Available 24/7',
            onTap: () => _makePhoneCall(),
          ),
          const Divider(),
          _buildContactItem(
            context,
            icon: Icons.email_rounded,
            title: 'Email Support',
            value: 'support@menahariya.com',
            subtitle: 'Response within 24 hours',
            onTap: () => _sendEmail(),
          ),
          const Divider(),
          _buildContactItem(
            context,
            icon: Icons.location_on_rounded,
            title: 'Office Address',
            value: 'Addis Ababa, Ethiopia',
            subtitle: 'Bole Road, Building X',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        child: Icon(icon, color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: AppFonts.medium)),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  void _startLiveChat() {
    Get.snackbar(
      'Live Chat',
      'Connecting to support agent...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Implement live chat navigation
  }

  void _makePhoneCall() async {
    const phoneNumber = '+251XXXXXXXXX';
    await Clipboard.setData(const ClipboardData(text: phoneNumber));
    Get.snackbar(
      'Phone Number Copied',
      phoneNumber,
      snackPosition: SnackPosition.BOTTOM,
    );
    // Use url_launcher to make call: launch('tel:$phoneNumber')
  }

  void _sendEmail() async {
    const email = 'support@menahariya.com';
    await Clipboard.setData(const ClipboardData(text: email));
    Get.snackbar(
      'Email Copied',
      email,
      snackPosition: SnackPosition.BOTTOM,
    );
    // Use url_launcher to send email: launch('mailto:$email')
  }

  void _submitSupportRequest(String name, String email, String subject, String message) {
    if (name.isEmpty || email.isEmpty || subject.isEmpty || message.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (AuthValidator.validateEmail(email) != null) {
      Get.snackbar(
        'Error',
        'Please enter a valid email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'Message Sent',
      'We\'ll get back to you soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Implement API call to submit support request
  }
}