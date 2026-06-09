import 'package:flutter/material.dart';

/// Widget marker yang menampilkan posisi pengguna di atas peta.
///
/// Menampilkan pulsing animation untuk menandakan lokasi live/real-time.
/// Dirancang untuk digunakan sebagai child di dalam flutter_map MarkerLayer.
class CurrentLocationMarker extends StatefulWidget {
  /// Akurasi GPS dalam meter (digunakan untuk menentukan radius pulse).
  final double accuracy;

  /// Warna utama marker.
  final Color color;

  const CurrentLocationMarker({
    super.key,
    this.accuracy = 20.0,
    this.color = const Color(0xFF2563EB),
  });

  @override
  State<CurrentLocationMarker> createState() => _CurrentLocationMarkerState();
}

class _CurrentLocationMarkerState extends State<CurrentLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Pulsing Ring (animasi lokasi live) ──────────────────────────
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  width: 60 * _pulseAnimation.value,
                  height: 60 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.25),
                  ),
                ),
              );
            },
          ),

          // ── Accuracy Circle (lingkaran akurasi GPS) ──────────────────────
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.15),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),

          // ── Main Dot ──────────────────────────────────────────────────────
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              border: Border.all(
                color: Colors.white,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Marker pin statis untuk lokasi yang dipilih user (drag).
class SelectedLocationPin extends StatelessWidget {
  final Color color;

  const SelectedLocationPin({
    super.key,
    this.color = const Color(0xFF2563EB),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 22,
          ),
        ),
        // Stem
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Shadow dot
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
