import 'package:flutter/material.dart';
import '../main.dart';
import '../core/auth_service.dart';
import '../core/url_helper.dart';
import 'login_screen.dart';
import 'my_requests_screen.dart';
class ProfileScreen extends StatefulWidget {
  final bool isWorkerMode;
  const ProfileScreen({super.key, this.isWorkerMode = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _isWorkerMode;

  @override
  void initState() {
    super.initState();
    _isWorkerMode = widget.isWorkerMode;
  }

  Future<void> _launchPrivacyPolicy() async {
    await openUrl('https://pion-privacy-policy.vercel.app/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profil'),
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          children: [
            // ── Profile Card ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
              ),
              child: Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop'),
                    ),
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Andi Pratama', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      const Text('andi.pratama@example.com', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_user_rounded, size: 14, color: colorScheme.primary),
                            const SizedBox(width: 6),
                            Text('KYC Lulus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colorScheme.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Mode Toggle ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: _isWorkerMode ? colorScheme.primary : const Color(0xFFEEF0FF),
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
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isWorkerMode ? 'Siap menerima penawaran kerja.' : 'Cari bantuan untuk tugas Anda.',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isWorkerMode,
                  activeColor: colorScheme.primary,
                  onChanged: (v) => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => MainNavigation(isWorkerMode: v)),
                    (route) => false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Menu ────────────────────────────────────────────────────────────
          _menuSection([
            _MenuItem(icon: Icons.person_outline_rounded, label: 'Edit Profil', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating))),
            _MenuItem(
              icon: Icons.assignment_outlined,
              label: 'Riwayat Permintaan',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRequestsScreen())),
            ),
            _MenuItem(icon: Icons.history_rounded, label: 'Riwayat Transaksi', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating))),
          ], theme),
          const SizedBox(height: 16),
          _menuSection([
            _MenuItem(icon: Icons.shield_outlined, label: 'Keamanan & Privasi', onTap: _launchPrivacyPolicy),
            _MenuItem(icon: Icons.help_outline_rounded, label: 'Pusat Bantuan', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating))),
            _MenuItem(
              icon: Icons.info_outline_rounded, 
              label: 'Tentang Pion', 
              trailingText: 'v1.0.3',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pion Versi 1.0.3', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating))
            ),
          ], theme),
          const SizedBox(height: 32),

          // ── Logout ─────────────────────────────────────────────────────────
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () async {
                await AuthService.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
              label: const Text('Keluar', style: TextStyle(color: Color(0xFFEF4444))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      ),
    );
  }

  Widget _menuSection(List<_MenuItem> items, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(12)),
                  child: Icon(e.value.icon, color: theme.colorScheme.primary, size: 22),
                ),
                title: Text(e.value.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                trailing: e.value.trailingText != null 
                    ? Text(e.value.trailingText!, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600))
                    : const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 24),
                onTap: e.value.onTap,
              ),
              if (!isLast) const Divider(height: 1, indent: 80),
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
  final VoidCallback onTap;
  final String? trailingText;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.trailingText});
}
