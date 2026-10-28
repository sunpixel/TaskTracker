import 'package:flutter/material.dart';

import '../data/user_store.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/country_code.dart';
import '../utils/input_validators.dart';

/// Combined log in / sign up dialog, against the real backend now.
class AuthDialog extends StatefulWidget {
  final UserStore store;

  const AuthDialog({super.key, required this.store});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  bool _signUpMode = false;
  bool _submitting = false;
  String? _error;
  CountryCode? _countryCode = CountryCode.unitedStates;

  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _emailErrorMessage(EmailError error, AppLocalizations l10n) {
    switch (error) {
      case EmailError.empty:
        return l10n.emailRequired;
      case EmailError.invalidFormat:
        return l10n.emailInvalid;
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final userName = _userNameController.text.trim();
    final password = _passwordController.text;

    if (userName.isEmpty || password.isEmpty) {
      setState(() => _error = l10n.authUsernamePasswordRequired);
      return;
    }

    String? phoneDigits;
    if (_signUpMode) {
      final emailError = validateEmail(_emailController.text);
      if (emailError != null) {
        setState(() => _error = _emailErrorMessage(emailError, l10n));
        return;
      }

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
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final success = _signUpMode
        ? await widget.store.signUp(
            userName: userName,
            password: password,
            email: _emailController.text.trim(),
            fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
            phone: phoneDigits,
            countryCode: phoneDigits == null ? null : _countryCode,
          )
        : await widget.store.login(userName, password);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _submitting = false;
        _error = widget.store.authError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(_signUpMode ? l10n.authCreateAccountTitle : l10n.authLogInTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: l10n.authUsernameLabel),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: l10n.authPasswordLabel),
              obscureText: true,
            ),
            if (_signUpMode) ...[
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
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 4),
            TextButton(
              onPressed: _submitting
                  ? null
                  : () => setState(() {
                        _signUpMode = !_signUpMode;
                        _error = null;
                      }),
              child: Text(_signUpMode ? l10n.authSwitchToLogin : l10n.authSwitchToSignUp),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(_signUpMode ? l10n.authCreateAccountTitle : l10n.authLogInTitle),
        ),
      ],
    );
  }
}
