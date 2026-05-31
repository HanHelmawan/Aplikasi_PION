import 'package:flutter/material.dart';
import '../models/task_request.dart';
import 'chat_screen.dart';
import 'rating_screen.dart';

class JobTrackingScreen extends StatefulWidget {
  final TaskRequest request;
  const JobTrackingScreen({super.key, required this.request});

  @override
  State<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends State<JobTrackingScreen> {
  // 0=menuju lokasi, 1=tiba, 2=dikerjakan, 3=selesai
  int _step = 0;

  final _steps = [
    _StepData(icon: Icons.directions_run_rounded,  label: 'Worker Menuju Lokasi', desc: 'Worker sedang dalam perjalanan menuju lokasi Anda.'),
    _StepData(icon: Icons.home_rounded,            label: 'Tiba di Lokasi',       desc: 'Worker telah tiba. Mohon buka pintu / sambut worker.'),
    _StepData(icon: Icons.build_rounded,           label: 'Sedang Dikerjakan',    desc: 'Pekerjaan sedang dalam proses. Harap tunggu hingga selesai.'),
    _StepData(icon: Icons.check_circle_rounded,    label: 'Pekerjaan Selesai',    desc: 'Worker melaporkan pekerjaan telah selesai. Silakan konfirmasi.'),
  ];

  String _fmtNum(double v) =>
      'Rp ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final finalPrice = req.finalPrice ?? req.estimatedPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('Lacak Pekerjaan',
            style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Inter', fontSize: 20, color: Color(0xFF0F172A))),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Theme.of(context).primaryColor.withValues(alpha: 0.08)],
            stops: const [0.3, 1.0],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            // ── Status Badge ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0525BB), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Color(0x330525BB), blurRadius: 16, offset: Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), // ✅ AUDIT FIX (L-1)
                        child: Icon(_steps[_step].icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_steps[_step].label,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                            const SizedBox(height: 2),
                            Text(_steps[_step].desc,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontFamily: 'Inter'), maxLines: 2), // ✅ AUDIT FIX (L-1)
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / _steps.length,
                      backgroundColor: Colors.white.withValues(alpha: 0.2), // ✅ AUDIT FIX (L-1)
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Langkah ${_step + 1} dari ${_steps.length}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontFamily: 'Inter')), // ✅ AUDIT FIX (L-1)
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Worker Info ─────────────────────────────────────────────────
            _card(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      req.assignedWorkerAvatar ?? 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop',
                      width: 60, height: 60, fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(req.assignedWorkerName ?? 'Worker',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                        const SizedBox(height: 2),
                        Text('Mitra Terverifikasi ✓',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                        const SizedBox(height: 2),
                        Text(req.assignedWorkerPhone ?? '-',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Inter')),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          providerName: req.assignedWorkerName ?? 'Worker',
                          providerAvatar: req.assignedWorkerAvatar ?? 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop',
                          isOnline: true,
                          request: req,
                        ),
                      ),
                    ),
                    icon: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.chat_bubble_outline_rounded, color: Theme.of(context).primaryColor, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Timeline ────────────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Riwayat Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                  const SizedBox(height: 16),
                  ..._steps.asMap().entries.map((e) {
                    final idx = e.key;
                    final s = e.value;
                    final done = idx <= _step;
                    final isLast = idx == _steps.length - 1;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: done ? Theme.of(context).primaryColor : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(done ? Icons.check_rounded : Icons.circle,
                                  size: done ? 16 : 8,
                                  color: done ? Colors.white : const Color(0xFFCBD5E1)),
                            ),
                            if (!isLast)
                              Container(width: 2, height: 36, color: done ? Theme.of(context).primaryColor : const Color(0xFFE2E8F0)),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.label,
                                    style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter',
                                      color: done ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                    )),
                                if (done)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(s.desc, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'Inter')),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }), // ✅ AUDIT FIX: removed unnecessary .toList() inside spread
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_step == _steps.length - 1) ...[
              _buildCompletionCard(context),
              const SizedBox(height: 16),
            ],

            // ── Price Summary ───────────────────────────────────────────────
            _card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Harga Disepakati', style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontFamily: 'Inter')),
                  Text(_fmtNum(finalPrice),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor, fontFamily: 'Inter')),
                ],
              ),
            ),

            // ── Dev helper: simulate next step ─────────────────────────────
            if (_step < _steps.length - 1) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => setState(() => _step++),
                icon: const Icon(Icons.skip_next_rounded, size: 18),
                label: const Text('Simulasi: Langkah Berikutnya', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ],
        ),
      ),

      // ── Bottom CTA ─────────────────────────────────────────────────────────
      bottomNavigationBar: _step == _steps.length - 1
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // ✅ AUDIT FIX (M-5): Gunakan copyWith() — tidak ada mutasi field final
                      final updated = widget.request.copyWith(
                        status: RequestStatus.selesai,
                      );
                      TaskRequestStore.instance.updateRequest(updated);
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (_) => RatingScreen(
                          taskId: req.id,
                          workerName: req.assignedWorkerName ?? 'Worker',
                          workerAvatar: req.assignedWorkerAvatar ?? '',
                          taskTitle: req.title,
                        ),
                      ));
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                    label: const Text('Konfirmasi Selesai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 8,
                      shadowColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCompletionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD1FAE5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pekerjaan Selesai!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mitra melaporkan bahwa pekerjaan telah rampung dengan sukses. Harap periksa hasil pekerjaan sebelum melakukan konfirmasi selesai.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontFamily: 'Inter',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.security_rounded, color: Color(0xFF16A34A), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PION Escrow menjamin dana Anda aman dan hanya akan dicairkan setelah Anda menyetujui.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF166534),
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
    ),
    child: child,
  );
}

class _StepData {
  final IconData icon;
  final String label;
  final String desc;
  const _StepData({required this.icon, required this.label, required this.desc});
}
