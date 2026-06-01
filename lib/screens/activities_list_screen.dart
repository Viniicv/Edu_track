import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity_model.dart';
import '../providers/activity_provider.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class ActivitiesListScreen extends StatelessWidget {
  const ActivitiesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        title: const Text('Lista de Atividades'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, activityProvider, _) {
          final activities = [...activityProvider.activities]
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

          if (activities.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma atividade criada',
                style: AppTextStyles.subtitle,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return _buildActivityCard(context, activities[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    final isLate = _isLate(activity);
    final statusColor = activity.isCompleted
        ? const Color(0xFF16A34A)
        : isLate
            ? const Color(0xFFEF4444)
            : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: activity.isCompleted,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (value) {
                activity.isCompleted = value ?? false;
                activity.progress = activity.isCompleted ? 100 : 0;

                Provider.of<ActivityProvider>(
                  context,
                  listen: false,
                ).updateActivity(activity);
              },
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: AppTextStyles.cardTitle.copyWith(
                      decoration: activity.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity.subject,
                    style: AppTextStyles.progressLabel,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Entrega até ${_formatDate(activity.dueDate)}',
                        style: AppTextStyles.progressLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Excluir atividade',
              icon: Icon(Icons.delete_outline, color: statusColor),
              onPressed: () => _confirmDelete(context, activity),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover atividade'),
          content: Text('Deseja remover "${activity.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
              ),
              onPressed: () {
                Provider.of<ActivityProvider>(
                  context,
                  listen: false,
                ).deleteActivity(activity.id!);

                Navigator.pop(context);
              },
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  bool _isLate(Activity activity) {
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);
    final dueDate = DateTime(
      activity.dueDate.year,
      activity.dueDate.month,
      activity.dueDate.day,
    );

    return dueDate.isBefore(currentDate) && !activity.isCompleted;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
