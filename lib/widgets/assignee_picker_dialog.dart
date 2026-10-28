import 'package:flutter/material.dart';

import '../data/user_store.dart';
import '../models/user.dart';
import 'user_avatar.dart';

/// Lets you pick who a task is assigned to: yourself, one of your
/// contacts, or someone found by searching the server for their
/// username (e.g. `alex_2232344`) — not in your contacts yet, but a
/// real account, which is what a task's assignee needs to be now that
/// there's a backend to validate it against.
class AssigneePickerDialog extends StatefulWidget {
  final UserStore userStore;

  const AssigneePickerDialog({super.key, required this.userStore});

  @override
  State<AssigneePickerDialog> createState() => _AssigneePickerDialogState();
}

class _AssigneePickerDialogState extends State<AssigneePickerDialog> {
  final _usernameController = TextEditingController();
  List<User>? _searchResults;
  bool _searching = false;
  String? _searchError;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _usernameController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _searching = true;
      _searchError = null;
    });
    final results = await widget.userStore.searchUsers(query);
    if (!mounted) return;
    setState(() {
      _searching = false;
      _searchResults = results;
      if (results.isEmpty) _searchError = 'No matching user found.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contacts = widget.userStore.contacts;
    final isLoggedIn = widget.userStore.isLoggedIn;
    final me = widget.userStore.currentUser;

    return AlertDialog(
      title: const Text('Assign to'),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: UserAvatar(imageBytes: me?.profilePicture, radius: 18),
                title: const Text('Myself'),
                onTap: () => Navigator.of(context).pop(widget.userStore.effectiveUserId),
              ),
              if (contacts.isNotEmpty) const Divider(),
              for (final contact in contacts)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: UserAvatar(imageBytes: contact.profilePicture, radius: 18),
                  title: Text(contact.userName),
                  subtitle: contact.fullName != null ? Text(contact.fullName!) : null,
                  onTap: () => Navigator.of(context).pop(contact.id),
                ),
              const Divider(),
              Text(
                isLoggedIn
                    ? 'Not in your contacts? Search by username:'
                    : 'Log in to search for other accounts.',
                style: theme.textTheme.bodySmall,
              ),
              if (isLoggedIn) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(hintText: 'username'),
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
                if (_searchError != null) ...[
                  const SizedBox(height: 8),
                  Text(_searchError!, style: TextStyle(color: theme.colorScheme.error)),
                ],
                if (_searchResults != null && _searchResults!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  for (final user in _searchResults!)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: UserAvatar(imageBytes: user.profilePicture, radius: 18),
                      title: Text(user.userName),
                      subtitle: user.fullName != null ? Text(user.fullName!) : null,
                      onTap: () => Navigator.of(context).pop(user.id),
                    ),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
