import 'package:flutter/material.dart';

import '../data/user_store.dart';
import '../data/user_store_scope.dart';
import '../l10n/generated/app_localizations.dart';
import '../locale/locale_controller.dart';
import '../models/search_privacy.dart';
import '../models/user.dart';
import '../theme/theme_controller.dart';
import '../widgets/add_contact_dialog.dart';
import '../widgets/auth_dialog.dart';
import '../widgets/contact_detail_dialog.dart';
import '../widgets/user_avatar.dart';

/// Profile tab: your own (local-only, for now) account, your contacts,
/// and the appearance/language switches.
class ProfileScreen extends StatelessWidget {
  final ThemeController themeController;
  final LocaleController localeController;

  const ProfileScreen({super.key, required this.themeController, required this.localeController});

  Future<void> _openAuthDialog(BuildContext context, UserStore store) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AuthDialog(store: store),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = UserStoreScope.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (store.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final me = store.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                UserAvatar(imageBytes: me?.profilePicture, radius: 40),
                const SizedBox(height: 12),
                Text(me?.displayName ?? l10n.profileNotLoggedIn, style: theme.textTheme.titleLarge),
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
                child: Text(l10n.profileLogIn),
              ),
            )
          else
            Center(
              child: TextButton(onPressed: store.logout, child: Text(l10n.profileLogOut)),
            ),
          const SizedBox(height: 24),
          _ContactsSection(store: store),
          if (me != null) ...[
            const SizedBox(height: 24),
            _PrivacySection(store: store, me: me),
          ],
          const SizedBox(height: 24),
          _AppearanceSection(themeController: themeController),
          const SizedBox(height: 24),
          _LanguageSection(localeController: localeController),
        ],
      ),
    );
  }
}

class _ContactsSection extends StatelessWidget {
  final UserStore store;

  const _ContactsSection({required this.store});

  Future<void> _addContact(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AddContactDialog(userStore: store),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final contacts = store.contacts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.profileContacts, style: theme.textTheme.titleMedium),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: l10n.profileAddContactTooltip,
              onPressed: () => _addContact(context),
            ),
          ],
        ),
        if (contacts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.profileNoContacts,
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileDeleteContactTitle),
        content: Text(l10n.profileDeleteContactBody(contact.userName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await store.deleteContact(contact.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: UserAvatar(imageBytes: contact.profilePicture, radius: 18),
      title: Text(contact.userName),
      subtitle: contact.fullName != null ? Text(contact.fullName!) : null,
      trailing: IconButton(
        icon: const Icon(Icons.close),
        tooltip: l10n.profileDeleteContactTooltip,
        onPressed: () => _confirmDelete(context),
      ),
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => ContactDetailDialog(contact: contact),
      ),
    );
  }
}

/// Who can find you via search (GET /users/search) — see
/// `models/search_privacy.dart` for what each tier means. Only shown
/// when logged in; the setting is meaningless otherwise.
class _PrivacySection extends StatefulWidget {
  final UserStore store;
  final User me;

  const _PrivacySection({required this.store, required this.me});

  @override
  State<_PrivacySection> createState() => _PrivacySectionState();
}

class _PrivacySectionState extends State<_PrivacySection> {
  bool _saving = false;

  Future<void> _changeTo(SearchPrivacy? privacy) async {
    if (privacy == null || _saving) return;
    setState(() => _saving = true);
    final ok = await widget.store.updatePrivacy(privacy);
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profilePrivacyUpdateError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    // Falls back to the server's own default if the cached profile
    // somehow doesn't have it yet (e.g. right after a fresh signup).
    final current = widget.me.searchPrivacy ?? SearchPrivacy.exactUsernameOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.profileWhoCanFindYou, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Card(
          child: RadioGroup<SearchPrivacy>(
            groupValue: current,
            onChanged: _changeTo, // the _saving guard inside stops double-submission
            child: Column(
              children: [
                for (final tier in SearchPrivacy.values)
                  RadioListTile<SearchPrivacy>(
                    value: tier,
                    title: Text(tier.label(l10n)),
                    subtitle: Text(tier.description(l10n)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  final ThemeController themeController;

  const _AppearanceSection({required this.themeController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(l10n.profileAppearance, style: theme.textTheme.titleMedium),
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

/// Language picker: "System default" (the `null` value — follow the
/// device's own language, see `LocaleController`) plus one entry per
/// `AppLocalizations.supportedLocales`, so adding a new translation
/// later only means adding its ARB file — no change needed here.
class _LanguageSection extends StatelessWidget {
  final LocaleController localeController;

  const _LanguageSection({required this.localeController});

  String _labelFor(Locale? locale, AppLocalizations l10n) {
    if (locale == null) return l10n.profileLanguageSystemDefault;
    switch (locale.languageCode) {
      case 'ru':
        return 'Русский';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final options = <Locale?>[null, ...AppLocalizations.supportedLocales];

    return Row(
      children: [
        Text(l10n.profileLanguage, style: theme.textTheme.titleMedium),
        const Spacer(),
        ValueListenableBuilder<Locale?>(
          valueListenable: localeController,
          builder: (context, current, _) => DropdownButton<Locale?>(
            value: current,
            items: [
              for (final option in options)
                DropdownMenuItem(value: option, child: Text(_labelFor(option, l10n))),
            ],
            onChanged: localeController.setLocale,
          ),
        ),
      ],
    );
  }
}
