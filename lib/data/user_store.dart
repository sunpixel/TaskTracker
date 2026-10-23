import 'package:flutter/foundation.dart';

import '../models/user.dart';
import 'user_repository.dart';

/// Reactive view of the local user/contacts data, backed by a
/// [UserRepository].
///
/// There's no backend yet, so "logging in" just checks against a profile
/// created locally on this device (via sign-up) — not a real account
/// system. The session also isn't persisted: [currentUser] always starts
/// `null` on launch, even if a local account already exists, so you log
/// in again each time for now.
class UserStore extends ChangeNotifier {
  UserStore({UserRepository? repository}) : _repository = repository ?? createUserRepository();

  final UserRepository _repository;

  User? _currentUser;
  List<User> _contacts = [];
  bool _isLoading = true;
  String? _authError;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  List<User> get contacts => List.unmodifiable(_contacts);
  bool get isLoading => _isLoading;
  String? get authError => _authError;

  Future<void> load() async {
    _contacts = await _repository.getContacts();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> hasLocalAccount() async => await _repository.getMe() != null;

  Future<bool> login(String userName, String password) async {
    final me = await _repository.getMe();
    if (me == null || me.userName != userName || me.password != password) {
      _authError = 'Incorrect username or password.';
      notifyListeners();
      return false;
    }
    _currentUser = me;
    _authError = null;
    notifyListeners();
    return true;
  }

  /// Creates the local "me" account. Only one is allowed per device —
  /// fails if one already exists (log in instead).
  Future<bool> signUp(User draft) async {
    if (await _repository.getMe() != null) {
      _authError = 'An account already exists on this device — log in instead.';
      notifyListeners();
      return false;
    }
    _currentUser = await _repository.upsertMe(draft);
    _authError = null;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> addContact(User draft) async {
    final created = await _repository.addContact(draft);
    _contacts = [..._contacts, created]..sort((a, b) => a.userName.compareTo(b.userName));
    notifyListeners();
  }

  Future<void> deleteContact(int id) async {
    await _repository.deleteContact(id);
    _contacts = _contacts.where((c) => c.id != id).toList();
    notifyListeners();
  }
}
