import 'package:flutter/material.dart';
import '../main.dart';
import '../core/auth_service.dart';
import 'register_screen.dart';
import 'location_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Harap isi email dan password');
      return;
    }

    setState(() => _isLoading = true);

    final user = await AuthService.login(
      email,
      password,
      onError: (msg) {
        if (mounted) _showSnackBar(msg);
      },
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      _navigateAfterLogin(user);
    }
  }

  void _loginWithGoogle() async {
    setState(() => _isLoading = true);
    final user = await AuthService.loginWithGoogle(
      onError: (msg) {
        if (mounted) _showSnackBar(msg);
      },
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (user != null) {
      _navigateAfterLogin(user);
    }
  }

  Future<void> _navigateAfterLogin(Map<String, dynamic> user) async {
    final firstLogin = await AuthService.isFirstLogin();
    if (!mounted) return;

    if (firstLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LocationSetupScreen(user: user),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigation(isWorkerMode: user['isWorkerMode'] ?? false),
        ),
      );
    }
  }

  void _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Masukkan email kamu terlebih dahulu');
      return;
    }

    setState(() => _isLoading = true);
    final error = await AuthService.sendPasswordReset(email);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      _showSnackBar('Email reset password telah dikirim ke $email ✉️', isSuccess: true);
    } else {
      _showSnackBar(error);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Inter')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? const Color(0xFF22C55E) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // ── Logo ───────────────────────────────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.explore_rounded,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Heading ────────────────────────────────────────────
              const Text(
                'Selamat Datang',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masuk ke akun Pion Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 48),

              // ── Email ──────────────────────────────────────────────
              _label('Email'),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('contoh@email.com', Icons.person_outline),
              ),
              const SizedBox(height: 20),

              // ── Password ───────────────────────────────────────────
              _label('Kata Sandi'),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: _inputDecoration(
                  'Masukkan kata sandi',
                  Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 22,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),
              ),

              // ── Forgot Password ────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading ? null : _forgotPassword,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  ),
                  child: const Text('Lupa Kata Sandi?'),
                ),
              ),
              const SizedBox(height: 16),

              // ── Login Button ───────────────────────────────────────
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Masuk'),
                ),
              ),
              const SizedBox(height: 24),

              // ── Divider ───────────────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'atau masuk dengan',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                ],
              ),
              const SizedBox(height: 20),

              // ── Google Sign-In Button ──────────────────────────
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _loginWithGoogle,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CustomPaint(painter: GoogleLogoPainter()),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Lanjutkan dengan Google',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Register ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      );

  static InputDecoration _inputDecoration(String hint, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 22, color: const Color(0xFF94A3B8)),
        suffixIcon: suffix,
      );
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    const strokeW = 4.5;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeW / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    const pi = 3.14159265358979;
    final segments = [
      [-pi / 4, pi * 0.6, const Color(0xFF4285F4)],
      [pi * 0.35, pi * 0.55, const Color(0xFFEA4335)],
      [pi * 0.9, pi * 0.55, const Color(0xFFFBBC05)],
      [pi * 1.45, pi * 0.6, const Color(0xFF34A853)],
    ];

    for (final seg in segments) {
      paint.color = seg[2] as Color;
      canvas.drawArc(rect, seg[0] as double, seg[1] as double, false, paint);
    }

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - strokeW / 2, r - strokeW / 2, strokeW),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
