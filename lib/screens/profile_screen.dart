import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

/// Profile tab. Currently just an avatar placeholder and the
/// light/dark/system theme switch — everything else (account info, sign
/// out, settings) will be added once there's a backend to back it with.
class ProfileScreen extends StatelessWidget {
  final ThemeController themeController;

  const ProfileScreen({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Your Name', style: theme.textTheme.titleLarge),
                Text(
                  'you@example.com',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Appearance', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeController,
              builder: (context, mode, _) {
                return RadioGroup<ThemeMode>(
                  groupValue: mode,
                  onChanged: (value) => themeController.setMode(value!),
                  child: const Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        title: Text('Light'),
                        secondary: Icon(Icons.light_mode_outlined),
                        value: ThemeMode.light,
                      ),
                      RadioListTile<ThemeMode>(
                        title: Text('Dark'),
                        secondary: Icon(Icons.dark_mode_outlined),
                        value: ThemeMode.dark,
                      ),
                      RadioListTile<ThemeMode>(
                        title: Text('System'),
                        secondary: Icon(Icons.settings_suggest_outlined),
                        value: ThemeMode.system,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
