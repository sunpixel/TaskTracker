import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'widgets/main_scaffold.dart';

void main() {
  runApp(TaskTrackerApp(themeController: ThemeController()));
}

class TaskTrackerApp extends StatelessWidget {
  final ThemeController themeController;

  const TaskTrackerApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'TaskTracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: MainScaffold(themeController: themeController),
        );
      },
    );
  }
}
