import 'package:flutter/material.dart';
import '../main.dart';
import '../core/auth_service.dart';
import '../core/theme.dart';
import '../models/task_request.dart';
import 'negotiation_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final _store = TaskRequestStore.instance;
  String _userName = 'Pekerja';

  // ── Dummy earnings & stats ─────────────────────────────────────────────────
  static const int _todayEarnings = 285000;
  static const int _weekEarnings = 1420000;
  static const double _workerRating = 4.9;
  static const int _todayCompleted = 3;

  @override
  void initState() {
    super.initState();
    _loadUser();
    TaskRequestStore.instance.fetchRequests().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _userName = user?['name'] ?? 'Pekerja Pion';
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final open = _openRequests;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Theme.of(context).primaryColor.withOpacity(0.12)],
            stops: const [0.3, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              title: const Text(
                'Beranda Pekerja',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              actions: [
                // Mode switcher
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainNavigation(isWorkerMode: false)),
                        (route) => false,
                      );
                    },
                    icon: Icon(Icons.swap_horiz_rounded, size: 14, color: Theme.of(context).primaryColor),
                    label: Text('Cari Jasa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor)),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).chipTheme.backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.08),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: PionAvatar(
                    radius: 18,
                    url: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting ─────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat datang,',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userName.split(' ').first,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Earnings Card ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.primaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
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
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 12),
                          // Stats row
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _earningsStatChip(
                                icon: Icons.task_alt_rounded,
                                label: '$_todayCompleted Selesai',
                                color: const Color(0xFF6EE7B7),
                              ),
                              _earningsStatChip(
                                icon: Icons.star_rounded,
                                label: '$_workerRating Rating',
                                color: const Color(0xFFFDE68A),
                              ),
                              _earningsStatChip(
                                icon: Icons.people_rounded,
                                label: '${open.length} Menunggu',
                                color: const Color(0xFF93C5FD),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Tugas Tersedia ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tugas Tersedia',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
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
                  const SizedBox(height: 8),

                  if (open.isEmpty)
                    _buildNoTasksCard()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: open.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _buildTaskCard(open[i]),
                    ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _earningsStatChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
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

  Widget _buildNoTasksCard() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assignment_turned_in_rounded, size: 36, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 16),
          const Text('Belum Ada Tugas Tersedia', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Semua tugas baru akan muncul di sini.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF64748B))),
        ],
      ),
    ),
  );

  Widget _buildTaskCard(TaskRequest r) {
    final distances = ['0.3 km', '0.8 km', '1.2 km', '1.7 km', '2.0 km'];
    final distIdx = int.parse(r.id.substring(r.id.length - 1)) % distances.length;
    final dist = distances[distIdx];

    final isUrgent = r.title.toLowerCase().contains('darurat') || r.estimatedPrice > 300000;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NegotiationScreen(request: r)),
      ).then((_) => setState(() {})),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUrgent
                ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).chipTheme.backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.near_me_rounded, size: 12, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 4),
                      Text(dist, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).chipTheme.backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(r.category, style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF94A3B8)),
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
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on_rounded, size: 14, color: Color(0xFF16A34A)),
                          const SizedBox(width: 5),
                          Text(
                            'Est. ${_fmtRp(r.estimatedPrice.toInt())}',
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
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
