import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';
import '../screens/interest_picker_screen.dart';
import '../screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    
    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );
    
    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    
    // Delayed shimmer effect
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _shimmerController.repeat(reverse: true);
      }
    });

    // Check Auth and Configure Navigation
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for minimum splash duration (e.g. 3 seconds)
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (mounted) {
        if (isLoggedIn) {
          // Check if user has selected interests
          final user = await _authService.getUser();
          final interestIds = user['interestIds'];

          if (interestIds == null || (interestIds is List && interestIds.isEmpty)) {
            Navigator.of(context).pushReplacement(_createRoute(const InterestPickerScreen()));
          } else {
            Navigator.of(context).pushReplacement(_createRoute(const HomePage()));
          }
        } else {
          Navigator.of(context).pushReplacement(_createRoute(const LoginScreen()));
        }
      }
    } catch (e) {
      // Fallback to login on error
      if (mounted) {
        Navigator.of(context).pushReplacement(_createRoute(const LoginScreen()));
      }
    }
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: curve));
        var scaleAnimation = animation.drive(tween);
        var fadeAnimation = animation.drive(Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)));

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001a4d),
              Color(0xFF003d99),
              Color(0xFF0059cc),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated circles background
            ...List.generate(5, (index) {
              return AnimatedCircle(
                delay: index * 0.3,
                size: 150.0 + (index * 50),
              );
            }),
            
            // Main logo content
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _fadeAnimation,
                  _scaleAnimation,
                ]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(
                        'assets/evolve_logo.png',
                        width: 120,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedCircle extends StatefulWidget {
  final double delay;
  final double size;

  const AnimatedCircle({
    Key? key,
    required this.delay,
    required this.size,
  }) : super(key: key);

  @override
  State<AnimatedCircle> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<AnimatedCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 3000 + (widget.delay * 1000).toInt()),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width / 2 - widget.size / 2,
          top: MediaQuery.of(context).size.height / 2 - widget.size / 2,
          child: Opacity(
            opacity: 0.1 * (1 - _animation.value),
            child: Container(
              width: widget.size + (widget.size * 0.5 * _animation.value),
              height: widget.size + (widget.size * 0.5 * _animation.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
