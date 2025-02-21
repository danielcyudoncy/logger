// widget/task_list)item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final Function(bool?)? onStatusChanged;
  final VoidCallback? onDelete;

  const TaskListItem({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  if (onStatusChanged != null)
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: onStatusChanged,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assigned to: ${task.assignedToName}',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (task.dueDate != null)
                    Text(
                      'Due: ${DateFormat('MMM d, y').format(task.dueDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getDueDateColor(theme),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDueDateColor(ThemeData theme) {
    if (task.dueDate == null) return theme.colorScheme.onSurface;

    if (task.isCompleted) {
      return theme.colorScheme.onSurface;
    }

    final now = DateTime.now();
    final difference = task.dueDate!.difference(now).inDays;

    if (difference < 0) {
      return theme.colorScheme.error;
    } else if (difference <= 2) {
      return theme.colorScheme.error.withOpacity(0.8);
    } else if (difference <= 7) {
      return theme.colorScheme.warning ?? Colors.orange;
    }

    return theme.colorScheme.onSurface;
  }
}extension on ColorScheme {
  get warning => null;
}