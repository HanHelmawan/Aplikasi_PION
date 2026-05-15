import 'package:flutter/material.dart';

import 'create_task_screen.dart';

class HomeSeekerScreen extends StatelessWidget {
  final bool isWorkerMode;
  const HomeSeekerScreen({super.key, this.isWorkerMode = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
        ),
        title: const Row(
          children: [
            Text('Pion', style: TextStyle(color: Color(0xFF0052CC), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE3EDFE), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Temukan bantuan,\nsekarang juga.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1B233A), height: 1.1),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Terhubung dengan penyedia jasa lokal terverifikasi untuk\nberbagai tugas yang Anda butuhkan hari ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  // Search Box
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Color(0xFF0052CC)),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Apa yang Anda butuhkan?',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.black38),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052CC),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cari Sekarang'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Explore Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jelajahi Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('Lihat semua')),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryItem(Icons.build, '#Perbaikan'),
                  _buildCategoryItem(Icons.group, '#TemanJalan'),
                  _buildCategoryItem(Icons.fitness_center, '#BantuAngkat'),
                  _buildCategoryItem(Icons.cleaning_services, '#Bersih2'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nearby Providers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Penyedia Terdekat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('Lihat peta')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildProviderCard(
                    name: 'Budi Santoso',
                    distance: '1.2 km',
                    rating: '4.9',
                    imageUrl: 'https://i.pravatar.cc/150?img=12',
                    tags: ['#Perbaikan', '#BantuAngkat'],
                  ),
                  _buildProviderCard(
                    name: 'Siti Aminah',
                    distance: '2.5 km',
                    rating: '4.8',
                    imageUrl: 'https://i.pravatar.cc/150?img=5',
                    tags: ['#BersihRumah', '#TemanJalan'],
                  ),
                  _buildProviderCard(
                    name: 'Andi Pratama',
                    distance: '3.1 km',
                    rating: '5.0',
                    imageUrl: 'https://i.pravatar.cc/150?img=13',
                    tags: ['#Pindahan', '#BantuAngkat'],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: isWorkerMode == true
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
              },
              backgroundColor: const Color(0xFF0525BB),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Icon(icon, color: const Color(0xFF0052CC)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProviderCard({
    required String name,
    required String distance,
    required String rating,
    required String imageUrl,
    required List<String> tags,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl)),
                    const Positioned(
                      bottom: 0, right: 0,
                      child: Icon(Icons.check_circle, color: Color(0xFF0052CC), size: 16),
                    )
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(distance, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE3EDFE), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 14),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: tags.map((tag) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE3EDFE), borderRadius: BorderRadius.circular(12)),
                  child: Text(tag, style: const TextStyle(fontSize: 10, color: Color(0xFF0052CC))),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE3EDFE),
                  foregroundColor: const Color(0xFF0052CC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lihat Profil'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
