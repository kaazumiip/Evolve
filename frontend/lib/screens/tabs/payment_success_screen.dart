import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/services/api_service.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String planName;

  const PaymentSuccessScreen({
    super.key,
    required this.planName,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rippleController;
  
  late Animation<double> _checkScale;
  late Animation<double> _ripple1;
  late Animation<double> _ripple2;
  late Animation<double> _rippleOp;

  @override
  void initState() {
    super.initState();
    _updateSubscription();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _checkScale = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutBack,
    );

    _ripple1 = Tween<double>(begin: 0.8, end: 1.8).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _ripple2 = Tween<double>(begin: 0.8, end: 2.4).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _rippleOp = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _mainController.forward();
  }

  Future<void> _updateSubscription() async {
    final apiService = ApiService();
    await apiService.updateSubscription(widget.planName);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final limeColor = const Color(0xFFD4FF00); // Vibrant Neon Lime
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white : const Color(0xFF64748B); // Change gray to white in dark mode

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bgColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              SizedBox(
                width: 320,
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripples
                    AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: _ripple2.value,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: limeColor.withOpacity(_rippleOp.value * 0.5), width: 2),
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: _ripple1.value,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: limeColor.withOpacity(_rippleOp.value * 0.3),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    
                    // Center Check
                    ScaleTransition(
                      scale: _checkScale,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: limeColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: limeColor.withOpacity(0.4),
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF0F172A), // Dark contrast
                          size: 70, 
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 56),
              
              Text(
                'Payment Successful',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome to your growth journey.',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: subTextColor,
                ),
              ),
              
              const Spacer(),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: limeColor,
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Start Exploring',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
