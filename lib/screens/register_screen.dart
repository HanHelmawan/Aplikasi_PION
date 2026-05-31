import 'package:flutter/material.dart';
import '../core/auth_service.dart';
import 'login_screen.dart';
import 'location_setup_screen.dart';
import '../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;
  bool _isWorkerMode = false;

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Harap lengkapi semua data');
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password minimal 6 karakter');
      return;
    }

    setState(() => _isLoading = true);

    final error = await AuthService.register(name, email, password, _isWorkerMode);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      final user = await AuthService.getCurrentUser();
      if (!mounted) return;
      if (user != null) _navigateAfterLogin(user);
    } else {
      _showSnackBar(error);
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
    if (user != null) _navigateAfterLogin(user);
  }

  Future<void> _navigateAfterLogin(Map<String, dynamic> user) async {
    final firstLogin = await AuthService.isFirstLogin();
    if (!mounted) return;
    if (firstLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LocationSetupScreen(user: user)),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
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
              const SizedBox(height: 32),

              // ── Heading ────────────────────────────────────────────
              const Text(
                'Buat Akun Baru',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bergabung dengan Pion sekarang',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 48),

              // ── Name ──────────────────────────────────────────────
              _label('Nama Lengkap'),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration('John Doe', Icons.badge_outlined),
              ),
              const SizedBox(height: 20),

              // ── Email ──────────────────────────────────────────────
              _label('Email'),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('contoh@email.com', Icons.email_outlined),
              ),
              const SizedBox(height: 20),

              // ── Password ───────────────────────────────────────────
              _label('Kata Sandi'),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: _inputDecoration(
                  'Minimal 6 karakter',
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
              const SizedBox(height: 20),

              // ── Role ──────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CheckboxListTile(
                  value: _isWorkerMode,
                  onChanged: (val) => setState(() => _isWorkerMode = val ?? false),
                  title: const Text(
                    'Daftar sebagai Pekerja (Worker)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Pilih ini jika kamu ingin menawarkan jasa',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              const SizedBox(height: 32),

              // ── Register Button ────────────────────────────────────
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Daftar Sekarang'),
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
                      'atau daftar dengan',
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

              // ── Login ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Masuk',
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
