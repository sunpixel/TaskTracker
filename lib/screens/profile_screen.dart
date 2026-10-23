import 'package:flutter/material.dart';

import '../data/user_store.dart';
import '../data/user_store_scope.dart';
import '../models/user.dart';
import '../theme/theme_controller.dart';
import '../widgets/add_contact_dialog.dart';
import '../widgets/auth_dialog.dart';
import '../widgets/contact_detail_dialog.dart';
import '../widgets/user_avatar.dart';

/// Profile tab: your own (local-only, for now) account, your contacts,
/// and the appearance switch.
class ProfileScreen extends StatelessWidget {
  final ThemeController themeController;

  const ProfileScreen({super.key, required this.themeController});

  Future<void> _openAuthDialog(BuildContext context, UserStore store) async {
    final hasAccount = await store.hasLocalAccount();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AuthDialog(store: store, startInSignUpMode: !hasAccount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = UserStoreScope.of(context);
    final theme = Theme.of(context);

    if (store.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final me = store.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                UserAvatar(imageBytes: me?.profilePicture, radius: 40),
                const SizedBox(height: 12),
                Text(me?.displayName ?? 'Not logged in', style: theme.textTheme.titleLarge),
                if (me != null)
                  Text(
                    me.email,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (me == null)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _openAuthDialog(context, store),
                child: const Text('Log in'),
              ),
            )
          else
            Center(
              child: TextButton(onPressed: store.logout, child: const Text('Log out')),
            ),
          const SizedBox(height: 24),
          _ContactsSection(store: store),
          const SizedBox(height: 24),
          _AppearanceSection(themeController: themeController),
        ],
      ),
    );
  }
}

class _ContactsSection extends StatelessWidget {
  final UserStore store;

  const _ContactsSection({required this.store});

  Future<void> _addContact(BuildContext context) async {
    final result = await showDialog<User>(
      context: context,
      builder: (context) => const AddContactDialog(),
    );
    if (result != null) {
      await store.addContact(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contacts = store.contacts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Contacts', style: theme.textTheme.titleMedium),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: 'Add contact',
              onPressed: () => _addContact(context),
            ),
          ],
        ),
        if (contacts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No contacts yet.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          )
        else
          for (final contact in contacts) _ContactRow(contact: contact, store: store),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final User contact;
  final UserStore store;

  const _ContactRow({required this.contact, required this.store});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text('Do you really wish to delete "${contact.userName}" from contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await store.deleteContact(contact.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: UserAvatar(imageBytes: contact.profilePicture, radius: 18),
      title: Text(contact.userName),
      subtitle: contact.fullName != null ? Text(contact.fullName!) : null,
      trailing: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Delete contact',
        onPressed: () => _confirmDelete(context),
      ),
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => ContactDetailDialog(contact: contact),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  final ThemeController themeController;

  const _AppearanceSection({required this.themeController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text('Appearance', style: theme.textTheme.titleMedium),
        const Spacer(),
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeController,
          builder: (context, mode, _) => SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined)),
              ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined)),
              ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_suggest_outlined)),
            ],
            selected: {mode},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => themeController.setMode(selection.first),
          ),
        ),
      ],
    );
  }
}
