import '../models/task.dart';

/// Placeholder data so the UI has something to render before the backend
/// is connected. Safe to delete once real data comes from RabbitMQ.
final List<Task> mockTasks = [
  Task(
    id: '1',
    title: 'Review pull request',
    description: 'Check the new auth flow before merging.',
    category: 'Work',
    assignment: TaskAssignment.assignedToMe,
    dueDate: DateTime.now().add(const Duration(days: 1)),
  ),
  Task(
    id: '2',
    title: 'Buy groceries',
    description: 'Milk, eggs, bread, and coffee.',
    category: 'Personal',
    assignment: TaskAssignment.createdByMe,
    dueDate: DateTime.now().add(const Duration(hours: 5)),
  ),
  Task(
    id: '3',
    title: 'Prepare sprint report',
    description: 'Summarize velocity and blockers for the team sync.',
    category: 'Work',
    assignment: TaskAssignment.createdByMe,
    dueDate: DateTime.now().add(const Duration(days: 2)),
  ),
  Task(
    id: '4',
    title: 'Book dentist appointment',
    description: 'Try to get a slot next week.',
    category: 'Health',
    assignment: TaskAssignment.createdByMe,
    dueDate: DateTime.now().add(const Duration(days: 3)),
  ),
  Task(
    id: '5',
    title: 'Fix login bug',
    description: 'Users get logged out after 5 minutes of inactivity.',
    category: 'Work',
    assignment: TaskAssignment.assignedToMe,
    dueDate: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Task(
    id: '6',
    title: 'Plan weekend trip',
    description: 'Decide on destination and book transport.',
    category: 'Personal',
    assignment: TaskAssignment.assignedToMe,
    dueDate: DateTime.now().add(const Duration(days: 5)),
  ),
  Task(
    id: '7',
    title: 'Renew gym membership',
    description: '',
    category: 'Health',
    assignment: TaskAssignment.createdByMe,
    dueDate: DateTime.now().add(const Duration(days: 7)),
    completed: true,
  ),
];
