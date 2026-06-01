import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../core/auth_service.dart';
import '../screens/select_provider_screen.dart';
import '../screens/provider_detail_screen.dart';
import '../widgets/worker_card.dart';
import '../widgets/promo_banner.dart';
import '../widgets/featured_provider_card.dart';
import '../widgets/kyc_verification_sheet.dart';
import '../widgets/worker_onboarding_sheet.dart';



class HomeSeekerScreen extends StatefulWidget {
  final bool isWorkerMode;
  const HomeSeekerScreen({super.key, this.isWorkerMode = false});

  @override
  State<HomeSeekerScreen> createState() => _HomeSeekerScreenState();
}

class _HomeSeekerScreenState extends State<HomeSeekerScreen> {
  String _currentLocation = 'Memuat...';
  String _userName = 'Pengguna';
  String _searchQuery = '';
  String? _selectedCategory;
  final _searchController = TextEditingController();

  // ── Data ──────────────────────────────────────────────────────────────────

  static final List<Map<String, dynamic>> _nearbyWorkers = [
    {
      'name': 'Budi Santoso',
      'specialty': 'Spesialis Pipa & Ledeng',
      'rating': '4.9',
      'jobs': '142',
      'distance': '0.8 km',
      'isOnline': true,
      'imageUrl': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop',
      'category': 'Ledeng',
      'categoryColor': 0xFFFFFBEB,
      'categoryIconColor': 0xFFD97706,
      'bio': 'Berpengalaman lebih dari 8 tahun di bidang perpipaan dan instalasi air. Siap membantu masalah kebocoran, instalasi pipa baru, hingga renovasi kamar mandi.',
      'skills': ['Instalasi Pipa', 'Perbaikan Keran', 'Water Heater', 'Renovasi KM', 'Saluran Mampet'],
      'problems': ['bocor', 'pipa bocor', 'keran rusak', 'wc mampet', 'wastafel tersumbat', 'ledeng', 'air mampet', 'pasang pipa', 'instalasi air', 'tandon bocor', 'pompa air', 'pipa pecah'],
      'reviews': const [
        ProviderReview(
          reviewerName: 'Andi Setiawan',
          reviewerAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100&auto=format&fit=crop',
          timeAgo: '3 hari lalu',
          rating: 5.0,
          text: 'Sangat profesional! Pipa bocor langsung teratasi dalam 1 jam. Recommended banget!',
        ),
      ],
    },
    {
      'name': 'Andi Pratama',
      'specialty': 'Ahli Listrik & Kelistrikan',
      'rating': '5.0',
      'jobs': '89',
      'distance': '1.2 km',
      'isOnline': true,
      'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
      'category': 'Listrik',
      'categoryColor': 0xFFFEF2F2,
      'categoryIconColor': 0xFFDC2626,
      'bio': 'Teknisi listrik bersertifikat dengan keahlian instalasi baru, perbaikan arus pendek (konsleting), pemasangan panel listrik, dan lampu rumah.',
      'skills': ['Instalasi Listrik', 'Cari Korsleting', 'Pasang Lampu', 'Perbaikan Panel', 'Grounding'],
      'problems': ['konslet', 'mati lampu', 'pasang lampu', 'kabel putus', 'instalasi listrik', 'sekring', 'pasang stopkontak', 'tambah daya', 'kabel terbakar', 'saklar rusak'],
      'reviews': const [
        ProviderReview(
          reviewerName: 'Budi Santoso',
          reviewerAvatar: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop',
          timeAgo: '5 hari lalu',
          rating: 5.0,
          text: 'Pekerjaan rapi sekali, langsung ketemu masalah konslet di atap rumah. Terima kasih mas!',
        ),
      ],
    },
    {
      'name': 'Siti Aminah',
      'specialty': 'Kebersihan Rumah & AC',
      'rating': '4.8',
      'jobs': '211',
      'distance': '1.5 km',
      'isOnline': false,
      'imageUrl': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&auto=format&fit=crop',
      'category': 'Kebersihan',
      'categoryColor': 0xFFF0FDF4,
      'categoryIconColor': 0xFF16A34A,
      'bio': 'Penyedia jasa kebersihan rumah profesional dan tepercaya. Menyediakan layanan pembersihan harian, deep cleaning, setrika, serta pembersihan AC.',
      'skills': ['Deep Cleaning', 'Setrika Baju', 'Sapu & Pel', 'Desinfeksi', 'Bersih Dapur'],
      'problems': ['sapu', 'pel', 'bersih rumah', 'setrika baju', 'cuci piring', 'cuci pakaian', 'sedot debu', 'bersih kamar', 'asisten rumah tangga', 'harian', 'kotor', 'debu', 'sapu rumah'],
      'reviews': const [
        ProviderReview(
          reviewerName: 'Eka Wijaya',
          reviewerAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100&auto=format&fit=crop',
          timeAgo: '2 hari lalu',
          rating: 4.8,
          text: 'Siti sangat rajin dan sopan. Rumah bersih mengkilap setelah ditinggal seharian.',
        ),
      ],
    },
    {
      'name': 'Rudi Hartono',
      'specialty': 'Servis AC & Elektronik',
      'rating': '4.7',
      'jobs': '67',
      'distance': '2.1 km',
      'isOnline': false,
      'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
      'category': 'Elektronik',
      'categoryColor': 0xFFEFF6FF,
      'categoryIconColor': 0xFF2563EB,
      'bio': 'Spesialis perbaikan dan pemeliharaan AC serta barang elektronik rumah tangga seperti mesin cuci, kulkas, dan televisi.',
      'skills': ['Cuci AC', 'Isi Freon AC', 'Servis Mesin Cuci', 'Reparasi TV', 'Kulkas'],
      'problems': ['ac panas', 'cuci ac', 'ac bocor', 'servis tv', 'mesin cuci rusak', 'kulkas tidak dingin', 'freon ac', 'elektronik', 'bongkar pasang ac', 'kipas angin', 'ac mati'],
      'reviews': const [
        ProviderReview(
          reviewerName: 'Roni Hermawan',
          reviewerAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100&auto=format&fit=crop',
          timeAgo: '1 minggu lalu',
          rating: 4.7,
          text: 'AC kamar yang tadinya panas sekarang langsung dingin seperti baru. Pengerjaan cepat!',
        ),
      ],
    },
    {
      'name': 'Ahmad Wijaya',
      'specialty': 'Tukang Kayu & Furniture',
      'rating': '4.9',
      'jobs': '112',
      'distance': '1.8 km',
      'isOnline': true,
      'imageUrl': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop',
      'category': 'Pertukangan',
      'categoryColor': 0xFFFFFBEB,
      'categoryIconColor': 0xFF92400E,
      'bio': 'Ahli pertukangan kayu untuk renovasi furniture, pintu macet, pembuatan lemari kustom, kitchen set, serta pemasangan lantai kayu.',
      'skills': ['Reparasi Furniture', 'Pembuatan Lemari', 'Kusen Pintu', 'Pasang HPL', 'Rak Dinding'],
      'problems': ['lemari rusak', 'pintu macet', 'pasang engsel', 'bikin meja', 'pertukangan', 'kayu', 'kusen', 'perbaikan atap', 'genteng bocor', 'kursi patah', 'meja goyang'],
      'reviews': const [
        ProviderReview(
          reviewerName: 'Dewi Lestari',
          reviewerAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=100&auto=format&fit=crop',
          timeAgo: '4 hari lalu',
          rating: 5.0,
          text: 'Lemari pakaian saya yang engselnya rusak sekarang sudah diperbaiki dengan sangat kokoh. Sangat recommended.',
        ),
      ],
    },
  ];

