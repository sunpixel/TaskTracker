import 'package:flutter/material.dart';

import '../navigation/app_nav_controller.dart';
import '../navigation/app_nav_scope.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/tasks_screen.dart';
import '../theme/theme_controller.dart';
import 'animated_nav_bar.dart';
import 'keep_alive_page.dart';

/// App shell: the bottom navigation bar with Home / Tasks / Profile, and
/// the page body for whichever tab is active.
///
/// Each tab owns its own [Navigator] (see [_TabNavigator]), so pushing a
/// screen from within a tab (e.g. a task's detail) only replaces that
/// tab's content — this outer [Scaffold], and its bottom nav bar, stay in
/// place. Switching tabs (bottom bar, or a jump from Home) changes
/// [AppNavController.tabIndex], which this widget turns into a slide via
/// [PageView] rather than an instant cut — synced directly from [build],
/// scheduling the animation for right after the frame via
/// [WidgetsBinding.addPostFrameCallback] (the standard, reliable way to
/// drive an [AnimationController]/[PageController] off external state).
///
/// Direction: moving to a later tab (Home -> Tasks -> Profile) slides the
/// new one in from the right; moving back slides in from the left —
/// standard paging convention. Flip `reverse` below to `true` to swap
/// which way each direction animates if this ever needs reversing again.
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

  final PageController _pageController = PageController();
  int _displayedIndex = 0;

  static const _items = [
    NavBarItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    NavBarItem(icon: Icons.checklist_outlined, selectedIcon: Icons.checklist, label: 'Tasks'),
    NavBarItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncPageTo(int target) {
    if (target == _displayedIndex) return;
    _displayedIndex = target;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final nav = AppNavScope.of(context);
    _syncPageTo(nav.tabIndex);

    final pages = [
      const HomeScreen(),
      const TasksScreen(),
      ProfileScreen(themeController: widget.themeController),
    ];

    final activeNavigator = _navigatorKeys[nav.tabIndex].currentState;
    final canExitApp = nav.tabIndex == 0 && !(activeNavigator?.canPop() ?? false);

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
        body: PageView(
          controller: _pageController,
          reverse: false,
          // Only ever driven programmatically (from the bottom bar or a
          // Home summary-card jump) — swiping would fight with the
          // horizontal-scrolling filter bar/category chips inside Tasks.
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < pages.length; i++)
              KeepAlivePage(
                child: _TabNavigator(navigatorKey: _navigatorKeys[i], child: pages[i]),
              ),
          ],
        ),
        bottomNavigationBar: AnimatedNavBar(
          selectedIndex: nav.tabIndex,
          items: _items,
          onSelected: nav.setTabIndex,
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
