import 'package:flutter/material.dart';
import '../../../models/journey_goal.dart';
import '../../../generated/l10n/app_localizations.dart';

class AddGoalPage extends StatefulWidget {
  final JourneyGoal? existingGoal;

  const AddGoalPage({super.key, this.existingGoal});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String _selectedCategory = 'Study';

  // Updated category list per feature spec
  final List<String> _categories = [
    'Study',
    'Project',
    'Career',
    'Personal',
    'Other',
  ];

  final Map<String, Color> _categoryColors = {
    'Study': const Color(0xFFF59E0B),
    'Project': const Color(0xFF7C3AED),
    'Career': const Color(0xFF10B981),
    'Personal': const Color(0xFFEC4899),
    'Other': const Color(0xFF6B7280),
  };

  // Helpful hint text per category
  final Map<String, String> _categoryHints = {
    'Study': 'assignments, exams, homework',
    'Project': 'school projects, coding projects',
    'Career': 'internships, portfolio, job prep',
    'Personal': 'habits, self-development, new skills',
    'Other': 'general goals',
  };

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingGoal?.title ?? '');
    _descController =
        TextEditingController(text: widget.existingGoal?.description ?? '');
    if (widget.existingGoal != null) {
      _selectedDate = widget.existingGoal!.deadline;
      // Gracefully handle legacy categories not in the new list
      _selectedCategory = _categories.contains(widget.existingGoal!.category)
          ? widget.existingGoal!.category
          : 'Other';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final goal = JourneyGoal(
      id: widget.existingGoal?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      deadline: _selectedDate,
      category: _selectedCategory,
      isCompleted: widget.existingGoal?.isCompleted ?? false,
    );
    Navigator.pop(context, goal);
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = _categoryColors[_selectedCategory]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingGoal == null ? AppLocalizations.of(context)!.addGoal : AppLocalizations.of(context)!.editGoal,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              AppLocalizations.of(context)!.save,
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Category first so users frame the goal in context ──────────
            _SectionLabel(label: AppLocalizations.of(context)!.category),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: selectedColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: selectedColor.withValues(alpha: 0.2), width: 1),
              ),
              child: Text(
                _getCategoryHint(context, _selectedCategory),
                style: TextStyle(
                  fontSize: 12,
                  color: selectedColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                final color = _categoryColors[cat]!;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      _translateCategory(context, cat),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Title ──────────────────────────────────────────────────────
            _SectionLabel(label: AppLocalizations.of(context)!.goalTitle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration(hint: AppLocalizations.of(context)!.buildFirstWebPageHint),
              validator: (v) =>
              v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.pleaseEnterTitle : null,
            ),
            const SizedBox(height: 20),

            // ── Description ────────────────────────────────────────────────
            _SectionLabel(label: AppLocalizations.of(context)!.description),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration:
              _inputDecoration(hint: AppLocalizations.of(context)!.whatDoYouWantToAchieveHint),
            ),
            const SizedBox(height: 20),

            // ── Deadline ───────────────────────────────────────────────────
            _SectionLabel(label: AppLocalizations.of(context)!.deadline),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: Color(0xFF64748B)),
                    const SizedBox(width: 10),
                    Text(
                      '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        size: 18, color: Color(0xFFCBD5E1)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Save Button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.existingGoal == null ? AppLocalizations.of(context)!.addGoal : AppLocalizations.of(context)!.saveChanges,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _translateCategory(BuildContext context, String cat) {
    switch (cat) {
      case 'Study': return AppLocalizations.of(context)!.catStudy;
      case 'Project': return AppLocalizations.of(context)!.catProject;
      case 'Career': return AppLocalizations.of(context)!.catCareer;
      case 'Personal': return AppLocalizations.of(context)!.catPersonal;
      case 'Other': return AppLocalizations.of(context)!.catOther;
      default: return cat;
    }
  }

  String _getCategoryHint(BuildContext context, String cat) {
    switch (cat) {
      case 'Study': return AppLocalizations.of(context)!.studyHint;
      case 'Project': return AppLocalizations.of(context)!.projectHint;
      case 'Career': return AppLocalizations.of(context)!.careerHint;
      case 'Personal': return AppLocalizations.of(context)!.personalHint;
      case 'Other': return AppLocalizations.of(context)!.otherHint;
      default: return "";
    }
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          color: Color(0xFFCBD5E1), fontWeight: FontWeight.w400),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }
}
