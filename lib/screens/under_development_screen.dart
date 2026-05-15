import 'package:flutter/material.dart';

class UnderDevelopmentScreen extends StatelessWidget {
  final String title;
  final String message;

  const UnderDevelopmentScreen({
    super.key,
    this.title = 'Fitur Dalam Pengembangan',
    this.message = 'Fitur ini sedang dalam tahap pengembangan dan belum dapat digunakan.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Pion'),
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
                decoration: BoxDecoration(color: const Color(0xFFEEF0FF), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC7D0F8))),
                child: Icon(Icons.construction_rounded, color: theme.colorScheme.primary, size: 48),
              ),
              const SizedBox(height: 32),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.6)),
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
