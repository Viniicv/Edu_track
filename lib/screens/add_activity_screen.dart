import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity_model.dart';
import '../providers/activity_provider.dart';
import '../providers/subject_provider.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() =>
      _AddActivityScreenState();
}

class _AddActivityScreenState
    extends State<AddActivityScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedSubject;

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    }
  }

  void _saveActivity() {
    if (_titleController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Preencha todos os campos'),
        ),
      );

      return;
    }

    final parts =
        _dateController.text.split('/');

    final formattedDate = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );

    final activity = Activity(
      title: _titleController.text,
      subject: _selectedSubject!,
      dueDate: formattedDate,
      isCompleted: false,
      isUrgent: false,
      progress: 0,
    );

    Provider.of<ActivityProvider>(
      context,
      listen: false,
    ).addActivity(activity);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final subjects =
        Provider.of<SubjectProvider>(context)
            .subjects;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF3F3F3),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // BOTÃO VOLTAR
              IconButton(
                onPressed: () =>
                    Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                  color: Colors.black,
                ),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(),
              ),

              const SizedBox(height: 90),

              // TÍTULO
              const Center(
                child: Text(
                  'Nova Atividade',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF1E3A8A),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // LABEL
              const Text(
                'Título da Atividade',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8A8A8A),
                ),
              ),

              const SizedBox(height: 6),

              // INPUT TÍTULO
              SizedBox(
                height: 42,
                child: TextField(
                  controller:
                      _titleController,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                  decoration:
                      _inputDecoration(
                    'EX: Resumo de BD',
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // LABEL
              const Text(
                'Data de Entrega',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8A8A8A),
                ),
              ),

              const SizedBox(height: 6),

              // INPUT DATA
              SizedBox(
                height: 42,
                child: TextField(
                  controller:
                      _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                  decoration:
                      _inputDecoration(
                    'EX: 01/01/2023',
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // LABEL
              const Text(
                'Selecione a Matéria',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8A8A8A),
                ),
              ),

              const SizedBox(height: 6),

              // DROPDOWN
              Container(
                height: 42,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                          6),
                  border: Border.all(
                    color: const Color(
                        0xFFE5E7EB),
                  ),
                ),
                child:
                    DropdownButtonHideUnderline(
                  child:
                      DropdownButton<String>(
                    value:
                        _selectedSubject,
                    isExpanded: true,
                    icon: const Icon(
                      Icons
                          .keyboard_arrow_down,
                      size: 20,
                    ),
                    hint: const Text(
                      '',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                    items: subjects
                        .map((subject) {
                      return DropdownMenuItem<
                          String>(
                        value:
                            subject.name,
                        child: Text(
                          subject.name,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject =
                            value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // BOTÃO
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed:
                      _saveActivity,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                            0xFF1E3A8A),
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  4),
                      side:
                          const BorderSide(
                        color:
                            Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    'SALVAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String hint) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: Color(0xFFBDBDBD),
        fontSize: 12,
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFF1E3A8A),
          width: 1.2,
        ),
      ),
    );
  }
}

