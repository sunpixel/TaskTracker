import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _createTasksTable = '''
  CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    created_at INTEGER NOT NULL,
    due_at INTEGER,
    assignee TEXT,
    assigner TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    categories TEXT NOT NULL DEFAULT '[]'
  )
''';

// `is_me` distinguishes the single local "you" row from contact rows —
// not in the originally requested column list, but needed to tell them
// apart within one shared table. `password` is nullable here even though
// it's required for your own account: that's enforced by the sign-up
// form, not the schema, since a contact row should never hold one.
// `profile_picture` defaults to NULL rather than a literal default blob —
// the app treats NULL as "show the built-in placeholder icon", which is
// simpler and just as effective as a real stored default image.
const _createUsersTable = '''
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_name TEXT NOT NULL UNIQUE,
    full_name TEXT,
    email TEXT NOT NULL,
    phone TEXT,
    password TEXT,
    profile_picture BLOB,
    description TEXT,
    is_me INTEGER NOT NULL DEFAULT 0
  )
''';

/// Opens (creating on first run) the local SQLite database used to cache
/// tasks and local user/contact data on-device. Native platforms only —
/// see `task_repository.dart`/`user_repository.dart`'s conditional
/// imports; this file is never pulled into a Web build.
class AppDatabase {
  AppDatabase._();

  static Database? _db;

  static Future<Database> instance() async {
    final existing = _db;
    if (existing != null) return existing;

    // sqflite's own plugin covers Android/iOS/macOS directly. Windows and
    // Linux have no platform-channel implementation, so route through
    // sqflite_common_ffi (dart:ffi, no plugin needed) instead.
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbDir = await getDatabasesPath();
    // Renamed from 'task_tracker.db' when the task schema changed (single
    // `category` -> `categories`, nullable `due_at`) — sidesteps any
    // ambiguity with a leftover file from the old schema rather than
    // relying on the upgrade path to have run cleanly on every device.
    final dbPath = p.join(dbDir, 'task_tracker_v2.db');

    final db = await openDatabase(
      dbPath,
      version: 3,
      onCreate: (db, version) async {
        await db.execute(_createTasksTable);
        await db.execute(_createUsersTable);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Schema was still settling pre-release — no real task data to
          // preserve from this far back, so just rebuild it.
          await db.execute('DROP TABLE IF EXISTS tasks');
          await db.execute(_createTasksTable);
        }
        if (oldVersion < 3) {
          // Purely additive — existing task data is left alone.
          await db.execute(_createUsersTable);
        }
      },
    );
    _db = db;
    return db;
  }
}
