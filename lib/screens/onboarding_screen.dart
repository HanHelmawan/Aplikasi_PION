import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final int _totalPages = 5;

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _skip();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> onboardingData = [
      {
        "title": "Cari Jasa Sekitar",
        "subtitle": "Temukan penyedia jasa terverifikasi untuk segala kebutuhan dalam radius 1-5km.",
        "widget": _buildMapIllustration(),
      },
      {
        "title": "Pilih Mitra Terbaik",
        "subtitle": "Lihat profil, keahlian, dan ulasan asli dari pengguna lain sebelum memilih.",
        "widget": _buildProfileIllustration(),
      },
      {
        "title": "Pesan & Sepakati",
        "subtitle": "Gunakan fitur pesan untuk menjelaskan detail tugas dan menyepakati harga.",
        "widget": _buildChatIllustration(),
      },
      {
        "title": "Bayar di Tempat",
        "subtitle": "Tanpa top-up saldo! Lakukan pembayaran langsung setelah tugas diselesaikan.",
        "widget": _buildPaymentIllustration(),
      },
      {
        "title": "Selesai & Ulas",
        "subtitle": "Konfirmasi penyelesaian di aplikasi dan berikan ulasan untuk membantu komunitas.",
        "widget": _buildRatingIllustration(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF), // background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Bar with Skip Button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: _skip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F2FE),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF444655),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              
              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration
                        Expanded(
                          child: Center(
                            child: onboardingData[index]["widget"],
                          ),
                        ),
                        
                        // Text Content
                        const SizedBox(height: 32.0),
                        Text(
                          onboardingData[index]["title"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Hanken Grotesk',
                            color: Color(0xFF1A1B23),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          onboardingData[index]["subtitle"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontFamily: 'Inter',
                            color: Color(0xFF444655),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32.0),
                      ],
                    );
                  },
                ),
              ),
              
              // Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8.0,
                    width: _currentPage == index ? 24.0 : 8.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF0525BB)
                          : const Color(0xFFDFE0FF),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              
              // Next / Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0525BB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == onboardingData.length - 1 ? 'Mulai Sekarang' : 'Next',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      if (_currentPage != onboardingData.length - 1) ...[
                        const SizedBox(width: 8.0),
                        const Icon(Icons.arrow_forward, size: 20.0),
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapIllustration() {
    return Container(
      width: 300.0,
      height: 300.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE9E7F3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: ),
            blurRadius: 20.0,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Map Pattern
          Icon(Icons.map_outlined, size: 200.0, color: Colors.white.withValues(alpha: )),
          // Pins
          const Positioned(
            top: 60.0,
            left: 80.0,
            child: Icon(Icons.location_on, color: Color(0xFF0525BB), size: 36.0),
          ),
          const Positioned(
            top: 100.0,
            right: 90.0,
            child: Icon(Icons.location_on, color: Color(0xFF757686), size: 28.0),
          ),
          const Positioned(
            bottom: 80.0,
            left: 60.0,
            child: Icon(Icons.location_on, color: Color(0xFF757686), size: 32.0),
          ),
          const Positioned(
            bottom: 110.0,
            right: 70.0,
            child: Icon(Icons.location_on, color: Color(0xFF0525BB), size: 36.0),
          ),
          // Center Red Dot
          Container(
            width: 16.0,
            height: 16.0,
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3.0),
              boxShadow: [
                BoxShadow(color: const Color(0xFFD32F2F).withValues(alpha: ), blurRadius: 8.0),
              ]
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileIllustration() {
    return Container(
      width: 300.0,
      height: 300.0,
      decoration: BoxDecoration(
        color: const Color(0xFFEEECF8),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: ),
                blurRadius: 15.0,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28.0,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Budi Santoso',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                fontFamily: 'Hanken Grotesk',
                                color: Color(0xFF1A1B23)
                              )
                            ),
                            const SizedBox(width: 4.0),
                            const Icon(Icons.verified, color: Color(0xFF0525BB), size: 16.0),
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        const Text(
                          'Master Plumber',
                          style: TextStyle(color: Color(0xFF757686), fontSize: 12.0, fontFamily: 'Inter')
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 14.0),
                            const SizedBox(width: 4.0),
                            const Text(
                              '4.9',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0, fontFamily: 'Inter')
                            ),
                            const Text(
                              ' (128 reviews)',
                              style: TextStyle(color: Color(0xFF757686), fontSize: 12.0, fontFamily: 'Inter')
                            ),
                          ]
                        )
                      ]
                    )
                  )
                ]
              ),
              const SizedBox(height: 20.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _buildSkillPill('Pipa Bocor', isBlue: true),
                  _buildSkillPill('Instalasi', isBlue: true),
                  _buildSkillPill('+3 keahlian', isBlue: false),
                ]
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatIllustration() {
    return Container(
      width: 300.0,
      height: 300.0,
      decoration: BoxDecoration(
        color: const Color(0xFFEEECF8),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0525BB),
                    borderRadius: BorderRadius.circular(16.0).copyWith(bottomRight: Radius.zero),
                    boxShadow: [BoxShadow(color: const Color(0xFF0525BB).withValues(alpha: ), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: const Text(
                    'Bisa perbaiki pipa bocor hari ini?',
                    style: TextStyle(color: Colors.white, fontSize: 12.0, fontFamily: 'Inter'),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 12.0,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0).copyWith(bottomLeft: Radius.zero),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: ), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: const Text(
                          'Tentu, saya bisa datang jam 2 siang. Biayanya Rp 150.000 ya.',
                          style: TextStyle(color: Color(0xFF1A1B23), fontSize: 12.0, fontFamily: 'Inter', height: 1.4),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentIllustration() {
    return Container(
      width: 300.0,
      height: 300.0,
      decoration: BoxDecoration(
        color: const Color(0xFFEEECF8),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Center(
        child: Container(
          width: 220.0,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: ),
                blurRadius: 15.0,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.payments_outlined, color: Color(0xFF2E7D32), size: 48.0),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Bayar Tunai',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  fontFamily: 'Hanken Grotesk',
                  color: Color(0xFF1A1B23),
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Langsung ke mitra di lokasi',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF757686), fontSize: 12.0, fontFamily: 'Inter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingIllustration() {
    return Container(
      width: 300.0,
      height: 300.0,
      decoration: BoxDecoration(
        color: const Color(0xFFEEECF8),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Center(
        child: Container(
          width: 220.0,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: ),
                blurRadius: 15.0,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF0525BB), size: 64.0),
              const SizedBox(height: 16.0),
              const Text(
                'Tugas Selesai',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  fontFamily: 'Hanken Grotesk',
                  color: Color(0xFF1A1B23),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => const Icon(Icons.star, color: Colors.orange, size: 28.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillPill(String text, {required bool isBlue}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isBlue ? const Color(0xFFE9E7F3) : const Color(0xFFF4F2FE),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          color: isBlue ? const Color(0xFF0525BB) : const Color(0xFF444655),
        ),
      ),
    );
  }
}
