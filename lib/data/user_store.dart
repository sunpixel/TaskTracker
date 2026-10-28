import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_token_store.dart';
import '../services/local_identity.dart';
import 'user_repository.dart';

/// Reactive view of your own profile and your contacts.
///
/// Authentication is now real — against the backend, via [ApiClient] —
/// rather than the local-only placeholder it used to be. [UserRepository]
/// (local SQLite) still caches your profile and contacts for offline
/// display, but it's a cache now, never the source of truth for
/// identity; the server is.
class UserStore extends ChangeNotifier {
  UserStore({
    UserRepository? repository,
    ApiClient? apiClient,
    AuthTokenStore? tokenStore,
    LocalIdentity? localIdentity,
  })  : _repository = repository ?? createUserRepository(),
        _api = apiClient ?? ApiClient(),
        _tokenStore = tokenStore ?? AuthTokenStore(),
        _localIdentity = localIdentity ?? LocalIdentity();

  final UserRepository _repository;
  final ApiClient _api;
  final AuthTokenStore _tokenStore;
  final LocalIdentity _localIdentity;

  User? _currentUser;
  String? _accessToken;
  List<User> _contacts = [];
  bool _isLoading = true;
  String? _authError;
  String _localDeviceId = '';

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  List<User> get contacts => List.unmodifiable(_contacts);
  bool get isLoading => _isLoading;
  String? get authError => _authError;
  String? get accessToken => _accessToken;

  /// Whoever is effectively "you" right now, for task
  /// ownership/filtering: your real account id if logged in, otherwise a
  /// stable id unique to this device/install (never sent to the server).
  String get effectiveUserId => _currentUser?.id ?? _localDeviceId;

  /// Resolves the local device id and tries to restore a session from a
  /// stored refresh token, so you're not forced to log in again every
  /// launch as long as it's still valid.
  Future<void> load() async {
    _localDeviceId = await _localIdentity.getOrCreate();
    _contacts = await _repository.getContacts();

    final storedRefreshToken = await _tokenStore.readRefreshToken();
    if (storedRefreshToken != null) {
      try {
        await _applyAuthResponse(await _api.refresh(refreshToken: storedRefreshToken));
      } catch (_) {
        // Stale/expired/revoked refresh token — routine, not an error
        // worth surfacing. Just stay logged out.
        await _tokenStore.clear();
        _currentUser = null;
      }
    }

    _isLoading = false;
    notifyListeners();

    if (isLoggedIn) {
      // Fire-and-forget — don't make a slow network hold up startup;
      // cached contacts are already loaded above.
      pullContactsFromServer();
    }
  }

  Future<bool> login(String userName, String password) async {
    try {
      await _applyAuthResponse(await _api.login(userName: userName, password: password));
      _authError = null;
      notifyListeners();
      pullContactsFromServer();
      return true;
    } catch (e) {
      _authError = _messageFor(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String userName,
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      await _applyAuthResponse(await _api.signup(
        userName: userName,
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      ));
      _authError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _authError = _messageFor(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken != null) {
      try {
        await _api.logout(refreshToken: refreshToken);
      } catch (_) {
        // Best-effort — local logout proceeds regardless of whether the
        // server could revoke it right now.
      }
    }
    await _tokenStore.clear();
    await _repository.clearMe();
    _currentUser = null;
    _accessToken = null;
    notifyListeners();
  }

  /// Returns a currently-valid access token for an authenticated
  /// request, refreshing first. Call this right before every
  /// server-bound request rather than reading [accessToken] directly —
  /// access tokens are short-lived (30 min) and there's no cheap way to
  /// check expiry without decoding the JWT, so this always refreshes
  /// rather than guessing whether the cached one is still good. Returns
  /// `null` if there's no session (not logged in) or the refresh token
  /// turned out to be invalid (in which case this also logs you out).
  Future<String?> ensureFreshAccessToken() async {
    if (!isLoggedIn) return null;
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null) {
      await logout();
      return null;
    }
    try {
      await _applyAuthResponse(await _api.refresh(refreshToken: refreshToken));
      notifyListeners();
      return _accessToken;
    } catch (_) {
      await logout();
      return null;
    }
  }

  Future<void> _applyAuthResponse(Map<String, dynamic> json) async {
    _accessToken = json['accessToken'] as String;
    await _tokenStore.saveRefreshToken(json['refreshToken'] as String);

    final meJson = await _api.getMe(accessToken: _accessToken!);
    final me = User.fromServerJson(meJson, isMe: true);
    _currentUser = me;
    await _repository.upsertMe(me);
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 401) return 'Incorrect username or password.';
      if (error.statusCode == 409) return 'Username or email is already taken.';
      return error.message;
    }
    return 'Could not reach the server. Check your connection and try again.';
  }

  // --- Contacts ---

  Future<List<User>> searchUsers(String query) async {
    final trimmed = query.trim();
    if (!isLoggedIn || trimmed.isEmpty) return [];
    final token = await ensureFreshAccessToken();
    if (token == null) return [];
    try {
      final results = await _api.searchUsers(accessToken: token, username: trimmed);
      return results.cast<Map<String, dynamic>>().map(User.fromServerJson).toList();
    } catch (_) {
      return [];
    }
  }

  /// Adds a contact by looking them up on the server by username.
  /// Throws [ApiException] (404) if logged in but the server doesn't
  /// recognize that username — callers should fall back to
  /// [addLocalPlaceholderContact] for that case. Throws [StateError] if
  /// not logged in at all.
  Future<void> addRealContact(String username) async {
    if (!isLoggedIn) throw StateError('Must be logged in to add a real contact.');
    final token = await ensureFreshAccessToken();
    if (token == null) throw StateError('Session expired.');
    final json = await _api.addContact(accessToken: token, contactUserName: username);
    final contact = User.fromServerJson(json);
    await _repository.upsertContact(contact);
    _contacts = [..._contacts.where((c) => c.id != contact.id), contact]
      ..sort((a, b) => a.userName.compareTo(b.userName));
    notifyListeners();
  }

  /// Adds a contact that only exists locally — for someone not on the
  /// app yet, or while offline/logged out. Never synced to the server.
  Future<void> addLocalPlaceholderContact(User contact) async {
    await _repository.upsertContact(contact);
    _contacts = [..._contacts, contact]..sort((a, b) => a.userName.compareTo(b.userName));
    notifyListeners();
  }

  Future<void> deleteContact(String id) async {
    if (isLoggedIn) {
      final token = await ensureFreshAccessToken();
      if (token != null) {
        try {
          await _api.removeContact(accessToken: token, contactId: id);
        } catch (_) {
          // If this was only ever a local placeholder, the server never
          // knew about it anyway — removing it locally below is still
          // correct either way.
        }
      }
    }
    await _repository.deleteContact(id);
    _contacts = _contacts.where((c) => c.id != id).toList();
    notifyListeners();
  }

  /// Refreshes the local contacts cache from the server. Additive only —
  /// never removes a local-only placeholder contact the server doesn't
  /// know about.
  Future<void> pullContactsFromServer() async {
    if (!isLoggedIn) return;
    final token = await ensureFreshAccessToken();
    if (token == null) return;
    try {
      final results = await _api.getContacts(accessToken: token);
      for (final json in results.cast<Map<String, dynamic>>()) {
        await _repository.upsertContact(User.fromServerJson(json));
      }
      _contacts = await _repository.getContacts();
      notifyListeners();
    } catch (_) {
      // Best-effort — keep whatever's already cached locally.
    }
  }
}
