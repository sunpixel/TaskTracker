import '../l10n/generated/app_localizations.dart';

/// A country's calling code, for splitting a phone number into
/// (country, national number) rather than one opaque formatted string —
/// see `utils/phone_numbers.dart` for why. Mirrors the server's
/// TaskTracker.Domain.Enums.CountryCode exactly, position-for-position
/// (both sides transmit this as a plain integer ordinal) — reordering
/// only one side would silently reassign everyone's country.
///
/// Deliberately just three countries for now, as a testing set.
enum CountryCode {
  unitedStates, // +1
  russia, // +7
  netherlands, // +31
}

extension CountryCodeInfo on CountryCode {
  int get dialCode {
    switch (this) {
      case CountryCode.unitedStates:
        return 1;
      case CountryCode.russia:
        return 7;
      case CountryCode.netherlands:
        return 31;
    }
  }

  /// Display label, localized — see `TaskStatusLabel.label`'s doc
  /// (task_status.dart) for why this takes [l10n] instead of being a
  /// plain getter.
  String label(AppLocalizations l10n) {
    switch (this) {
      case CountryCode.unitedStates:
        return l10n.countryUnitedStates;
      case CountryCode.russia:
        return l10n.countryRussia;
      case CountryCode.netherlands:
        return l10n.countryNetherlands;
    }
  }

  /// A light sanity check, not real validation — see
  /// `utils/phone_numbers.dart`'s doc.
  int get expectedNationalNumberLength {
    switch (this) {
      case CountryCode.unitedStates:
        return 10;
      case CountryCode.russia:
        return 10;
      case CountryCode.netherlands:
        return 9;
    }
  }
}
