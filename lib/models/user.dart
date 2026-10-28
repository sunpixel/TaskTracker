import 'dart:typed_data';

import 'country_code.dart';
import 'search_privacy.dart';

/// A locally-known person: either "me" (your cached profile, if logged
/// in) or a contact. Both shapes share this one table/model — [isMe]
/// tells them apart.
///
/// [id] is a real server-issued account id for anyone fetched from the
/// backend (your own profile once logged in, or a contact found via
/// `/users/search`), or a locally-generated placeholder id for a contact
/// added while offline/not found on the server — see
/// `AddContactDialog`/`UserStore.addContact`.
///
/// No password field — now that there's a real backend, auth happens
/// there (see `ApiClient`/`UserStore`); this model is just a cached
/// profile, never a credential.
///
/// [phone] is digits-only (the national number, no dial code, no
/// formatting) — [countryCode] holds the dial code half. See
/// `utils/input_validators.dart` / the server's `PhoneNumbers` for why
/// phone numbers are split this way.
///
/// [profilePicture] being `null` means "show the default placeholder
/// icon", not literally an empty image.
///
/// [searchPrivacy] is only ever populated for "me" — the server only
/// exposes it on `GET /users/me`, never on a contact/search result (it's
/// nobody else's business). It's `null` for every contact.
class User {
  final String id;
  final String userName;
  final String? fullName;
  final String email;
  final String? phone;
  final CountryCode? countryCode;
  final Uint8List? profilePicture;
  final String? description;
  final bool isMe;
  final SearchPrivacy? searchPrivacy;

  const User({
    required this.id,
    required this.userName,
    this.fullName,
    required this.email,
    this.phone,
    this.countryCode,
    this.profilePicture,
    this.description,
    this.isMe = false,
    this.searchPrivacy,
  });

  User copyWith({bool? isMe, SearchPrivacy? searchPrivacy}) => User(
        id: id,
        userName: userName,
        fullName: fullName,
        email: email,
        phone: phone,
        countryCode: countryCode,
        profilePicture: profilePicture,
        description: description,
        isMe: isMe ?? this.isMe,
        searchPrivacy: searchPrivacy ?? this.searchPrivacy,
      );

  /// Display name: full name if given, otherwise the username.
  String get displayName => (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : userName;

  /// A human-readable "+(dial code) (national number)" — not fully
  /// formatted the way a real phone-number library would (no per-country
  /// grouping of digits), just dial code + digits.
  String? get formattedPhone {
    if (phone == null) return null;
    final dial = countryCode?.dialCode;
    return dial == null ? phone : '+$dial $phone';
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'user_name': userName,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'country_code': countryCode?.index,
        'profile_picture': profilePicture,
        'description': description,
        'is_me': isMe ? 1 : 0,
      };

  factory User.fromMap(Map<String, Object?> map) => User(
        id: map['id'] as String,
        userName: map['user_name'] as String,
        fullName: map['full_name'] as String?,
        email: map['email'] as String,
        phone: map['phone'] as String?,
        countryCode: map['country_code'] == null ? null : CountryCode.values[map['country_code'] as int],
        profilePicture: map['profile_picture'] as Uint8List?,
        description: map['description'] as String?,
        isMe: (map['is_me'] as int? ?? 0) == 1,
        // searchPrivacy isn't persisted locally — only ever relevant
        // while online and only for "me"; re-fetched from the server
        // each time it matters rather than cached.
      );

  /// Maps the server's user DTO (`UserSummaryDto`, or `MeDto` when this
  /// is your own profile) to a local [User].
  factory User.fromServerJson(Map<String, dynamic> json, {bool isMe = false}) => User(
        id: json['id'] as String,
        userName: json['userName'] as String,
        fullName: json['fullName'] as String?,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        countryCode: json['countryCode'] == null ? null : CountryCode.values[json['countryCode'] as int],
        description: json['description'] as String?,
        isMe: isMe,
        searchPrivacy: json['searchPrivacy'] == null ? null : SearchPrivacy.values[json['searchPrivacy'] as int],
      );
}
