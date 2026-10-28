import 'package:uuid/uuid.dart';

import 'key_value_store.dart';

/// A stable, per-device id generated once and persisted, used as the
/// "current user" for task bucketing/ownership when nobody is logged in
/// — exactly the role the old hardcoded `currentUserId` placeholder used
/// to serve, except real now that accounts exist: once you log in, your
/// real server-issued user id takes over as the effective identity (see
/// UserStore.effectiveUserId), and this is only ever used offline.
///
/// Never sent to the server — it has no meaning there.
class LocalIdentity {
  static const _key = 'local_device_id';

  final KeyValueStore _storage;

  LocalIdentity({KeyValueStore? storage}) : _storage = storage ?? SecureKeyValueStore();

  Future<String> getOrCreate() async {
    final existing = await _storage.read(_key);
    if (existing != null) return existing;
    final generated = const Uuid().v4();
    await _storage.write(_key, generated);
    return generated;
  }
}
