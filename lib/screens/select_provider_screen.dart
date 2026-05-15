import 'package:flutter/material.dart';
import 'provider_detail_screen.dart';

class SelectProviderScreen extends StatelessWidget {
  const SelectProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pilih Penyedia'),
        actions: [
          IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: theme.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────────
            const Text(
              '5 profesional siap membantu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pilih mitra terbaik yang sesuai dengan kebutuhan Anda.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 28),

            // ── Provider Cards ────────────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive Wrap acts as a neat grid that doesn't force vertical heights.
                final isWide = constraints.maxWidth > 600;
                final cardWidth = isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;
                
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: _buildCards(context).map((c) => SizedBox(width: cardWidth, child: c)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCards(BuildContext context) => [
    _buildCard(context, name: 'Budi Santoso', category: 'Spesialis Instalasi & Pipa', tags: ['#AhliAir', '#TepatWaktu'], rating: 4.9, reviews: 128, imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBCZMqpSGrSJ4udn_WZzCN5Dz39RyaXM9RReqz42aEH1RaCYdMLb0ZnPpCCBXwjaAdEqbzeQBHLBQy4_UENmvw8P6ypARh_5jj5y4dLdy9HIU3xx8QZ3H482aVgOxR6V6A0VD3_8zfa_1XQZxperSeBfrpiT1zA1m4fTo9Fi5gQ3x_zH4x6mxe5wGfVUec_37zYdJyL9Tx2Mo_Qa2FvuWYPWA3wjG_B7C3fY3bntI_Jd1cts9vnIiFXvcdSiy1o0O0YfjMhW1CuKjSS'),
    _buildCard(context, name: 'Siti Aminah', category: 'Layanan Kebersihan Pro', tags: ['#BersihKilat', '#Ramah'], rating: 4.8, reviews: 94, imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBsGG3QZiqbGXWHdn2njMLBETpASlOqE4tN-9Aq3db5ObZlGcIvwejiqm8tOrad6Vs8FvurttLHQmMA_VJ8abkaE2aPcHqJjUGzDXmKHBWl86V17r_Vyv_oku2Lj8Ucd7eeJ9QtoJSseRNzaW50lR_K_oVjHp6eGmnU7sYPRoYy6-Nbttk1uLeaEfm0Pyv6BaM3FdPcD2JdZQwWpe917BPPPdzu6JPcCpo6X4xmpPXt17a_HlpKoXps9zBjJzaOfSmrMxvY_SW_u3rz'),
    _buildCard(context, name: 'Andi Pratama', category: 'Ahli Listrik & Elektronik', tags: ['#SolusiCepat', '#Aman'], rating: 5.0, reviews: 76, imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtHKokFpO_dEk7PxGBLgrfBeQBPIaro37Ovz2a1b9HnEJNrP7anJZR4jRvv65Z3XnxvgDsX3J0d9GfvZX9VcNIHvdqWQ3zXFBOqQuYZn0oc_jMLBq-FKeQFsASAiJBSs7XeChnORw60RolofIFDjqG6uZn1m_QC9ptV464hL2uIVA4CNjNf99uY45Re4DLNEZl3egBvKwQ0HrO9oXBBt7VRBrBx2Clw4Lh_JITs4ry2PSmLPDU1R8Sm7Dlga9qT-Xo4QjV25v1-eM5'),
    _buildCard(context, name: 'Ahmad Wijaya', category: 'Tukang Kebun', tags: ['#PeralatanLengkap', '#Hijau'], rating: 4.7, reviews: 53, imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBCZMqpSGrSJ4udn_WZzCN5Dz39RyaXM9RReqz42aEH1RaCYdMLb0ZnPpCCBXwjaAdEqbzeQBHLBQy4_UENmvw8P6ypARh_5jj5y4dLdy9HIU3xx8QZ3H482aVgOxR6V6A0VD3_8zfa_1XQZxperSeBfrpiT1zA1m4fTo9Fi5gQ3x_zH4x6mxe5wGfVUec_37zYdJyL9Tx2Mo_Qa2FvuWYPWA3wjG_B7C3fY3bntI_Jd1cts9vnIiFXvcdSiy1o0O0YfjMhW1CuKjSS'),
    _buildCard(context, name: 'Rina Amelia', category: 'Servis AC', tags: ['#DinginSekejap', '#Garansi'], rating: 4.9, reviews: 111, imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBsGG3QZiqbGXWHdn2njMLBETpASlOqE4tN-9Aq3db5ObZlGcIvwejiqm8tOrad6Vs8FvurttLHQmMA_VJ8abkaE2aPcHqJjUGzDXmKHBWl86V17r_Vyv_oku2Lj8Ucd7eeJ9QtoJSseRNzaW50lR_K_oVjHp6eGmnU7sYPRoYy6-Nbttk1uLeaEfm0Pyv6BaM3FdPcD2JdZQwWpe917BPPPdzu6JPcCpo6X4xmpPXt17a_HlpKoXps9zBjJzaOfSmrMxvY_SW_u3rz'),
  ];

  Widget _buildCard(BuildContext context, {
    required String name,
    required String category,
    required List<String> tags,
    required double rating,
    required int reviews,
    required String imageUrl,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: const Color(0x0A0F172A), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Avatar + Verified ──────────────────────────────────────────────
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imageUrl, width: 64, height: 64, fit: BoxFit.cover),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, color: theme.colorScheme.primary, size: 14),
                    const SizedBox(width: 4),
                    Text('Terverifikasi', style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Name & Category ────────────────────────────────────────────────
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(category, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 12),

          // ── Rating ─────────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
              const SizedBox(width: 4),
              Text(rating.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              Text(' ($reviews ulasan)', style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 16),

          // ── Tags ───────────────────────────────────────────────────────────
          Wrap(
            spacing: 8, runSpacing: 8,
            children: tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
            )).toList(),
          ),
          const SizedBox(height: 24),

          // ── Button ─────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProviderDetailScreen(
                  provider: ProviderData(
                    name: name,
                    title: category,
                    avatarUrl: imageUrl,
                    rating: rating,
                    tasksCompleted: reviews,
                    bio: 'Profesional berpengalaman di bidangnya. Berkomitmen memberikan solusi cepat, andal, dan aman. Sudah terverifikasi dan diasuransikan.',
                    skills: tags,
                    reviews: [
                      ProviderReview(reviewerName: 'Sarah J.', reviewerAvatar: 'https://i.pravatar.cc/150?img=5', timeAgo: '2 hari lalu', rating: 5, text: 'Sangat efisien dan profesional!'),
                    ],
                    category: category,
                  ),
                )),
              ),
              child: const Text('Pilih Penyedia'),
            ),
          ),
        ],
      ),
    );
  }
}
