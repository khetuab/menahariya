// lib/modules/legal/views/privacy_view.dart

import 'package:flutter/material.dart';
import '../widgets/legal_section.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menahariya Privacy Policy',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: April 2026',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 20),

              const LegalSection(
                title: '1. Information We Collect',
                content:
                'We collect personal information such as phone number, name, and booking data.',
              ),
              const LegalSection(
                title: '2. How We Use Data',
                content:
                'Your data is used to process bookings, provide services, and improve user experience.',
              ),
              const LegalSection(
                title: '3. Data Sharing',
                content:
                'We do not sell your data. Information may be shared with transport providers for service delivery.',
              ),
              const LegalSection(
                title: '4. Data Security',
                content:
                'We implement security measures to protect your information from unauthorized access.',
              ),
              const LegalSection(
                title: '5. User Rights',
                content:
                'You can request access, correction, or deletion of your personal data.',
              ),
              const LegalSection(
                title: '6. Cookies & Tracking',
                content:
                'We may use cookies and analytics to enhance app performance.',
              ),
              const LegalSection(
                title: '7. Updates',
                content:
                'This policy may change over time. Continued use means acceptance.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}