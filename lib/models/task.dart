import 'dart:convert';

import 'task_status.dart';

/// How a task relates to a given user. Derived from [Task.assignee]/
/// [Task.assigner] rather than stored — see [Task.assignmentFor].
enum TaskAssignment {
  assignedToMe,
  mine,
}

/// A single task.
///
/// [id] is a client-generated GUID (via the `uuid` package, at the point
/// a new task is drafted — see `task_detail_screen.dart`), not a
/// database auto-increment — this is what lets two offline devices each
/// create tasks without colliding, and matches the same field on the
/// server (TaskTrackerServer's `TaskItem.Id`).
///
/// [assignee]/[assigner] hold user ids — either a real server-issued
/// account id (once logged in) or the local per-device id (see
/// `LocalIdentity`) for anything created while offline.
class Task {
  final String id;
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

  /// Last-write-wins timestamp — compared against the server's copy of
  /// the same id during sync (see `server_sync_service.dart`) to decide
  /// which side is newer. Defaults to [createdAt] for a brand new task.
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueAt,
    this.assignee,
    this.assigner,
    required this.status,
    this.categories = const [],
    required this.updatedAt,
  });

  bool get isCompleted => status == TaskStatus.completed;

  bool get isOverdue {
    final due = dueAt;
    return due != null && !isCompleted && due.isBefore(DateTime.now());
  }

  /// Whether [currentUserId] is this task's assignee, its assigner, both
  /// (a self-made task), or neither.
  TaskAssignment assignmentFor(String currentUserId) {
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
    DateTime? updatedAt,
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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
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
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory Task.fromMap(Map<String, Object?> map) {
    final dueAtMs = map['due_at'] as int?;
    final updatedAtMs = map['updated_at'] as int?;
    final createdAt = DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int);
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      createdAt: createdAt,
      dueAt: dueAtMs == null ? null : DateTime.fromMillisecondsSinceEpoch(dueAtMs),
      assignee: map['assignee'] as String?,
      assigner: map['assigner'] as String?,
      status: TaskStatus.values.byName(map['status'] as String),
      categories: _parseCategories(map['categories']),
      updatedAt: updatedAtMs == null ? createdAt : DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    );
  }

  /// Maps the server's JSON task DTO (TaskTrackerServer's `TaskDto`) to a
  /// local [Task]. Server fields are PascalCase-serialized-as-camelCase
  /// by ASP.NET Core's default JSON naming, and the status comes back as
  /// an integer enum ordinal (matching `TaskTracker.Domain.Enums.TaskStatus`'s
  /// declaration order) rather than a name string.
  factory Task.fromServerJson(Map<String, dynamic> json) {
    final dueAtRaw = json['dueAt'] as String?;
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      dueAt: dueAtRaw == null ? null : DateTime.parse(dueAtRaw).toLocal(),
      assignee: json['assigneeId'] as String?,
      assigner: json['assignerId'] as String,
      status: TaskStatus.values[json['status'] as int],
      categories: (json['categories'] as List).cast<String>(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }

  /// Whether the server considers this task deleted — only meaningful on
  /// a [Task] built straight from `fromServerJson`'s source map, since
  /// the server's DTO carries `deletedAt` but the local model has no use
  /// for a tombstone once a device has actually removed its local copy.
  static bool isDeletedInServerJson(Map<String, dynamic> json) => json['deletedAt'] != null;

  /// What the server's write endpoints (POST/PUT /tasks) expect in their
  /// request body — deliberately excludes [id] (goes in the URL/request
  /// shape separately) and never includes [assigner] — the server fixes
  /// that from the authenticated caller on create and never lets it
  /// change on update, so sending it at all would be misleading.
  Map<String, dynamic> toServerRequestBody() => {
        'title': title,
        'description': description,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'dueAt': dueAt?.toUtc().toIso8601String(),
        'assigneeId': assignee,
        'status': status.index,
        'categories': categories,
      };

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
