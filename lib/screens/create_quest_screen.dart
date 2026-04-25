import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../providers/game_provider.dart';
import '../models/quest.dart';
import '../theme/app_theme.dart';

class CreateQuestScreen extends StatefulWidget {
  const CreateQuestScreen({super.key});

  @override
  State<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends State<CreateQuestScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _category = 'Academic';
  String _difficulty = 'Medium';
  DateTime? _deadline = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);

  // ── Static data ──────────────────────────────────
  static const _categories = ['Academic', 'Fitness', 'Life'];
  static const _categoryIcons = {
    'Academic': Icons.menu_book,
    'Fitness': Icons.fitness_center,
    'Life': Icons.home_filled,
  };
  static Map<String, Color> get _categoryColors => {
    'Academic': AppColors.academic,
    'Fitness': AppColors.fitness,
    'Life': AppColors.life,
  };

  static const _difficulties = ['Easy', 'Medium', 'Hard'];
  static Map<String, Color> get _difficultyColors => {
    'Easy': AppColors.easy,
    'Medium': AppColors.medium,
    'Hard': AppColors.hard,
  };
  static const _difficultyRewards = {
    'Easy': 20,
    'Medium': 50,
    'Hard': 100,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── Validation + save ────────────────────────────
  void _saveQuest() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚔️  Enter a quest title to proceed.')),
      );
      return;
    }
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏳  Set a deadline before accepting your quest.')),
      );
      return;
    }
    if (_deadline!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️  Deadline has already passed. Choose a future time.'),
        ),
      );
      return;
    }

    final provider = context.read<GameProvider>();
    final newQuest = Quest(
      userId: provider.userId!,
      id: const Uuid().v4(),
      title: title,
      description: _descController.text.trim(),
      category: _category,
      difficulty: _difficulty,
      expReward: _difficultyRewards[_difficulty]!,
      status: 'Pending',
      mediaProofPath: '',
      deadline: _deadline!.toIso8601String(),
    );

    context.read<GameProvider>().addQuest(newQuest);
    Navigator.pop(context);
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.gold,
            onPrimary: Colors.black,
            surface: AppColors.of(context).bgSurface,
            onSurface: AppColors.of(context).textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 59),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.gold,
            onPrimary: Colors.black,
            surface: AppColors.of(context).bgSurface,
            onSurface: AppColors.of(context).textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _deadline = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text('NEW QUEST', style: AppText.heading(size: 17, color: AppColors.gold)),
        backgroundColor: colors.bgCard.withAlpha(180),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Quest title ──
            _sectionLabel('QUEST TITLE'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: AppText.body(size: 16),
              decoration: const InputDecoration(
                hintText: 'What must be accomplished?',
              ),
            ),
            const SizedBox(height: 20),

            // ── Description ──
            _sectionLabel('DESCRIPTION  (OPTIONAL)'),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              style: AppText.body(size: 15),
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Add context or notes...'),
            ),
            const SizedBox(height: 24),

            // ── Category selector ──
            _sectionLabel('CATEGORY'),
            const SizedBox(height: 12),
            Row(
              children: _categories.map((cat) {
                final isSelected = _category == cat;
                final color = _categoryColors[cat]!;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withAlpha(30) : colors.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? color : colors.borderSubtle,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _categoryIcons[cat],
                            color: isSelected ? color : colors.textMuted,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.toUpperCase(),
                            style: AppText.label(
                              size: 10,
                              color: isSelected ? color : colors.textMuted,
                              spacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Difficulty selector ──
            _sectionLabel('DIFFICULTY'),
            const SizedBox(height: 12),
            Row(
              children: _difficulties.map((diff) {
                final isSelected = _difficulty == diff;
                final color = _difficultyColors[diff]!;
                final reward = _difficultyRewards[diff]!;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _difficulty = diff),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withAlpha(30) : colors.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? color : colors.borderSubtle,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            diff.toUpperCase(),
                            style: AppText.label(
                              size: 12,
                              color: isSelected ? color : colors.textMuted,
                              spacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+$reward EXP',
                            style: AppText.label(
                              size: 10,
                              color: isSelected
                                  ? color.withAlpha(180)
                                  : colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Deadline picker ──
            _sectionLabel('DEADLINE'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDeadline,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _deadline != null
                        ? AppColors.gold.withAlpha(100)
                        : colors.borderSubtle,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: _deadline != null ? AppColors.gold : colors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _deadline == null
                            ? 'Tap to set deadline'
                            : DateFormat('EEE, MMM dd  •  hh:mm a')
                                .format(_deadline!),
                        style: AppText.body(
                          size: 15,
                          color: _deadline != null
                              ? colors.textPrimary
                              : colors.textMuted,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: _deadline != null ? AppColors.gold : colors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ── Submit button ──
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  _saveQuest();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: AppGradients.gold,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withAlpha(90),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.black, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'ACCEPT QUEST',
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: AppText.label(size: 10, color: AppColors.of(context).textMuted, spacing: 2),
      );
}
