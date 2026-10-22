import 'package:flutter/material.dart';

import '../data/mock_tasks.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';

/// Full task list with the horizontal filter bar on top.
///
/// Filtering is intentionally simple right now: one active filter at a
/// time, mixing assignment ("Assigned to me" / "Created by me") and
/// category into a single row. This is the first iteration — multi-select,
/// search, and sorting are natural next steps once the design settles.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late List<Task> _tasks;
  TaskFilter _selected = const TaskFilter.all();

  @override
  void initState() {
    super.initState();
    _tasks = List.of(mockTasks);
  }

  List<TaskFilter> get _filters {
    final categories = _tasks.map((t) => t.category).toSet().toList()..sort();
    return [
      const TaskFilter.all(),
      const TaskFilter.assignment(TaskAssignment.assignedToMe, 'Assigned to me'),
      const TaskFilter.assignment(TaskAssignment.createdByMe, 'Created by me'),
      for (final category in categories) TaskFilter.category(category, category),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _tasks.where(_selected.matches).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: TaskFilterBar(
              filters: _filters,
              selected: _selected,
              onSelected: (filter) => setState(() => _selected = filter),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No tasks match this filter.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      return TaskCard(
                        task: task,
                        onToggleCompleted: (value) {
                          setState(() {
                            final i = _tasks.indexWhere((t) => t.id == task.id);
                            _tasks[i] = _tasks[i].copyWith(completed: value);
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: wire up task creation once the backend is in place.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add task — coming soon')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
