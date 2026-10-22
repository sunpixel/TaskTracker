import 'package:flutter/widgets.dart';

import 'app_nav_controller.dart';

/// Makes an [AppNavController] available to the widget tree below it.
class AppNavScope extends InheritedNotifier<AppNavController> {
  const AppNavScope({
    super.key,
    required AppNavController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppNavController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppNavScope>();
    assert(scope != null, 'No AppNavScope found in context');
    return scope!.notifier!;
  }
}
