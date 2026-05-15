import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Dompet'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: theme.dividerColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Balance Card ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0525BB), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Saldo Escrow', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 6),
                            Text('Aman', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Rp 0', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Bayar langsung ke mitra setelah selesai', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      _actionBtn(icon: Icons.add_rounded, label: 'Top Up'),
                      const SizedBox(width: 16),
                      _actionBtn(icon: Icons.arrow_upward_rounded, label: 'Kirim'),
                      const SizedBox(width: 16),
                      _actionBtn(icon: Icons.history_rounded, label: 'Riwayat'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Info Banner ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Pion menggunakan sistem bayar di tempat. Tidak perlu top-up saldo untuk mulai.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.primary, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Transaction History ───────────────────────────────────────────
            const Text('Riwayat Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),

            _transactionItem(
              icon: Icons.check_circle_rounded,
              iconBg: const Color(0xFFD1FAE5),
              iconColor: const Color(0xFF10B981),
              title: 'Perbaikan Pipa Bocor',
              subtitle: 'Budi Santoso · 14 Mei 2026',
              amount: '- Rp 250.000',
              amountColor: const Color(0xFF0F172A),
              badge: 'SELESAI',
              badgeBg: const Color(0xFFD1FAE5),
              badgeColor: const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            _transactionItem(
              icon: Icons.schedule_rounded,
              iconBg: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFF59E0B),
              title: 'Layanan Kebersihan',
              subtitle: 'Siti Aminah · 10 Mei 2026',
              amount: '- Rp 180.000',
              amountColor: const Color(0xFF0F172A),
              badge: 'DIPROSES',
              badgeBg: const Color(0xFFFEF3C7),
              badgeColor: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 12),
            _transactionItem(
              icon: Icons.cancel_rounded,
              iconBg: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFEF4444),
              title: 'Servis AC',
              subtitle: 'Rina Amelia · 5 Mei 2026',
              amount: '- Rp 200.000',
              amountColor: const Color(0xFF0F172A),
              badge: 'DIBATALKAN',
              badgeBg: const Color(0xFFFEE2E2),
              badgeColor: const Color(0xFFEF4444),
            ),
            const SizedBox(height: 12),
            _transactionItem(
              icon: Icons.check_circle_rounded,
              iconBg: const Color(0xFFD1FAE5),
              iconColor: const Color(0xFF10B981),
              title: 'Servis Listrik',
              subtitle: 'Andi Pratama · 28 Apr 2026',
              amount: '- Rp 300.000',
              amountColor: const Color(0xFF0F172A),
              badge: 'SELESAI',
              badgeBg: const Color(0xFFD1FAE5),
              badgeColor: const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _actionBtn({required IconData icon, required String label}) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );

  static Widget _transactionItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
    required String badge,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: amountColor)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
                child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: badgeColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
