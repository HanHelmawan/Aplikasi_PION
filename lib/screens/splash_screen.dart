import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/auth_service.dart';
import '../main.dart';
import 'onboarding_screen.dart';
import 'location_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // Enable sticky immersive mode (completely full screen, hides status and navigation bars)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // After animation + brief hold, decide where to go
    Future.delayed(const Duration(milliseconds: 2000), _navigate);
  }

  Future<void> _navigate() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (firebaseUser == null) {
      // No active session → show onboarding
      _pushReplacement(const OnboardingScreen());
    } else {
      // User is logged in → get full user data from Firestore
      final user = await AuthService.getCurrentUser();
      if (!mounted) return;

      final firstLogin = await AuthService.isFirstLogin();
      if (!mounted) return;

      if (firstLogin && user != null) {
        _pushReplacement(LocationSetupScreen(user: user));
      } else {
        _pushReplacement(
          MainNavigation(isWorkerMode: user?['isWorkerMode'] ?? false),
        );
      }
    }
  }

  void _pushReplacement(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    // Restore edge-to-edge mode and standard status bar styling when leaving the splash screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF3B82F6),
              Color(0xFF1D4ED8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Animated Logo ───────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    children: [
                      // Logo Container
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.explore_rounded,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // App Name
                      const Text(
                        'Pion',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tagline
                      Text(
                        'Jasa Hiperlokal di Sekitarmu',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── Loading Indicator ───────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat aplikasi...',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
