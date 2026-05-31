import 'package:flutter/material.dart';
import '../main.dart';
import '../core/auth_service.dart';
import '../core/url_helper.dart';
import '../core/theme.dart';
import 'login_screen.dart';
import 'activity_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isWorkerMode;
  const ProfileScreen({super.key, this.isWorkerMode = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _isWorkerMode;
  String _userName = '';
  String _userEmail = '';
  // ✅ AUDIT FIX (L-5/L-6): Simpan avatarUrl dan kycPassed dari Firestore
  String _userAvatarUrl = '';
  bool _kycPassed = false;
  bool _isLoadingUser = true;

  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _primaryLight => Theme.of(context).chipTheme.backgroundColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.08); // ✅ AUDIT FIX (L-1)

  // Editable fields (local state)
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isWorkerMode = widget.isWorkerMode;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _userName = user?['name'] ?? 'Pengguna Pion';
        _userEmail = user?['email'] ?? '-';
        // ✅ AUDIT FIX (L-5/L-6): Ambil avatarUrl dan kycPassed dari Firestore
        _userAvatarUrl = user?['avatarUrl'] ?? '';
        _kycPassed = user?['kycPassed'] ?? false;
        _nameCtrl.text = _userName;
        _phoneCtrl.text = user?['phone'] ?? '';
        _bioCtrl.text = user?['bio'] ?? '';
        _isLoadingUser = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchPrivacyPolicy() async {
    await openUrl('https://pion-privacy-policy.vercel.app/');
  }

  void _showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                const Text(
                  'Edit Profil',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Perbarui informasi pribadi Anda',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 28),

                // Avatar
                Center(
                  child: Stack(
                    children: [
                      PionAvatar(
                        radius: 44,
                        url: _userAvatarUrl,
                      ),
                      Positioned(
                        right: 0, bottom: 0,
                        child: GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ubah foto — segera hadir', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating),
                          ),
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: _primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Nama Lengkap
                _fieldLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  decoration: _inputDeco('Masukkan nama lengkap', Icons.person_outline_rounded),
                ),
                const SizedBox(height: 16),

                // Nomor HP
                _fieldLabel('Nomor HP'),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDeco('08xx-xxxx-xxxx', Icons.phone_outlined),
                ),
                const SizedBox(height: 16),

                // Bio / Keahlian (untuk worker)
                _fieldLabel(_isWorkerMode ? 'Deskripsi Keahlian' : 'Bio Singkat'),
                const SizedBox(height: 8),
                TextField(
                  controller: _bioCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                     hintText: _isWorkerMode
                        ? 'Contoh: Berpengalaman 5 tahun di bidang kelistrikan...'
                        : 'Ceritakan sedikit tentang diri Anda...',
                    hintStyle: const TextStyle(fontFamily: 'Inter', color: Color(0xFF94A3B8), fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _primaryColor, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Show loading, save to Firestore
                      Navigator.pop(ctx);
                      final error = await AuthService.updateProfile(
                        name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : _userName,
                        phone: _phoneCtrl.text,
                        bio: _bioCtrl.text,
                      );
                      if (!mounted) return;
                      if (error == null) {
                        setState(() => _userName = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : _userName);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Profil berhasil diperbarui ✓', style: TextStyle(fontFamily: 'Inter')),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF10B981),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error, style: const TextStyle(fontFamily: 'Inter')),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFFEF4444),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    child: const Text('Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
      );

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Inter', color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _primaryColor, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, _primaryColor.withValues(alpha: 0.08)], // ✅ AUDIT FIX (L-1)
            stops: const [0.3, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              title: const Text(
                'Profil',
                style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                  onPressed: () async {
                    await AuthService.logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  tooltip: 'Keluar',
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Profile Card ───────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryColor, _primaryColor.withValues(alpha: 0.8)], // ✅ AUDIT FIX (L-1)
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [BoxShadow(color: _primaryColor.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))], // ✅ AUDIT FIX (L-1)
                      ),
                      child: _isLoadingUser
                          ? const SizedBox(
                              height: 80,
                              child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            )
                          : Row(
                              children: [
                                Stack(
                                  children: [
                                    PionAvatar(
                                      radius: 38,
                                      // ✅ AUDIT FIX (L-5): Gunakan avatarUrl dari Firestore
                                      url: _userAvatarUrl,
                                      borderWidth: 3,
                                      borderColor: Colors.white.withValues(alpha: 0.5),
                                    ),
                                    Positioned(
                                      right: 0, bottom: 0,
                                      child: GestureDetector(
                                        onTap: _showEditProfileSheet,
                                        child: Container(
                                          width: 28, height: 28,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: _primaryColor, width: 1.5),
                                          ),
                                          child: Icon(Icons.edit_rounded, color: _primaryColor, size: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _userName,
                                        style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _userEmail,
                                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withValues(alpha: 0.75)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      // ✅ AUDIT FIX (L-6): Hanya tampilkan badge KYC jika benar-benar lulus
                                      if (_kycPassed)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.verified_user_rounded, size: 13, color: Colors.white),
                                              SizedBox(width: 5),
                                              Text('KYC Lulus', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                                            ],
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.pending_rounded, size: 13, color: Colors.white),
                                              SizedBox(width: 5),
                                              Text('KYC Belum Diverifikasi', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 12),

                    // ── Stats Row ──────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 12, offset: Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          _statItem('0', 'Tugas\nSelesai', Icons.task_alt_rounded, const Color(0xFF10B981)),
                          _vertDivider(),
                          _statItem('—', 'Rating\nAnda', Icons.star_rounded, const Color(0xFFF59E0B)),
                          _vertDivider(),
                          _statItem('Baru', 'Bergabung\nSejak', Icons.calendar_today_rounded, _primaryColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Mode Toggle ────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: _isWorkerMode ? colorScheme.primary : _primaryLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _isWorkerMode ? Icons.work_rounded : Icons.search_rounded,
                              color: _isWorkerMode ? Colors.white : colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isWorkerMode ? 'Mode Kerja Aktif' : 'Mode Cari Jasa',
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _isWorkerMode ? 'Siap menerima penawaran kerja.' : 'Cari bantuan untuk tugas Anda.',
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isWorkerMode,
                            activeThumbColor: colorScheme.primary,
                            onChanged: (v) => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (ctx) => MainNavigation(isWorkerMode: v)),
                              (route) => false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Menu Akun ──────────────────────────────────────────────
                    _menuSection([
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profil',
                        subtitle: 'Nama, foto, nomor HP',
                        onTap: _showEditProfileSheet,
                      ),
                      _MenuItem(
                        icon: Icons.history_rounded,
                        label: 'Riwayat Transaksi',
                        subtitle: 'Aktif, selesai & dibatalkan',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const ActivityScreen()),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    _menuSection([
                      _MenuItem(
                        icon: Icons.lock_outline_rounded,
                        label: 'Keamanan & Privasi',
                        subtitle: 'Sandi & kebijakan privasi',
                        onTap: _launchPrivacyPolicy,
                      ),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Pusat Bantuan',
                        subtitle: 'FAQ & kontak dukungan',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pusat bantuan — segera hadir', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'Tentang Pion',
                        subtitle: 'Versi aplikasi & lisensi',
                        trailingText: 'v1.0.3',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pion Versi 1.0.3', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon, Color color) =>
      Expanded(
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF94A3B8), height: 1.3),
            ),
          ],
        ),
      );

  Widget _vertDivider() => Container(width: 1, height: 56, color: const Color(0xFFE2E8F0));

  Widget _menuSection(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x060F172A), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(14)),
                  child: Icon(e.value.icon, color: _primaryColor, size: 22),
                ),
                title: Text(e.value.label, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                subtitle: e.value.subtitle != null
                    ? Text(e.value.subtitle!, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF94A3B8)))
                    : null,
                trailing: e.value.trailingText != null
                    ? Text(e.value.trailingText!, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600))
                    : const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 22),
                onTap: e.value.onTap,
              ),
              if (!isLast) const Divider(height: 1, indent: 80, color: Color(0xFFF1F5F9)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final String? trailingText;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.subtitle, this.trailingText});
}
