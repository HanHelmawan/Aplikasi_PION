import 'package:flutter/material.dart';

/// Kartu promo banner yang ditampilkan horizontal di HomeSeekerScreen.
class PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color1;
  final Color color2;
  final IconData icon;

  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x1A0525BB), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20, bottom: -20,
            child: Icon(icon, size: 100, color: Colors.white.withValues(alpha: 0.1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('PROMO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, )),
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, )),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, )),
            ],
          ),
        ],
      ),
    );
  }
}
