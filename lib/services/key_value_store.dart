import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin abstraction over secure key-value storage, purely so tests can
/// inject [InMemoryKeyValueStore] instead of [SecureKeyValueStore] —
/// `flutter_secure_storage`'s platform channel isn't mocked under
/// `flutter test`, the same issue sqflite/flutter_local_notifications
/// have there.
abstract class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureKeyValueStore implements KeyValueStore {
  final FlutterSecureStorage _storage;

  SecureKeyValueStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);
}
