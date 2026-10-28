import 'dart:async';

import 'package:flutter/material.dart';

import '../data/user_store.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/user.dart';
import 'user_avatar.dart';

/// A username search field that fires automatically — no search button —
/// once there are at least 3 characters, after a short debounce delay.
/// Typing again before that delay elapses cancels the pending search and
/// restarts the wait, so a fast typist never fires a request per
/// keystroke. A response that comes back after the query has since
/// changed is discarded rather than shown.
///
/// Results render in a fixed-height, scrollable area sized for at least
/// [visibleTileCount] rows, so the dialog around this doesn't jump
/// around as the result count changes.
class DebouncedUserSearch extends StatefulWidget {
  final UserStore userStore;
  final ValueChanged<User> onSelected;

  /// Defaults to the localized "Username" when left unset — `null`
  /// rather than a hardcoded English default, since a const default
  /// can't call `AppLocalizations.of(context)`.
  final String? labelText;

  final int visibleTileCount;

  const DebouncedUserSearch({
    super.key,
    required this.userStore,
    required this.onSelected,
    this.labelText,
    this.visibleTileCount = 3,
  });

  @override
  State<DebouncedUserSearch> createState() => _DebouncedUserSearchState();
}

class _DebouncedUserSearchState extends State<DebouncedUserSearch> {
  static const _minQueryLength = 3;
  static const _debounceDelay = Duration(milliseconds: 400);
  static const _tileHeight = 64.0; // ListTile with a subtitle, roughly.

  final _controller = TextEditingController();
  Timer? _debounce;
  String? _searchedQuery;
  bool _searching = false;
  List<User> _results = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel(); // A new keystroke always cancels the pending wait.
    final query = value.trim();
    if (query.length < _minQueryLength) {
      setState(() {
        _searching = false;
        _results = const [];
        _searchedQuery = null;
      });
      return;
    }
    _debounce = Timer(_debounceDelay, () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    setState(() {
      _searching = true;
      _searchedQuery = query;
    });
    final results = await widget.userStore.searchUsers(query);
    if (!mounted) return;
    // The field may have changed again while this request was in flight —
    // a stale response shouldn't overwrite a newer (possibly empty) state.
    if (_controller.text.trim() != query) return;
    setState(() {
      _searching = false;
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final showResultsArea = _searchedQuery != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.labelText ?? l10n.searchUsernameLabel,
            hintText: l10n.searchHintMinChars(_minQueryLength),
          ),
          onChanged: _onChanged,
        ),
        if (showResultsArea) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: _tileHeight * widget.visibleTileCount,
            child: _searching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Text(l10n.searchNoResults, style: theme.textTheme.bodySmall),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final user = _results[index];
                          return ListTile(
                            leading: UserAvatar(imageBytes: user.profilePicture, radius: 18),
                            title: Text(user.userName),
                            subtitle: user.fullName != null ? Text(user.fullName!) : null,
                            onTap: () => widget.onSelected(user),
                          );
                        },
                      ),
          ),
        ],
      ],
    );
  }
}
