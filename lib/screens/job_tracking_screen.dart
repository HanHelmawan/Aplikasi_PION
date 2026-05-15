import 'package:flutter/material.dart';
import '../models/task_request.dart';
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
        automaticallyImplyLeading: false,
        title: const Text('Lacak Pekerjaan',
            style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Inter', fontSize: 18, color: Color(0xFF0F172A))),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFC6D8FF)],
            stops: [0.3, 1.0],
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
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
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
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontFamily: 'Inter'), maxLines: 2),
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
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Langkah ${_step + 1} dari ${_steps.length}',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontFamily: 'Inter')),
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
                        const Text('Mitra Terverifikasi ✓',
                            style: TextStyle(fontSize: 12, color: Color(0xFF0525BB), fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                        const SizedBox(height: 2),
                        Text(req.assignedWorkerPhone ?? '-',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Inter')),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating),
                    ),
                    icon: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF0525BB), size: 18),
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
                                color: done ? const Color(0xFF0525BB) : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(done ? Icons.check_rounded : Icons.circle,
                                  size: done ? 16 : 8,
                                  color: done ? Colors.white : const Color(0xFFCBD5E1)),
                            ),
                            if (!isLast)
                              Container(width: 2, height: 36, color: done ? const Color(0xFF0525BB) : const Color(0xFFE2E8F0)),
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
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Price Summary ───────────────────────────────────────────────
            _card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Harga Disepakati', style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontFamily: 'Inter')),
                  Text(_fmtNum(finalPrice),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0525BB), fontFamily: 'Inter')),
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
                      widget.request.status = RequestStatus.selesai;
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (_) => RatingScreen(
                          workerName: req.assignedWorkerName ?? 'Worker',
                          workerAvatar: req.assignedWorkerAvatar ?? '',
                          taskTitle: req.title,
                        ),
                      ));
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                    label: const Text('Konfirmasi Selesai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
            )
          : null,
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
