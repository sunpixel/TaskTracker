import 'key_value_store.dart';

/// Persists the refresh token in the platform keychain/keystore — never
/// the access token, which is short-lived and only ever kept in memory
/// (see UserStore). Losing the refresh token just means logging in
/// again; it's not catastrophic, so this stays a thin wrapper rather
/// than something elaborate.
class AuthTokenStore {
  static const _refreshTokenKey = 'refresh_token';

  final KeyValueStore _storage;

  AuthTokenStore({KeyValueStore? storage}) : _storage = storage ?? SecureKeyValueStore();

  Future<String?> readRefreshToken() => _storage.read(_refreshTokenKey);

  Future<void> saveRefreshToken(String token) => _storage.write(_refreshTokenKey, token);

  Future<void> clear() => _storage.delete(_refreshTokenKey);
}
