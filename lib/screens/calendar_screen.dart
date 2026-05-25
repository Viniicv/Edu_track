import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity_model.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),

      appBar: AppBar(
        title: const Text('Calendário'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // BOTÃO FLUTUANTE
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 6,
        onPressed: () {
          _showAddTaskDialog(context, _selectedDate);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // CARD DO CALENDÁRIO
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // MÊS E ANO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(
                              _currentMonth.year,
                              _currentMonth.month - 1,
                              1,
                            );
                          });
                        },
                      ),

                      Row(
                        children: [
                          Text(
                            _getMonthName(_currentMonth),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            _currentMonth.year.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(
                              _currentMonth.year,
                              _currentMonth.month + 1,
                              1,
                            );
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // DIAS DA SEMANA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                        ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((day) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // GRID DO CALENDÁRIO
                  SizedBox(
                    height: 260,
                    child: _buildCalendarGrid(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TÍTULO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tarefas do Dia',
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // LISTA DE TAREFAS
            Expanded(
              child: _buildTasksForDay(),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);

    final startingWeekday = firstDayOfMonth.weekday % 7;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 42,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - startingWeekday + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox();
        }

        final date = DateTime(
          _currentMonth.year,
          _currentMonth.month,
          dayNumber,
        );

        final isSelected = _selectedDate.year == date.year &&
            _selectedDate.month == date.month &&
            _selectedDate.day == date.day;

        final hasTasks = _hasTasksOnDate(date);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayNumber.toString(),
                  style: TextStyle(
                    color:
                        isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (hasTasks && !isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasksForDay() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        final tasks =
            activityProvider.getActivitiesByDate(_selectedDate);

        if (tasks.isEmpty) {
          return Center(
            child: Text(
              'Nenhuma tarefa para este dia',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 100,
          ),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildTaskItem(context, task);
          },
        );
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, Activity task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (bool? value) {
              final provider =
                  Provider.of<ActivityProvider>(
                context,
                listen: false,
              );

              task.isCompleted = value ?? false;
              task.progress =
                  task.isCompleted ? 100 : 0;

              provider.updateActivity(task);

              setState(() {});
            },
          ),

          const SizedBox(width: 8),

          // TEXTO
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  task.subject,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onPressed: () {
              _showDeleteConfirmation(context, task);
            },
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(
      BuildContext context,
      DateTime date,
      ) {
    final titleController = TextEditingController();

    String selectedSubject = 'Dispositivos Móveis';

    final subjects = [
      'Dispositivos Móveis',
      'Back End',
      'Front End',
      'Banco de Dados',
      'Empreendedorismo',
      'Residência de Software'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Adicionar Tarefa - ${_formatDate(date)}',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título da tarefa',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Matéria',
                  border: OutlineInputBorder(),
                ),
                items: subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedSubject = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final newTask = Activity(
                    id: DateTime.now()
                        .millisecondsSinceEpoch,
                    title: titleController.text,
                    subject: selectedSubject,
                    dueDate: date,
                    isUrgent: false,
                    isCompleted: false,
                    progress: 0,
                  );

                  Provider.of<ActivityProvider>(
                    context,
                    listen: false,
                  ).addActivity(newTask);

                  Navigator.pop(context);

                  setState(() {});
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context,
      Activity task,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover tarefa'),
          content: Text(
            'Deseja remover "${task.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),

            TextButton(
              onPressed: () {
                Provider.of<ActivityProvider>(
                  context,
                  listen: false,
                ).deleteActivity(task.id!);

                Navigator.pop(context);

                setState(() {});
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  bool _hasTasksOnDate(DateTime date) {
    final provider =
        Provider.of<ActivityProvider>(
      context,
      listen: false,
    );

    final tasks =
        provider.getActivitiesByDate(date);

    return tasks.isNotEmpty;
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];

    return months[date.month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
