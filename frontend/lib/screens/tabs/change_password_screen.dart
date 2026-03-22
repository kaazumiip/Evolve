import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/forgot_password_screen.dart';
import '../../auth/otp_verification_screen.dart';
import '../../generated/l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onUpdate;
  const ChangePasswordScreen({super.key, required this.userData, this.onUpdate});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  bool _isLoading = false;

  bool get _isPasswordSet => widget.userData['is_password_set'] == 1 || widget.userData['is_password_set'] == true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_newPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.enterNewPassword)));
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (!_isPasswordSet) {
        await _authService.sendOTP(widget.userData['email'], 'password_change');
        
        if (mounted) {
          final otp = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                email: widget.userData['email'],
                type: 'password_change',
              ),
            ),
          );
          if (otp != null) {
            setState(() => _isLoading = true);
            await _authService.changePassword(
              newPassword: _newPasswordController.text.trim(),
              otp: otp,
            );
            _completeSuccess();
          }
        }
      } else {
        if (_oldPasswordController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.enterCurrentPassword)));
          return;
        }

        await _authService.changePassword(
          oldPassword: _oldPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
        );
        _completeSuccess();
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

  void _completeSuccess() {
    if (mounted) {
      widget.onUpdate?.call();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.passwordUpdatedSuccessfully)),
      );
    }
  }

  void _handleForgotPassword() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPasswordScreen(
          initialEmail: widget.userData['email'],
        ),
      ),
    );
    if (result == true && mounted) {
       Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? Colors.white : const Color(0xFF64748B);
    final inputBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFF);
    final inputBorderColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      _isPasswordSet ? AppLocalizations.of(context)!.changePasswordTitle : AppLocalizations.of(context)!.setNewPassword,
                      style: GoogleFonts.raleway(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isPasswordSet 
                          ? AppLocalizations.of(context)!.updateSecurityCredentials 
                          : AppLocalizations.of(context)!.createSecurePassword,
                      style: GoogleFonts.raleway(
                        fontSize: 15,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    if (_isPasswordSet) ...[
                      _buildLabel(AppLocalizations.of(context)!.currentPassword, titleColor, isDark),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _oldPasswordController,
                        hint: AppLocalizations.of(context)!.passwordHint,
                        bgColor: inputBgColor,
                        borderColor: inputBorderColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    _buildLabel(AppLocalizations.of(context)!.newPassword, titleColor, isDark),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      hint: AppLocalizations.of(context)!.min6CharsHint,
                      bgColor: inputBgColor,
                      borderColor: inputBorderColor,
                      isDark: isDark,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildLabel(AppLocalizations.of(context)!.confirmNewPassword, titleColor, isDark),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hint: AppLocalizations.of(context)!.retypePasswordHint,
                      bgColor: inputBgColor,
                      borderColor: inputBorderColor,
                      isDark: isDark,
                    ),
                    
                    if (_isPasswordSet)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : _handleForgotPassword,
                          child: Text(
                            AppLocalizations.of(context)!.forgotCurrentPassword,
                            style: GoogleFonts.raleway(
                              color: const Color(0xFF6366F1),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: _buildUpdateButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
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
                AppLocalizations.of(context)!.updatePassword,
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
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
        obscureText: true,
        style: GoogleFonts.raleway(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.white38 : const Color(0xFF64748B), size: 20),
          hintText: hint,
          hintStyle: GoogleFonts.raleway(color: isDark ? Colors.white30 : const Color(0xFF94A3B8), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
