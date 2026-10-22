import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_tracker/main.dart';
import 'package:task_tracker/theme/theme_controller.dart';

void main() {
  testWidgets('App starts on Home and can navigate to Tasks and Profile',
      (WidgetTester tester) async {
    await tester.pumpWidget(TaskTrackerApp(themeController: ThemeController()));

    expect(find.text('Home'), findsWidgets);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('Tasks'), findsWidgets);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Appearance'), findsOneWidget);
  });
}
