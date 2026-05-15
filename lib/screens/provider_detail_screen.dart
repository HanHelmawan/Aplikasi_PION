import 'package:flutter/material.dart';
import 'checkout_screen.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Penyedia'),
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1), 
          child: Container(height: 1, color: theme.dividerColor),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile Card ───────────────────────────────────────────
                  _card(
                    child: Column(
                      children: [
                        CircleAvatar(radius: 48, backgroundImage: NetworkImage(provider.avatarUrl)),
                        const SizedBox(height: 16),
                        Text(provider.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        const SizedBox(height: 6),
                        Text(provider.title, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                        if (provider.kycPassed) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_user_rounded, size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text('KYC Lulus', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Stats ─────────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: _statCard(icon: Icons.star_rounded, iconColor: const Color(0xFFF59E0B), value: provider.rating.toString(), label: 'Rating')),
                      const SizedBox(width: 16),
                      Expanded(child: _statCard(icon: Icons.task_alt_rounded, iconColor: theme.colorScheme.primary, value: provider.tasksCompleted.toString(), label: 'Tugas Selesai')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── About ─────────────────────────────────────────────────
                  const Text('Tentang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(provider.bio, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.6)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: provider.skills.map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Reviews ───────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ulasan Pelanggan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...provider.reviews.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _reviewCard(r, theme),
                  )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // ── CTA ─────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, -4))],
            ),
            child: SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CheckoutScreen(providerName: provider.name, taskTitle: 'Perbaikan / Layanan', category: provider.category)),
                ),
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text('Undang ke Tugas'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
    ),
    child: child,
  );

  Widget _statCard({required IconData icon, required Color iconColor, required String value, required String label}) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ]),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          ],
        ),
      );

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
                ? CircleAvatar(radius: 20, backgroundImage: NetworkImage(review.reviewerAvatar))
                : CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFEEF0FF),
                    child: Text(review.reviewerName[0], style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.reviewerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(review.timeAgo, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
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
        Text(review.text, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.6)),
      ],
    ),
  );
}
