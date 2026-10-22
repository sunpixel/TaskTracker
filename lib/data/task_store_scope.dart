import 'package:flutter/widgets.dart';

import 'task_store.dart';

/// Makes a [TaskStore] available to the widget tree below it, rebuilding
/// dependents whenever the store notifies (new data loaded, a task's
/// status changed, etc.).
class TaskStoreScope extends InheritedNotifier<TaskStore> {
  const TaskStoreScope({
    super.key,
    required TaskStore store,
    required super.child,
  }) : super(notifier: store);

  static TaskStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TaskStoreScope>();
    assert(scope != null, 'No TaskStoreScope found in context');
    return scope!.notifier!;
  }
}
