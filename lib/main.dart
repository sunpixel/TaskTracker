import 'package:flutter/material.dart';

import 'data/task_store.dart';
import 'data/task_store_scope.dart';
import 'data/user_store.dart';
import 'data/user_store_scope.dart';
import 'navigation/app_nav_controller.dart';
import 'navigation/app_nav_scope.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'widgets/main_scaffold.dart';

void main() {
  runApp(TaskTrackerApp(themeController: ThemeController()));
}

class TaskTrackerApp extends StatefulWidget {
  final ThemeController themeController;

  /// Overridable for tests, so they don't hit the real SQLite path or
  /// the real backend.
  final TaskStore? taskStore;
  final UserStore? userStore;

  const TaskTrackerApp({
    super.key,
    required this.themeController,
    this.taskStore,
    this.userStore,
  });

  @override
  State<TaskTrackerApp> createState() => _TaskTrackerAppState();
}

class _TaskTrackerAppState extends State<TaskTrackerApp> {
  // UserStore first: TaskStore needs it (effectiveUserId, login state)
  // to load correctly, so it must already exist by the time TaskStore's
  // own `late` initializer runs.
  late final UserStore _userStore = widget.userStore ?? UserStore();
  late final TaskStore _taskStore = widget.taskStore ?? TaskStore(userStore: _userStore);
  final AppNavController _navController = AppNavController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // UserStore resolves the local device id and restores a session (if
    // a stored refresh token is still valid) before TaskStore loads —
    // TaskStore needs that to know whether to seed demo data and who
    // "effectively" owns any task it creates.
    await _userStore.load();
    await _taskStore.load();
    _initNotifications();
  }

  /// Best-effort — a missing platform implementation (e.g. under
  /// `flutter test`, which has no plugin channel mocked) must never
  /// block the rest of the app from starting.
  Future<void> _initNotifications() async {
    try {
      await NotificationService.instance.initialize();
      await NotificationService.instance.requestPermissions();
    } catch (_) {
      // See above.
    }
  }

  @override
  Widget build(BuildContext context) {
    return TaskStoreScope(
      store: _taskStore,
      child: UserStoreScope(
        store: _userStore,
        child: AppNavScope(
          controller: _navController,
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: widget.themeController,
            builder: (context, mode, _) {
              return MaterialApp(
                title: 'TaskTracker',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: mode,
                home: MainScaffold(themeController: widget.themeController),
              );
            },
          ),
        ),
      ),
    );
  }
}
