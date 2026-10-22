import 'package:flutter/material.dart';

/// Central place for the app's light/dark themes.
///
/// Keeping both themes built off the same seed color so switching between
/// them (see the Profile tab) doesn't jar visually.
class AppTheme {
  AppTheme._();

  static const _seedColor = Colors.indigo;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          height: 64,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          height: 64,
        ),
      );
}
