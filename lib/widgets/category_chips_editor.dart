import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Horizontally scrollable row of a task's categories, each removable,
/// with a "+" to add more pinned at the right edge of the viewport.
///
/// The "+" doesn't reserve its own layout space — it floats in a [Stack]
/// on top of the scrolling chip row, which fades out under it (via
/// [ShaderMask]) so chip labels never look abruptly clipped as they
/// scroll past, however many categories there are.
class CategoryChipsEditor extends StatelessWidget {
  final List<String> categories;
  final bool editable;
  final ValueChanged<List<String>> onChanged;

  /// Categories already used elsewhere (across other tasks), offered as
  /// one-tap suggestions in the add dialog so reusing one doesn't require
  /// retyping it.
  final List<String> suggestions;

  const CategoryChipsEditor({
    super.key,
    required this.categories,
    required this.onChanged,
    this.editable = true,
    this.suggestions = const [],
  });

  bool _alreadyHas(String value) =>
      categories.any((c) => c.toLowerCase() == value.toLowerCase());

  Future<void> _promptAdd(BuildContext context) async {
    final controller = TextEditingController();
    final reusable = suggestions.where((s) => !_alreadyHas(s)).toList();
    final l10n = AppLocalizations.of(context)!;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.categoryEditorAddTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reusable.isNotEmpty) ...[
                Text(l10n.categoryEditorExisting, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final existing in reusable)
                      ActionChip(
                        label: Text(existing),
                        onPressed: () => Navigator.pop(context, existing),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(l10n.categoryEditorOrCreateNew, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
              ],
              TextField(
                controller: controller,
                autofocus: reusable.isEmpty,
                decoration: InputDecoration(hintText: l10n.categoryEditorNameHint),
                onSubmitted: (value) => Navigator.pop(context, value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    if (_alreadyHas(trimmed)) return;
    onChanged([...categories, trimmed]);
  }

  void _remove(int index) {
    onChanged([...categories]..removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final chipRow = ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(right: editable ? 48 : 0),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final label = categories[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: editable
              ? InputChip(
                  label: Text(label),
                  onDeleted: () => _remove(index),
                  deleteIconColor: theme.colorScheme.onSecondaryContainer,
                )
              : Chip(label: Text(label)),
        );
      },
    );

    return SizedBox(
      height: 44,
      child: categories.isEmpty && !editable
          ? Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.categoryEditorNoCategories, style: theme.textTheme.bodyMedium),
            )
          : Stack(
              children: [
                if (!editable)
                  chipRow
                else
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: const [Colors.black, Colors.black, Colors.transparent],
                      stops: const [0.0, 0.8, 1.0],
                    ).createShader(bounds),
                    blendMode: BlendMode.dstIn,
                    child: chipRow,
                  ),
                if (editable)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: _AddButton(onTap: () => _promptAdd(context)),
                  ),
              ],
            ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 40,
      child: Center(
        child: Material(
          color: theme.colorScheme.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.add, size: 18, color: theme.colorScheme.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
