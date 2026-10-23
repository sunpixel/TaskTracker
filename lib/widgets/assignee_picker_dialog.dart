import 'package:flutter/material.dart';

import '../data/current_user.dart';
import '../data/user_store.dart';
import 'user_avatar.dart';

/// Lets you pick who a task is assigned to: yourself, one of your
/// contacts, or a raw username typed in directly for someone not yet in
/// your contacts (e.g. `alex_2232344`) — stored as-is for now; once a
/// backend exists this would be checked against it there.
class AssigneePickerDialog extends StatefulWidget {
  final UserStore userStore;

  const AssigneePickerDialog({super.key, required this.userStore});

  @override
  State<AssigneePickerDialog> createState() => _AssigneePickerDialogState();
}

class _AssigneePickerDialogState extends State<AssigneePickerDialog> {
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contacts = widget.userStore.contacts;

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
                leading: const UserAvatar(radius: 18),
                title: const Text('Myself'),
                onTap: () => Navigator.of(context).pop(currentUserId),
              ),
              if (contacts.isNotEmpty) const Divider(),
              for (final contact in contacts)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: UserAvatar(imageBytes: contact.profilePicture, radius: 18),
                  title: Text(contact.userName),
                  subtitle: contact.fullName != null ? Text(contact.fullName!) : null,
                  onTap: () => Navigator.of(context).pop(contact.userName),
                ),
              const Divider(),
              Text(
                'Not in your contacts? Enter their username:',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(hintText: 'username'),
                      onSubmitted: (value) => _useTyped(context, value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _useTyped(context, _usernameController.text),
                    child: const Text('Use'),
                  ),
                ],
              ),
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

  void _useTyped(BuildContext context, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    Navigator.of(context).pop(trimmed);
  }
}
