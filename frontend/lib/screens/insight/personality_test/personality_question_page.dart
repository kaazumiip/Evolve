import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/personality_test_service.dart';
import 'personality_result_page.dart';
import '../../../services/personality_storage_service.dart';
import '../../../generated/l10n/app_localizations.dart';

class PersonalityQuestionPage extends StatefulWidget {
  const PersonalityQuestionPage({super.key});

  @override
  State<PersonalityQuestionPage> createState() =>
      _PersonalityQuestionPageState();
}

class _PersonalityQuestionPageState extends State<PersonalityQuestionPage>
    with TickerProviderStateMixin {
  static const int questionsPerPage = 5;
  final Map<int, String> _answers = {};
  int _currentPage = 0;
  final PageController _pageController = PageController();
  late AnimationController _progressAnimController;
  late Animation<double> _progressAnimation;
  double _prevProgress = 0.0;

  int get totalPages =>
      (PersonalityTestService.questions.length / questionsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressAnimation =
        Tween<double>(begin: 0, end: 0).animate(_progressAnimController);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await PersonalityStorageService.getProgress();
    if (progress != null) {
      final Map<String, dynamic> answersData = progress['answers'] ?? {};
      final savedIndex = progress['questionIndex'] ?? 0;
      
      setState(() {
        answersData.forEach((key, value) {
          _answers[int.parse(key)] = value.toString();
        });
        _currentPage = savedIndex;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentPage > 0) {
          _pageController.jumpToPage(_currentPage);
          _animateProgress(_progressValue);
        }
      });
    }
  }

  Future<void> _saveProgress() async {
    await PersonalityStorageService.saveProgress(
      questionIndex: _currentPage,
      answers: _answers,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimController.dispose();
    super.dispose();
  }

  List<dynamic> get _currentQuestions {
    final start = _currentPage * questionsPerPage;
    final end = (start + questionsPerPage)
        .clamp(0, PersonalityTestService.questions.length);
    return PersonalityTestService.questions.sublist(start, end);
  }

  double get _progressValue =>
      (_currentPage + 1) / totalPages;

  void _animateProgress(double newValue) {
    _progressAnimation = Tween<double>(
      begin: _prevProgress,
      end: newValue,
    ).animate(CurvedAnimation(
      parent: _progressAnimController,
      curve: Curves.easeInOut,
    ));
    _progressAnimController.forward(from: 0);
    _prevProgress = newValue;
  }

  bool get _currentPageAnswered {
    for (final q in _currentQuestions) {
      if (!_answers.containsKey(q.id)) return false;
    }
    return true;
  }

  void _goNext() {
    if (!_currentPageAnswered) {
      _showUnansweredSnackbar();
      return;
    }
    if (_currentPage < totalPages - 1) {
      setState(() => _currentPage++);
      _animateProgress(_progressValue);
      _saveProgress(); // Update progress on page turn
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishTest();
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _animateProgress(_progressValue);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _finishTest() async {
    final type = PersonalityTestService.calculateType(_answers);
    final scores = PersonalityTestService.getDimensionScores(_answers);
    
    // Auto-save result
    await PersonalityStorageService.saveResult(
      type: type,
      scores: scores,
    );

    // Clear progress
    await PersonalityStorageService.clearProgress();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PersonalityResultPage(personalityType: type, scores: scores),
        ),
      );
    }
  }

  void _showUnansweredSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.pleaseAnswerAllQuestions),
          ],
        ),
        backgroundColor: const Color(0xFF225BE3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandColor = isDark ? const Color(0xFF6366F1) : const Color(0xFF225BE3);
    final bgColor = isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF5F7FF);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar area
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                   Row(
                    children: [
                      GestureDetector(
                        onTap: _goBack,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 16, color: brandColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.personalityTest,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.pageOf(_currentPage + 1, totalPages),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: brandColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.tasksCompleted(_answers.length),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : brandColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, _) {
                      final val = _progressAnimController.isAnimating
                          ? _progressAnimation.value
                          : _progressValue;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: val,
                          backgroundColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE8EEFF),
                          valueColor:
                          AlwaysStoppedAnimation<Color>(brandColor),
                          minHeight: 7,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Questions
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalPages,
                itemBuilder: (context, pageIndex) {
                  final start = pageIndex * questionsPerPage;
                  final end = (start + questionsPerPage)
                      .clamp(0, PersonalityTestService.questions.length);
                  final pageQuestions =
                  PersonalityTestService.questions.sublist(start, end);

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
                    itemCount: pageQuestions.length,
                    itemBuilder: (context, index) {
                      final q = pageQuestions[index];
                      final globalIndex = start + index;
                      return _QuestionCard(
                        question: q.question,
                        questionNumber: globalIndex + 1,
                        optionA: q.optionA,
                        optionB: q.optionB,
                        selectedOption: _answers[q.id],
                        onSelect: (option) {
                          setState(() => _answers[q.id] = option);
                          _saveProgress();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back button
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: _goBack,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFDDE3FF), width: 1.5),
                  backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
                  foregroundColor: brandColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      _currentPage == 0 ? AppLocalizations.of(context)!.exit : AppLocalizations.of(context)!.back,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Next / Finish button
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: _goNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentPageAnswered
                      ? brandColor
                      : (isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFB0BFFF)),
                  foregroundColor: _currentPageAnswered ? Colors.white : (isDark ? Colors.white24 : Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: _currentPageAnswered ? 3 : 0,
                  shadowColor: brandColor.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentPage == totalPages - 1
                          ? AppLocalizations.of(context)!.seeResults
                          : AppLocalizations.of(context)!.next,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _currentPage == totalPages - 1
                          ? Icons.emoji_events_rounded
                          : Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final int questionNumber;
  final String optionA;
  final String optionB;
  final String? selectedOption;
  final void Function(String) onSelect;

  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.optionA,
    required this.optionB,
    required this.selectedOption,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandColor = isDark ? const Color(0xFF6366F1) : const Color(0xFF225BE3);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    final isAnswered = selectedOption != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isAnswered
                ? brandColor.withOpacity(isDark ? 0.2 : 0.08)
                : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: isAnswered
            ? Border.all(color: brandColor.withOpacity(isDark ? 0.3 : 0.15), width: 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isAnswered
                        ? brandColor
                        : (isDark ? Colors.white24 : const Color(0xFFF0F4FF)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$questionNumber',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isAnswered ? Colors.white : brandColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      question,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Options
            _OptionTile(
              label: 'A',
              text: optionA,
              isSelected: selectedOption == 'A',
              onTap: () => onSelect('A'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.grey[200])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    AppLocalizations.of(context)!.or,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.grey[200])),
              ],
            ),
            const SizedBox(height: 8),
            _OptionTile(
              label: 'B',
              text: optionB,
              isSelected: selectedOption == 'B',
              onTap: () => onSelect('B'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandColor = isDark ? const Color(0xFF6366F1) : const Color(0xFF225BE3);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? brandColor.withOpacity(isDark ? 0.15 : 0.08)
              : (isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF8F9FF)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? brandColor : (isDark ? Colors.white12 : const Color(0xFFEBEFF8)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? brandColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? brandColor : (isDark ? Colors.white12 : const Color(0xFFCDD5F0)),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 16)
                    : Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF8090B0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? (isDark ? Colors.white : brandColor) : (isDark ? Colors.white60 : const Color(0xFF3A3A5A)),
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
