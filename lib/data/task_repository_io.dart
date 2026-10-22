import 'sqlite_task_repository.dart';
import 'task_repository.dart';

/// Native implementation of the conditional import in `task_repository.dart`.
/// Selected on every platform with `dart:io` — Android, iOS, macOS,
/// Windows, Linux.
TaskRepository createTaskRepository() => SqliteTaskRepository();
