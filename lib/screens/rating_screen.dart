import 'package:flutter/material.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 4;
  final List<String> _allTags = ['Sopan', 'Cepat', 'Sesuai Deskripsi', 'Ramah', 'Ahli', 'Tepat Waktu'];
  final List<String> _selected = ['Sesuai Deskripsi'];
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) => setState(() {
    _selected.contains(tag) ? _selected.remove(tag) : _selected.add(tag);
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Beri Ulasan'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: theme.dividerColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Provider Summary ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 28, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12')),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Budi Santoso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        SizedBox(height: 4),
                        Text('Layanan Perbaikan Keran', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(20)),
                    child: const Text('SELESAI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Star Rating ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                children: [
                  const Text('Bagaimana layanannya?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  const Text('Ketuk bintang untuk memberi penilaian', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final active = i < _rating;
                      return GestureDetector(
                        onTap: () => setState(() => _rating = _rating == i + 1 ? i : i + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            active ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 48,
                            color: active ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ['', 'Sangat Buruk', 'Buruk', 'Cukup', 'Bagus', 'Sangat Bagus'][_rating],
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Tag Selector ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Apa yang kamu sukai?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    children: _allTags.map((tag) {
                      final selected = _selected.contains(tag);
                      return GestureDetector(
                        onTap: () => _toggleTag(tag),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? theme.colorScheme.primary : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: selected ? theme.colorScheme.primary : const Color(0xFFE2E8F0)),
                            boxShadow: selected ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF64748B)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Written Review ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ulasan Tertulis (Opsional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                    child: TextField(
                      controller: _reviewController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Ceritakan pengalamanmu lebih detail...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.all(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ── Submit Button ─────────────────────────────────────────────────
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Kirim Ulasan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
