import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'dart:math';
import 'dart:async';

const Color kPrimaryBlue = Color(0xFF2563EB);

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 1; // 1: Email, 2: OTP, 3: New Password
  bool _isLoading = false;
  bool _isOTPError = false;
  bool _isOTPSuccess = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _successController;
  late List<Animation<double>> _boxPulseAnimations;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    _successController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _boxPulseAnimations = List.generate(6, (index) {
      double start = index * 0.12; 
      double end = start + 0.3;
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
      ]).animate(CurvedAnimation(parent: _successController, curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.easeInOut)));
    });

    _sparkleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _sendOTP());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (var c in _otpControllers) c.dispose();
    for (var f in _otpFocusNodes) f.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your email')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.forgotPassword(_emailController.text.trim());
      setState(() => _step = 2);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the 6-digit code')));
      return;
    }

    setState(() {
      _isLoading = true;
      _isOTPError = false;
      _isOTPSuccess = false;
    });

    try {
      final isValid = await _authService.verifyOTP(
        _emailController.text.trim(),
        otp,
        'password_reset',
      );
      
      if (isValid) {
        setState(() => _isOTPSuccess = true);
        _sparkleController.forward();
        await _successController.forward();
        await Future.delayed(const Duration(milliseconds: 400));
        setState(() => _step = 3);
      } else {
        _handleOTPError();
      }
    } catch (e) {
      _handleOTPError();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleOTPError() {
    setState(() {
      _isOTPError = true;
      _isLoading = false;
    });
    _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && _isOTPError) {
        for (var c in _otpControllers) c.clear();
        _otpFocusNodes[0].requestFocus();
        setState(() => _isOTPError = false);
      }
    });
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a new password')));
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String otp = _otpControllers.map((c) => c.text).join();
      await _authService.resetPassword(
        _emailController.text.trim(),
        otp,
        _newPasswordController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final accentColor = const Color(0xFF6366F1);

    String stepTitle = 'Reset Password';
    String stepDesc = '';
    
    if (_step == 1) {
      stepTitle = 'Forgot Password?';
      stepDesc = 'Enter your email to receive a recovery code.';
    } else if (_step == 2) {
      stepTitle = 'Verification';
      stepDesc = 'We sent a 6-digit code to ${_emailController.text}';
    } else {
      stepTitle = 'New Password';
      stepDesc = 'Create a secure password for your account.';
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Account Recovery', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: titleColor)),
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              stepTitle,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: titleColor),
            ),
            const SizedBox(height: 8),
            Text(
              stepDesc,
              style: GoogleFonts.outfit(fontSize: 15, color: subtitleColor),
            ),
            const SizedBox(height: 32),
            
            if (_step == 1) ...[
              _buildLabel('Email Address', titleColor),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hint: 'example@gmail.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isDark: isDark,
              ),
              const SizedBox(height: 48),
              _buildButton(text: 'Send Code', onPressed: _isLoading ? null : _sendOTP, color: accentColor),
            ] else if (_step == 2) ...[
              _buildLabel('Verification Code', titleColor),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value * (sin(_shakeController.value * 10 * pi)), 0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) => 
                            ScaleTransition(
                              scale: _isOTPSuccess ? _boxPulseAnimations[index] : const AlwaysStoppedAnimation(1.0),
                              child: _buildOTPBox(index, isDark, accentColor),
                            )
                          ),
                        ),
                        if (_isOTPSuccess)
                          ...List.generate(12, (index) {
                            return AnimatedBuilder(
                              animation: _sparkleController,
                              builder: (context, child) {
                                final progress = _sparkleController.value;
                                final angle = (index * (360 / 12)) * (pi / 180);
                                final radius = 60 + (progress * 40);
                                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                                return Positioned(
                                  left: (MediaQuery.of(context).size.width / 2) - 44 + cos(angle) * radius,
                                  top: sin(angle) * radius,
                                  child: Opacity(
                                    opacity: opacity,
                                    child: const Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 16),
                                  ),
                                );
                              },
                            );
                          }),
                      ],
                    ),
                  );
                },
              ),
              if (_isOTPError)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(child: Text('Invalid code. Please try again.', style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 13))),
                ),
               const SizedBox(height: 48),
              _buildButton(text: 'Verify identity', onPressed: _isLoading ? null : _verifyOTP, color: accentColor),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _step = 1),
                  child: Text(
                    'Resend Code',
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ] else ...[
              _buildLabel('New Password', titleColor),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _newPasswordController,
                hint: 'Minimum 6 characters',
                icon: Icons.lock_outline,
                obscure: true,
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              _buildLabel('Confirm Password', titleColor),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _confirmPasswordController,
                hint: 'Retype your password',
                icon: Icons.lock_outline,
                obscure: true,
                isDark: isDark,
              ),
              const SizedBox(height: 80),
              _buildButton(text: 'Update Password', onPressed: _isLoading ? null : _resetPassword, color: accentColor),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index, bool isDark, Color accentColor) {
    Color borderColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);
    Color bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFF);
    
    if (_isOTPSuccess) {
      borderColor = Colors.green.shade400;
      bgColor = isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50;
    } else if (_isOTPError) {
      borderColor = Colors.red.shade400;
      bgColor = isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50;
    } else if (_otpFocusNodes[index].hasFocus) {
      borderColor = accentColor;
    }

    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        enabled: !_isLoading && !_isOTPSuccess,
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _isOTPError ? Colors.red : (_isOTPSuccess ? Colors.green : (isDark ? Colors.white : const Color(0xFF1E293B))),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _otpFocusNodes[index + 1].requestFocus();
            } else {
              _otpFocusNodes[index].unfocus();
              _verifyOTP();
            }
          } else if (value.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
          setState(() {}); 
        },
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    int? maxLength,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          counterText: "",
          prefixIcon: Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF64748B), size: 20),
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: isDark ? Colors.white30 : const Color(0xFF94A3B8), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback? onPressed, required Color color}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