  // ✅ AUDIT FIX: Hapus duplikasi _categories/_allCategories — gunakan satu list
  static const List<Map<String, dynamic>> _allCategories = [
    {'icon': Icons.build_rounded, 'label': 'Perbaikan', 'color': 0xFFEFF6FF, 'iconColor': 0xFF2563EB},
    {'icon': Icons.cleaning_services_rounded, 'label': 'Kebersihan', 'color': 0xFFF0FDF4, 'iconColor': 0xFF16A34A},
    {'icon': Icons.electrical_services_rounded, 'label': 'Listrik', 'color': 0xFFFEF2F2, 'iconColor': 0xFFDC2626},
    {'icon': Icons.plumbing_rounded, 'label': 'Ledeng', 'color': 0xFFFFFBEB, 'iconColor': 0xFFD97706},
    {'icon': Icons.ac_unit_rounded, 'label': 'AC & Elektronik', 'color': 0xFFEFF6FF, 'iconColor': 0xFF0284C7},
    {'icon': Icons.local_florist_rounded, 'label': 'Taman', 'color': 0xFFF0FDF4, 'iconColor': 0xFF15803D},
    {'icon': Icons.security_rounded, 'label': 'Keamanan', 'color': 0xFFF5F3FF, 'iconColor': 0xFF7C3AED},
    {'icon': Icons.local_shipping_rounded, 'label': 'Angkut', 'color': 0xFFFFF7ED, 'iconColor': 0xFFEA580C},
    {'icon': Icons.carpenter_rounded, 'label': 'Pertukangan', 'color': 0xFFFFFBEB, 'iconColor': 0xFF92400E},
    {'icon': Icons.health_and_safety_rounded, 'label': 'Kesehatan', 'color': 0xFFFFF1F2, 'iconColor': 0xFFBE123C},
    {'icon': Icons.school_rounded, 'label': 'Les Privat', 'color': 0xFFEFF6FF, 'iconColor': 0xFF1D4ED8},
    {'icon': Icons.camera_alt_rounded, 'label': 'Fotografi', 'color': 0xFFF5F3FF, 'iconColor': 0xFF6D28D9},
    {'icon': Icons.brush_rounded, 'label': 'Cat Rumah', 'color': 0xFFFFF7ED, 'iconColor': 0xFFB45309},
    {'icon': Icons.kitchen_rounded, 'label': 'Perabot', 'color': 0xFFF0FDF4, 'iconColor': 0xFF166534},
  ];

