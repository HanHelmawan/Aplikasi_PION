import 'package:flutter/material.dart';
import 'create_task_screen.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF8FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0525BB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dashboard Pekerja',
          style: TextStyle(
            color: Color(0xFF0525BB),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Hanken Grotesk',
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE9E7F3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.work_outline,
                size: 40,
                color: Color(0xFF0525BB),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mode Kerja Aktif',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Hanken Grotesk',
                color: Color(0xFF1A1B23),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Anda sekarang dalam Mode Kerja. Radar aktif untuk menerima tugas di sekitar Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  color: Color(0xFF444655),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0525BB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Kembali ke Pencari Jasa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
        },
        backgroundColor: const Color(0xFF0525BB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
