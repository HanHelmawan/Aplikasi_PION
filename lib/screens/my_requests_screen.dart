import 'package:flutter/material.dart';
import '../models/task_request.dart';
import 'job_tracking_screen.dart';

/// Shows the current user's own submitted requests (their history).
class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final _store = TaskRequestStore.instance;

  String _fmtPrice(double v) {
    if (v <= 0) return 'Belum ditentukan';
    final parts = v.toStringAsFixed(0).split('');
    final buf = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buf.write('.');
      buf.write(parts[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  Color _statusColor(RequestStatus s) {
    switch (s) {
      case RequestStatus.menunggu:   return const Color(0xFFD97706);
      case RequestStatus.ditawar:    return const Color(0xFF7C3AED);
      case RequestStatus.dikerjakan: return const Color(0xFF0525BB);
      case RequestStatus.selesai:    return const Color(0xFF16A34A);
      case RequestStatus.dibatalkan: return const Color(0xFFDC2626);
    }
  }

  Color _statusBg(RequestStatus s) => _statusColor(s).withOpacity(0.1);

  @override
  Widget build(BuildContext context) {
    final requests = _store.requests;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Riwayat Permintaan',
            style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Inter', fontSize: 20, color: Color(0xFF0F172A))),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0525BB)),
            onPressed: () => setState(() {}),
          ),
        ],
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
        child: requests.isEmpty ? _buildEmpty() : ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          itemCount: requests.length,
          itemBuilder: (_, i) => _buildCard(requests[i]),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120, height: 120,
          decoration: const BoxDecoration(color: Color(0xFFEEF0FF), shape: BoxShape.circle),
          child: const Icon(Icons.assignment_outlined, size: 56, color: Color(0xFF0525BB)),
        ),
        const SizedBox(height: 24),
        const Text('Belum Ada Riwayat',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            'Permintaan yang Anda buat akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.6, fontFamily: 'Inter'),
          ),
        ),
      ],
    ),
  );

  Widget _buildCard(TaskRequest r) {
    final statusColor = _statusColor(r.status);
    final statusBg    = _statusBg(r.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(r.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter'),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.3))),
                child: Text(r.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor, fontFamily: 'Inter')),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Category ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(12)),
            child: Text(r.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0525BB), fontFamily: 'Inter')),
          ),
          const SizedBox(height: 10),

          // ── Meta ────────────────────────────────────────────────────────
          Row(children: [
            const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
            const SizedBox(width: 6),
            Text(r.scheduledAt, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Inter')),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF94A3B8)),
            const SizedBox(width: 6),
            Expanded(child: Text(r.location, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Inter'), overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.monetization_on_rounded, size: 13, color: Color(0xFF16A34A)),
            const SizedBox(width: 6),
            Text('Estimasi: ${_fmtPrice(r.estimatedPrice)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A), fontFamily: 'Inter')),
            if (r.finalPrice != null) ...[
              const Text(' → ', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              Text('Final: ${_fmtPrice(r.finalPrice!)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0525BB), fontFamily: 'Inter')),
            ],
          ]),

          // ── Worker Info ──────────────────────────────────────────────────
          if (r.assignedWorkerName != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  r.assignedWorkerAvatar ?? 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=100&auto=format&fit=crop',
                  width: 36, height: 36, fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.assignedWorkerName!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                  const Text('Mitra Pion', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'Inter')),
                ],
              )),
              // Tracking button for active jobs
              if (r.status == RequestStatus.dikerjakan)
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobTrackingScreen(request: r))),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFEEF0FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gps_fixed_rounded, size: 14, color: Color(0xFF0525BB)),
                      SizedBox(width: 4),
                      Text('Lacak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0525BB), fontFamily: 'Inter')),
                    ],
                  ),
                ),
            ]),
          ],

          // ── Footer ──────────────────────────────────────────────────────
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(children: [
            Text('#${r.id}', style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1), fontFamily: 'Inter')),
            const Spacer(),
            Text('${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'Inter')),
          ]),
        ],
      ),
    );
  }
}
