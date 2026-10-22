import 'dart:convert';

import '../data/current_user.dart';
import 'task_status.dart';

/// How a task relates to the current user. Derived from [Task.assignee]/
/// [Task.assigner] rather than stored — see [Task.assignment].
enum TaskAssignment {
  assignedToMe,
  mine,
}

/// A single task.
///
/// [assignee] and [assigner] are plain ids (currently just `'me'` or a
/// placeholder name like `'alex'` — there's no real multi-user backend
/// yet). They already drive the Home/Tasks "Assigned to me" vs "Mine"
/// split, the completion-permission rules in `task_permissions.dart`, and
/// who's allowed to edit a task at all (its assigner, only).
class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;

  /// Optional — a task can exist with no due date at all. When set, it
  /// must be at least a minute after [createdAt]; see `task_validators.dart`.
  final DateTime? dueAt;

  final String? assignee;
  final String? assigner;
  final TaskStatus status;
  final List<String> categories;

  const Task({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueAt,
    this.assignee,
    this.assigner,
    required this.status,
    this.categories = const [],
  });

  bool get isCompleted => status == TaskStatus.completed;

  bool get isOverdue {
    final due = dueAt;
    return due != null && !isCompleted && due.isBefore(DateTime.now());
  }

  /// Whether the current user is this task's assignee, its assigner, both
  /// (a self-made task), or neither.
  TaskAssignment get assignment {
    if (assignee == currentUserId && assigner != currentUserId) {
      return TaskAssignment.assignedToMe;
    }
    return TaskAssignment.mine;
  }

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueAt,
    bool clearDueAt = false,
    String? assignee,
    String? assigner,
    TaskStatus? status,
    List<String>? categories,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      assignee: assignee ?? this.assignee,
      assigner: assigner ?? this.assigner,
      status: status ?? this.status,
      categories: categories ?? this.categories,
    );
  }

  Task withId(int newId) => Task(
        id: newId,
        title: title,
        description: description,
        createdAt: createdAt,
        dueAt: dueAt,
        assignee: assignee,
        assigner: assigner,
        status: status,
        categories: categories,
      );

  Map<String, Object?> toMap() => {
        'title': title,
        'description': description,
        'created_at': createdAt.millisecondsSinceEpoch,
        'due_at': dueAt?.millisecondsSinceEpoch,
        'assignee': assignee,
        'assigner': assigner,
        'status': status.name,
        // Stored as JSON rather than a delimiter-joined string so a
        // category name can contain any character, including a comma.
        'categories': jsonEncode(categories),
      };

  factory Task.fromMap(Map<String, Object?> map) {
    final dueAtMs = map['due_at'] as int?;
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      dueAt: dueAtMs == null ? null : DateTime.fromMillisecondsSinceEpoch(dueAtMs),
      assignee: map['assignee'] as String?,
      assigner: map['assigner'] as String?,
      status: TaskStatus.values.byName(map['status'] as String),
      categories: _parseCategories(map['categories']),
    );
  }

  /// Tolerant parsing of the `categories` column: anything other than a
  /// well-formed JSON array of strings (missing column from an old schema,
  /// a stray literal `null`, a corrupt value, ...) just becomes `[]`
  /// rather than crashing the whole task list.
  static List<String> _parseCategories(Object? raw) {
    if (raw is! String) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.whereType<String>().toList();
    } catch (_) {
      // Fall through to the empty-list default below.
    }
    return const [];
  }
}
