import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Opens (creating on first run) the local SQLite database used to cache
/// tasks on-device. Native platforms only — see `task_repository.dart`'s
/// conditional import; this file is never pulled into a Web build.
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
    // Renamed from 'task_tracker.db' when the schema changed (single
    // `category` -> `categories`, nullable `due_at`) — sidesteps any
    // ambiguity with a leftover file from the old schema rather than
    // relying on the upgrade path to have run cleanly on every device.
    final dbPath = p.join(dbDir, 'task_tracker_v2.db');

    const createTable = '''
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

    final db = await openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(createTable);
      },
      // Schema is still settling pre-release — no real user data to
      // preserve yet, so upgrades just rebuild the table from scratch
      // rather than carrying a migration chain.
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS tasks');
        await db.execute(createTable);
      },
    );
    _db = db;
    return db;
  }
}
