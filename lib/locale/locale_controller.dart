import 'package:flutter/material.dart';

/// Holds the app's language override and notifies listeners when it
/// changes, so the Profile screen can set it and the root [MaterialApp]
/// can react — mirrors `ThemeController`'s shape exactly.
///
/// `null` means "follow the system language" — [MaterialApp.locale] is
/// then left `null` too, which makes Flutter resolve the device's own
/// locale against `supportedLocales` itself (falling back to English if
/// the device isn't set to one of the supported languages). Resets to
/// `null` on every launch, same as `ThemeController` resets to
/// `ThemeMode.system` — no persistence yet.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController() : super(null);

  void setLocale(Locale? locale) => value = locale;
}
