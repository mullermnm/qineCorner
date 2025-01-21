import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/theme/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ;
    final user = authState.when(
      data: (state) => state?.user,
      loading: () => null,
      error: (_, __) => null,
    );

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 50,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, 20),
              child: Column(
                children: [
                  Hero(
                    tag: 'profile-photo',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        backgroundImage: user.profileImage != null
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child: user.profileImage == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.verified,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Joined on ${DateFormat.yMMMMd().format(user.createdAt)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              isDark
                                  ? Colors.grey[900]!
                                  : Theme.of(context).colorScheme.surface,
                              isDark
                                  ? Colors.grey[850]!
                                  : Theme.of(context).colorScheme.surface,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.phone,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                title: const Text('Phone'),
                                subtitle: Text(user.phone),
                              ),
                              const Divider(),
                              ListTile(
                                leading: Icon(
                                  Icons.email,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                title: const Text('Email'),
                                subtitle: Text(
                                  user.email ?? 'Email not set',
                                ),
                                trailing: user.email == null
                                    ? TextButton(
                                        onPressed: () {
                                          context.push('/profile/edit');
                                        },
                                        child: const Text('Add Email'),
                                      )
                                    : null,
                              ),
                              const Divider(),
                              SwitchListTile(
                                secondary: Icon(
                                  isDark ? Icons.dark_mode : Icons.light_mode,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                title: const Text('Dark Mode'),
                                value: isDark,
                                onChanged: (value) {
                                  ref
                                      .read(themeProvider.notifier)
                                      .toggleTheme();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            context.push('/profile/edit');
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.read(authNotifierProvider.notifier).logout();
                            context.go('/');
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            foregroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
