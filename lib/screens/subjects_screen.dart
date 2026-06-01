import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../models/subject_model.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
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
              child: Consumer<SubjectProvider>(
                builder: (context, subjectProvider, _) {
                  final subjects = subjectProvider.subjects;

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
                      return _buildSubjectItem(subjects[index]);
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

  Widget _buildSubjectItem(Subject subject) {
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
          Text(
            subject.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${subject.progress}% Concluído',
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
              value: subject.progress / 100,
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
}
