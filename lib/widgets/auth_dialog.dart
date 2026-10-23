import 'package:flutter/material.dart';

import '../data/user_store.dart';
import '../models/user.dart';

/// Combined log in / sign up dialog.
///
/// There's no backend yet — this only checks against (or creates) a
/// single local "me" profile on this device. Starts in sign-up mode if
/// no local account exists yet, log-in mode otherwise.
class AuthDialog extends StatefulWidget {
  final UserStore store;
  final bool startInSignUpMode;

  const AuthDialog({super.key, required this.store, required this.startInSignUpMode});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  late bool _signUpMode = widget.startInSignUpMode;
  bool _submitting = false;
  String? _error;

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

  Future<void> _submit() async {
    final userName = _userNameController.text.trim();
    final password = _passwordController.text;

    if (userName.isEmpty || password.isEmpty) {
      setState(() => _error = 'Username and password are required.');
      return;
    }
    if (_signUpMode && _emailController.text.trim().isEmpty) {
      setState(() => _error = 'Email is required.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final success = _signUpMode
        ? await widget.store.signUp(User(
            userName: userName,
            password: password,
            email: _emailController.text.trim(),
            fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          ))
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
    return AlertDialog(
      title: Text(_signUpMode ? 'Create account' : 'Log in'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_signUpMode) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full name (optional)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
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
              child: Text(_signUpMode ? 'Already have an account? Log in' : 'New here? Create an account'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(_signUpMode ? 'Create account' : 'Log in'),
        ),
      ],
    );
  }
}
