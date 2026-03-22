import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'insight/vision_board_page.dart';
import '../models/journey_goal.dart';
import '../state/emoticon_provider.dart';
import 'insight/emoticon/emoticon_page.dart';
import 'insight/reflection_journal/journal_list_page.dart';
import 'insight/stickers/sticker_page.dart';
import 'insight/ai_mind_chat_page.dart';
import 'insight/journey_map/journey_map_page.dart';
import 'insight/personality_test/personality_intro_page.dart';
import 'insight/personality_test/personality_result_page.dart';
import '../services/db_helper.dart';
import '../services/personality_storage_service.dart';
import '../generated/l10n/app_localizations.dart';


Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class InsightTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  const InsightTab({super.key, required this.userData});

  @override
  State<InsightTab> createState() => _InsightTabState();
}

class _InsightTabState extends State<InsightTab> {
  // ─── Journey Map live data ────────────────────────────────────────────────
  int _totalGoals = 0;
  int _completedGoals = 0;
  int _journalCount = 0;
  int _visionCount = 0;
  int _customEmoticonCount = 0;
  Map<String, dynamic>? _personalityResult;
  double _personalityProgressValue = 0.0;
  bool _journeyLoading = true;

  static const String _journeyStorageKey = 'journey_goals';
  static const String _visionStorageKey = 'vision_items';
  static const String _emoticonStorageKey = 'custom_emoticons';

  double get _journeyProgress =>
      _totalGoals == 0 ? 0.0 : _completedGoals / _totalGoals;
  int get _journeyPercent => (_journeyProgress * 100).round();

