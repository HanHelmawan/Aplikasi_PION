import 'package:flutter/material.dart';
import 'checkout_screen.dart';

// ─── Data models ────────────────────────────────────────────────────────────

class ProviderReview {
  final String reviewerName;
  final String reviewerAvatar; // network url or '' for initials
  final String timeAgo;
  final double rating;
  final String text;

  const ProviderReview({
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.timeAgo,
    required this.rating,
    required this.text,
  });
}

class ProviderData {
  final String name;
  final String title;
  final String avatarUrl;
  final bool kycPassed;
  final double rating;
  final int tasksCompleted;
  final String bio;
  final List<String> skills;
  final List<ProviderReview> reviews;
  final String category;
  final String price; // e.g. "Rp 250k"

  const ProviderData({
    required this.name,
    required this.title,
    required this.avatarUrl,
    this.kycPassed = true,
    required this.rating,
    required this.tasksCompleted,
    required this.bio,
    required this.skills,
    required this.reviews,
    required this.category,
    required this.price,
  });
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class ProviderDetailScreen extends StatelessWidget {
  final ProviderData provider;

  const ProviderDetailScreen({super.key, required this.provider});

  /// Convenience factory with default dummy data so the screen can be opened
  /// without passing explicit arguments during prototyping.
  factory ProviderDetailScreen.dummy() {
    return ProviderDetailScreen(
      provider: const ProviderData(
        name: 'Budi Santoso',
        title: 'Spesialis Instalasi & Pipa',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBCZMqpSGrSJ4udn_WZzCN5Dz39RyaXM9RReqz42aEH1RaCYdMLb0ZnPpCCBXwjaAdEqbzeQBHLBQy4_UENmvw8P6ypARh_5jj5y4dLdy9HIU3xx8QZ3H482aVgOxR6V6A0VD3_8zfa_1XQZxperSeBfrpiT1zA1m4fTo9Fi5gQ3x_zH4x6mxe5wGfVUec_37zYdJyL9Tx2Mo_Qa2FvuWYPWA3wjG_B7C3fY3bntI_Jd1cts9vnIiFXvcdSiy1o0O0YfjMhW1CuKjSS',
        kycPassed: true,
        rating: 4.9,
        tasksCompleted: 142,
        bio:
            'Profesional berpengalaman di bidang instalasi pipa dan sistem air dengan lebih dari 8 tahun pengalaman. Berkomitmen memberikan solusi cepat, andal, dan aman untuk hunian maupun usaha kecil. Sudah terverifikasi dan diasuransikan demi ketenangan pikiran Anda.',
        skills: ['#AhliAir', '#TepatWaktu', '#Perbaikan', '#Instalasi'],
        category: 'Plumbing',
        price: 'Rp 250.000',
        reviews: [
          ProviderReview(
            reviewerName: 'Sarah J.',
            reviewerAvatar:
                'https://i.pravatar.cc/150?img=5',
            timeAgo: '2 hari yang lalu',
            rating: 5,
            text:
                'Budi sangat efisien dan profesional. Ia mendiagnosis masalah pipa saya dalam hitungan menit dan seluruh sistem kembali berjalan mulus. Sangat direkomendasikan!',
          ),
          ProviderReview(
            reviewerName: 'David L.',
            reviewerAvatar: '',
            timeAgo: '1 minggu yang lalu',
            rating: 4,
            text:
                'Datang tepat waktu dan sangat transparan soal biaya. Berhasil memperbaiki kebocoran yang sudah lama mengganggu. Pelayanan memuaskan.',
          ),
          ProviderReview(
            reviewerName: 'Rina M.',
            reviewerAvatar:
                'https://i.pravatar.cc/150?img=9',
            timeAgo: '2 minggu yang lalu',
            rating: 5,
            text:
                'Pekerjaan rapi, cepat, dan hasilnya bersih. Tidak ada tetesan tersisa setelah selesai. Pasti akan memanggil lagi jika ada masalah.',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FE),
      // ── AppBar ─────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F2FE),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0525BB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pion',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
            color: Color(0xFF0525BB),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: Color(0xFF444655)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Scrollable content ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile Card ───────────────────────────────────
                  _buildCard(
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: NetworkImage(provider.avatarUrl),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          provider.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Color(0xFF1A1B23),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            color: Color(0xFF757686),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // KYC Badge
                        if (provider.kycPassed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDFE0FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_user_outlined,
                                    size: 15, color: Color(0xFF0525BB)),
                                SizedBox(width: 6),
                                Text(
                                  'KYC Lulus',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                    color: Color(0xFF0525BB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Stats Row ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.star_rounded,
                          iconColor: const Color(0xFFFFC107),
                          value: provider.rating.toString(),
                          label: 'Rating Keseluruhan',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle_outline_rounded,
                          iconColor: const Color(0xFF0525BB),
                          value: provider.tasksCompleted.toString(),
                          label: 'Tugas Selesai',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── About Section ──────────────────────────────────
                  Text(
                    'Tentang ${provider.name.split(' ').first}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: Color(0xFF1A1B23),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.bio,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            color: Color(0xFF444655),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: provider.skills
                              .map((s) => _buildSkillChip(s))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Reviews Section ────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ulasan Pelanggan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: Color(0xFF1A1B23),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            color: Color(0xFF0525BB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...provider.reviews.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildReviewCard(r),
                      )),
                  const SizedBox(height: 80), // padding for bottom button
                ],
              ),
            ),
          ),

          // ── Bottom CTA ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F2FE),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(
                        providerName: provider.name,
                        taskTitle: 'Perbaikan Pipa Bocor',
                        category: provider.category,
                        serviceFeeCents: int.tryParse(
                                provider.price.replaceAll(RegExp(r'[^0-9]'), '')) ??
                            150000,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'Undang ke Tugas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0525BB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0x330525BB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper widgets ──────────────────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: Color(0xFF1A1B23),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'Inter',
              color: Color(0xFF757686),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEECF8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          color: Color(0xFF0525BB),
        ),
      ),
    );
  }

  Widget _buildReviewCard(ProviderReview review) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              review.reviewerAvatar.isNotEmpty
                  ? CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(review.reviewerAvatar),
                    )
                  : CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFDFE0FF),
                      child: Text(
                        review.reviewerName[0],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0525BB),
                        ),
                      ),
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        color: Color(0xFF1A1B23),
                      ),
                    ),
                    Text(
                      review.timeAgo,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'Inter',
                        color: Color(0xFF757686),
                      ),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 14,
                    color: const Color(0xFFFFC107),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.text,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Inter',
              color: Color(0xFF444655),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
