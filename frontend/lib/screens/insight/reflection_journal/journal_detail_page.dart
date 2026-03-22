import 'package:flutter/material.dart';
import '../../../services/db_helper.dart';
import '../../../models/journal_model.dart';
import 'add_journal_page.dart';
import '../../../generated/l10n/app_localizations.dart';

class JournalDetailPage extends StatefulWidget {
  final JournalEntry entry;

  const JournalDetailPage({super.key, required this.entry});

  @override
  State<JournalDetailPage> createState() => _JournalDetailPageState();
}

class _JournalDetailPageState extends State<JournalDetailPage> {
  late JournalEntry currentEntry;

  @override
  void initState() {
    super.initState();
    currentEntry = widget.entry;
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case "Happy":
        return Icons.sentiment_satisfied;
      case "Good":
        return Icons.thumb_up;
      case "Okay":
        return Icons.pan_tool;
      case "Sad":
        return Icons.sentiment_dissatisfied;
      case "Bad":
        return Icons.thumb_down;
      default:
        return Icons.sentiment_satisfied;
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case "Happy":
        return Colors.green;
      case "Good":
        return Colors.blue;
      case "Okay":
        return Colors.orange;
      case "Sad":
        return Colors.purple;
      case "Bad":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _deleteEntry() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)!.deleteEntry),
        content: Text(AppLocalizations.of(context)!.deleteEntryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && currentEntry.id != null) {
      await DBHelper.instance.deleteEntry(currentEntry.id!);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _toggleArchive() async {
    if (currentEntry.id != null) {
      final newArchiveStatus = !currentEntry.isArchived;
      await DBHelper.instance.archiveEntry(currentEntry.id!, newArchiveStatus);

      setState(() {
        currentEntry = currentEntry.copyWith(isArchived: newArchiveStatus);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newArchiveStatus ? AppLocalizations.of(context)!.entryArchived : AppLocalizations.of(context)!.entryUnarchived,
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _editEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddJournalPage(entryToEdit: currentEntry),
      ),
    );

    if (result == true && currentEntry.id != null) {
      final entries = await DBHelper.instance.getEntries(includeArchived: true);
      final updatedEntry = entries.firstWhere(
            (e) => e.id == currentEntry.id,
        orElse: () => currentEntry,
      );

      setState(() {
        currentEntry = updatedEntry;
      });
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF215AE2)),
              title: Text(AppLocalizations.of(context)!.edit),
              onTap: () {
                Navigator.pop(context);
                _editEntry();
              },
            ),
            ListTile(
              leading: Icon(
                currentEntry.isArchived ? Icons.unarchive : Icons.archive,
                color: Colors.orange[700],
              ),
              title: Text(currentEntry.isArchived ? AppLocalizations.of(context)!.unarchive : AppLocalizations.of(context)!.archive),
              onTap: () {
                Navigator.pop(context);
                _toggleArchive();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteEntry();
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          AppLocalizations.of(context)!.journalEntry,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentEntry.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF215AE2),
                          ),
                        ),
                      ),
                      if (currentEntry.isArchived)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.archived,
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Mood Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getMoodColor(currentEntry.mood).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getMoodColor(currentEntry.mood).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getMoodIcon(currentEntry.mood),
                              size: 16,
                              color: _getMoodColor(currentEntry.mood),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _translateMood(context, currentEntry.mood),
                              style: TextStyle(
                                color: _getMoodColor(currentEntry.mood),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        currentEntry.date,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                currentEntry.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _editEntry,
                      icon: const Icon(Icons.edit),
                      label: Text(AppLocalizations.of(context)!.edit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF215AE2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _toggleArchive,
                      icon: Icon(
                        currentEntry.isArchived ? Icons.unarchive : Icons.archive,
                      ),
                      label: Text(currentEntry.isArchived ? AppLocalizations.of(context)!.unarchive : AppLocalizations.of(context)!.archive),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange[700],
                        side: BorderSide(color: Colors.orange[700]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _deleteEntry,
                  icon: const Icon(Icons.delete),
                  label: Text(AppLocalizations.of(context)!.deleteEntry),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
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
}
