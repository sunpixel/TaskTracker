import 'package:flutter/material.dart';

import '../models/user.dart';
import 'user_avatar.dart';

/// Small overlay showing one contact's details, opened by tapping their
/// row in the Contacts list.
class ContactDetailDialog extends StatelessWidget {
  final User contact;

  const ContactDetailDialog({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(imageBytes: contact.profilePicture, radius: 32),
              const SizedBox(height: 12),
              Text(contact.displayName, style: theme.textTheme.titleMedium),
              Text('@${contact.userName}', style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              _Row(icon: Icons.email_outlined, value: contact.email),
              if (contact.phone != null) _Row(icon: Icons.phone_outlined, value: contact.phone!),
              if (contact.description != null) ...[
                const SizedBox(height: 8),
                Text(contact.description!, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String value;

  const _Row({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
