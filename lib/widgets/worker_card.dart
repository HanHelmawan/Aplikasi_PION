import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';
import '../screens/provider_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Kartu pekerja terdekat yang ditampilkan di list utama HomeSeekerScreen.
class WorkerCard extends StatelessWidget {
  final Map<String, dynamic> worker;
  final ProviderData dummyProvider;

  const WorkerCard({
    super.key,
    required this.worker,
    required this.dummyProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = worker['isOnline'] as bool;
    final workerName = worker['name'] as String;
    final workerAvatar = worker['imageUrl'] as String;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => ProviderDetailScreen(provider: dummyProvider)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: workerAvatar,
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
                if (isOnline)
                  Positioned(
                    right: 2, bottom: 2,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          workerName,
                          style: const TextStyle( fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Color(worker['categoryColor'] as int),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          worker['category'] as String,
                          style: TextStyle( fontSize: 10, fontWeight: FontWeight.w700, color: Color(worker['categoryIconColor'] as int)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(worker['specialty'] as String,
                      style: const TextStyle( fontSize: 12, color: Color(0xFF64748B)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(worker['rating'] as String, style: const TextStyle( fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                        const SizedBox(width: 12),
                        const Icon(Icons.task_alt_rounded, size: 13, color: Color(0xFF10B981)),
                        const SizedBox(width: 3),
                        Text('${worker['jobs']} tugas', style: const TextStyle( fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(width: 16),
                        const Icon(Icons.near_me_rounded, size: 13, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 3),
                        Text(worker['distance'] as String, style: const TextStyle( fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (ctx) => ChatScreen(
                              providerName: workerName,
                              providerAvatar: workerAvatar,
                              isOnline: isOnline,
                            ),
                          )),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF2563EB)),
                                  SizedBox(width: 5),
                                  Text('Hubungi', style: TextStyle( fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (ctx) => ProviderDetailScreen(provider: dummyProvider),
                          )),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(12)),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text('Lihat Profil', style: TextStyle( fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
