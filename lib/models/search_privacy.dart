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
  String get label {
    switch (this) {
      case SearchPrivacy.allowAll:
        return 'Allow all searches';
      case SearchPrivacy.exactUsernameOnly:
        return 'Exact username only';
      case SearchPrivacy.contactsOrPhoneOnly:
        return 'Contacts/phone only';
    }
  }

  String get description {
    switch (this) {
      case SearchPrivacy.allowAll:
        return 'Anyone can find you by typing part of your username.';
      case SearchPrivacy.exactUsernameOnly:
        return "Only findable if someone types your exact username.";
      case SearchPrivacy.contactsOrPhoneOnly:
        return 'Not findable by username at all — only by your exact phone number.';
    }
  }
}
