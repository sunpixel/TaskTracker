import 'package:flutter/material.dart';

import 'data/task_store.dart';
import 'data/task_store_scope.dart';
import 'data/user_store.dart';
import 'data/user_store_scope.dart';
import 'navigation/app_nav_controller.dart';
import 'navigation/app_nav_scope.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'widgets/main_scaffold.dart';

void main() {
  runApp(TaskTrackerApp(themeController: ThemeController()));
}

class TaskTrackerApp extends StatefulWidget {
  final ThemeController themeController;

  /// Overridable for tests, so they don't hit the real SQLite path.
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
  late final TaskStore _taskStore = widget.taskStore ?? TaskStore();
  late final UserStore _userStore = widget.userStore ?? UserStore();
  final AppNavController _navController = AppNavController();

  @override
  void initState() {
    super.initState();
    _taskStore.load();
    _userStore.load();
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
