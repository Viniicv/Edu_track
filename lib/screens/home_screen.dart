import 'package:edutrack_app/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/activity_provider.dart';
import '../utils/theme.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import 'calendar_screen.dart';
import 'subjects_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const HomeContent(),
    const CalendarScreen(),
    const SubjectsScreen(showBottomNavigation: false),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: false,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Center(child: LogoWidget(size: 24, showText: false)),
              ),
              const SizedBox(width: 10),
              const Text(
                'EDUTRACK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: _buildHeader(context),
        ),
        SliverToBoxAdapter(
          child: _buildUrgentSection(context),
        ),
        SliverToBoxAdapter(
          child: _buildNextWeekSection(context),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _getUserName(),
            builder: (context, snapshot) {
              final name = snapshot.data ?? 'Estudante';
              return Text(
                'Olá, $name!',
                style: AppTextStyles.heading,
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Aqui estão suas prioridades:',
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }

  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'Estudante';
  }

  Widget _buildUrgentSection(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        final urgentActivities = activityProvider.getTodayUrgentActivities();

        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                title: 'Hoje: URGENTE!',
                color: AppTheme.urgentColor,
              ),
              const SizedBox(height: 12),
              if (urgentActivities.isEmpty)
                _buildEmptyCard('Nenhuma tarefa urgente!')
              else
                ...urgentActivities.map((activity) => _buildTaskCard(
                      context,
                      activity.title,
                      activity.subject,
                      activity.dueDate,
                      isUrgent: true,
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNextWeekSection(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        final nextWeekActivities = activityProvider.getNextWeekActivities();

        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                title: 'Próxima semana',
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              if (nextWeekActivities.isEmpty)
                _buildEmptyCard('Nenhuma atividade para a próxima semana')
              else
                ...nextWeekActivities.take(3).map((activity) => _buildTaskCard(
                      context,
                      activity.title,
                      activity.subject,
                      activity.dueDate,
                    )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/activities');
                  },
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Ver lista de atividades'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required String title,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            message,
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    String title,
    String subject,
    DateTime dueDate, {
    bool isUrgent = false,
  }) {
    final color = isUrgent ? const Color(0xFFEF4444) : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isUrgent ? Icons.warning_amber_rounded : Icons.assignment,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subject,
                        style: AppTextStyles.progressLabel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Entrega até ${_formatDate(dueDate)}',
                  style: AppTextStyles.progressLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
