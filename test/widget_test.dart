import 'package:flutter_test/flutter_test.dart';

import 'package:task_tracker/data/in_memory_task_repository.dart';
import 'package:task_tracker/data/in_memory_user_repository.dart';
import 'package:task_tracker/data/task_store.dart';
import 'package:task_tracker/data/user_store.dart';
import 'package:task_tracker/main.dart';
import 'package:task_tracker/services/auth_token_store.dart';
import 'package:task_tracker/services/key_value_store.dart';
import 'package:task_tracker/services/local_identity.dart';
import 'package:task_tracker/theme/theme_controller.dart';

void main() {
  testWidgets('App starts on Home and can navigate to Tasks and Profile',
      (WidgetTester tester) async {
    // In-memory repositories/storage rather than the real SQLite DB or
    // secure storage, so this test doesn't depend on native plugin
    // channels that aren't mocked under `flutter test` (sqflite,
    // flutter_secure_storage). No server call happens either: UserStore
    // only calls the API when a stored refresh token exists, and this
    // store starts with none — logged-out stays fully offline, by design.
    final userStore = UserStore(
      repository: InMemoryUserRepository(),
      tokenStore: AuthTokenStore(storage: InMemoryKeyValueStore()),
      localIdentity: LocalIdentity(storage: InMemoryKeyValueStore()),
    );

    await tester.pumpWidget(TaskTrackerApp(
      themeController: ThemeController(),
      taskStore: TaskStore(userStore: userStore, repository: InMemoryTaskRepository()),
      userStore: userStore,
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
