import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'checkout_screen.dart';
import 'chat_screen.dart';

// ─── Data models ─────────────────────────────────────────────────────────────

class ProviderReview {
  final String reviewerName;
  final String reviewerAvatar;
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
  final String? uid;
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
  final String? price;

  const ProviderData({
    this.uid,
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
    this.price,
  });
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class ProviderDetailScreen extends StatelessWidget {
  final ProviderData provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Profil', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, )),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Color(0xFF0F172A)), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle()), behavior: SnackBarBehavior.floating))),
          IconButton(icon: const Icon(Icons.favorite_border_rounded, color: Color(0xFF0F172A)), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle()), behavior: SnackBarBehavior.floating))),
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
          children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile Card ───────────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 24, offset: Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            PionAvatar(radius: 56, url: provider.avatarUrl),
                            if (provider.kycPassed)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                                  child: const Icon(Icons.verified, color: Colors.white, size: 16),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(provider.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), )),
                        const SizedBox(height: 6),
                        Text(provider.title, style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), )),
                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMiniStat(Icons.star_rounded, provider.rating.toString(), 'Rating', const Color(0xFFF59E0B)),
                            _buildMiniStat(Icons.task_alt_rounded, provider.tasksCompleted.toString(), 'Selesai', const Color(0xFF10B981)),
                            _buildMiniStat(Icons.flash_on_rounded, '< 10m', 'Respons', const Color(0xFF2563EB)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Trust & Safety Banner ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Garansi Pion Protection', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF031480), )),
                                SizedBox(height: 4),
                                Text('Pekerjaan dilindungi garansi 30 hari. Dana aman hingga selesai.', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB),  height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── About ─────────────────────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Tentang Pekerja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), )),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(provider.bio, style: const TextStyle(fontSize: 15, color: Color(0xFF475569), height: 1.6, )),
                  ),
                  const SizedBox(height: 24),

                  // ── Skills & Badges ────────────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Keahlian & Pencapaian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), )),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        _buildAchievementBadge('Top Worker', Icons.workspace_premium, const Color(0xFF2563EB)),
                        const SizedBox(width: 12),
                        _buildAchievementBadge('Cepat Tanggap', Icons.bolt, const Color(0xFFF59E0B)),
                        const SizedBox(width: 12),
                        ...provider.skills.map((s) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569), )),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Portfolio Gallery ──────────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Portofolio Pekerjaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), )),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      clipBehavior: Clip.none,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network('https://picsum.photos/id/${10 + index}/200', width: 160, height: 120, fit: BoxFit.cover),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Reviews ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ulasan Pelanggan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), )),
                        TextButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle()), behavior: SnackBarBehavior.floating)),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                          // ✅ AUDIT FIX (L-8): Gunakan jumlah ulasan dinamis dari data provider
                          child: Text('Semua (${provider.reviews.length})', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...provider.reviews.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
                    child: _reviewCard(r, theme),
                  )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // ── Bottom Action ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, -8))],
            ),
            child: Row(
              children: [
                // Hubungi button
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: provider.uid != null
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => ChatScreen(
                                  providerId: provider.uid,
                                  providerName: provider.name,
                                  providerAvatar: provider.avatarUrl,
                                  isOnline: true,
                                ),
                              ),
                            )
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Mitra ini belum terdaftar di Pion. Hubungi via nomor telepon.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Hubungi',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Pilih & Lanjutkan button
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => CheckoutScreen(
                            providerName: provider.name,
                            providerAvatar: provider.avatarUrl,
                            taskTitle: 'Pekerjaan',
                            category: provider.category,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Pilih & Lanjutkan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), )),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), )),
      ],
    );
  }

  Widget _buildAchievementBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        // ✅ AUDIT FIX (L-1): withOpacity → withValues(alpha:)
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color, )),
        ],
      ),
    );
  }

  Widget _reviewCard(ProviderReview review, ThemeData theme) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            review.reviewerAvatar.isNotEmpty
                ? PionAvatar(radius: 20, url: review.reviewerAvatar)
                : CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: Text(review.reviewerName[0], style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.reviewerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), )),
                  const SizedBox(height: 2),
                  Text(review.timeAgo, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), )),
                ],
              ),
            ),
            Row(
              children: List.generate(5, (i) => Icon(
                i < review.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: const Color(0xFFF59E0B),
              )),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(review.text, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.6, )),
      ],
    ),
  );
}
