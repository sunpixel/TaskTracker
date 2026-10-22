/// Who the task is tied to, relative to the current user.
enum TaskAssignment {
  assignedToMe,
  createdByMe,
}

/// A single task shown in the Tasks list.
///
/// This is a plain in-memory model for now. Once the backend (RabbitMQ on
/// localhost:8022) is wired up, this will likely gain fields like `ownerId`
/// / `assigneeId` and be built from a decoded message payload instead of
/// mock data.
class Task {
  final String id;
  final String title;
  final String description;
  final String category;
  final TaskAssignment assignment;
  final DateTime dueDate;
  final bool completed;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.assignment,
    required this.dueDate,
    this.completed = false,
  });

  Task copyWith({bool? completed}) {
    return Task(
      id: id,
      title: title,
      description: description,
      category: category,
      assignment: assignment,
      dueDate: dueDate,
      completed: completed ?? this.completed,
    );
  }
}
