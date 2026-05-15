import 'package:flutter/material.dart';
import 'create_task_screen.dart';
import 'select_provider_screen.dart';

class HomeSeekerScreen extends StatelessWidget {
  final bool isWorkerMode;
  const HomeSeekerScreen({super.key, this.isWorkerMode = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            title: Text('Pion', style: TextStyle(color: colorScheme.primary, fontSize: 24, fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEEF0FF),
                  backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: theme.dividerColor),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting ───────────────────────────────────────────────
                  Text(
                    'Halo, Andi! 👋',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Butuh bantuan hari ini?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Search Bar ─────────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: const Color(0x080F172A), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: TextField(
                      readOnly: true,
                      onTap: () {},
                      decoration: InputDecoration(
                        hintText: 'Cari jasa atau kebutuhan...',
                        prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary, size: 24),
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Post Task Banner ───────────────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0525BB), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Buat Permintaan',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Deskripsikan tugas Anda\ndan temukan mitra.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Categories ─────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kategori',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: const Text('Lihat semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 96,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: const [
                        _CategoryItem(icon: Icons.build_rounded, label: 'Perbaikan'),
                        _CategoryItem(icon: Icons.cleaning_services_rounded, label: 'Kebersihan'),
                        _CategoryItem(icon: Icons.electrical_services_rounded, label: 'Listrik'),
                        _CategoryItem(icon: Icons.fitness_center_rounded, label: 'Angkat'),
                        _CategoryItem(icon: Icons.yard_rounded, label: 'Taman'),
                        _CategoryItem(icon: Icons.ac_unit_rounded, label: 'AC'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Nearby Providers ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Penyedia Terdekat',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectProviderScreen())),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: const Text('Lihat semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _ProviderCard(
                    name: 'Budi Santoso',
                    specialty: 'Spesialis Pipa & Instalasi',
                    distance: '1.2 km',
                    rating: '4.9',
                    reviews: 128,
                    imageUrl: 'https://i.pravatar.cc/150?img=12',
                    tags: const ['#Perbaikan', '#AhliAir'],
                  ),
                  const SizedBox(height: 16),
                  _ProviderCard(
                    name: 'Siti Aminah',
                    specialty: 'Layanan Kebersihan Pro',
                    distance: '2.5 km',
                    rating: '4.8',
                    reviews: 94,
                    imageUrl: 'https://i.pravatar.cc/150?img=5',
                    tags: const ['#Kebersihan', '#Cepat'],
                  ),
                  const SizedBox(height: 16),
                  _ProviderCard(
                    name: 'Andi Pratama',
                    specialty: 'Ahli Listrik & Elektronik',
                    distance: '3.1 km',
                    rating: '5.0',
                    reviews: 76,
                    imageUrl: 'https://i.pravatar.cc/150?img=13',
                    tags: const ['#Listrik', '#Aman'],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isWorkerMode
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen())),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0x0A0F172A), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String distance;
  final String rating;
  final int reviews;
  final String imageUrl;
  final List<String> tags;

  const _ProviderCard({
    required this.name,
    required this.specialty,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: const Color(0x0A0F172A), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 32, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ),
                    Icon(Icons.verified_rounded, color: Theme.of(context).colorScheme.primary, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    Text(' ($reviews)', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    const Spacer(),
                    const Icon(Icons.near_me_rounded, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(distance, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: tags.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF0FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
