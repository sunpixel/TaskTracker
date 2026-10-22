import 'package:flutter/material.dart';

import 'data/task_store.dart';
import 'data/task_store_scope.dart';
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

  const TaskTrackerApp({super.key, required this.themeController, this.taskStore});

  @override
  State<TaskTrackerApp> createState() => _TaskTrackerAppState();
}

class _TaskTrackerAppState extends State<TaskTrackerApp> {
  late final TaskStore _taskStore = widget.taskStore ?? TaskStore();
  final AppNavController _navController = AppNavController();

  @override
  void initState() {
    super.initState();
    _taskStore.load();
  }

  @override
  Widget build(BuildContext context) {
    return TaskStoreScope(
      store: _taskStore,
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
    );
  }
}
