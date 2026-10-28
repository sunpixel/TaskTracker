import 'dart:typed_data';

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
/// [profilePicture] being `null` means "show the default placeholder
/// icon", not literally an empty image.
class User {
  final String id;
  final String userName;
  final String? fullName;
  final String email;
  final String? phone;
  final Uint8List? profilePicture;
  final String? description;
  final bool isMe;

  const User({
    required this.id,
    required this.userName,
    this.fullName,
    required this.email,
    this.phone,
    this.profilePicture,
    this.description,
    this.isMe = false,
  });

  User copyWith({bool? isMe}) => User(
        id: id,
        userName: userName,
        fullName: fullName,
        email: email,
        phone: phone,
        profilePicture: profilePicture,
        description: description,
        isMe: isMe ?? this.isMe,
      );

  /// Display name: full name if given, otherwise the username.
  String get displayName => (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : userName;

  Map<String, Object?> toMap() => {
        'id': id,
        'user_name': userName,
        'full_name': fullName,
        'email': email,
        'phone': phone,
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
        profilePicture: map['profile_picture'] as Uint8List?,
        description: map['description'] as String?,
        isMe: (map['is_me'] as int? ?? 0) == 1,
      );

  /// Maps the server's user DTO (`UserSummaryDto`) to a local [User].
  factory User.fromServerJson(Map<String, dynamic> json, {bool isMe = false}) => User(
        id: json['id'] as String,
        userName: json['userName'] as String,
        fullName: json['fullName'] as String?,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        description: json['description'] as String?,
        isMe: isMe,
      );
}
