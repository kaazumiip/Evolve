import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/db_helper.dart';
import '../../../models/journal_model.dart';
import '../../../generated/l10n/app_localizations.dart';

class AddJournalPage extends StatefulWidget {
  final JournalEntry? entryToEdit;

  const AddJournalPage({super.key, this.entryToEdit});

  @override
  State<AddJournalPage> createState() => _AddJournalPageState();
}

class _AddJournalPageState extends State<AddJournalPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String selectedMood = "Happy";
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.entryToEdit != null) {
      _isEditing = true;
      titleController.text = widget.entryToEdit!.title;
      contentController.text = widget.entryToEdit!.content;
      selectedMood = widget.entryToEdit!.mood;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> saveEntry() async {
    // Prevent multiple saves
    if (_isSaving) {
      print("Already saving, please wait...");
      return;
    }

    final title = titleController.text.trim();
    final content = contentController.text.trim();

    print("=== SAVE BUTTON CLICKED ===");
    print("Title: $title");
    print("Content: $content");
    print("Mood: $selectedMood");

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseFillBothTitleAndContent),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final date = DateFormat('MMM dd').format(DateTime.now());
      print("Date formatted: $date");

      if (_isEditing && widget.entryToEdit != null) {
        print("=== UPDATING EXISTING ENTRY ===");
        final updatedEntry = widget.entryToEdit!.copyWith(
          title: title,
          content: content,
          mood: selectedMood,
        );
        print("Updated entry: ${updatedEntry.toMap()}");

        await DBHelper.instance.updateEntry(updatedEntry);
        print("Entry updated successfully!");
      } else {
        print("=== CREATING NEW ENTRY ===");
        final entry = JournalEntry(
          title: title,
          content: content,
          mood: selectedMood,
          date: date,
        );
        print("New entry: ${entry.toMap()}");

        final id = await DBHelper.instance.insertEntry(entry);
        print("Entry saved successfully with ID: $id");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? AppLocalizations.of(context)!.updatedSuccessfully : AppLocalizations.of(context)!.savedSuccessfully),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 2),
          ),
        );

        // Wait a moment for the user to see the success message
        await Future.delayed(const Duration(milliseconds: 500));

        // Go back and tell the previous page to refresh
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print("=== ERROR SAVING ENTRY ===");
      print("Error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSavingEntry(e.toString())),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget moodButton(String mood, IconData icon) {
    final isSelected = selectedMood == mood;
    return GestureDetector(
      onTap: () {
        print("Mood selected: $mood");
        setState(() => selectedMood = mood);
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF215AE2) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF215AE2) : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF215AE2),
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _translateMood(context, mood),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF215AE2) : Colors.grey[700],
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              _isEditing ? AppLocalizations.of(context)!.editReflection : AppLocalizations.of(context)!.myDailyReflection,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                DateFormat('EEEE, d MMMM').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood Selection Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.howAreYouFeelingToday,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        moodButton("Happy", Icons.sentiment_satisfied),
                        moodButton("Good", Icons.thumb_up),
                        moodButton("Okay", Icons.pan_tool),
                        moodButton("Sad", Icons.sentiment_dissatisfied),
                        moodButton("Bad", Icons.thumb_down),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Journal Entry Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.journalEntry,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context)!.journalEntrySubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title Field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F1FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: titleController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.title,
                          hintStyle: const TextStyle(
                            color: Color(0xFF8AABCC),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Content Field
                    Container(
                      height: 350,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F1FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          TextField(
                            controller: contentController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.startWritingYourThoughts,
                              hintStyle: const TextStyle(
                                color: Color(0xFF8AABCC),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF215AE2),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: const Color(0xFF215AE2).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    _isEditing ? AppLocalizations.of(context)!.updateReflection : AppLocalizations.of(context)!.saveReflection,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
