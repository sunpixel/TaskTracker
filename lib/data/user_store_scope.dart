import 'package:flutter/widgets.dart';

import 'user_store.dart';

/// Makes a [UserStore] available to the widget tree below it.
class UserStoreScope extends InheritedNotifier<UserStore> {
  const UserStoreScope({
    super.key,
    required UserStore store,
    required super.child,
  }) : super(notifier: store);

  static UserStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<UserStoreScope>();
    assert(scope != null, 'No UserStoreScope found in context');
    return scope!.notifier!;
  }
}
