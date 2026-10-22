import 'package:flutter/material.dart';

import '../navigation/app_nav_controller.dart';
import '../navigation/app_nav_scope.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/tasks_screen.dart';
import '../theme/theme_controller.dart';

/// App shell: the bottom navigation bar with Home / Tasks / Profile, and
/// the page body for whichever tab is active.
///
/// Each tab owns its own [Navigator] (see [_TabNavigator]), so pushing a
/// screen from within a tab (e.g. a task's detail) only replaces that
/// tab's content — this outer [Scaffold], and its bottom nav bar, stay in
/// place. Switching tabs (bottom bar, or a jump from Home) changes
/// [AppNavController.tabIndex] directly and never touches any tab's push
/// stack, which is why it has no back button.
class MainScaffold extends StatefulWidget {
  final ThemeController themeController;

  const MainScaffold({super.key, required this.themeController});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    3,
    (_) => GlobalKey<NavigatorState>(),
  );

  @override
  Widget build(BuildContext context) {
    final nav = AppNavScope.of(context);

    final pages = [
      const HomeScreen(),
      const TasksScreen(),
      ProfileScreen(themeController: widget.themeController),
    ];

    final activeNavigator = _navigatorKeys[nav.tabIndex].currentState;
    final canExitApp =
        nav.tabIndex == 0 && !(activeNavigator?.canPop() ?? false);

    return PopScope(
      canPop: canExitApp,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final navigator = _navigatorKeys[nav.tabIndex].currentState!;
        if (navigator.canPop()) {
          navigator.pop();
        } else if (nav.tabIndex != 0) {
          nav.setTabIndex(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: nav.tabIndex,
          children: [
            for (var i = 0; i < pages.length; i++)
              _TabNavigator(navigatorKey: _navigatorKeys[i], child: pages[i]),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: nav.tabIndex,
          onDestinationSelected: nav.setTabIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps one tab's root page in its own [Navigator], so screens pushed
/// within a tab (e.g. task detail) don't cover the shared bottom nav bar.
class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const _TabNavigator({required this.navigatorKey, required this.child});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => child),
    );
  }
}
