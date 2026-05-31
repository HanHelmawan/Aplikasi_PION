import 'package:flutter/material.dart';
import '../models/task_request.dart';
import 'negotiation_screen.dart';

/// Public job board — shows all open task requests from users.
/// Workers browse this screen and pick jobs to respond to.
class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  final _store = TaskRequestStore.instance;

  String _selectedFilter = 'Semua';
  final _filters = ['Semua', 'Perbaikan', 'Kebersihan', 'Listrik', 'Ledeng', 'Umum'];

  List<TaskRequest> get _filtered {
    final openRequests = _store.requests.where((r) => r.status == RequestStatus.menunggu).toList();
    if (_selectedFilter == 'Semua') return openRequests;
    return openRequests.where((r) => r.category.contains(_selectedFilter)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

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
        title: const Text(
          'Papan Tugas',
          style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Inter', fontSize: 20, color: Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Theme.of(context).primaryColor),
            onPressed: () async {
              await TaskRequestStore.instance.fetchRequests();
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Theme.of(context).primaryColor.withValues(alpha: 0.12)], // ✅ AUDIT FIX (L-1)
            stops: const [0.3, 1.0],
          ),
        ),
        child: Column(
          children: [
            // ── Stats Bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(child: _statItem('${_store.requests.length}', 'Permintaan\nMasuk')),
                    Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.3)), // ✅ AUDIT FIX (L-1)
                    Expanded(child: _statItem(
                      '${_store.requests.where((r) => r.status == RequestStatus.menunggu).length}',
                      'Belum\nDitangani',
                    )),
                    Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.3)), // ✅ AUDIT FIX (L-1)
                    Expanded(child: _statItem('0', 'Sedang\nDikerjakan')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Filter Chips ─────────────────────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final selected = _selectedFilter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? Theme.of(context).primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? Theme.of(context).primaryColor : const Color(0xFFE2E8F0)),
                        boxShadow: selected
                            ? [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))] // ✅ AUDIT FIX (L-1)
                            : [],
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter',
                          color: selected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // ── List ─────────────────────────────────────────────────────────
            Expanded(
              child: items.isEmpty ? _buildEmpty() : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                itemCount: items.length,
                itemBuilder: (_, i) => _buildJobCard(items[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) => Column(
    children: [
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Inter')),
      const SizedBox(height: 2),
      Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8), fontFamily: 'Inter')), // ✅ AUDIT FIX (L-1)
    ],
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(color: Theme.of(context).chipTheme.backgroundColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.08), shape: BoxShape.circle), // ✅ AUDIT FIX (L-1)
          child: Icon(Icons.inbox_rounded, size: 56, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 24),
        const Text('Belum Ada Permintaan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            'Permintaan dari pengguna akan muncul di sini. Tunggu sebentar atau coba refresh.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.6, fontFamily: 'Inter'),
          ),
        ),
      ],
    ),
  );

  Widget _buildJobCard(TaskRequest r) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 6))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top: status badge + ID
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, size: 8, color: Color(0xFFD97706)),
                    SizedBox(width: 6),
                    Text('Menunggu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFD97706), fontFamily: 'Inter')),
                  ],
                ),
              ),
              const Spacer(),
              Text('#${r.id}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'Inter')),
            ],
          ),
        ),
        // Photos
        if (r.photoUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: r.photoUrls.length,
              itemBuilder: (_, i) => Container(
                width: 120, height: 120,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(image: NetworkImage(r.photoUrls[i]), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(r.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter'), maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              // Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Theme.of(context).chipTheme.backgroundColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)), // ✅ AUDIT FIX (L-1)
                child: Text(r.category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor, fontFamily: 'Inter')),
              ),
              const SizedBox(height: 12),
              // Time & Location
              Row(children: [
                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(r.scheduledAt, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontFamily: 'Inter')),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Expanded(child: Text(r.location, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontFamily: 'Inter'), overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 16),
              // Action
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NegotiationScreen(request: r)),
                  ),
                  icon: const Icon(Icons.handshake_outlined, size: 18),
                  label: const Text('Ambil Tugas Ini', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
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