  // ─── Quotes ───────────────────────────────────────────────────────────────
  // ─── Quotes ───────────────────────────────────────────────────────────────
  List<Map<String, String>> get _localizedQuotes => [
    {
      'quote': AppLocalizations.of(context)!.quote1,
      'title': AppLocalizations.of(context)!.quote1Title,
    },
    {
      'quote': AppLocalizations.of(context)!.quote2,
      'title': AppLocalizations.of(context)!.quote2Title,
    },
    {
      'quote': AppLocalizations.of(context)!.quote3,
      'title': AppLocalizations.of(context)!.quote3Title,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadJourneyProgress(),
      _loadJournalCount(),
      _loadPersonalityResult(),
      _loadVisionCount(),
      _loadEmoticonCount(),
    ]);
  }

  Future<void> _loadVisionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_visionStorageKey);
    if (raw != null) {
      final List<dynamic> decoded = jsonDecode(raw);
      if (mounted) setState(() => _visionCount = decoded.length);
    }
  }

  Future<void> _loadEmoticonCount() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_emoticonStorageKey);
    if (list != null) {
      if (mounted) setState(() => _customEmoticonCount = list.length);
    }
  }

  Future<void> _loadPersonalityResult() async {
    final result = await PersonalityStorageService.getResult();
    final progress = await PersonalityStorageService.getProgress();
    
    if (mounted) {
      setState(() {
        _personalityResult = result;
        if (progress != null) {
          final answers = progress['answers'] as Map<String, dynamic>? ?? {};
          // There are 70 questions in total for this test
          _personalityProgressValue = answers.length / 70.0;
        } else {
          _personalityProgressValue = 0.0;
        }
      });
    }
  }

  Future<void> _loadJournalCount() async {
    final entries = await DBHelper.instance.getEntries(includeArchived: false);
    if (mounted) {
      setState(() {
        _journalCount = entries.length;
      });
    }
  }

  Future<void> _loadJourneyProgress() async {
    setState(() => _journeyLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_journeyStorageKey);
    if (raw != null) {
      final List<dynamic> decoded = jsonDecode(raw);
      final goals = decoded.map((e) => JourneyGoal.fromJson(e)).toList();
      setState(() {
        _totalGoals = goals.length;
        _completedGoals = goals.where((g) => g.isCompleted).length;
      });
    } else {
      setState(() {
        _totalGoals = 0;
        _completedGoals = 0;
      });
    }
    setState(() => _journeyLoading = false);
  }

  String _getTodayQuote() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final dayOfYear = int.parse(DateFormat('D').format(now));
    return _localizedQuotes[dayOfYear % _localizedQuotes.length]['quote']!;
  }

  String _getTodayTitle() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final dayOfYear = int.parse(DateFormat('D').format(now));
    return _localizedQuotes[dayOfYear % _localizedQuotes.length]['title']!;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 23, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.insight,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.personalGrowthJourney,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 50),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuoteCard(isDark),
                    const SizedBox(height: 36),
                    _buildStatsGrid(isDark),
                    const SizedBox(height: 48),
                    _buildToolsGrid(isDark),
                    const SizedBox(height: 24),
                    _buildJourneyMapCard(isDark),
                    const SizedBox(height: 48),
                    _buildAICard(isDark),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF6366F1), const Color(0xFF4F46E5)] 
              : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBlue(context).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.todayQuote,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Text(_getTodayTitle(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(_getTodayQuote(),
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    '${widget.userData['current_streak'] ?? 0}',
                    AppLocalizations.of(context)!.daysStreak,
                    isDark: isDark)),
            const SizedBox(width: 20),
            Expanded(child: _buildStatCard('$_journalCount', AppLocalizations.of(context)!.journalEntries, isDark: isDark)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('2', AppLocalizations.of(context)!.totalInsights, isDark: isDark)),
            const SizedBox(width: 20),
            Expanded(
              child: _buildStatCard(
                '$_journeyPercent%', 
                AppLocalizations.of(context)!.growth,
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JourneyMapPage()),
                ).then((_) => _loadData()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolsGrid(bool isDark) {
    final width = MediaQuery.of(context).size.width;
    // Breakpoint for phone size
    final bool isPhone = width <= 600;
    
    // User requested: 2 column for phone (2x2 grid), 4 column for larger (4x1 row)
    final int crossAxisCount = isPhone ? 2 : 4;
    
    // Ensure the aspect ratio keeps cards small and consistent
    final double aspectRatio = isPhone ? 0.72 : 0.8; 


    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 20,
      mainAxisSpacing: 34,
      childAspectRatio: aspectRatio,
      children: [
        _buildToolCard(
          _personalityResult != null
              ? AppLocalizations.of(context)!.typeLabel(_personalityResult!['type'])
              : AppLocalizations.of(context)!.personalityTest,
          _personalityResult != null
              ? AppLocalizations.of(context)!.viewFullProfile
              : AppLocalizations.of(context)!.discoverYourTraits,
          Icons.psychology_rounded,
          isDark: isDark,
          onTap: () {
            if (_personalityResult != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PersonalityResultPage(
                    personalityType: _personalityResult!['type'],
                    scores: Map<String, int>.from(
                        _personalityResult!['scores']),
                  ),
                ),
              ).then((_) => _loadData());
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PersonalityIntroPage()),
              ).then((_) => _loadData());
            }
          },
        ),
        _buildToolCard(
          AppLocalizations.of(context)!.visionBoard,
          AppLocalizations.of(context)!.manifestYourFuture,
          Icons.grid_view_rounded,
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VisionBoardPage()),
          ),
        ),
        _buildToolCard(
          AppLocalizations.of(context)!.reflectionJournal,
          AppLocalizations.of(context)!.documentYourGrowth,
          Icons.menu_book_rounded,
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JournalListPage()),
          ),
        ),
        _buildToolCard(
          AppLocalizations.of(context)!.emoticon,
          AppLocalizations.of(context)!.expressYourself,
          Icons.emoji_emotions_rounded,
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => EmoticonProvider(),
                child: const EmoticonPage(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyMapCard(bool isDark) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JourneyMapPage()),
        );
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: kPrimaryBlue(context).withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryBlue(context).withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: kPrimaryBlue(context),
                child: const Icon(Icons.map_rounded, color: Colors.white, size: 26),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.journeyMap,
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E40AF),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _journeyLoading
                        ? AppLocalizations.of(context)!.loading
                        : (_totalGoals == 0
                            ? AppLocalizations.of(context)!.noGoalsYetTapToAdd
                            : AppLocalizations.of(context)!.goalsCompleted(_completedGoals, _totalGoals)),
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: _journeyLoading ? null : _journeyProgress,
                      minHeight: 6,
                      backgroundColor: isDark ? Colors.white10 : const Color(0xFFBFDBFE),
                      valueColor: AlwaysStoppedAnimation(kPrimaryBlue(context)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (!_journeyLoading)
              Text(
                '$_journeyPercent%',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryBlue(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, {required bool isDark, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlue(context))),

            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
      String title,
      String subtitle,
      IconData icon, {
        required bool isDark,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 48, 14, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryBlue(context).withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1E40AF),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF2563EB),
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                _buildCardFooter(icon, isDark),
                const SizedBox(height: 4),
              ],
            ),
          ),
          Positioned(
            top: -28,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: kPrimaryBlue(context),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAICard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBlue(context).withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: kPrimaryBlue(context),
            radius: 32,
            child: const Icon(Icons.support_agent, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.aiMindChat,
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E40AF))),
          const SizedBox(height: 6),
          Text(AppLocalizations.of(context)!.getPersonalizedGuidance,
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF2563EB))),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AIMindChatPage(userData: widget.userData)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue(context),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(AppLocalizations.of(context)!.startChat,
                  style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(IconData icon, bool isDark) {
    String label = "";
    double progress = 0.0;
    
    // Safety check for localization methods that might be missing in generated code
    final l10n = AppLocalizations.of(context);
    
    if (icon == Icons.psychology_rounded) {
      label = _personalityResult != null ? "100%" : "${(_personalityProgressValue * 100).toInt()}%";
      progress = _personalityResult != null ? 1.0 : _personalityProgressValue;
    } else if (icon == Icons.grid_view_rounded) {
      // Use fallback if method is missing during generation
      try { label = l10n!.visionsCreated(_visionCount); } catch(_) { label = "$_visionCount Visions Created"; }
      progress = (_visionCount / 10).clamp(0.0, 1.0); // Visual target of 10
    } else if (icon == Icons.menu_book_rounded) {
      try { label = l10n!.storiesRecorded(_journalCount); } catch(_) { label = "$_journalCount Stories Recorded"; }
      progress = (_journalCount / 20).clamp(0.0, 1.0); // Visual target of 20
    } else if (icon == Icons.emoji_emotions_rounded) {
      try { label = l10n!.vibesSaved(_customEmoticonCount); } catch(_) { label = "$_customEmoticonCount Vibes Saved"; }
      progress = (_customEmoticonCount / 15).clamp(0.0, 1.0); // Visual target of 15
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w800, 
            color: kPrimaryBlue(context),
            fontFamily: 'Raleway',
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: (icon == Icons.grid_view_rounded || icon == Icons.emoji_emotions_rounded || icon == Icons.menu_book_rounded) 
                ? Colors.transparent 
                : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
            valueColor: AlwaysStoppedAnimation(kPrimaryBlue(context)),
          ),
        ),
      ],
    );
  }
}
