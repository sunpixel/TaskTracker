import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/user_store.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/country_code.dart';
import '../models/user.dart';
import '../utils/input_validators.dart';
import 'debounced_user_search.dart';

/// Dialog for adding a contact. Logged in: searches the server by
/// username first — a contact has to be a real account now, since the
/// relationship is actually stored there (see the design notes: a
/// "contact with no password" never made sense; the fix is that a
/// contact is just another real account, not a fake row). Not logged
/// in, or the search comes up empty: falls back to a local-only
/// placeholder, for someone not on the app yet.
class AddContactDialog extends StatefulWidget {
  final UserStore userStore;

  const AddContactDialog({super.key, required this.userStore});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  bool _showPlaceholderForm = false;

  // Placeholder-only fields.
  final _userNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _error;
  CountryCode? _countryCode = CountryCode.unitedStates;

  @override
  void dispose() {
    _userNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addReal(User user) async {
    try {
      await widget.userStore.addRealContact(user.userName);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = AppLocalizations.of(context)!.addContactFailed);
    }
  }

  String? _emailErrorMessage(EmailError error, AppLocalizations l10n) {
    switch (error) {
      case EmailError.empty:
        return l10n.emailRequired;
      case EmailError.invalidFormat:
        return l10n.emailInvalid;
    }
  }

  Future<void> _addPlaceholder() async {
    final l10n = AppLocalizations.of(context)!;
    final userName = _userNameController.text.trim();
    final email = _emailController.text.trim();
    if (userName.isEmpty || email.isEmpty) {
      setState(() => _error = l10n.addContactUsernameEmailRequired);
      return;
    }
    final emailError = validateEmail(email);
    if (emailError != null) {
      setState(() => _error = _emailErrorMessage(emailError, l10n));
      return;
    }

    String? phoneDigits;
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isNotEmpty) {
      phoneDigits = phoneDigitsOnly(rawPhone);
      final country = _countryCode;
      if (country == null) {
        setState(() => _error = l10n.authPickCountry);
        return;
      }
      final phoneError = validatePhoneDigits(phoneDigits, country);
      if (phoneError != null) {
        setState(() => _error = l10n.phoneLengthError(
              phoneError.country.label(l10n),
              phoneError.expected,
              phoneError.actual,
            ));
        return;
      }
    }

    await widget.userStore.addLocalPlaceholderContact(User(
      id: const Uuid().v4(),
      userName: userName,
      email: email,
      fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
      phone: phoneDigits,
      countryCode: phoneDigits == null ? null : _countryCode,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLoggedIn = widget.userStore.isLoggedIn;

    return AlertDialog(
      title: Text(l10n.addContactTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoggedIn && !_showPlaceholderForm) ...[
              DebouncedUserSearch(
                userStore: widget.userStore,
                onSelected: _addReal,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _showPlaceholderForm = true),
                child: Text(l10n.addContactNotOnApp),
              ),
            ] else ...[
              if (isLoggedIn)
                TextButton(
                  onPressed: () => setState(() => _showPlaceholderForm = false),
                  child: Text(l10n.addContactSearchInstead),
                ),
              TextField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: l10n.authUsernameLabel),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: l10n.authEmailLabel),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: l10n.authFullNameLabel),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<CountryCode>(
                      initialValue: _countryCode,
                      decoration: InputDecoration(labelText: l10n.authCountryLabel),
                      items: CountryCode.values
                          .map((c) => DropdownMenuItem(value: c, child: Text(c.label(l10n), overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (value) => setState(() => _countryCode = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: l10n.authPhoneLabel),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [digitsOnlyInputFormatter],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: l10n.addContactDescriptionLabel),
                maxLines: 2,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        if (!isLoggedIn || _showPlaceholderForm) FilledButton(onPressed: _addPlaceholder, child: Text(l10n.add)),
      ],
    );
  }
}
