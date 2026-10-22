import 'package:flutter/material.dart';

/// Holds the app's current [ThemeMode] and notifies listeners when it
/// changes, so the Profile screen can flip it and the root [MaterialApp]
/// can react.
///
/// No persistence yet (resets to [ThemeMode.system] on every launch) —
/// that can be added later with e.g. shared_preferences once we decide
/// where settings should live relative to the backend.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  void setMode(ThemeMode mode) => value = mode;

  void toggleLightDark() {
    value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
