import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../core/app_colors.dart';
import '../core/app_icon_sizes.dart';
import '../core/app_radius.dart';
import '../core/app_spacing.dart';
import '../core/app_text_styles.dart';
import 'add_activity_screen.dart';
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
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              elevation: 6,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddActivityScreen()),
                );
              },
              child: const Icon(
                Icons.add,
                color: AppColors.surface,
                size: AppIconSizes.main,
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
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
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: _buildTopHeader(context),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildUrgentSection(context),
        ),
        SliverToBoxAdapter(
          child: _buildThisWeekSection(context),
        ),
        SliverToBoxAdapter(
          child: _buildNextWeekSection(context),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.buttonHeight + 32),
        ),
      ],
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.horizontalPadding,
        AppSpacing.horizontalPadding,
        AppSpacing.horizontalPadding,
        AppSpacing.smallGap,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EDUTRACK',
                style: AppTextStyles.mediumTitle.copyWith(
                  letterSpacing: 0.2,
                ),
              ),
              Tooltip(
                message: 'Sair',
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  onTap: () => _logout(context),
                  child: Container(
                    width: AppIconSizes.button,
                    height: AppIconSizes.button,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(AppRadius.input / 2),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: AppColors.surface,
                      size: AppIconSizes.small,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.smallGap + 4),
          FutureBuilder<String>(
            future: _getUserName(),
            builder: (context, snapshot) {
              final name = snapshot.data ?? 'Estudante';
              return Text(
                'Olá, $name!',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.smallGap),
          Text(
            'Aqui estão as suas prioridades:',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }

  Future<String> _getUserName() async {
    return AuthService.instance.safeGreetingName;
  }

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    await AuthService.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Widget _buildUrgentSection(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        final todayActivities = activityProvider.getTodayPendingActivities();

        return Container(
          margin: const EdgeInsets.all(AppSpacing.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                title: 'Hoje: URGENTE!',
                color: AppTheme.urgentColor,
              ),
              const SizedBox(height: AppSpacing.smallGap + 4),
              if (todayActivities.isEmpty)
                _buildEmptyCard('Nenhuma tarefa urgente!')
              else
                ...todayActivities.map((activity) => _buildTaskCard(
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
        final nextWeekActivities =
            activityProvider.getNextWeekPendingActivities();

        return Container(
          margin: const EdgeInsets.all(AppSpacing.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                title: 'Próxima semana',
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.smallGap + 4),
              if (nextWeekActivities.isEmpty)
                _buildEmptyCard('Nenhuma atividade para a próxima semana')
              else
                ...nextWeekActivities.take(3).map((activity) => _buildTaskCard(
                      context,
                      activity.title,
                      activity.subject,
                      activity.dueDate,
                    )),
              const SizedBox(height: AppSpacing.smallGap),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/activities');
                  },
                  icon: const Icon(
                    Icons.list_alt,
                    size: AppIconSizes.button,
                  ),
                  label: const Text('Ver lista de atividades'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThisWeekSection(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        final thisWeekActivities =
            activityProvider.getThisWeekPendingActivities();

        return Container(
          margin: const EdgeInsets.all(AppSpacing.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                title: 'Essa semana',
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.smallGap + 4),
              if (thisWeekActivities.isEmpty)
                _buildEmptyCard('Nenhuma atividade para esta semana')
              else
                ...thisWeekActivities.take(3).map((activity) => _buildTaskCard(
                      context,
                      activity.title,
                      activity.subject,
                      activity.dueDate,
                    )),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smallGap),
      child: Row(
        children: [
          Container(
            width: AppSpacing.smallGap,
            height: AppSpacing.smallGap,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.smallGap),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
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
        padding: const EdgeInsets.all(AppSpacing.sectionGap + 8),
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
    final color = isUrgent ? AppColors.error : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.smallGap + 4),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.smallGap),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: Icon(
                    isUrgent ? Icons.warning_amber_rounded : Icons.assignment,
                    size: AppIconSizes.button,
                    color: color,
                  ),
                ),
                const SizedBox(width: AppSpacing.smallGap + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: AppSpacing.smallGap / 2),
                      Text(
                        subject,
                        style: AppTextStyles.progressLabel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.smallGap + 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: AppIconSizes.small,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.smallGap / 2),
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
