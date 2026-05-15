import 'package:flutter/material.dart';
import '../main.dart';
import 'login_screen.dart';

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
    _isWorkerMode = widget.isWorkerMode == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF), // background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF8FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Color(0xFF0525BB),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Hanken Grotesk',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // User Info
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Andi Pratama',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Hanken Grotesk',
                        color: Color(0xFF1A1B23),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'andi.pratama@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: Color(0xFF757686),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFE0FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF0525BB)),
                          SizedBox(width: 4),
                          Text(
                            'KYC Lulus',
                            style: TextStyle(
                              fontSize: 10,
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
            ],
          ),
          const SizedBox(height: 32),

          // Dual Role Toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC5C5D7), width: 1),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isWorkerMode ? const Color(0xFF0525BB) : const Color(0xFFEEECF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isWorkerMode ? Icons.work_outline : Icons.search_rounded,
                    color: _isWorkerMode ? Colors.white : const Color(0xFF0525BB),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isWorkerMode ? 'Mode Kerja' : 'Mode Cari Jasa',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: Color(0xFF1A1B23),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isWorkerMode
                            ? 'Anda siap menerima penawaran kerja.'
                            : 'Cari bantuan untuk tugas Anda.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Inter',
                          color: Color(0xFF444655),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isWorkerMode,
                  activeTrackColor: const Color(0xFF0525BB),
                  onChanged: (value) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MainNavigation(isWorkerMode: value),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items
          _buildMenuItem(Icons.person_outline, 'Edit Profil'),
          _buildMenuItem(Icons.history, 'Riwayat Transaksi'),
          _buildMenuItem(Icons.shield_outlined, 'Keamanan & Privasi'),
          _buildMenuItem(Icons.help_outline, 'Pusat Bantuan'),
          const SizedBox(height: 24),
          
          TextButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Color(0xFFBA1A1A)),
            label: const Text(
              'Keluar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                color: Color(0xFFBA1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEEECF8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF0525BB), size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          color: Color(0xFF1A1B23),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF757686)),
      onTap: () {},
    );
  }
}