  // ✅ AUDIT FIX: _categories sekarang cukup ambil 8 item pertama dari _allCategories
  static List<Map<String, dynamic>> get _categories => _allCategories.take(8).toList();

  static const List<String> _cityList = [
    'Jakarta Pusat', 'Jakarta Selatan', 'Jakarta Barat', 'Jakarta Timur', 'Jakarta Utara',
    'Bogor', 'Depok', 'Tangerang', 'Tangerang Selatan', 'Bekasi',
    'Bandung', 'Surabaya', 'Medan', 'Semarang', 'Makassar',
    'Palembang', 'Denpasar', 'Yogyakarta', 'Malang', 'Solo',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  bool _kycPassed = false;
  bool _hasWorkerProfile = false;
  List<Map<String, dynamic>> _firestoreWorkers = [];

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    final location = await AuthService.getSavedLocation();
    final dbWorkers = await AuthService.getAllWorkers();
    
    final mapped = dbWorkers.map((w) => _mapFirestoreUserToWorker(w)).toList();

    if (mounted) {
      setState(() {
        _currentLocation = location ?? 'Pilih Lokasi';
        _userName = user?['name'] ?? 'Pengguna';
        _kycPassed = user?['kycPassed'] ?? false;
        _hasWorkerProfile = user?['workerProfile'] != null;
        _firestoreWorkers = mapped;
      });
    }
  }

