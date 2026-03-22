import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class BioEditScreen extends StatefulWidget {
  final String initialBio;
  final String name;
  final VoidCallback onSave;

  const BioEditScreen({
    super.key,
    required this.initialBio,
    required this.name,
    required this.onSave,
  });

  @override
  State<BioEditScreen> createState() => _BioEditScreenState();
}

class _BioEditScreenState extends State<BioEditScreen> {
  late TextEditingController _bioController;
  final AuthService _authService = AuthService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      await _authService.updateProfile(
        widget.name,
        bio: _bioController.text.trim(),
      );
      widget.onSave();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving bio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 100,
        leading: Center(
          child: TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.outfit(
                      color: kPrimaryBlue(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Me',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
             Text(
              'Write something interesting about yourself.',
              style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TextField(
                controller: _bioController,
                maxLines: null,
                expands: false,
                autofocus: true,
                style: GoogleFonts.outfit(fontSize: 16, height: 1.5, color: titleColor),
                decoration: InputDecoration(
                  hintText: 'Enter your bio...',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.outfit(color: isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
