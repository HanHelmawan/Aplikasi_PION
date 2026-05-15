import 'package:flutter/material.dart';
import '../models/task_request.dart';
import 'negotiation_screen.dart';

/// User-facing request list — shows all open requests from all users.
/// Regular users can browse but CANNOT take jobs.
/// Worker mode shows an 'Ambil Pekerjaan' button.
class TaskRequestListScreen extends StatefulWidget {
  final bool isWorkerMode;
  const TaskRequestListScreen({super.key, this.isWorkerMode = false});

  @override
  State<TaskRequestListScreen> createState() => _TaskRequestListScreenState();
}

class _TaskRequestListScreenState extends State<TaskRequestListScreen> {
  final _store = TaskRequestStore.instance;
  String _selectedFilter = 'Semua';
  final _filters = ['Semua', '#Perbaikan', '#Darurat', 'Umum'];

  String _fmtPrice(double v) {
    final parts = v.toStringAsFixed(0).split('');
    final buf = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buf.write('.');
      buf.write(parts[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  List<TaskRequest> get _filtered {
    if (_selectedFilter == 'Semua') return _store.requests;
    return _store.requests
        .where((r) => r.category.contains(_selectedFilter))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Permintaan',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
            fontSize: 20,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0525BB)),
            tooltip: 'Refresh',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sub-header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                '${_store.requests.length} permintaan aktif di sekitar Anda',
                style: const TextStyle(
                  fontSize: 14, color: Color(0xFF64748B), fontFamily: 'Inter',
                ),
              ),
            ),

            // ── Filter Chips ─────────────────────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final selected = _selectedFilter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF0525BB)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: selected
                                ? const Color(0xFF0525BB)
                                : const Color(0xFFE2E8F0)),
                        boxShadow: selected
                            ? const [
                                BoxShadow(
                                    color: Color(0x330525BB),
                                    blurRadius: 8,
                                    offset: Offset(0, 3))
                              ]
                            : [],
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: selected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── List ─────────────────────────────────────────────────────────
            Expanded(
              child: items.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _buildCard(items[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                  color: Color(0xFFEEF0FF), shape: BoxShape.circle),
              child: const Icon(Icons.inbox_rounded,
                  size: 56, color: Color(0xFF0525BB)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Permintaan',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Inter'),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Belum ada permintaan yang diajukan. Jadilah yang pertama!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.6,
                    fontFamily: 'Inter'),
              ),
            ),
          ],
        ),
      );

  Widget _buildCard(TaskRequest r) {
    // Generate a fake user name from the id for display
    final userNames = ['Budi S.', 'Siti A.', 'Ahmad W.', 'Rina P.', 'Dian K.'];
    final userIdx = int.parse(r.id.substring(r.id.length - 1)) % userNames.length;
    final userName = userNames[userIdx];
    final userAvatars = [
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=100&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=100&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=100&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1600868620786-641e737119b4?q=80&w=100&auto=format&fit=crop',
    ];
    final avatarUrl = userAvatars[userIdx];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 16,
              offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── User Row ──────────────────────────────────────────────────────
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(avatarUrl,
                    width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            fontFamily: 'Inter')),
                    const SizedBox(height: 2),
                    Text(r.scheduledAt,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  r.status.label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD97706),
                      fontFamily: 'Inter'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Task Description ──────────────────────────────────────────────
          Text(
            r.title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                fontFamily: 'Inter'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // ── Category + Location ───────────────────────────────────────────
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFEEF0FF),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(r.category,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0525BB),
                        fontFamily: 'Inter')),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.location_on_rounded,
                  size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(r.location,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontFamily: 'Inter'),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),

          // ── Photos strip ──────────────────────────────────────────────────
          if (r.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: r.photoUrls.length,
                itemBuilder: (_, i) => Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                        image: NetworkImage(r.photoUrls[i]),
                        fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ],

          // ── Price row ─────────────────────────────────────────────────────
          if (r.estimatedPrice > 0) ...[  
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.monetization_on_rounded, size: 14, color: Color(0xFF16A34A)),
              const SizedBox(width: 6),
              Text(
                'Estimasi: ${_fmtPrice(r.estimatedPrice)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF16A34A), fontFamily: 'Inter'),
              ),
            ]),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // ── Footer ────────────────────────────────────────────────────────
          if (widget.isWorkerMode && r.status == RequestStatus.menunggu)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NegotiationScreen(request: r)),
                ).then((_) => setState(() {})),
                icon: const Icon(Icons.handshake_rounded, size: 18),
                label: const Text('Ambil Pekerjaan', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0525BB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                const Text('Permintaan publik', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontFamily: 'Inter')),
                const Spacer(),
                Text('#${r.id}', style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1), fontFamily: 'Inter')),
              ],
            ),
        ],
      ),
    );
  }
}
