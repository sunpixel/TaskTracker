import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/tasks_screen.dart';
import '../theme/theme_controller.dart';

/// App shell: the bottom navigation bar with Home / Tasks / Profile, and
/// the page body for whichever tab is active.
///
/// Uses an [IndexedStack] so switching tabs doesn't rebuild/lose the state
/// of the other tabs (e.g. the selected filter on the Tasks screen).
class MainScaffold extends StatefulWidget {
  final ThemeController themeController;

  const MainScaffold({super.key, required this.themeController});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const TasksScreen(),
      ProfileScreen(themeController: widget.themeController),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
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
    );
  }
}
