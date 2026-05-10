import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/primary_button.dart';
import 'package:menahariya/core/widgets/inputs/custom_textfield.dart';
import 'package:menahariya/core/utils/validators/auth_validator.dart';
import 'package:menahariya/modules/driver/controllers/driver_support_controller.dart';
import 'package:menahariya/modules/driver/views/support/driver_my_tickets_view.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverHelpSupportView extends GetView<DriverSupportController> {
  DriverHelpSupportView({Key? key}) : super(key: key);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final RxBool isSubmitted = false.obs;
  final RxString nameError = RxString('');
  final RxString emailError = RxString('');
  final RxString subjectError = RxString('');
  final RxString messageError = RxString('');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Get.to(() => const DriverMyTicketsView()),
            tooltip: 'My Tickets',
          ),
        ],
      ),
      body: Obx(() {
        if (isSubmitted.value) {
          return _buildSuccessView(context);
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            children: [
              _buildQuickActions(context),
              const SizedBox(height: AppDimens.margin16),
              _buildFAQSection(context),
              const SizedBox(height: AppDimens.margin16),
              _buildContactForm(context),
              const SizedBox(height: AppDimens.margin16),
              _buildContactInfo(context),
              const SizedBox(height: AppDimens.margin16),
              _buildMyTicketsButton(context),
            ],
          ),
        );
      }),
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
              icon: Icons.support_agent_rounded,
              title: 'My Tickets',
              onTap: () => Get.to(() => const DriverMyTicketsView()),
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
            question: 'How do I go online/offline?',
            answer: 'Use the online/offline toggle switch in the top right corner of your dashboard to indicate your availability for trips.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I validate passenger tickets?',
            answer: 'Go to the Boarding section, select your trip, and use the QR scanner or enter the ticket code manually to validate passengers.',
          ),
          _buildFAQItem(
            context,
            question: 'What if a passenger doesn\'t have a QR code?',
            answer: 'You can manually enter their ticket ID or search for them in the passenger list and mark them as checked in.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I report an issue during a trip?',
            answer: 'Go to the trip details page and use the "Report Issue" button to report delays, accidents, or other incidents.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I update trip status?',
            answer: 'On your active trip page, you can update the status to "Departed", "In Transit", or "Completed" as you progress through the trip.',
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

          Obx(() => CustomTextField(
            label: 'Your Name',
            controller: nameController,
            onChanged: (_) => _validateName(),
            prefixIcon: Icons.person_rounded,
            errorText: nameError.value.isEmpty ? null : nameError.value,
          )),
          const SizedBox(height: AppDimens.margin12),

          Obx(() => CustomTextField(
            label: 'Email Address',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _validateEmail(),
            prefixIcon: Icons.email_rounded,
            errorText: emailError.value.isEmpty ? null : emailError.value,
          )),
          const SizedBox(height: AppDimens.margin12),

          Obx(() => CustomTextField(
            label: 'Subject',
            controller: subjectController,
            onChanged: (_) => _validateSubject(),
            prefixIcon: Icons.title_rounded,
            errorText: subjectError.value.isEmpty ? null : subjectError.value,
          )),
          const SizedBox(height: AppDimens.margin12),

          Obx(() => CustomTextField(
            label: 'Message',
            controller: messageController,
            maxLines: 4,
            onChanged: (_) => _validateMessage(),
            prefixIcon: Icons.message_rounded,
            errorText: messageError.value.isEmpty ? null : messageError.value,
          )),
          const SizedBox(height: AppDimens.margin16),

          Obx(() => PrimaryButton(
            text: 'Send Message',
            onPressed: controller.isLoading ? null : _submitSupportRequest,
            isLoading: controller.isLoading,
            icon: Icons.send_rounded,
          )),
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
            value: '+251-906464607',
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

  Widget _buildMyTicketsButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return OutlinedButton.icon(
      onPressed: () => Get.to(() => const DriverMyTicketsView()),
      icon: const Icon(Icons.history_rounded),
      label: const Text('View My Support Tickets'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(AppDimens.padding12),
        side: BorderSide(
          color: isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.successLight : AppColors.success).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 40,
                color: isDark ? AppColors.successLight : AppColors.success,
              ),
            ),
            const SizedBox(height: AppDimens.margin24),
            Text(
              'Message Sent!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: AppFonts.bold,
              ),
            ),
            const SizedBox(height: AppDimens.margin8),
            Text(
              'Thank you for contacting us.\nWe\'ll get back to you within 24 hours.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.margin32),
            PrimaryButton(
              text: 'Send Another Message',
              onPressed: () {
                nameController.clear();
                emailController.clear();
                subjectController.clear();
                messageController.clear();
                isSubmitted.value = false;
              },
              icon: Icons.refresh_rounded,
            ),
            const SizedBox(height: AppDimens.margin12),
            OutlinedButton(
              onPressed: () => Get.back(),
              child: const Text('Back to Support'),
            ),
          ],
        ),
      ),
    );
  }

  void _validateName() {
    if (nameController.text.trim().isEmpty) {
      nameError.value = 'Name is required';
    } else {
      nameError.value = '';
    }
  }

  void _validateEmail() {
    if (emailController.text.trim().isEmpty) {
      emailError.value = 'Email is required';
    } else {
      final validationError = AuthValidator.validateEmail(emailController.text);
      emailError.value = validationError ?? '';
    }
  }

  void _validateSubject() {
    if (subjectController.text.trim().isEmpty) {
      subjectError.value = 'Subject is required';
    } else {
      subjectError.value = '';
    }
  }

  void _validateMessage() {
    if (messageController.text.trim().isEmpty) {
      messageError.value = 'Message is required';
    } else {
      messageError.value = '';
    }
  }

  bool _isFormValid() {
    _validateName();
    _validateEmail();
    _validateSubject();
    _validateMessage();

    return nameError.value.isEmpty &&
        emailError.value.isEmpty &&
        subjectError.value.isEmpty &&
        messageError.value.isEmpty &&
        nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        subjectController.text.trim().isNotEmpty &&
        messageController.text.trim().isNotEmpty;
  }

  Future<void> _submitSupportRequest() async {
    if (!_isFormValid()) {
      Get.snackbar(
        'Validation Error',
        'Please fix the errors before submitting',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final success = await controller.submitSupportRequest(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      subject: subjectController.text.trim(),
      message: messageController.text.trim(),
    );

    if (success) {
      isSubmitted.value = true;
      Get.snackbar(
        'Message Sent',
        'We\'ll get back to you soon!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _makePhoneCall() async {
    const phoneNumber = '+251906464607';
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      Get.snackbar(
        'Phone Number Copied',
        phoneNumber,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _sendEmail() async {
    const email = 'support@menahariya.com';
    final Uri emailUri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      await Clipboard.setData(ClipboardData(text: email));
      Get.snackbar(
        'Email Copied',
        email,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    //super.dispose();
  }
}