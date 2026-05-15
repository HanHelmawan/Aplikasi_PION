import 'package:flutter/material.dart';
import 'create_task_screen.dart';
import 'select_provider_screen.dart';
import 'task_request_list_screen.dart';
import '../models/task_request.dart';

class HomeSeekerScreen extends StatelessWidget {
  final bool isWorkerMode;
  const HomeSeekerScreen({super.key, this.isWorkerMode = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWorkerMode = this.isWorkerMode;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFC6D8FF)],
            stops: [0.3, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // ── AppBar ──────────────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Icon(Icons.widgets_rounded, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Pion', style: TextStyle(color: colorScheme.primary, fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: const Color(0xFF0F172A),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFEEF0FF),
                  backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop'), // User avatar
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting & Location ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lokasi Saat Ini',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontFamily: 'Inter'),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.location_on, size: 16, color: Color(0xFF0525BB)),
                              SizedBox(width: 4),
                              Text(
                                'Kebayoran Baru, Jakarta',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontFamily: 'Inter'),
                              ),
                              Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF0F172A)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // ── Greeting ───────────────────────────────────────────────
                  const Text(
                    'Halo, Andi 👋',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Apa yang bisa kami bantu hari ini?',
                    style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 20),

                  // ── Floating Search Bar ────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A0F172A), blurRadius: 24, offset: Offset(0, 8)),
                      ],
                    ),
                    child: TextField(
                      readOnly: true,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating)),
                      decoration: InputDecoration(
                        hintText: 'Cari perbaikan AC, Pipa, dll...',
                        hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0525BB), size: 22),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0525BB),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                        ),
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(24)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(24)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(24)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Promo Banner (Carousel) ────────────────────────────────
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        _buildPromoBanner(
                          title: 'Diskon 50%',
                          subtitle: 'Untuk servis AC pertama Anda',
                          color1: const Color(0xFF0525BB),
                          color2: const Color(0xFF2563EB),
                          icon: Icons.ac_unit_rounded,
                        ),
                        const SizedBox(width: 16),
                        _buildPromoBanner(
                          title: 'Pion Protection',
                          subtitle: 'Garansi pengerjaan 30 hari',
                          color1: const Color(0xFF0F172A),
                          color2: const Color(0xFF334155),
                          icon: Icons.shield_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Categories ─────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kategori Populer',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter'),
                      ),
                      TextButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating)),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: const Text('Lihat semua', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: Color(0xFF0525BB))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 16,
                    children: const [
                      _CategoryItem(icon: Icons.build_rounded, label: 'Perbaikan', color: Color(0xFFEFF6FF), iconColor: Color(0xFF2563EB)),
                      _CategoryItem(icon: Icons.cleaning_services_rounded, label: 'Kebersihan', color: Color(0xFFF0FDF4), iconColor: Color(0xFF16A34A)),
                      _CategoryItem(icon: Icons.electrical_services_rounded, label: 'Listrik', color: Color(0xFFFEF2F2), iconColor: Color(0xFFDC2626)),
                      _CategoryItem(icon: Icons.plumbing_rounded, label: 'Ledeng', color: Color(0xFFFFFBEB), iconColor: Color(0xFFD97706)),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // ── Featured Providers (Mitra Teratas) ─────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mitra Teratas (Rating 4.9+)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectProviderScreen())),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: const Text('Semua', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: Color(0xFF0525BB))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 240,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: const [
                        _FeaturedProviderCard(
                          name: 'Budi Santoso',
                          specialty: 'Spesialis Pipa & Ledeng',
                          rating: '4.9',
                          jobs: '142',
                          imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop',
                          isVerified: true,
                        ),
                        SizedBox(width: 16),
                        _FeaturedProviderCard(
                          name: 'Andi Pratama',
                          specialty: 'Ahli Listrik & Kelistrikan',
                          rating: '5.0',
                          jobs: '89',
                          imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
                          isVerified: true,
                        ),
                      ],
                    ),
                  ),

                  // ── Daftar Permintaan (Worker only) ──────────────────
                  if (isWorkerMode) ...[
                    const SizedBox(height: 36),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskRequestListScreen(isWorkerMode: true))),
                      child: Container(
                        width: double.infinity,
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                    child: Text(
                                      '${TaskRequestStore.instance.requests.length} permintaan menunggu',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Daftar Permintaan',
                                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                                  const SizedBox(height: 4),
                                  Text('Lihat permintaan pengguna dan ambil pekerjaan',
                                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontFamily: 'Inter')),
                                ],
                              ),
                            ),
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 26),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 100), // padding for FAB

                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPromoBanner({
    required String title,
    required String subtitle,
    required Color color1,
    required Color color2,
    required IconData icon,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x1A0525BB), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(icon, size: 100, color: Colors.white.withOpacity(0.1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Text('PROMO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontFamily: 'Inter')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  
  const _CategoryItem({required this.icon, required this.label, required this.color, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569), fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }
}

class _FeaturedProviderCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String rating;
  final String jobs;
  final String imageUrl;
  final bool isVerified;

  const _FeaturedProviderCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.jobs,
    required this.imageUrl,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imageUrl, width: 64, height: 64, fit: BoxFit.cover),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: const [
                      Icon(Icons.verified, color: Color(0xFF0525BB), size: 12),
                      SizedBox(width: 4),
                      Text('Top', style: TextStyle(color: Color(0xFF0525BB), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(specialty, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontFamily: 'Inter')),
          const Spacer(),
          const Divider(color: Color(0xFFF1F5F9)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 4),
                  Text(rating, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontFamily: 'Inter')),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.task_alt_rounded, color: Color(0xFF10B981), size: 14),
                  const SizedBox(width: 4),
                  Text('$jobs tugas', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontFamily: 'Inter')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
