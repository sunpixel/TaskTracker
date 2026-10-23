import 'dart:typed_data';

import 'package:flutter/material.dart';

/// A circular avatar: the person's stored picture if there is one,
/// otherwise the shared default placeholder icon.
class UserAvatar extends StatelessWidget {
  final Uint8List? imageBytes;
  final double radius;

  const UserAvatar({super.key, this.imageBytes, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bytes = imageBytes;
    if (bytes != null) {
      return CircleAvatar(radius: radius, backgroundImage: MemoryImage(bytes));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        size: radius,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }
}
