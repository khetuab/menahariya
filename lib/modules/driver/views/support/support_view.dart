import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';

import '../driver_help_support_view.dart';

class SupportView extends StatelessWidget {
  const SupportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor:
        isDark ? AppColors.surfaceDark : AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.padding16),
        children: [
          _buildTile(
            context,
            icon: Icons.help_outline,
            title: 'FAQs',
            onTap: () => Get.to(() => const FAQView()),
          ),
          _buildTile(
            context,
            icon: Icons.headset_mic_outlined,
            title: 'Help And Support',
            onTap: () => Get.to(() =>  DriverHelpSupportView()),
          ),
          _buildTile(
            context,
            icon: Icons.phone_rounded,
            title: 'Call Support',
            onTap: () {
              Get.snackbar('Support', '+251 906464607');
            },
          ),
          _buildTile(
            context,
            icon: Icons.email_rounded,
            title: 'Email Support',
            onTap: () {
              Get.snackbar('Email', 'support@menahariya.com');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required IconData icon,
        required String title,
        required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
class ReportIssueView extends StatelessWidget {
  const ReportIssueView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Report Issue')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe your issue...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar('Submitted', 'Issue reported successfully');
              },
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
class FAQView extends StatelessWidget {
  const FAQView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'How do I go online?',
        'a': 'Use the availability toggle in your profile.'
      },
      {
        'q': 'How do I receive trips?',
        'a': 'Stay online and ensure your preferences allow trips.'
      },
      {
        'q': 'How do I withdraw earnings?',
        'a': 'Go to Earnings → Withdraw.'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FAQs')),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(faqs[index]['q']!),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(faqs[index]['a']!),
              )
            ],
          );
        },
      ),
    );
  }
}