import 'package:flutter/material.dart';
import '../core/auth_service.dart';
import '../core/theme.dart';
import '../models/task_request.dart';
import 'negotiation_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _radarController;

  final _store = TaskRequestStore.instance;
  String _userName = 'Pekerja';
  bool _radarActive = true;

  // ── Dummy earnings & stats ─────────────────────────────────────────────────
  static const int _todayEarnings = 285000;
  static const int _weekEarnings = 1420000;
  static const double _workerRating = 4.9;
  static const int _todayCompleted = 3;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _userName = user?['name'] ?? 'Pekerja Pion';
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  String _fmtRp(int v) {
    final s = v.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  List<TaskRequest> get _openRequests => _store.requests
      .where((r) => r.status == RequestStatus.menunggu)
      .toList();

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final open = _openRequests;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0F1E),
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _radarActive
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _radarActive
                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                          : const Color(0xFFEF4444).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) => Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _radarActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            boxShadow: [
                              BoxShadow(
                                color: (_radarActive
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444))
                                    .withValues(alpha: _pulseController.value * 0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _radarActive ? 'Radar Aktif' : 'Radar Mati',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _radarActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Toggle radar switch
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: _radarActive,
                  activeThumbColor: const Color(0xFF10B981),
                  inactiveThumbColor: const Color(0xFF475569),
                  inactiveTrackColor: const Color(0xFF1E293B),
                  onChanged: (v) => setState(() => _radarActive = v),
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: PionAvatar(
                  radius: 18,
                  url: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop',
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting & Radar Visualizer ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat datang,',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _userName.split(' ').first,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Radar animation widget
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: AnimatedBuilder(
                          animation: _radarController,
                          builder: (_, __) => CustomPaint(
                            painter: _RadarPainter(
                              progress: _radarActive ? _radarController.value : 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Earnings Card ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pendapatan Hari Ini',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Hari ini',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _fmtRp(_todayEarnings),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFF6EE7B7)),
                            const SizedBox(width: 4),
                            Text(
                              'Minggu ini: ${_fmtRp(_weekEarnings)}',
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF6EE7B7)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stats row
                        Row(
                          children: [
                            _earningsStatChip(
                              icon: Icons.task_alt_rounded,
                              label: '$_todayCompleted Selesai',
                              color: const Color(0xFF6EE7B7),
                            ),
                            const SizedBox(width: 10),
                            _earningsStatChip(
                              icon: Icons.star_rounded,
                              label: '$_workerRating Rating',
                              color: const Color(0xFFFDE68A),
                            ),
                            const SizedBox(width: 10),
                            _earningsStatChip(
                              icon: Icons.people_rounded,
                              label: '${open.length} Menunggu',
                              color: const Color(0xFFA5B4FC),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Tugas Tersedia ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tugas Tersedia di Radar',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      if (open.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${open.length} baru',
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (!_radarActive)
                  _buildRadarOffBanner()
                else if (open.isEmpty)
                  _buildNoTasksCard()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: open.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildTaskCard(open[i]),
                  ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _earningsStatChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildRadarOffBanner() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off_rounded, color: Color(0xFFEF4444), size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Radar Tidak Aktif', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                SizedBox(height: 3),
                Text(
                  'Aktifkan radar untuk menerima tugas di sekitar Anda.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildNoTasksCard() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.radar_rounded, size: 36, color: Color(0xFF818CF8)),
          ),
          const SizedBox(height: 16),
          const Text('Belum Ada Tugas Masuk', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 6),
          const Text('Radar sedang memindai area Anda...', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF64748B))),
        ],
      ),
    ),
  );

  Widget _buildTaskCard(TaskRequest r) {
    // Jarak acak untuk demo
    final distances = ['0.3 km', '0.8 km', '1.2 km', '1.7 km', '2.0 km'];
    final distIdx = int.parse(r.id.substring(r.id.length - 1)) % distances.length;
    final dist = distances[distIdx];

    // Urgency badge
    final isUrgent = r.title.toLowerCase().contains('darurat') || r.estimatedPrice > 300000;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NegotiationScreen(request: r)),
      ).then((_) => setState(() {})),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUrgent
                ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                : const Color(0xFF334155),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isUrgent)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, size: 12, color: Color(0xFFEF4444)),
                              SizedBox(width: 4),
                              Text('MENDESAK', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                      Text(
                        r.title,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Distance badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me_rounded, size: 12, color: Color(0xFF818CF8)),
                      const SizedBox(width: 4),
                      Text(dist, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF818CF8))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Meta info row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(r.category, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF818CF8))),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF475569)),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    r.location,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            if (r.estimatedPrice > 0) ...[
              const SizedBox(height: 10),
              const Divider(color: Color(0xFF334155), height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on_rounded, size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 5),
                      Text(
                        'Est. ${_fmtRp(r.estimatedPrice.toInt())}',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Ambil Tugas',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Radar Painter ──────────────────────────────────────────────────────────────
class _RadarPainter extends CustomPainter {
  final double progress;
  _RadarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    // Background circles
    final ringPaint = Paint()
      ..color = const Color(0xFF4F46E5).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double r = maxR * 0.35; r <= maxR; r += maxR * 0.33) {
      canvas.drawCircle(center, r, ringPaint);
    }

    // Sweep
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF4F46E5).withValues(alpha: 0),
          const Color(0xFF4F46E5).withValues(alpha: 0.5),
          const Color(0xFF4F46E5).withValues(alpha: 0),
        ],
        stops: const [0.0, 0.12, 0.25],
        transform: GradientRotation(progress * 2 * 3.14159),
      ).createShader(Rect.fromCircle(center: center, radius: maxR));

    canvas.drawCircle(center, maxR, sweepPaint);

    // Center dot
    canvas.drawCircle(
      center,
      4,
      Paint()..color = const Color(0xFF818CF8),
    );

    // Cross lines
    final linePaint = Paint()
      ..color = const Color(0xFF4F46E5).withValues(alpha: 0.3)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(center.dx, center.dy - maxR), Offset(center.dx, center.dy + maxR), linePaint);
    canvas.drawLine(Offset(center.dx - maxR, center.dy), Offset(center.dx + maxR, center.dy), linePaint);

    // Blip dots (simulated at fixed positions)
    final blipPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(center + Offset(maxR * 0.4, -maxR * 0.3), 3.5, blipPaint);
    canvas.drawCircle(center + Offset(-maxR * 0.55, maxR * 0.2), 2.5, blipPaint);
    canvas.drawCircle(center + Offset(maxR * 0.15, maxR * 0.6), 3, blipPaint);
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) => oldDelegate.progress != progress;
}
