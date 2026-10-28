import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/user_store.dart';
import '../models/user.dart';
import 'user_avatar.dart';

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
  final _userNameController = TextEditingController();
  bool _searching = false;
  List<User>? _searchResults;
  bool _showPlaceholderForm = false;

  // Placeholder-only fields.
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _userNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _userNameController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _searching = true;
      _error = null;
    });
    final results = await widget.userStore.searchUsers(query);
    if (!mounted) return;
    setState(() {
      _searching = false;
      _searchResults = results;
    });
  }

  Future<void> _addReal(User user) async {
    try {
      await widget.userStore.addRealContact(user.userName);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = 'Could not add that contact.');
    }
  }

  Future<void> _addPlaceholder() async {
    final userName = _userNameController.text.trim();
    final email = _emailController.text.trim();
    if (userName.isEmpty || email.isEmpty) {
      setState(() => _error = 'Username and email are required.');
      return;
    }
    await widget.userStore.addLocalPlaceholderContact(User(
      id: const Uuid().v4(),
      userName: userName,
      email: email,
      fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoggedIn = widget.userStore.isLoggedIn;

    return AlertDialog(
      title: const Text('Add contact'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoggedIn && !_showPlaceholderForm) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _userNameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _searching ? null : _search,
                    child: const Text('Search'),
                  ),
                ],
              ),
              if (_searching) ...[
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_searchResults != null) ...[
                const SizedBox(height: 8),
                if (_searchResults!.isEmpty)
                  Text('No matching user found.', style: theme.textTheme.bodySmall)
                else
                  for (final user in _searchResults!)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: UserAvatar(imageBytes: user.profilePicture, radius: 18),
                      title: Text(user.userName),
                      subtitle: user.fullName != null ? Text(user.fullName!) : null,
                      onTap: () => _addReal(user),
                    ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _showPlaceholderForm = true),
                child: const Text("Not on the app yet? Add them anyway"),
              ),
            ] else ...[
              if (isLoggedIn)
                TextButton(
                  onPressed: () => setState(() => _showPlaceholderForm = false),
                  child: const Text('Search for a real account instead'),
                ),
              TextField(
                controller: _userNameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
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
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
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
          child: const Text('Cancel'),
        ),
        if (!isLoggedIn || _showPlaceholderForm) FilledButton(onPressed: _addPlaceholder, child: const Text('Add')),
      ],
    );
  }
}
