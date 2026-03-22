import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/journey_goal.dart';
import 'add_goal_page.dart';
import '../../../generated/l10n/app_localizations.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class JourneyMapPage extends StatefulWidget {
  const JourneyMapPage({super.key});

  @override
  State<JourneyMapPage> createState() => _JourneyMapPageState();
}

class _JourneyMapPageState extends State<JourneyMapPage>
    with SingleTickerProviderStateMixin {
  final List<JourneyGoal> _goals = [];
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isLoading = true;

  // Primary filter: status tab (always visible, compact)
  String _activeFilter = 'All';
  // Secondary filter: category (hidden in bottom sheet to reduce clutter)
  String _selectedCategory = 'All';

  static const String _storageKey = 'journey_goals';
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkBlue = Color(0xFF1D4ED8);

  final Map<String, Color> _categoryColors = {
    'Study': const Color(0xFFF59E0B),
    'Project': const Color(0xFF7C3AED),
    'Career': const Color(0xFF10B981),
    'Personal': const Color(0xFFEC4899),
    'Other': const Color(0xFF6B7280),
    'Education': const Color(0xFF3B82F6),
    'Health': const Color(0xFFEF4444),
  };

  List<String> get _statusFilters => ['All', 'In Progress', 'Completed', 'Overdue'];
  List<String> get _categoryOptions => ['All', 'Study', 'Project', 'Career', 'Personal', 'Other'];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _loadGoals();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  // ─── Persistence ─────────────────────────────────────────────────────────────

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final List<dynamic> decoded = jsonDecode(raw);
      setState(() => _goals.addAll(decoded.map((e) => JourneyGoal.fromJson(e))));
    }
    setState(() => _isLoading = false);
    _animateProgress(_completionRate);
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_goals.map((g) => g.toJson()).toList()));
  }

  // ─── Computed ─────────────────────────────────────────────────────────────────

  double get _completionRate {
    if (_goals.isEmpty) return 0.0;
    return _goals.where((g) => g.isCompleted).length / _goals.length;
  }

  String _goalStatus(JourneyGoal g) {
    if (g.isCompleted) return 'Completed';
    if (g.deadline.isBefore(DateTime.now())) return 'Overdue';
    return 'In Progress';
  }

  List<JourneyGoal> get _filteredGoals {
    return _goals.where((g) {
      final status = _goalStatus(g);
      final catMatch = _selectedCategory == 'All' || g.category == _selectedCategory;
      // On "All" tab: show pending/overdue always, but only this-week completions.
      // Older completed goals are exclusively visible in the "Completed" tab.
      if (_activeFilter == 'All') {
        if (status == 'Completed') {
          return catMatch && !g.deadline.isBefore(_startOfThisWeek);
        }
        return catMatch;
      }
      return (status == _activeFilter) && catMatch;
    }).toList();
  }

  List<JourneyGoal> get _pendingFiltered =>
      _filteredGoals.where((g) => !g.isCompleted).toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));

  // Start-of-this-week helper (Monday)
  DateTime get _startOfThisWeek {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
  }

  /// On "All" tab: only completed goals from this week (keeps main view clean).
  /// On "Completed" tab: all completed goals, grouped by time period.
  Map<String, List<JourneyGoal>> get _completedGrouped {
    final allCompleted = _filteredGoals.where((g) => g.isCompleted).toList()
      ..sort((a, b) => b.deadline.compareTo(a.deadline));

    final now = DateTime.now();
    final startOfThisWeek = _startOfThisWeek;

    if (_activeFilter == 'All') {
      final thisWeek = allCompleted
          .where((g) => !g.deadline.isBefore(startOfThisWeek))
          .toList();
      if (thisWeek.isEmpty) return {};
      return {AppLocalizations.of(context)!.completedThisWeek: thisWeek};
    }

    // "Completed" tab → full history grouped by period
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final startOfThisMonth = DateTime(now.year, now.month, 1);
    final Map<String, List<JourneyGoal>> groups = {
      AppLocalizations.of(context)!.thisWeek: [],
      AppLocalizations.of(context)!.lastWeek: [],
      AppLocalizations.of(context)!.thisMonth: [],
      AppLocalizations.of(context)!.earlier: [],
    };
    for (final g in allCompleted) {
      if (!g.deadline.isBefore(startOfThisWeek)) {
        groups[AppLocalizations.of(context)!.thisWeek]!.add(g);
      } else if (!g.deadline.isBefore(startOfLastWeek)) {
        groups[AppLocalizations.of(context)!.lastWeek]!.add(g);
      } else if (!g.deadline.isBefore(startOfThisMonth)) {
        groups[AppLocalizations.of(context)!.thisMonth]!.add(g);
      } else {
        groups[AppLocalizations.of(context)!.earlier]!.add(g);
      }
    }
    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }

  String _translateStatus(BuildContext context, String status) {
    switch (status) {
      case 'All': return AppLocalizations.of(context)!.all;
      case 'In Progress': return AppLocalizations.of(context)!.inProgress;
      case 'Completed': return AppLocalizations.of(context)!.completed;
      case 'Overdue': return AppLocalizations.of(context)!.overdue;
      default: return status;
    }
  }

  String _translateCategory(BuildContext context, String cat) {
    switch (cat) {
      case 'All': return AppLocalizations.of(context)!.all;
      case 'Study': return AppLocalizations.of(context)!.catStudy;
      case 'Project': return AppLocalizations.of(context)!.catProject;
      case 'Career': return AppLocalizations.of(context)!.catCareer;
      case 'Personal': return AppLocalizations.of(context)!.catPersonal;
      case 'Other': return AppLocalizations.of(context)!.catOther;
      default: return cat;
    }
  }

  int get _overdueCount => _goals.where((g) => _goalStatus(g) == 'Overdue').length;
  bool get _hasCategoryFilter => _selectedCategory != 'All';

  // ─── Animation ────────────────────────────────────────────────────────────────

  void _animateProgress(double target) {
    final current = _progressAnimation.value;
    _progressAnimation = Tween<double>(begin: current, end: target).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController..reset()..forward();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────────

  void _toggleComplete(String id) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;
    setState(() => _goals[index].isCompleted = !_goals[index].isCompleted);
    _animateProgress(_completionRate);
    _saveGoals();
  }

  Future<void> _openAddGoal({JourneyGoal? existing}) async {
    final result = await Navigator.push<JourneyGoal>(
      context,
      MaterialPageRoute(builder: (_) => AddGoalPage(existingGoal: existing)),
    );
    if (result != null) {
      setState(() {
        final index = _goals.indexWhere((g) => g.id == result.id);
        if (index != -1) _goals[index] = result; else _goals.add(result);
      });
      _animateProgress(_completionRate);
      _saveGoals();
    }
  }

  void _deleteGoal(String id) {
    setState(() => _goals.removeWhere((g) => g.id == id));
    _animateProgress(_completionRate);
    _saveGoals();
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  // ─── Category Bottom Sheet ────────────────────────────────────────────────────

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.filterByCategory,
                style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(AppLocalizations.of(context)!.showGoalsFromSpecificArea,
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: _categoryOptions.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final color = cat == 'All'
                      ? _primaryBlue
                      : (_categoryColors[cat] ?? const Color(0xFF6B7280));
                  return GestureDetector(
                    onTap: () {
                      setSheetState(() => _selectedCategory = cat);
                      setState(() => _selectedCategory = cat);
                      Navigator.pop(ctx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      decoration: BoxDecoration(
                        color: isSelected ? color : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFF)),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? color : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(_translateCategory(context, cat),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = kPrimaryBlue(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(child: _buildFilterBar()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _filteredGoals.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : _buildGoalSliver(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ─── Sliver Header ────────────────────────────────────────────────────────────

  SliverToBoxAdapter _buildSliverHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 16, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                      ),
                    ),
                    const Spacer(),
                    Text(AppLocalizations.of(context)!.futureMap,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 38),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildProgressCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final now = DateTime.now();
    final nextGoal = (() {
      final pending = _goals
          .where((g) => !g.isCompleted && g.deadline.isAfter(now))
          .toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));
      return pending.isNotEmpty ? pending.first : null;
    })();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = kPrimaryBlue(context);
    final darkColor = isDark ? const Color(0xFF4F46E5) : const Color(0xFF1D4ED8);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, darkColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.overallProgress,
                        style: const TextStyle(
                          color: Colors.white60, fontSize: 10,
                          fontWeight: FontWeight.w700, letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (_, __) {
                          final pct = _goals.isEmpty
                              ? 0
                              : (_progressAnimation.value * 100).round();
                          return Text('$pct%',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 44,
                              fontWeight: FontWeight.w900, letterSpacing: -1.5,
                            ),
                          );
                        },
                      ),
                      Text(
                        AppLocalizations.of(context)!.goalsCompleted(_goals.where((g) => g.isCompleted).length, _goals.length),
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (nextGoal != null) ...[
                      Text(AppLocalizations.of(context)!.nextDue,
                        style: const TextStyle(
                          color: Colors.white60, fontSize: 10,
                          fontWeight: FontWeight.w700, letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(_formatDate(nextGoal.deadline),
                        style: const TextStyle(
                          color: Colors.white, fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(nextGoal.title,
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (_overdueCount > 0) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(AppLocalizations.of(context)!.overdueCount(_overdueCount),
                              style: const TextStyle(
                                color: Colors.white, fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (_, __) => LinearProgressIndicator(
                  value: _goals.isEmpty ? 0.0 : _progressAnimation.value,
                  minHeight: 7,
                  backgroundColor: Colors.white.withOpacity(0.20),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Filter Bar ───────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          // Status chips — compact, no border, pill shape
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((f) {
                  final isSelected = _activeFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? kPrimaryBlue(context)
                              : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_translateStatus(context, f),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Category filter — single button, opens sheet
          GestureDetector(
            onTap: _showCategorySheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _hasCategoryFilter
                    ? (_categoryColors[_selectedCategory] ?? kPrimaryBlue(context))
                    .withOpacity(0.10)
                    : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(20),
                border: _hasCategoryFilter
                    ? Border.all(
                  color: _categoryColors[_selectedCategory] ?? kPrimaryBlue(context),
                  width: 1.5,
                )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 14,
                    color: _hasCategoryFilter
                        ? (_categoryColors[_selectedCategory] ?? _primaryBlue)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _hasCategoryFilter ? _translateCategory(context, _selectedCategory) : AppLocalizations.of(context)!.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _hasCategoryFilter
                          ? (_categoryColors[_selectedCategory] ?? kPrimaryBlue(context))
                          : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Goal Sliver ──────────────────────────────────────────────────────────────

  SliverList _buildGoalSliver() {
    final pending = _pendingFiltered;
    final grouped = _completedGrouped;
    final items = <Widget>[];

    if (pending.isNotEmpty) {
      items.add(_buildListHeader(AppLocalizations.of(context)!.upcoming,
          icon: Icons.rocket_launch_rounded, color: _primaryBlue));
      items.addAll(pending.map(_buildGoalCard));
    }

    grouped.forEach((label, goals) {
      items.add(_buildListHeader(label,
          icon: Icons.check_circle_rounded, color: const Color(0xFF10B981)));
      items.addAll(goals.map(_buildGoalCard));
    });

    return SliverList(delegate: SliverChildListDelegate(items));
  }

  Widget _buildListHeader(String title,
      {required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Goal Card ────────────────────────────────────────────────────────────────

  Widget _buildGoalCard(JourneyGoal goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = _goalStatus(goal);
    final catColor = _categoryColors[goal.category] ?? const Color(0xFF6B7280);
    final isOverdue = status == 'Overdue';

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => _deleteGoal(goal.id),
      child: GestureDetector(
        onLongPress: () => _openAddGoal(existing: goal),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: isOverdue
                ? Border.all(
                color: const Color(0xFFEF4444).withOpacity(0.28), width: 1.5)
                : goal.isCompleted
                ? Border.all(
                color: const Color(0xFF10B981).withOpacity(0.22), width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.033),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () => _toggleComplete(goal.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: goal.isCompleted ? _primaryBlue : Colors.transparent,
                      border: Border.all(
                        color: goal.isCompleted
                            ? kPrimaryBlue(context)
                            : isOverdue
                            ? const Color(0xFFEF4444)
                            : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                        width: 2,
                      ),
                    ),
                    child: goal.isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: goal.isCompleted
                              ? (isDark ? Colors.white24 : const Color(0xFFB0BEC5))
                              : (isDark ? Colors.white : const Color(0xFF0F172A)),
                          decoration: goal.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: const Color(0xFFB0BEC5),
                        ),
                      ),
                      if (goal.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(goal.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: goal.isCompleted
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF64748B),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Footer
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 12,
                              color: isOverdue
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFB0BEC5)),
                          const SizedBox(width: 4),
                          Text(_formatDate(goal.deadline),
                            style: TextStyle(
                              fontSize: 11,
                              color: isOverdue
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFB0BEC5),
                              fontWeight: isOverdue
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          _Tag(label: _translateCategory(context, goal.category), color: catColor),
                          if (isOverdue) ...[
                            const SizedBox(width: 6),
                            _Tag(label: AppLocalizations.of(context)!.overdue,
                                color: const Color(0xFFEF4444)),
                          ],
                          if (goal.isCompleted) ...[
                            const SizedBox(width: 6),
                            _Tag(label: AppLocalizations.of(context)!.done,
                                color: const Color(0xFF10B981)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── FAB ─────────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _openAddGoal(),
      backgroundColor: kPrimaryBlue(context),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      label: Text(AppLocalizations.of(context)!.addMilestone,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final isFiltered = _activeFilter != 'All' || _hasCategoryFilter;
    // Distinguish: no goals at all vs no goals matching filter
    final hasAnyGoal = _goals.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76, height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                isFiltered
                    ? Icons.filter_list_off_rounded
                    : Icons.flag_outlined,
                size: 34, color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isFiltered ? AppLocalizations.of(context)!.noGoalsMatch : AppLocalizations.of(context)!.noGoalsYet,
              style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? AppLocalizations.of(context)!.tryChangingFilters
                  : hasAnyGoal
                  ? AppLocalizations.of(context)!.nothingPendingRightNow
                  : AppLocalizations.of(context)!.tapAddMilestoneBelow,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF94A3B8), height: 1.5),
            ),
            if (isFiltered) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setState(() {
                  _activeFilter = 'All';
                  _selectedCategory = 'All';
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(AppLocalizations.of(context)!.clearFilters,
                    style: const TextStyle(
                      color: _primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Tag Widget ───────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700, color: color,
        ),
      ),
    );
  }
}
