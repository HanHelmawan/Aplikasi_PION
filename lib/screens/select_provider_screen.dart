import 'package:flutter/material.dart';
import 'provider_detail_screen.dart';
class SelectProviderScreen extends StatelessWidget {
  const SelectProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF8FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF0525BB)),
          onPressed: () {
            // Navigator.pop(context); // removed because it's a root tab now
          },
        ),
        title: const Text(
          'Pion',
          style: TextStyle(
            color: Color(0xFF0525BB),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Hanken Grotesk',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF0525BB)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Penyedia',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1B23),
                fontFamily: 'Hanken Grotesk',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '5 profesional telah memberikan penawaran untuk tugas Anda.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444655),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),
            // Provider Cards
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return GridView.count(
                    crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                    children: _buildProviderCards(context),
                  );
                } else {
                  return Column(
                    children: _buildProviderCards(context)
                        .map((card) => Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: card,
                            ))
                        .toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProviderCards(BuildContext context) {
    return [
      _buildProviderCard(
        context,
        name: 'Budi Santoso',
        category: 'Spesialis Instalasi & Pipa',
        tags: ['#AhliAir', '#TepatWaktu'],
        price: 'Rp 250.000',
        rating: 4.9,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBCZMqpSGrSJ4udn_WZzCN5Dz39RyaXM9RReqz42aEH1RaCYdMLb0ZnPpCCBXwjaAdEqbzeQBHLBQy4_UENmvw8P6ypARh_5jj5y4dLdy9HIU3xx8QZ3H482aVgOxR6V6A0VD3_8zfa_1XQZxperSeBfrpiT1zA1m4fTo9Fi5gQ3x_zH4x6mxe5wGfVUec_37zYdJyL9Tx2Mo_Qa2FvuWYPWA3wjG_B7C3fY3bntI_Jd1cts9vnIiFXvcdSiy1o0O0YfjMhW1CuKjSS',
      ),
      _buildProviderCard(
        context,
        name: 'Siti Aminah',
        category: 'Layanan Kebersihan Pro',
        tags: ['#BersihKilat', '#SangatRamah'],
        price: 'Rp 180.000',
        rating: 4.8,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBsGG3QZiqbGXWHdn2njMLBETpASlOqE4tN-9Aq3db5ObZlGcIvwejiqm8tOrad6Vs8FvurttLHQmMA_VJ8abkaE2aPcHqJjUGzDXmKHBWl86V17r_Vyv_oku2Lj8Ucd7eeJ9QtoJSseRNzaW50lR_K_oVjHp6eGmnU7sYPRoYy6-Nbttk1uLeaEfm0Pyv6BaM3FdPcD2JdZQwWpe917BPPPdzu6JPcCpo6X4xmpPXt17a_HlpKoXps9zBjJzaOfSmrMxvY_SW_u3rz',
      ),
      _buildProviderCard(
        context,
        name: 'Andi Pratama',
        category: 'Ahli Listrik & Elektronik',
        tags: ['#SolusiCepat', '#Bersertifikat'],
        price: 'Rp 300.000',
        rating: 5.0,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBtHKokFpO_dEk7PxGBLgrfBeQBPIaro37Ovz2a1b9HnEJNrP7anJZR4jRvv65Z3XnxvgDsX3J0d9GfvZX9VcNIHvdqWQ3zXFBOqQuYZn0oc_jMLBq-FKeQFsASAiJBSs7XeChnORw60RolofIFDjqG6uZn1m_QC9ptV464hL2uIVA4CNjNf99uY45Re4DLNEZl3egBvKwQ0HrO9oXBBt7VRBrBx2Clw4Lh_JITs4ry2PSmLPDU1R8Sm7Dlga9qT-Xo4QjV25v1-eM5',
      ),
      _buildProviderCard(
        context,
        name: 'Ahmad Wijaya',
        category: 'Tukang Kebun',
        tags: ['#PeralatanLengkap', '#RamahLingkungan'],
        price: 'Rp 150.000',
        rating: 4.7,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBCZMqpSGrSJ4udn_WZzCN5Dz39RyaXM9RReqz42aEH1RaCYdMLb0ZnPpCCBXwjaAdEqbzeQBHLBQy4_UENmvw8P6ypARh_5jj5y4dLdy9HIU3xx8QZ3H482aVgOxR6V6A0VD3_8zfa_1XQZxperSeBfrpiT1zA1m4fTo9Fi5gQ3x_zH4x6mxe5wGfVUec_37zYdJyL9Tx2Mo_Qa2FvuWYPWA3wjG_B7C3fY3bntI_Jd1cts9vnIiFXvcdSiy1o0O0YfjMhW1CuKjSS',
      ),
      _buildProviderCard(
        context,
        name: 'Rina Amelia',
        category: 'Servis AC',
        tags: ['#DinginSekejap', '#Garansi'],
        price: 'Rp 200.000',
        rating: 4.9,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBsGG3QZiqbGXWHdn2njMLBETpASlOqE4tN-9Aq3db5ObZlGcIvwejiqm8tOrad6Vs8FvurttLHQmMA_VJ8abkaE2aPcHqJjUGzDXmKHBWl86V17r_Vyv_oku2Lj8Ucd7eeJ9QtoJSseRNzaW50lR_K_oVjHp6eGmnU7sYPRoYy6-Nbttk1uLeaEfm0Pyv6BaM3FdPcD2JdZQwWpe917BPPPdzu6JPcCpo6X4xmpPXt17a_HlpKoXps9zBjJzaOfSmrMxvY_SW_u3rz',
      ),
    ];
  }

  Widget _buildProviderCard(
    BuildContext context, {
    required String name,
    required String category,
    required List<String> tags,
    required String price,
    required double rating,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E1ED)), // surface-variant
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image & Badges Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF380D00), // on-tertiary-fixed
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFFFFFF), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFE0FF), // primary-fixed
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified,
                        color: Color(0xFF1731C2),
                        size: 14), // on-primary-fixed-variant
                    SizedBox(width: 4),
                    Text(
                      'Terverifikasi',
                      style: TextStyle(
                          color: Color(0xFF1731C2),
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Name & Category
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1B23),
              fontFamily: 'Hanken Grotesk',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF444655),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEECF8), // surface-container
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF0525BB), // primary
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          // Price & Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Penawaran',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757686), // outline
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0525BB), // primary
                  fontFamily: 'Hanken Grotesk',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProviderDetailScreen(
                  provider: ProviderData(
                    name: name,
                    title: category,
                    avatarUrl: imageUrl,
                    rating: rating,
                    tasksCompleted: 142,
                    bio: 'Profesional berpengalaman di bidangnya. Berkomitmen memberikan solusi cepat, andal, dan aman. Sudah terverifikasi dan diasuransikan demi ketenangan pikiran Anda.',
                    skills: tags,
                    reviews: [
                      ProviderReview(
                        reviewerName: 'Sarah J.',
                        reviewerAvatar: 'https://i.pravatar.cc/150?img=5',
                        timeAgo: '2 hari yang lalu',
                        rating: 5,
                        text: 'Sangat efisien dan profesional. Sangat direkomendasikan!',
                      ),
                    ],
                    category: category,
                    price: price,
                  ),
                )));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0525BB), // primary
                foregroundColor: const Color(0xFFFFFFFF), // on-primary
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Pilih Penyedia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
