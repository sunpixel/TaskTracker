import 'package:flutter/material.dart';

import '../data/user_store.dart';
import 'debounced_user_search.dart';
import 'user_avatar.dart';

/// Lets you pick who a task is assigned to: yourself, one of your
/// contacts, or someone found by searching the server for their
/// username (e.g. `alex_2232344`) — not in your contacts yet, but a
/// real account, which is what a task's assignee needs to be now that
/// there's a backend to validate it against.
class AssigneePickerDialog extends StatelessWidget {
  final UserStore userStore;

  const AssigneePickerDialog({super.key, required this.userStore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contacts = userStore.contacts;
    final isLoggedIn = userStore.isLoggedIn;
    final me = userStore.currentUser;

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
                onTap: () => Navigator.of(context).pop(userStore.effectiveUserId),
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
                DebouncedUserSearch(
                  userStore: userStore,
                  onSelected: (user) => Navigator.of(context).pop(user.id),
                ),
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
