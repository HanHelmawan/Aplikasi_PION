import 'package:flutter/material.dart';
import 'dart:ui';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF), // background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFBF8FF), // surface
            boxShadow: [
              BoxShadow(
                color: Color(0x0D000000), // shadow-sm
                blurRadius: 4,
                offset: Offset(0, 1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20), // px-margin
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF1A1B23)), // on-surface
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16), // gap-4
                      const Text(
                        'Dompet Pion',
                        style: TextStyle(
                          fontSize: 24, // h2
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Hanken Grotesk',
                          color: Color(0xFF0525BB), // primary
                          letterSpacing: -0.01 * 24,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Color(0xFF0525BB)), // primary
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // px-margin, pt-lg
        child: Column(
          children: [
            // Escrow Balance Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF384DD9), // surface-tint (brighter blue)
                borderRadius: BorderRadius.circular(12), // rounded-xl
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000), // shadow
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Decorative Accents
                    Positioned(
                      right: -32,
                      bottom: -32,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 60,
                      top: -40,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    
                    // Card Content
                    Padding(
                      padding: const EdgeInsets.all(24), // p-lg
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SALDO TERTAHAN (ESCROW)',
                            style: TextStyle(
                              fontSize: 12, // label-caps
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                              letterSpacing: 0.05 * 12,
                              color: Color(0xCCC2C8FF), // text-on-primary-container opacity-80
                            ),
                          ),
                          const SizedBox(height: 4), // mt-xs
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: const [
                              Text(
                                'Rp',
                                style: TextStyle(
                                  fontSize: 20, // h3
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Hanken Grotesk',
                                  color: Color(0xE6C2C8FF), // opacity-90
                                ),
                              ),
                              SizedBox(width: 8), // gap-2
                              Text(
                                '2.450.000',
                                style: TextStyle(
                                  fontSize: 32, // h1
                                  fontWeight: FontWeight.w800, // extrabold
                                  fontFamily: 'Hanken Grotesk',
                                  letterSpacing: -0.02 * 32,
                                  color: Color(0xFFC2C8FF), // text-on-primary-container
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24), // mt-lg
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0x1AFFFFFF), // white/10
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.lock_outline, color: Color(0xFFC2C8FF), size: 14),
                                    SizedBox(width: 8),
                                    Text(
                                      '3 Transaksi\nBerjalan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        color: Color(0xFFC2C8FF),
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFFFF),
                                  foregroundColor: const Color(0xFF0525BB), // primary
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Detail\nEscrow',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12, // label-medium
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                    height: 1.2,
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
            ),
            const SizedBox(height: 24), // space-y-lg
            
            // Total Pendapatan Card
            Container(
              padding: const EdgeInsets.all(16), // p-md
              decoration: BoxDecoration(
                color: const Color(0xFFF4F2FE), // surface-container-low
                borderRadius: BorderRadius.circular(12), // rounded-xl
                border: Border.all(color: const Color(0xFFC5C5D7)), // border-outline-variant
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, // w-12
                    height: 48, // h-12
                    decoration: const BoxDecoration(
                      color: Color(0x33FE9400), // secondary-container/20
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.payments_outlined, color: Color(0xFF8C5000)), // text-secondary
                    ),
                  ),
                  const SizedBox(width: 16), // gap-4
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Total Pendapatan',
                        style: TextStyle(
                          fontSize: 12, // label-caps
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: Color(0xFF1A1B23), // on-surface
                        ),
                      ),
                      Text(
                        'Rp 12.890.000',
                        style: TextStyle(
                          fontSize: 20, // h3
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Hanken Grotesk',
                          color: Color(0xFF1A1B23), // on-background
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // space-y-lg
            
            // Aktivitas Terkini
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Aktivitas Terkini',
                      style: TextStyle(
                        fontSize: 20, // h3
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Hanken Grotesk',
                        color: Color(0xFF1A1B23), // on-background
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                      child: Row(
                        children: const [
                          Text(
                            'Lihat Semua ',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Inter',
                              color: Color(0xFF0525BB),
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 16, color: Color(0xFF0525BB)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // space-y-md
                
                // Activity List
                _buildActivityItem(
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBBvM2Uo0FHGTPCrrbqLOuACrTB8cjiUSI_iDnHGtmhk6w28HIvcAOgpAk6nDMXIB7UN1FssIVe9ubysCn_lcMGbPN-sW82LkbL3_IdPqy7BcLFn9Ka35WZz78lO5-E62NkwQsdK98Cg1XqC4K-hY00yNHPczBHuZ4hOBlYZy4n0HEer8Rf9O99l47op9izAF2CIeEteaZET0f3fpwr111ywWU_pRoTLkelL4RRB-c7IIKh1pl5M2UZOOONk1X_Vmeeoikv1PFoQyEG',
                  title: 'Reparasi AC - Kelapa Gading',
                  subtitle: 'Inv #PION-9921',
                  amount: 'Rp\n450.000',
                  badgeText: 'Dalam\nEscrow',
                  badgeColor: const Color(0xFFFFFBEB), // amber-50/100 roughly
                  badgeTextColor: const Color(0xFF92400E), // amber-800
                ),
                const SizedBox(height: 16),
                
                _buildActivityItem(
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDwx4ctSTi80LkJvZKwL8HK6u2Nb6IhR7ZT710fpVbBTIJdbySqqZ-3KDR0SAOBzl_lt5L_M7KPo8d3Ct2QMIEiH_tzyAKH60ETs-SRGCPCaBtjmpi40EXw3-1P7qL6xqK_Ebl8uQUe-ZEIq9k2PRHQT_XoBaBsw6JQP7KvCsgKSVSuGXgcztu2MQXtJGVdPmvxBbb0YANbXjIWj6K1OJIwE3jfQnYS4AnU35BRKMCRwlP9_qZGlIr19FzYDmfw_mHzkyIAYPq8Oryf',
                  title: 'Instalasi Listrik - Tebet',
                  subtitle: 'Inv #PION-9884',
                  amount: 'Rp\n1.200.000',
                  badgeText: 'Cair',
                  badgeColor: const Color(0xFFDCFCE7), // green-100
                  badgeTextColor: const Color(0xFF166534), // green-800
                ),
                const SizedBox(height: 16),
                
                _buildActivityItem(
                  icon: Icons.handyman_outlined,
                  title: 'Pembersihan Taman',
                  subtitle: 'Inv #PION-9721',
                  amount: 'Rp\n350.000',
                  badgeText: 'Selesai',
                  badgeColor: const Color(0xFFE3E1ED), // surface-container-highest
                  badgeTextColor: const Color(0xFF444655), // on-surface-variant
                  opacity: 0.7,
                ),
              ],
            ),
            const SizedBox(height: 24), // space-y-lg
            
            // Security Note
            Container(
              padding: const EdgeInsets.all(16), // p-md
              decoration: BoxDecoration(
                color: const Color(0xFFEEECF8), // surface-container
                borderRadius: BorderRadius.circular(12), // rounded-xl
                border: Border.all(color: const Color(0x4DC5C5D7)), // outline-variant/30 (30% is ~4D)
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Color(0xFF0525BB), size: 36), // text-primary text-3xl
                  const SizedBox(width: 16), // gap-md
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Dana Anda Aman',
                          style: TextStyle(
                            fontSize: 16, // button
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Hanken Grotesk',
                            color: Color(0xFF1A1B23), // on-background
                          ),
                        ),
                        SizedBox(height: 4), // space-y-1
                        Text(
                          'Escrow Pion memastikan pembayaran hanya dilepaskan saat pekerjaan telah terverifikasi selesai oleh kedua pihak.',
                          style: TextStyle(
                            fontSize: 14, // text-sm
                            fontFamily: 'Inter',
                            color: Color(0xFF444655), // on-surface-variant
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
      ),
    );
  }

  Widget _buildActivityItem({
    String? imageUrl,
    IconData? icon,
    required String title,
    required String subtitle,
    required String amount,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.all(16), // p-md
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8FF), // surface
          borderRadius: BorderRadius.circular(12), // rounded-xl
          border: Border.all(color: const Color(0xFFE3E1ED)), // surface-variant
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000), // shadow
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 40, // w-10
                    height: 40, // h-10
                    decoration: BoxDecoration(
                      color: icon != null ? const Color(0xFFE9E7F3) : null, // surface-container-high
                      borderRadius: BorderRadius.circular(8), // rounded-lg
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: imageUrl != null
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : Icon(icon, color: const Color(0xFF444655)), // on-surface-variant
                  ),
                  const SizedBox(width: 12), // gap-3
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16, // button
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Hanken Grotesk',
                            color: Color(0xFF1A1B23), // on-background
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14, // body-sm
                            fontFamily: 'Inter',
                            color: Color(0xFF444655), // on-surface-variant
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (amount.contains('\n'))
                  RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${amount.split('\n')[0]}\n',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Hanken Grotesk',
                            color: Color(0xFF1A1B23),
                          ),
                        ),
                        TextSpan(
                          text: amount.split('\n')[1],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Hanken Grotesk',
                            color: Color(0xFF1A1B23),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 20, // h3
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Hanken Grotesk',
                      color: Color(0xFF1A1B23), // on-background
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // px-2.5 py-1
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12), // rounded
                  ),
                  child: Text(
                    badgeText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10, // text-xs
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: badgeTextColor,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
