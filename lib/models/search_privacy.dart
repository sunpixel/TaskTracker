import '../l10n/generated/app_localizations.dart';

/// Who can find this account via username/phone search. Mirrors the
/// server's TaskTracker.Domain.Enums.SearchPrivacy exactly,
/// position-for-position — both sides transmit this as a plain integer
/// ordinal (see User.fromServerJson/toServerJson below), so reordering
/// only one side would silently misinterpret every account's setting.
enum SearchPrivacy {
  /// Findable by any partial/substring username match.
  allowAll,

  /// Only findable by typing the *exact* username. The default for new
  /// accounts.
  exactUsernameOnly,

  /// Invisible to username search entirely — only findable by an exact
  /// phone-number match, and only if a phone number is on file.
  contactsOrPhoneOnly,
}

extension SearchPrivacyLabel on SearchPrivacy {
  /// Display label, localized — see `TaskStatusLabel.label`'s doc for
  /// why this takes [l10n] instead of being a plain getter.
  String label(AppLocalizations l10n) {
    switch (this) {
      case SearchPrivacy.allowAll:
        return l10n.privacyAllowAllLabel;
      case SearchPrivacy.exactUsernameOnly:
        return l10n.privacyExactUsernameLabel;
      case SearchPrivacy.contactsOrPhoneOnly:
        return l10n.privacyContactsPhoneLabel;
    }
  }

  String description(AppLocalizations l10n) {
    switch (this) {
      case SearchPrivacy.allowAll:
        return l10n.privacyAllowAllDescription;
      case SearchPrivacy.exactUsernameOnly:
        return l10n.privacyExactUsernameDescription;
      case SearchPrivacy.contactsOrPhoneOnly:
        return l10n.privacyContactsPhoneDescription;
    }
  }
}
