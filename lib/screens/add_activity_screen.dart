import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity_model.dart';
import '../providers/activity_provider.dart';
import '../providers/subject_provider.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedSubject;

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      _dateController.text = '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    }
  }

  Future<void> _saveActivity() async {
    if (_titleController.text.trim().isEmpty ||
        _dateController.text.isEmpty ||
        _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final parts = _dateController.text.split('/');

    final activity = Activity(
      title: _titleController.text.trim(),
      subject: _selectedSubject!,
      dueDate: DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      ),
      isCompleted: false,
      isUrgent: false,
      progress: 0,
    );

    await Provider.of<ActivityProvider>(
      context,
      listen: false,
    ).addActivity(activity);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final subjects = Provider.of<SubjectProvider>(context).subjects;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 22,
                  color: Colors.black,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 26),
              const Center(
                child: Text(
                  'Nova Atividade',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _buildLabel('Título da Atividade'),
              const SizedBox(height: 6),
              _buildField(
                child: TextField(
                  controller: _titleController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                  decoration: _inputDecoration('EX: Resumo de BD'),
                ),
              ),
              const SizedBox(height: 12),
              _buildLabel('Data de Entrega'),
              const SizedBox(height: 6),
              _buildField(
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                  decoration: _inputDecoration('EX: 01/01/2023'),
                ),
              ),
              const SizedBox(height: 12),
              _buildLabel('Selecione a Matéria'),
              const SizedBox(height: 6),
              if (subjects.isEmpty)
                const Text(
                  'Cadastre uma matéria antes de criar atividades.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                )
              else
                _buildDropdown(subjects),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: subjects.isEmpty ? null : _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                      side: const BorderSide(color: Colors.black, width: 1.4),
                    ),
                  ),
                  child: const Text(
                    'SALVAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF7B8190),
      ),
    );
  }

  Widget _buildField({required Widget child}) {
    return SizedBox(
      height: 36,
      child: child,
    );
  }

  Widget _buildDropdown(List subjects) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSubject,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          hint: const Text(''),
          style: const TextStyle(fontSize: 13, color: Colors.black),
          items: subjects.map<DropdownMenuItem<String>>((subject) {
            return DropdownMenuItem<String>(
              value: subject.name,
              child: Center(child: Text(subject.name)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSubject = value;
            });
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFBDBDBD),
        fontSize: 12,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(
          color: Color(0xFF1E3A8A),
          width: 1.2,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
