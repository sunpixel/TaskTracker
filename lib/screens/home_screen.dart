import 'package:flutter/material.dart';

import '../data/mock_tasks.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';

/// Landing tab: a quick glance at what's due, rather than the full
/// filterable list (that lives in the Tasks tab).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pending = mockTasks.where((t) => !t.completed).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final assignedToMe =
        pending.where((t) => t.assignment == TaskAssignment.assignedToMe).length;
    final createdByMe =
        pending.where((t) => t.assignment == TaskAssignment.createdByMe).length;

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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.edit_note_outlined,
                      label: 'Created by me',
                      count: createdByMe,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Up next',
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
              itemBuilder: (context, index) => TaskCard(task: pending[index]),
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

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: theme.textTheme.headlineMedium,
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
