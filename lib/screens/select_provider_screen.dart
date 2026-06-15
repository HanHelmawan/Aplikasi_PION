import 'package:flutter/material.dart';
import '../core/auth_service.dart';
import 'provider_detail_screen.dart';
import 'chat_screen.dart';

class SelectProviderScreen extends StatefulWidget {
  final String? initialCategory;
  const SelectProviderScreen({super.key, this.initialCategory});

  @override
  State<SelectProviderScreen> createState() => _SelectProviderScreenState();
}

class _SelectProviderScreenState extends State<SelectProviderScreen> {
  List<Map<String, dynamic>> _workers = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  static const List<String> _filterCategories = [
    'Semua', 'Perbaikan', 'Kebersihan', 'Listrik', 'Ledeng', 'AC & Elektronik', 
    'Taman', 'Keamanan', 'Angkut', 'Pertukangan', 'Kesehatan', 'Les Privat', 
    'Fotografi', 'Cat Rumah', 'Perabot'
  ];

  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Semua';
    _loadWorkers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoading = true);
    try {
      final workers = await AuthService.getAllWorkers();
      if (mounted) {
        setState(() {
          _workers = workers;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('SelectProviderScreen._loadWorkers error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredWorkers = _selectedCategory == 'Semua'
        ? _workers
        : _workers.where((w) {
            final profile = w['workerProfile'] as Map<String, dynamic>? ?? {};
            final cat = profile['category'] as String? ?? 'Umum';
            return cat.toLowerCase() == _selectedCategory.toLowerCase();
          }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pilih Penyedia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadWorkers,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: theme.dividerColor),
        ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _workers.isEmpty
                ? _buildEmpty(context)
                : RefreshIndicator(
                    onRefresh: _loadWorkers,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${filteredWorkers.length} profesional siap membantu',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pilih mitra terbaik yang sesuai dengan kebutuhan Anda.',
                            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 24),
                          
                          // Category Filter Chips
                          SizedBox(
                            height: 38,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _filterCategories.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final cat = _filterCategories[index];
                                final isSelected = _selectedCategory == cat;
                                return ChoiceChip(
                                  label: Text(cat),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedCategory = cat;
                                      });
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        if (_scrollController.hasClients) {
                                          _scrollController.animateTo(
                                            140,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      });
                                    }
                                  },
                                  selectedColor: theme.colorScheme.primary,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelected ? theme.colorScheme.primary : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  showCheckmark: false,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                          
                          if (filteredWorkers.isEmpty)
                            _buildCategoryEmpty(context)
                          else
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 600;
                                final cardWidth = isWide
                                    ? (constraints.maxWidth - 24) / 2
                                    : constraints.maxWidth;
                                return Wrap(
                                  spacing: 24,
                                  runSpacing: 24,
                                  children: filteredWorkers
                                      .map((w) => SizedBox(
                                            width: cardWidth,
                                            child: _buildCard(context, w),
                                          ))
                                      .toList(),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF0FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline_rounded,
                  size: 48, color: Color(0xFF0525BB)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Mitra Tersedia',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Mitra profesional akan muncul di sini setelah mendaftar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWorkers,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Muat Ulang'),
            ),
          ],
        ),
      );

  Widget _buildCard(BuildContext context, Map<String, dynamic> worker) {
    final theme = Theme.of(context);
    final profile = worker['workerProfile'] as Map<String, dynamic>? ?? {};
    final uid = worker['uid'] as String?;
    final name = worker['name'] as String? ?? 'Pekerja Pion';
    final specialty = profile['specialty'] as String? ?? 'Penyedia Jasa';
    final category = profile['category'] as String? ?? 'Umum';
    final rating = (profile['rating'] as num?)?.toDouble() ?? 5.0;
    final jobsCompleted = (profile['jobsCompleted'] as int?) ?? 0;
    final avatarUrl = (worker['avatarUrl'] as String?)?.isNotEmpty == true
        ? worker['avatarUrl'] as String
        : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop';
    final bio = profile['bio'] as String? ??
        'Profesional berpengalaman di bidangnya. Siap membantu kebutuhan Anda.';
    final skills = List<String>.from(profile['skills'] as List? ?? []);
    final isOnline = worker['isOnline'] as bool? ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Avatar + Online Status ───────────────────────────────────────
          Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      avatarUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, url, err) => Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF0FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.person_rounded,
                            size: 32, color: Color(0xFF0525BB)),
                      ),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFFEEF0FF),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        color: theme.colorScheme.primary, size: 14),
                    const SizedBox(width: 4),
                    Text('Terverifikasi',
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Name & Category ─────────────────────────────────────────────
          Text(name,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(specialty,
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 12),

          // ── Stats ───────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
              const SizedBox(width: 4),
              Text(rating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
              const SizedBox(width: 12),
              const Icon(Icons.task_alt_rounded,
                  color: Color(0xFF10B981), size: 16),
              const SizedBox(width: 4),
              Flexible(
                  child: Text('$jobsCompleted selesai',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A)),
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),

          // ── Category chip ───────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(category,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary)),
          ),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: skills
                  .take(3)
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(s,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569))),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),

          // ── Action Buttons ──────────────────────────────────────────────
          Row(
            children: [
              // Hubungi (Chat)
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: uid != null
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  providerId: uid,
                                  providerName: name,
                                  providerAvatar: avatarUrl,
                                  isOnline: isOnline,
                                ),
                              ),
                            )
                        : null,
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: const Text('Chat',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Lihat Detail
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProviderDetailScreen(
                          provider: ProviderData(
                            uid: uid,
                            name: name,
                            title: specialty,
                            avatarUrl: avatarUrl,
                            rating: rating,
                            tasksCompleted: jobsCompleted,
                            bio: bio,
                            skills: skills,
                            reviews: const [],
                            category: category,
                            isOnline: isOnline,
                          ),
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Detail',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryEmpty(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search_off_rounded,
                    size: 38, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mitra Tidak Ditemukan',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Text(
                'Belum ada mitra di kategori "$_selectedCategory" saat ini.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
}
