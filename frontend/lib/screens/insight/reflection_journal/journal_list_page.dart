import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/db_helper.dart';
import '../../../models/journal_model.dart';
import 'add_journal_page.dart';
import 'journal_detail_page.dart';
import '../../../generated/l10n/app_localizations.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});

  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  List<JournalEntry> entries = [];
  List<JournalEntry> filteredEntries = [];
  final TextEditingController _searchController = TextEditingController();
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    loadEntries();
    _searchController.addListener(_filterEntries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadEntries() async {
    final data = await DBHelper.instance.getEntries(includeArchived: _showArchived);
    if (mounted) {
      setState(() {
        entries = data;
        filteredEntries = data;
      });
    }
  }

  void _filterEntries() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredEntries = entries;
      } else {
        filteredEntries = entries
            .where((entry) =>
        entry.title.toLowerCase().contains(query) ||
            entry.content.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _toggleShowArchived() async {
    setState(() {
      _showArchived = !_showArchived;
    });
    await loadEntries();
    _filterEntries();
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case "Happy": return Icons.sentiment_satisfied;
      case "Good": return Icons.thumb_up;
      case "Okay": return Icons.pan_tool;
      case "Sad": return Icons.sentiment_dissatisfied;
      case "Bad": return Icons.thumb_down;
      default: return Icons.sentiment_satisfied;
    }
  }

  String _translateMood(BuildContext context, String mood) {
    switch (mood) {
      case "Happy": return AppLocalizations.of(context)!.moodHappy;
      case "Good": return AppLocalizations.of(context)!.moodGood;
      case "Okay": return AppLocalizations.of(context)!.moodOkay;
      case "Sad": return AppLocalizations.of(context)!.moodSad;
      case "Bad": return AppLocalizations.of(context)!.moodBad;
      default: return mood;
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case "Happy": return Colors.green;
      case "Good": return const Color(0xFF3B82F6);
      case "Okay": return Colors.orange;
      case "Sad": return Colors.purple;
      case "Bad": return Colors.red;
      default: return Colors.grey;
    }
  }

  String shortText(String text) =>
      text.length > 60 ? "${text.substring(0, 60)}..." : text;

  Map<String, List<JournalEntry>> groupEntriesByWeek() {
    final Map<String, List<JournalEntry>> grouped = {
      AppLocalizations.of(context)!.thisWeek: [],
      AppLocalizations.of(context)!.lastWeek: [],
      AppLocalizations.of(context)!.older: [],
    };

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));

    for (var entry in filteredEntries) {
      try {
        final parts = entry.date.split(' ');
        final month = _getMonthNumber(parts[0]);
        final day = int.parse(parts[1]);
        final year = now.year;
        final entryDate = DateTime(year, month, day);

        if (entryDate.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
          grouped[AppLocalizations.of(context)!.thisWeek]!.add(entry);
        } else if (entryDate.isAfter(startOfLastWeek.subtract(const Duration(days: 1)))) {
          grouped[AppLocalizations.of(context)!.lastWeek]!.add(entry);
        } else {
          grouped[AppLocalizations.of(context)!.older]!.add(entry);
        }
      } catch (e) {
        grouped[AppLocalizations.of(context)!.older]!.add(entry);
      }
    }
    return grouped;
  }

  int _getMonthNumber(String month) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[month] ?? 1;
  }

  Future<void> _navigateToDetail(JournalEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JournalDetailPage(entry: entry)),
    );
    if (result == true) {
      await loadEntries();
      _filterEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupedEntries = groupEntriesByWeek();
    final primaryColor = kPrimaryBlue(context);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white70 : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.myJournal,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showArchived ? Icons.archive : Icons.archive_outlined,
              color: _showArchived ? Colors.orange[700] : (isDark ? Colors.white54 : Colors.grey[600]),
            ),
            onPressed: _toggleShowArchived,
            tooltip: _showArchived ? AppLocalizations.of(context)!.hideArchived : AppLocalizations.of(context)!.showArchived,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchYourEntries,
                  hintStyle: TextStyle(color: isDark ? Colors.white24 : const Color(0xFF94A3B8)),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.white24 : const Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          if (_showArchived)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.showingArchivedEntries,
                    style: TextStyle(color: Colors.orange[700], fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

          Expanded(
            child: filteredEntries.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchController.text.isNotEmpty ? Icons.search_off : Icons.book_outlined,
                    size: 64,
                    color: isDark ? Colors.white10 : Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                   Text(
                    _searchController.text.isNotEmpty
                        ? AppLocalizations.of(context)!.noEntriesFound
                        : AppLocalizations.of(context)!.noJournalEntriesYet,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.white38 : Colors.grey[500]),
                  ),
                ],
              ),
            )
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (groupedEntries[AppLocalizations.of(context)!.thisWeek]!.isNotEmpty) ...[
                  _buildSectionHeader(AppLocalizations.of(context)!.thisWeek, isDark),
                  ...groupedEntries[AppLocalizations.of(context)!.thisWeek]!.map((e) => _buildEntryCard(e, isDark, primaryColor, cardColor)),
                  const SizedBox(height: 16),
                ],
                if (groupedEntries[AppLocalizations.of(context)!.lastWeek]!.isNotEmpty) ...[
                  _buildSectionHeader(AppLocalizations.of(context)!.lastWeek, isDark),
                  ...groupedEntries[AppLocalizations.of(context)!.lastWeek]!.map((e) => _buildEntryCard(e, isDark, primaryColor, cardColor)),
                  const SizedBox(height: 16),
                ],
                if (groupedEntries[AppLocalizations.of(context)!.older]!.isNotEmpty) ...[
                  _buildSectionHeader(AppLocalizations.of(context)!.older, isDark),
                  ...groupedEntries[AppLocalizations.of(context)!.older]!.map((e) => _buildEntryCard(e, isDark, primaryColor, cardColor)),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddJournalPage()),
          );
          if (result == true) {
            await loadEntries();
            _filterEntries();
          }
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white38 : Colors.black54,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry e, bool isDark, Color primaryColor, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _getMoodColor(e.mood).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getMoodIcon(e.mood), color: _getMoodColor(e.mood), size: 24),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  e.title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 16,
                  ),
                ),
              ),
              if (e.isArchived) ...[
                const SizedBox(width: 8),
                Icon(Icons.archive, size: 14, color: Colors.orange[700]),
              ],
              const SizedBox(width: 8),
              Text(
                e.date,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white24 : Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              shortText(e.content),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          onTap: () => _navigateToDetail(e),
        ),
      ),
    );
  }
}
