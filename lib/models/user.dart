import 'dart:typed_data';

/// A locally-known person: either "me" (the logged-in local profile, if
/// any) or a contact you've added/communicated with (e.g. someone who
/// assigned you a task). Both shapes share this one table/model —
/// [isMe] tells them apart.
///
/// [password] only ever has a real value for your own account — a
/// contact's password is never something this app should know or store.
/// [profilePicture] being `null` means "show the default placeholder
/// icon", not literally an empty image.
class User {
  final int? id;
  final String userName;
  final String? fullName;
  final String email;
  final String? phone;
  final String? password;
  final Uint8List? profilePicture;
  final String? description;
  final bool isMe;

  const User({
    this.id,
    required this.userName,
    this.fullName,
    required this.email,
    this.phone,
    this.password,
    this.profilePicture,
    this.description,
    this.isMe = false,
  });

  User withId(int newId) => User(
        id: newId,
        userName: userName,
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        profilePicture: profilePicture,
        description: description,
        isMe: isMe,
      );

  User copyWith({bool? isMe}) => User(
        id: id,
        userName: userName,
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        profilePicture: profilePicture,
        description: description,
        isMe: isMe ?? this.isMe,
      );

  /// Display name: full name if given, otherwise the username.
  String get displayName => (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : userName;

  Map<String, Object?> toMap() => {
        'user_name': userName,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'profile_picture': profilePicture,
        'description': description,
        'is_me': isMe ? 1 : 0,
      };

  factory User.fromMap(Map<String, Object?> map) => User(
        id: map['id'] as int?,
        userName: map['user_name'] as String,
        fullName: map['full_name'] as String?,
        email: map['email'] as String,
        phone: map['phone'] as String?,
        password: map['password'] as String?,
        profilePicture: map['profile_picture'] as Uint8List?,
        description: map['description'] as String?,
        isMe: (map['is_me'] as int? ?? 0) == 1,
      );
}
