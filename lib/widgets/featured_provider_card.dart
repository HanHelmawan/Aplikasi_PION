import 'package:flutter/material.dart';
import '../screens/provider_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Kartu provider unggulan yang ditampilkan horizontal di bagian "Mitra Teratas".
class FeaturedProviderCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String rating;
  final String jobs;
  final String imageUrl;
  final bool isVerified;
  final ProviderData provider;

  const FeaturedProviderCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.jobs,
    required this.imageUrl,
    required this.isVerified,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => ProviderDetailScreen(provider: provider)),
      ),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
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
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => Container(
                      width: 64, height: 64,
                      color: const Color(0xFFF8FAFC),
                      child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                    ),
                    errorWidget: (ctx, url, err) => Container(
                      width: 64, height: 64,
                      color: const Color(0xFFEFF6FF),
                      child: const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 32),
                    ),
                  ),
                ),
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Color(0xFF2563EB), size: 12),
                        SizedBox(width: 4),
                        Text('Top', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(specialty, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 4),
                  Text(rating, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                ]),
                Row(children: [
                  const Icon(Icons.task_alt_rounded, color: Color(0xFF10B981), size: 14),
                  const SizedBox(width: 4),
                  Text('$jobs tugas', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
