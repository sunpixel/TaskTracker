import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// `id` is TEXT (a client-generated GUID), not an autoincrement int — it
// has to match the server's id for the same task once synced, and a
// GUID generated offline needs no round-trip to become "real". See
// `models/task.dart`. `updated_at` backs last-write-wins sync merges
// (server_sync_service.dart) and incremental pulls.
const _createTasksTable = '''
  CREATE TABLE tasks (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    created_at INTEGER NOT NULL,
    due_at INTEGER,
    assignee TEXT,
    assigner TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    categories TEXT NOT NULL DEFAULT '[]',
    updated_at INTEGER NOT NULL DEFAULT 0
  )
''';

// `id` is TEXT for the same reason as tasks.id above — a real account id
// once synced from the server, or a locally-generated placeholder id for
// an offline-added contact that isn't a found/real account.
// `is_me` distinguishes the single local "you" row from contact rows —
// not in the originally requested column list, but needed to tell them
// apart within one shared table. No `password` column anymore — auth
// happens against the real backend now (see UserStore), so this table is
// purely a cached profile, never a credential.
// `profile_picture` defaults to NULL rather than a literal default blob —
// the app treats NULL as "show the built-in placeholder icon", which is
// simpler and just as effective as a real stored default image.
const _createUsersTable = '''
  CREATE TABLE users (
    id TEXT PRIMARY KEY,
    user_name TEXT NOT NULL UNIQUE,
    full_name TEXT,
    email TEXT NOT NULL,
    phone TEXT,
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
      version: 4,
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
        if (oldVersion < 4) {
          // Breaking: id columns moved from INTEGER to TEXT (GUIDs) for
          // server sync — no existing local data is salvageable across
          // that type change, so both tables are rebuilt from scratch.
          await db.execute('DROP TABLE IF EXISTS tasks');
          await db.execute(_createTasksTable);
          await db.execute('DROP TABLE IF EXISTS users');
          await db.execute(_createUsersTable);
        }
      },
    );
    _db = db;
    return db;
  }
}
