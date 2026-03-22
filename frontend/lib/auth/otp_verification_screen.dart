import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'dart:async';
import 'dart:math';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String type; // 'registration', 'password_reset', 'password_change'

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.type,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _successController;
  late Animation<double> _bounceAnimation;
  
  bool _isLoading = false;
  bool _isError = false;
  bool _isSuccess = false;
  int _resendTimer = 60;
  Timer? _timer;

  // Staggered animations for boxes
  late List<Animation<double>> _boxPulseAnimations;
  // Sparkle animations
  late AnimationController _sparkleController;
  late List<Point<double>> _sparkleOffsets;

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Shake animation for error
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Simplified staggered pulse for boxes
    _boxPulseAnimations = List.generate(6, (index) {
      double start = index * 0.12; // More staggered
      double end = start + 0.3;
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
      ]).animate(
        CurvedAnimation(
          parent: _successController,
          curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.easeInOut),
        ),
      );
    });

    // Sparkle animations
    _sparkleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _sparkleOffsets = List.generate(12, (_) => Point(Random().nextDouble(), Random().nextDouble()));
    
    _animationController.forward();
  }

  void _startTimer() {
    _resendTimer = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _animationController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  Future<void> _resendCode() async {
    if (_resendTimer > 0) return;
    
    setState(() => _isLoading = true);
    try {
      await _authService.sendOTP(widget.email, widget.type);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code resent!')),
      );
      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onOTPChanged() {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOTP(otp);
    }
  }

  Future<void> _verifyOTP(String otp) async {
    setState(() {
      _isLoading = true;
      _isError = false;
      _isSuccess = false;
    });

    try {
      // Small delay to let user see the last digit filled
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Verification logic depends on type
      bool isValid = false;
      if (widget.type == 'registration') {
        // For registration, we just return the OTP for the signup screen to use
        // But we can do a mock "pre-verify" or just assume success if it's 6 digits
        isValid = otp.length == 6;
      } else {
        isValid = await _authService.verifyOTP(widget.email, otp, widget.type);
      }
      
      if (isValid) {
        setState(() => _isSuccess = true);
        _sparkleController.forward();
        await _successController.forward();
        // Give time for animations
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) Navigator.pop(context, otp);
      } else {
        _triggerError();
      }
    } catch (e) {
      _triggerError();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _triggerError() {
    setState(() {
      _isError = true;
      _isLoading = false;
    });
    _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
    // Clear OTP on error after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && _isError) {
        for (var c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
        setState(() => _isError = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? Colors.white : const Color(0xFF64748B); // Change to white
    final accentColor = const Color(0xFF6366F1); // Purple-Blue

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 48,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Verify Your Email',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Please enter the 6-digit code sent to\n'),
                    TextSpan(
                      text: widget.email,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value * (sin(_shakeController.value * 10 * pi)), 0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // OTP Boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) => 
                            ScaleTransition(
                              scale: _isSuccess ? _boxPulseAnimations[index] : const AlwaysStoppedAnimation(1.0),
                              child: _buildOTPBox(index),
                            )
                          ),
                        ),
                        // Sparkles
                        if (_isSuccess)
                          ...List.generate(12, (index) {
                            return AnimatedBuilder(
                              animation: _sparkleController,
                              builder: (context, child) {
                                final progress = _sparkleController.value;
                                final angle = (index * (360 / 12)) * (pi / 180);
                                final radius = 60 + (progress * 40);
                                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                                
                                return Positioned(
                                  left: (MediaQuery.of(context).size.width / 2) - 24 + cos(angle) * radius,
                                  top: (radius / 3) + sin(angle) * radius,
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
              const SizedBox(height: 12),
              if (_isError)
                Text(
                  'Invalid verification code. Please try again.',
                  style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              const SizedBox(height: 48),
              if (_isLoading)
                 CircularProgressIndicator(color: accentColor)
              else ...[
                Text(
                  _resendTimer > 0 
                    ? 'Resend code in ${_resendTimer}s' 
                    : 'Didn\'t receive the code?',
                  style: GoogleFonts.outfit(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: _resendTimer > 0 ? null : _resendCode,
                  child: Text(
                    'Resend Code',
                    style: GoogleFonts.outfit(
                      color: _resendTimer > 0 ? (isDark ? Colors.white24 : Colors.grey) : accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading 
                      ? null 
                      : () {
                          String otp = _controllers.map((c) => c.text).join();
                          if (otp.length == 6) {
                            _verifyOTP(otp);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter all 6 digits')),
                            );
                          }
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Verify Code',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = const Color(0xFF6366F1);
    Color borderColor = isDark ? Colors.white10 : const Color(0xFFE2E8F0);
    Color bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFF);
    
    if (_isSuccess) {
      borderColor = Colors.green.shade400;
      bgColor = isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50;
    } else if (_isError) {
      borderColor = Colors.red.shade400;
      bgColor = isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50;
    } else if (_focusNodes[index].hasFocus) {
      borderColor = accentColor;
    }

    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: (_isSuccess || _isError) ? [
          BoxShadow(
            color: (_isSuccess ? Colors.green : Colors.red).withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ] : null,
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        enabled: !_isLoading && !_isSuccess,
        style: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _isError ? Colors.red : (_isSuccess ? Colors.green : (isDark ? Colors.white : const Color(0xFF1E293B))),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              _onOTPChanged();
            }
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
