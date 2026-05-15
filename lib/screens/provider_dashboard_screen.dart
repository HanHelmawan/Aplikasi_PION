import 'package:flutter/material.dart';
import 'create_task_screen.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Dashboard Pekerja'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: theme.dividerColor)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Status Indicator ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(24)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Color(0xFF10B981), size: 12),
                    SizedBox(width: 8),
                    Text('Radar Aktif', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Icon ──────────────────────────────────────────────────────
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: const Color(0xFFEEF0FF), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC7D0F8))),
                child: Icon(Icons.work_rounded, size: 48, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 24),

              // ── Text ──────────────────────────────────────────────────────
              const Text(
                'Mode Kerja Aktif',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Anda sekarang dalam Mode Kerja. Radar aktif untuk menerima tugas di sekitar Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.6),
                ),
              ),
              const SizedBox(height: 48),

              // ── Stats Row ─────────────────────────────────────────────────
              Row(
                children: [
                  _statCard(icon: Icons.assignment_rounded, value: '3', label: 'Tugas Baru', theme: theme),
                  const SizedBox(width: 16),
                  _statCard(icon: Icons.star_rounded, value: '4.9', label: 'Rating', theme: theme),
                  const SizedBox(width: 16),
                  _statCard(icon: Icons.task_alt_rounded, value: '142', label: 'Selesai', theme: theme),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity, height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali ke Pencari Jasa'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen())),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  static Widget _statCard({required IconData icon, required String value, required String label, required ThemeData theme}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}
