import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../generated/l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onUpdate;

  const EditProfileScreen({super.key, required this.userData, required this.onUpdate});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllFields)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.updateProfile(
        _nameController.text.trim(),
        email: _emailController.text.trim() != widget.userData['email'] 
            ? _emailController.text.trim() 
            : null,
      );
      
      widget.onUpdate();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? Colors.white : const Color(0xFF64748B); // Pure white in dark mode
    final inputBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFF);
    final inputBorderColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);
    final accentColor = const Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.editProfileInfo,
              style: GoogleFonts.raleway(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.updateAccountInfo,
              style: GoogleFonts.raleway(
                fontSize: 15,
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 40),
            
            _buildLabel(AppLocalizations.of(context)!.fullName, titleColor, isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: AppLocalizations.of(context)!.fullName,
              icon: Icons.person_outline,
              bgColor: inputBgColor,
              borderColor: inputBorderColor,
              isDark: isDark,
            ),
            
            const SizedBox(height: 24),
            
            _buildLabel(AppLocalizations.of(context)!.emailAddress, titleColor, isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: AppLocalizations.of(context)!.emailAddress,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              bgColor: inputBgColor,
              borderColor: inputBorderColor,
              isDark: isDark,
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        AppLocalizations.of(context)!.saveChanges,
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.raleway(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : color,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    required Color bgColor,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.raleway(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF64748B), size: 20),
          hintText: hint,
          hintStyle: GoogleFonts.raleway(color: isDark ? Colors.white30 : const Color(0xFF94A3B8), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