  void _startKycFlow() {
    showKycVerificationSheet(
      context,
      userName: _userName,
      onCompleted: () {
        _loadUserData();
        showWorkerOnboardingSheet(
          context,
          userName: _userName,
          onCompleted: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigation(isWorkerMode: true)),
              (route) => false,
            );
          },
        );
      },
    );
  }

  void _showKycWarningDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.gpp_maybe_rounded,
                size: 34,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Verifikasi KYC Diperlukan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Untuk menjaga keamanan komunitas Pion, Anda harus menyelesaikan verifikasi identitas (KYC) terlebih dahulu sebelum dapat mengaktifkan Mode Kerja.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: const Color(0xFF475569),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF94A3B8)),
            child: Text('Nanti Saja', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startKycFlow();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text('Verifikasi Sekarang', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredWorkers {
    final allWorkers = [..._firestoreWorkers, ..._nearbyWorkers];
    var workers = allWorkers.toList();
    // Prioritaskan pencarian text secara global agar pencarian nama mitra
    // atau permasalahan/pekerjaan dapat mencakup seluruh kategori.
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      return workers.where((w) =>
          (w['name'] as String).toLowerCase().contains(q) ||
          (w['specialty'] as String).toLowerCase().contains(q) ||
          (w['category'] as String).toLowerCase().contains(q) ||
          ((w['problems'] as List<String>?) ?? []).any((p) => p.toLowerCase().contains(q))).toList();
    }
    if (_selectedCategory != null) {
      workers = workers.where((w) => (w['category'] as String) == _selectedCategory).toList();
    }
    return workers;
  }

  ProviderData _getProviderData(Map<String, dynamic> w) {
    return ProviderData(
      name: w['name'] as String,
      title: w['specialty'] as String,
      avatarUrl: w['imageUrl'] as String,
      rating: double.tryParse(w['rating'] as String) ?? 5.0,
      tasksCompleted: int.tryParse(w['jobs'] as String) ?? 0,
      bio: w['bio'] as String? ?? 'Penyedia jasa profesional yang terverifikasi di Pion.',
      skills: List<String>.from(w['skills'] as List? ?? []),
      category: w['category'] as String,
      reviews: List<ProviderReview>.from(w['reviews'] as List? ?? []),
    );
  }

  Map<String, dynamic> _mapFirestoreUserToWorker(Map<String, dynamic> userData) {
    final profile = userData['workerProfile'] as Map<String, dynamic>? ?? {};
    final category = profile['category'] ?? 'Umum';
    
    int categoryColor = 0xFFEFF6FF;
    int categoryIconColor = 0xFF2563EB;
    
    final catLower = category.toString().toLowerCase();
    if (catLower.contains('perbaikan')) {
      categoryColor = 0xFFEFF6FF;
      categoryIconColor = 0xFF2563EB;
    } else if (catLower.contains('kebersihan')) {
      categoryColor = 0xFFF0FDF4;
      categoryIconColor = 0xFF16A34A;
    } else if (catLower.contains('listrik')) {
      categoryColor = 0xFFFEF2F2;
      categoryIconColor = 0xFFDC2626;
    } else if (catLower.contains('ledeng')) {
      categoryColor = 0xFFFFFBEB;
      categoryIconColor = 0xFFD97706;
    } else if (catLower.contains('ac') || catLower.contains('elektronik')) {
      categoryColor = 0xFFEFF6FF;
      categoryIconColor = 0xFF0284C7;
    } else if (catLower.contains('taman')) {
      categoryColor = 0xFFF0FDF4;
      categoryIconColor = 0xFF15803D;
    } else if (catLower.contains('keamanan')) {
      categoryColor = 0xFFF5F3FF;
      categoryIconColor = 0xFF7C3AED;
    }
    
    return {
      'uid': userData['uid'],
      'name': userData['name'] ?? 'Pekerja Pion',
      'specialty': profile['specialty'] ?? 'Penyedia Jasa',
      'rating': (profile['rating'] ?? 5.0).toString(),
      'jobs': (profile['jobsCompleted'] ?? 0).toString(),
      'distance': '0.5 km',
      'isOnline': profile['isOnline'] ?? true,
      'imageUrl': userData['avatarUrl'] != null && userData['avatarUrl'].toString().isNotEmpty
          ? userData['avatarUrl']
          : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
      'category': category,
      'categoryColor': categoryColor,
      'categoryIconColor': categoryIconColor,
      'bio': profile['bio'] ?? '',
      'skills': List<String>.from(profile['skills'] ?? []),
      'problems': List<String>.from(profile['problems'] ?? []),
    };
  }

  void _showLocationSheet() {
    String? tempCity = _currentLocation;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Ubah Lokasi', style: TextStyle( fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Pilih area pencarian jasa Anda', style: TextStyle( fontSize: 14, color: Color(0xFF64748B))),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _cityList.contains(tempCity) ? tempCity : null,
                      isExpanded: true,
                      hint: const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Pilih kota', style: TextStyle( color: Color(0xFF94A3B8)))),
                      icon: const Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B))),
                      borderRadius: BorderRadius.circular(16),
                      items: _cityList.map((c) => DropdownMenuItem(value: c, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(c, style: const TextStyle( fontSize: 15, color: Color(0xFF0F172A)))))).toList(),
                      onChanged: (val) => setSheetState(() => tempCity = val),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (tempCity != null) {
                        await AuthService.saveLocation(tempCity!);
                        setState(() => _currentLocation = tempCity!);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Konfirmasi Lokasi'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllCategories() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (ctx, scroll) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Semua Kategori', style: TextStyle( fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 20, childAspectRatio: 0.7),
                  itemCount: _allCategories.length,
                  itemBuilder: (buildCtx, i) {
                    final cat = _allCategories[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Kategori: ${cat['label']}', style: const TextStyle()),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ));
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(color: Color(cat['color'] as int), borderRadius: BorderRadius.circular(18)),
                            child: Icon(cat['icon'] as IconData, color: Color(cat['iconColor'] as int), size: 26),
                          ),
                          const SizedBox(height: 8),
                          Text(cat['label'] as String, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle( fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredWorkers = _filteredWorkers;

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
            // ── Top App Bar ──────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              title: GestureDetector(
                onTap: _showLocationSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFBFDBFE))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF2563EB)),
                      const SizedBox(width: 4),
                      Flexible(child: Text(_currentLocation, style: const TextStyle( fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextButton.icon(
                    onPressed: () {
                      if (!_kycPassed) {
                        _showKycWarningDialog();
                      } else if (!_hasWorkerProfile) {
                        showWorkerOnboardingSheet(
                          context,
                          userName: _userName,
                          onCompleted: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const MainNavigation(isWorkerMode: true)),
                              (route) => false,
                            );
                          },
                        );
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const MainNavigation(isWorkerMode: true)),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.swap_horiz_rounded, size: 14, color: Color(0xFF2563EB)),
                    label: const Text('Mode Kerja', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                    style: TextButton.styleFrom(backgroundColor: const Color(0xFFEFF6FF), padding: const EdgeInsets.symmetric(horizontal: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: const Color(0xFF0F172A),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belum ada notifikasi baru', style: TextStyle()), behavior: SnackBarBehavior.floating)),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: CircleAvatar(backgroundColor: Color(0xFFEFF6FF), radius: 18, child: Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 20)),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // ── Greeting ────────────────────────────────────────────
                    Text(
                      'Halo, ${_userName.split(' ').first}',
                      style: const TextStyle( fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    const Text('Apa yang bisa kami bantu hari ini?', style: TextStyle( fontSize: 15, color: Color(0xFF64748B))),
                    const SizedBox(height: 12),

                    // ── Search Bar ──────────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 24, offset: Offset(0, 8))]),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Cari perbaikan AC, Pipa, dll...',
                          hintStyle: const TextStyle( fontSize: 14, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2563EB), size: 22),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 20), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                              : Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18)),
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(24)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(24)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Promo Banner ────────────────────────────────────────
                    if (_searchQuery.isEmpty) ...[
                      SizedBox(
                        height: 125,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          children: const [
                            PromoBanner(title: 'Diskon 50%', subtitle: 'Untuk servis AC pertama Anda', color1: Color(0xFF2563EB), color2: Color(0xFF2563EB), icon: Icons.ac_unit_rounded),
                            SizedBox(width: 16),
                            PromoBanner(title: 'Pion Protection', subtitle: 'Garansi pengerjaan 30 hari', color1: Color(0xFF0F172A), color2: Color(0xFF334155), icon: Icons.shield_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Kategori ──────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kategori', style: TextStyle( fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          GestureDetector(
                            onTap: _showAllCategories,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Text('Lihat Semua', style: TextStyle( fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                                SizedBox(width: 4),
                                Icon(Icons.grid_view_rounded, size: 14, color: Color(0xFF2563EB)),
                              ]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 12, childAspectRatio: 0.72),
                        itemCount: _categories.length,
                        itemBuilder: (buildCtx, i) {
                          final cat = _categories[i];
                          final catLabel = cat['label'] as String;
                          final isActive = _selectedCategory == catLabel;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = isActive ? null : catLabel),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 60, height: 60,
                                  decoration: BoxDecoration(
                                    color: isActive ? const Color(0xFF2563EB) : Color(cat['color'] as int),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: isActive ? [const BoxShadow(color: Color(0x332563EB), blurRadius: 8, offset: Offset(0, 4))] : null,
                                  ),
                                  child: Icon(cat['icon'] as IconData, color: isActive ? Colors.white : Color(cat['iconColor'] as int), size: 26),
                                ),
                                const SizedBox(height: 7),
                                Text(catLabel, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle( fontSize: 11, fontWeight: isActive ? FontWeight.w800 : FontWeight.w600, color: isActive ? const Color(0xFF2563EB) : const Color(0xFF475569))),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),

                      // ── Mitra Teratas ─────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mitra Teratas ⭐ ', style: TextStyle( fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const SelectProviderScreen())),
                            child: const Text('Semua', style: TextStyle( fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 210,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: 2,
                          separatorBuilder: (_, _) => const SizedBox(width: 16),
                          itemBuilder: (buildCtx, i) {
                            final w = _nearbyWorkers[i];
                            return FeaturedProviderCard(
                              name: w['name'] as String,
                              specialty: w['specialty'] as String,
                              rating: w['rating'] as String,
                              jobs: w['jobs'] as String,
                              imageUrl: w['imageUrl'] as String,
                              isVerified: true,
                              provider: _getProviderData(w),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Terdekat / Search Results ──────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _searchQuery.isEmpty ? 'Terdekat dari Anda' : 'Hasil Pencarian',
                          style: const TextStyle( fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        if (_searchQuery.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(12)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                              SizedBox(width: 5),
                              Text('Live', style: TextStyle( fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                            ]),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (filteredWorkers.isEmpty)
                      _buildSearchEmpty()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredWorkers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (buildCtx, i) {
                          final worker = filteredWorkers[i];
                          return WorkerCard(
                            worker: worker,
                            dummyProvider: _getProviderData(worker),
                          );
                        },
                      ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchEmpty() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 88, height: 88, decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle), child: const Icon(Icons.search_off_rounded, size: 42, color: Color(0xFF2563EB))),
        const SizedBox(height: 16),
        const Text('Tidak Ditemukan', style: TextStyle( fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        const SizedBox(height: 6),
        const Text('Coba kata kunci lain', style: TextStyle( fontSize: 13, color: Color(0xFF64748B))),
      ],
    ),
  );
}
