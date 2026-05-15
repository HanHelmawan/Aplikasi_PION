import 'package:flutter/material.dart';
import 'chat_screen.dart';
import '../main.dart'; // To navigate back home safely

class ActiveTaskScreen extends StatelessWidget {
  const ActiveTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // ── Map Background (Placeholder) ──────────────────────────────────
          Container(
            color: const Color(0xFFE2E8F0),
            child: const Center(
              child: Text(
                'Peta Integrasi (Google Maps / Mapbox)\nMenampilkan rute penyedia jasa',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8), height: 1.5),
              ),
            ),
          ),

          // ── Map Markers ───────────────────────────────────────────────────
          Positioned(
            top: 250, left: 100,
            child: _mapMarker(Icons.location_on_rounded, colorScheme.primary, true),
          ),
          Positioned(
            top: 350, right: 120,
            child: _mapMarker(Icons.home_rounded, const Color(0xFF0F172A), false),
          ),

          // ── Top Bar (Floating) ────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20, right: 20,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainNavigation()), (r) => false),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0x1A0F172A), blurRadius: 12, offset: Offset(0, 4))]),
                    child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x1A0F172A), blurRadius: 12, offset: Offset(0, 4))]),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Text('Penyedia dalam perjalanan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Info Sheet ─────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [BoxShadow(color: Color(0x1A0F172A), blurRadius: 24, offset: Offset(0, 8))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Grip
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),

                  // Provider Info
                  Row(
                    children: [
                      const CircleAvatar(radius: 28, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12')),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Budi Santoso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                                const SizedBox(width: 4),
                                const Text('4.9', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                const Text(' (128)', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(10)),
                                  child: Text('Spesialis Pipa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colorScheme.primary)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Chat Icon
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]),
                          child: const Icon(Icons.chat_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Status Timeline
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.electric_moped_rounded, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Menuju ke lokasi Anda', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                              SizedBox(height: 4),
                              Text('Estimasi tiba dalam 12 menit (2.4 km)', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            foregroundColor: const Color(0xFF0F172A),
                          ),
                          child: const Text('Detail Tugas'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Telepon'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapMarker(IconData icon, Color color, bool pulse) {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
