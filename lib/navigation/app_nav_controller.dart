import 'package:flutter/foundation.dart';

import '../widgets/task_filter_bar.dart';

/// Coordinates the kind of cross-tab navigation that isn't a plain
/// push/pop — e.g. tapping a Home summary card and landing directly on
/// the Tasks tab with that filter already selected. It's a tab switch,
/// not a stack push, but still shows a back button on Tasks (via
/// [tasksTabHasBackButton]) so there's an easy way back to Home —
/// switching tabs normally (the bottom bar) never shows one.
class AppNavController extends ChangeNotifier {
  int _tabIndex = 0;
  bool _arrivedAtTasksViaJump = false;
  TaskFilter? _pendingTasksFilter;

  int get tabIndex => _tabIndex;

  bool get tasksTabHasBackButton => _tabIndex == 1 && _arrivedAtTasksViaJump;

  /// Normal tab switch — the bottom nav bar. Never shows a back button.
  void setTabIndex(int index) {
    final changed = index != _tabIndex || _arrivedAtTasksViaJump;
    _arrivedAtTasksViaJump = false;
    _tabIndex = index;
    if (changed) notifyListeners();
  }

  /// Switches to the Tasks tab, optionally pre-selecting [filter], and
  /// shows a back button there pointing back to Home.
  void goToTasksTab({TaskFilter? filter}) {
    _pendingTasksFilter = filter;
    _arrivedAtTasksViaJump = true;
    _tabIndex = 1;
    notifyListeners();
  }

  /// Consumes the pending filter request, if any — call once and act on
  /// the result; it won't be handed out again.
  TaskFilter? consumePendingTasksFilter() {
    final filter = _pendingTasksFilter;
    _pendingTasksFilter = null;
    return filter;
  }
}
