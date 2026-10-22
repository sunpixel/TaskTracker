import 'package:flutter/material.dart';

import '../data/task_store_scope.dart';
import '../models/task.dart';
import '../navigation/app_nav_scope.dart';
import '../utils/sort_tasks.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bar.dart';
import 'task_detail_screen.dart';

/// Landing tab: a quick glance at what's due, rather than the full
/// filterable list (that lives in the Tasks tab).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TaskStoreScope.of(context);
    final navController = AppNavScope.of(context);

    if (store.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pending = sortByDeadline(store.tasks.where((t) => !t.isCompleted).toList());
    final assignedToMe = pending
        .where((t) => t.assignment == TaskAssignment.assignedToMe)
        .length;
    final mine = pending.where((t) => t.assignment == TaskAssignment.mine).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.assignment_ind_outlined,
                      label: 'Assigned to me',
                      count: assignedToMe,
                      onTap: () => navController.goToTasksTab(
                        filter: const TaskFilter.assignedToMe(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.edit_note_outlined,
                      label: 'Mine',
                      count: mine,
                      onTap: () => navController.goToTasksTab(
                        filter: const TaskFilter.mine(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Text('Up next', style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          if (pending.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Nothing due. Nice work!')),
            )
          else
            SliverList.builder(
              itemCount: pending.length,
              itemBuilder: (context, index) {
                final task = pending[index];
                return TaskCard(
                  task: task,
                  onToggle: () => store.quickToggle(task),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id!)),
                  ),
                );
              },
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text('$count', style: theme.textTheme.headlineMedium),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
