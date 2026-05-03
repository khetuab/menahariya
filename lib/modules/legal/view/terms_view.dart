// lib/modules/legal/views/terms_view.dart

import 'package:flutter/material.dart';
import '../widgets/legal_section.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menahariya Terms of Service',
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
                title: '1. Acceptance of Terms',
                content:
                'By accessing or using the Menahariya platform, you agree to be bound by these Terms of Service.',
              ),
              const LegalSection(
                title: '2. User Responsibilities',
                content:
                'You agree to provide accurate information and use the platform only for lawful purposes.',
              ),
              const LegalSection(
                title: '3. Bookings & Payments',
                content:
                'All bookings are subject to availability. Payments must be completed through supported methods.',
              ),
              const LegalSection(
                title: '4. Cancellations & Refunds',
                content:
                'Cancellation policies depend on transport providers. Refunds are processed accordingly.',
              ),
              const LegalSection(
                title: '5. Prohibited Activities',
                content:
                'You must not misuse the platform, attempt fraud, or disrupt system operations.',
              ),
              const LegalSection(
                title: '6. Limitation of Liability',
                content:
                'We are not responsible for delays, accidents, or third-party service issues.',
              ),
              const LegalSection(
                title: '7. Modifications',
                content:
                'We may update these terms at any time. Continued use means acceptance of updates.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}