import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity_model.dart';
import '../providers/subject_provider.dart';
import '../providers/activity_provider.dart';
import '../models/subject_model.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../utils/subject_activity_helpers.dart' as subject_activity_helpers;
import 'add_subject_screen.dart';

class SubjectsScreen extends StatelessWidget {
  final bool showBottomNavigation;

  const SubjectsScreen({
    super.key,
    this.showBottomNavigation = true,
  });

  static const _progressColor = AppColors.primary;
  static const _screenBackground = Color(0xFFF3F3F3);
  static const _trackColor = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 72),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: () => _openAddSubject(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Nova Matéria',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer2<SubjectProvider, ActivityProvider>(
                builder: (context, subjectProvider, activityProvider, _) {
                  final subjects = subjectProvider.subjects;
                  final activities = activityProvider.activities;

                  if (subjects.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhuma matéria cadastrada',
                        style: AppTextStyles.subtitle,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 19),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      return _buildSubjectItem(
                        context,
                        subjects[index],
                        activities,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showBottomNavigation
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              currentIndex: 2,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/calendar');
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: 'Calendário',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_outlined),
                  activeIcon: Icon(Icons.list_alt),
                  label: 'Matérias',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildSubjectItem(
    BuildContext context,
    Subject subject,
    List<Activity> activities,
  ) {
    final linkedActivities =
        subject_activity_helpers.linkedActivitiesForSubject(
      subject,
      activities,
    );
    final progress =
        subject_activity_helpers.calculateSubjectProgress(linkedActivities);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(14, 7, 14, 10),
      decoration: BoxDecoration(
        color: _screenBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD3D5DB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  subject.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                height: 32,
                child: IconButton(
                  tooltip: 'Excluir matéria',
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEF4444),
                    size: 22,
                  ),
                  onPressed: () {
                    _confirmDeleteSubject(
                      context,
                      subject,
                      linkedActivities,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '$progress% Concluído',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: _trackColor,
              valueColor: const AlwaysStoppedAnimation(_progressColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _openAddSubject(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddSubjectScreen()),
    );
  }

  void _confirmDeleteSubject(
    BuildContext context,
    Subject subject,
    List<Activity> linkedActivities,
  ) {
    if (linkedActivities.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não é possível excluir esta matéria porque ela possui tarefas vinculadas.',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir matéria'),
          content: Text('Deseja excluir "${subject.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
              ),
              onPressed: () async {
                final id = subject.id;
                if (id == null) return;

                await Provider.of<SubjectProvider>(
                  context,
                  listen: false,
                ).deleteSubject(id);

                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}
