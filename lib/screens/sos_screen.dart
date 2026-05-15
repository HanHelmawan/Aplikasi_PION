import 'package:flutter/material.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Darurat'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: theme.dividerColor)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFCA5A5), width: 2)),
                child: const Icon(Icons.construction_rounded, color: Color(0xFFEF4444), size: 48),
              ),
              const SizedBox(height: 32),
              const Text('Fitur Dalam Pengembangan', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              const Text('Fitur Emergency SOS saat ini sedang dalam tahap pengembangan dan belum dapat digunakan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.6)),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
