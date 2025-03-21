import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Privacy Policy'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.security,
                    size: 64,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSection(
                    context,
                    title: 'Information We Collect',
                    icon: Icons.info,
                    content: '''• Account information (name, email, phone)
• Reading preferences and history
• Device information and usage data
• Book club participation data
• Article interactions and comments
• Reading progress and goals''',
                  ),
                  _buildSection(
                    context,
                    title: 'How We Use Your Data',
                    icon: Icons.data_usage,
                    content: '''• Personalize your reading experience
• Improve our services and features
• Send relevant notifications
• Track reading progress
• Facilitate social features
• Analyze app performance''',
                  ),
                  _buildSection(
                    context,
                    title: 'Data Protection',
                    icon: Icons.shield,
                    content: '''• Industry-standard encryption
• Secure data storage
• Regular security audits
• Limited employee access
• Third-party security compliance''',
                  ),
                  _buildSection(
                    context,
                    title: 'Your Rights',
                    icon: Icons.verified_user,
                    content: '''• Access your personal data
• Request data correction
• Delete your account
• Export your data
• Opt-out of communications
• Control privacy settings''',
                  ),
                  _buildSection(
                    context,
                    title: 'Data Sharing',
                    icon: Icons.share,
                    content: 'We never sell your personal data. We only share data with trusted partners necessary for providing our services.',
                  ),
                  _buildSection(
                    context,
                    title: 'Cookies & Tracking',
                    icon: Icons.cookie,
                    content: 'We use cookies and similar technologies to improve user experience and analyze app usage patterns.',
                  ),
                  _buildSection(
                    context,
                    title: 'Children\'s Privacy',
                    icon: Icons.child_care,
                    content: 'We do not knowingly collect data from children under 13. Parents can request deletion of any such data.',
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Last Updated: February 2024',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
} 