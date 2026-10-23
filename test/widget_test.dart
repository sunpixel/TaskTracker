import 'package:flutter_test/flutter_test.dart';

import 'package:task_tracker/data/in_memory_task_repository.dart';
import 'package:task_tracker/data/in_memory_user_repository.dart';
import 'package:task_tracker/data/task_store.dart';
import 'package:task_tracker/data/user_store.dart';
import 'package:task_tracker/main.dart';
import 'package:task_tracker/theme/theme_controller.dart';

void main() {
  testWidgets('App starts on Home and can navigate to Tasks and Profile',
      (WidgetTester tester) async {
    // Use the in-memory repositories rather than the real SQLite ones, so
    // this test doesn't depend on a native sqlite3 library being present
    // on the test host.
    await tester.pumpWidget(TaskTrackerApp(
      themeController: ThemeController(),
      taskStore: TaskStore(repository: InMemoryTaskRepository()),
      userStore: UserStore(repository: InMemoryUserRepository()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);

    // Tapped by label text rather than widget type since the bottom bar
    // is a custom AnimatedNavBar, not the stock NavigationBar/Destination.
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('Tasks'), findsWidgets);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Appearance'), findsOneWidget);
  });
}
