import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
              title: const Text('Terms of Service'),
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
                    Icons.gavel,
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
                    title: '1. Acceptance of Terms',
                    icon: Icons.check_circle,
                    content: 'By accessing or using Qine Corner, you agree to be bound by these Terms of Service and all applicable laws and regulations.',
                  ),
                  _buildSection(
                    context,
                    title: '2. User Accounts',
                    icon: Icons.person,
                    content: '''• You must provide accurate and complete information when creating an account
• You are responsible for maintaining the security of your account
• You must not share your account credentials with others
• You must notify us immediately of any unauthorized access''',
                  ),
                  _buildSection(
                    context,
                    title: '3. Content Guidelines',
                    icon: Icons.article,
                    content: '''• You retain ownership of your content
• You grant us license to use your content
• Content must not violate any laws or rights
• We reserve the right to remove inappropriate content
• No plagiarism or copyright infringement''',
                  ),
                  _buildSection(
                    context,
                    title: '4. Book Club Rules',
                    icon: Icons.groups,
                    content: '''• Respect all members
• No hate speech or harassment
• Keep discussions on topic
• Follow club guidelines
• Moderators' decisions are final''',
                  ),
                  _buildSection(
                    context,
                    title: '5. Intellectual Property',
                    icon: Icons.copyright,
                    content: 'All content and materials available through Qine Corner are protected by intellectual property rights. You may not use, reproduce, or distribute without permission.',
                  ),
                  _buildSection(
                    context,
                    title: '6. Termination',
                    icon: Icons.block,
                    content: 'We reserve the right to terminate or suspend accounts that violate these terms or for any other reason at our discretion.',
                  ),
                  _buildSection(
                    context,
                    title: '7. Changes to Terms',
                    icon: Icons.update,
                    content: 'We may update these terms at any time. Continued use of Qine Corner after changes constitutes acceptance of new terms.',
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