import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.location_on_outlined,
      title: 'Cari Jasa Sekitar',
      subtitle: 'Temukan penyedia jasa terverifikasi untuk segala kebutuhan dalam radius 1–5 km dari lokasi Anda.',
      color: Color(0xFF0525BB),
    ),
    _OnboardingPage(
      icon: Icons.verified_user_outlined,
      title: 'Pilih Mitra Terbaik',
      subtitle: 'Lihat profil, keahlian, dan ulasan asli dari pengguna lain sebelum memilih mitra kerja.',
      color: Color(0xFF0525BB),
    ),
    _OnboardingPage(
      icon: Icons.chat_bubble_outline,
      title: 'Pesan & Sepakati',
      subtitle: 'Gunakan fitur pesan untuk menjelaskan detail tugas dan menyepakati harga dengan mudah.',
      color: Color(0xFF0525BB),
    ),
    _OnboardingPage(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Bayar di Tempat',
      subtitle: 'Tanpa top-up saldo! Lakukan pembayaran langsung setelah tugas diselesaikan dengan sempurna.',
      color: Color(0xFF0525BB),
    ),
    _OnboardingPage(
      icon: Icons.star_outline_rounded,
      title: 'Selesai & Ulas',
      subtitle: 'Konfirmasi penyelesaian di aplikasi dan berikan ulasan untuk membantu komunitas Pion.',
      color: Color(0xFF0525BB),
    ),
  ];

  void _skip() => Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _skip();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip Button ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF94A3B8),
                  ),
                  child: const Text('Lewati'),
                ),
              ),
            ),

            // ── Pages ────────────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _pages[i],
              ),
            ),

            // ── Indicators ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: active ? 28 : 8,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF0525BB) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),

            // ── Next Button ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_currentPage == _pages.length - 1 ? 'Mulai Sekarang' : 'Lanjut'),
                      if (_currentPage < _pages.length - 1) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Illustration ─────────────────────────────────────────────────
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 72, color: color),
          ),
          const SizedBox(height: 48),

          // ── Title ─────────────────────────────────────────────────────────
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),

          // ── Subtitle ──────────────────────────────────────────────────────
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF475569),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
