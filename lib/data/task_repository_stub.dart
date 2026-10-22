import 'in_memory_task_repository.dart';
import 'task_repository.dart';

/// Web implementation of the conditional import in `task_repository.dart`.
/// sqflite has no Web support, so Web always gets the in-memory fallback.
TaskRepository createTaskRepository() => InMemoryTaskRepository();
