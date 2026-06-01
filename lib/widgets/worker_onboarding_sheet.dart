import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/auth_service.dart';

class WorkerOnboardingSheet extends StatefulWidget {
  final String userName;
  final VoidCallback onCompleted;

  const WorkerOnboardingSheet({
    super.key,
    required this.userName,
    required this.onCompleted,
  });

  @override
  State<WorkerOnboardingSheet> createState() => _WorkerOnboardingSheetState();
}

class _WorkerOnboardingSheetState extends State<WorkerOnboardingSheet> {
  int _currentStep = 1;
  bool _isSubmitting = false;

  // Form Fields
  String _selectedCategory = 'Perbaikan';
  final _specialtyCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _skillInputCtrl = TextEditingController();

  final List<String> _skills = [];
  final List<String> _selectedProblems = [];
  bool _isOnline = true;

  // Categories list matching Home Seeker Screen
  final List<String> _categories = [
    'Perbaikan',
    'Kebersihan',
    'Listrik',
    'Ledeng',
    'AC & Elektronik',
    'Taman',
    'Keamanan',
    'Angkut',
    'Pertukangan',
    'Kesehatan',
    'Les Privat',
    'Fotografi',
    'Cat Rumah',
    'Perabot',
  ];

  // Dynamic Suggestion Chips for Problems based on Category
  Map<String, List<String>> get _problemSuggestions => {
        'Perbaikan': ['pompa air', 'kunci macet', 'engsel rusak', 'dinding retak', 'atap bocor'],
        'Kebersihan': ['sapu pel', 'setrika baju', 'deep cleaning', 'bersih rumah', 'cuci piring', 'debu'],
        'Listrik': ['konslet', 'mati lampu', 'pasang lampu', 'kabel putus', 'sekring', 'saklar rusak'],
        'Ledeng': ['bocor', 'pipa bocor', 'keran rusak', 'wc mampet', 'wastafel tersumbat', 'pasang pipa'],
        'AC & Elektronik': ['ac panas', 'cuci ac', 'ac bocor', 'servis tv', 'mesin cuci rusak', 'kulkas'],
        'Taman': ['potong rumput', 'tanam bunga', 'pupuk tanaman', 'hama', 'kolam ikan'],
        'Pertukangan': ['lemari rusak', 'pintu macet', 'kayu', 'bikin meja', 'pasang engsel'],
        'Cat Rumah': ['cat tembok', 'cat plafon', 'dinding rembes', 'wallpaper', 'kupas cat'],
      };

  @override
  void dispose() {
    _specialtyCtrl.dispose();
    _bioCtrl.dispose();
    _skillInputCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    final text = _skillInputCtrl.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _skillInputCtrl.clear();
      });
    }
  }

  void _toggleProblem(String problem) {
    setState(() {
      if (_selectedProblems.contains(problem)) {
        _selectedProblems.remove(problem);
      } else {
        _selectedProblems.add(problem);
      }
    });
  }

  Future<void> _submitProfile() async {
    if (_specialtyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masukkan spesialisasi / keahlian Anda.', style: GoogleFonts.nunitoSans()),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Save profile to Firestore via AuthService
    final error = await AuthService.updateWorkerProfile(
      category: _selectedCategory,
      specialty: _specialtyCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isNotEmpty
          ? _bioCtrl.text.trim()
          : 'Penyedia jasa profesional kategori $_selectedCategory.',
      skills: _skills.isEmpty ? [_specialtyCtrl.text.trim()] : _skills,
      problems: _selectedProblems.isEmpty ? [_selectedCategory.toLowerCase()] : _selectedProblems,
      isOnline: _isOnline,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (error == null) {
        // Success animation or message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil Jasa Berhasil Diaktifkan! Selamat bekerja ✓', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
        Navigator.pop(context); // Close the sheet
        widget.onCompleted(); // Switch mode
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: GoogleFonts.nunitoSans()),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFF3B82F6);

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Handler bar
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Siapkan Profil Jasa',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Langkah $_currentStep dari 2',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded, size: 14, color: Color(0xFF2563EB)),
                      const SizedBox(width: 4),
                      Text(
                        'Keamanan Mitra',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Step Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _currentStep == 1 ? _buildStep1(primaryColor) : _buildStep2(primaryColor),
              ),
            ),
          ),

          const SizedBox(height: 24),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                if (_currentStep > 1)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        'Kembali',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 1) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : (_currentStep == 1 ? () => setState(() => _currentStep++) : _submitProfile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _currentStep == 1 ? 'Lanjutkan' : 'Simpan & Aktifkan',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(Color primaryColor) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Kategori & Bidang Keahlian',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),

        // Category dropdown
        _inputLabel('Pilih Kategori Utama Jasa Anda'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: _categories
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(
                        cat,
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCategory = val;
                    // Reset selected problems when category changes
                    _selectedProblems.clear();
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Specialty Title
        _inputLabel('Gelar / Spesialisasi Spesifik'),
        const SizedBox(height: 8),
        TextField(
          controller: _specialtyCtrl,
          decoration: _inputDecoration('Contoh: Ahli Instalasi Pipa & Kran Air', Icons.work_outline_rounded, primaryColor),
          style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Bio
        _inputLabel('Deskripsi Keahlian / Bio Singkat'),
        const SizedBox(height: 8),
        TextField(
          controller: _bioCtrl,
          maxLines: 3,
          style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Tulis keahlian dan pengalaman Anda agar pencari jasa tertarik memilih Anda...',
            hintStyle: GoogleFonts.nunitoSans(color: const Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 1.5)),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(Color primaryColor) {
    final suggestions = _problemSuggestions[_selectedCategory] ?? [];

    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Target Permasalahan & Keahlian Khusus',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 14),

        // Target Problems
        _inputLabel('Pilih Masalah yang Bisa Anda Atasi'),
        const SizedBox(height: 4),
        Text(
          'Pencari jasa akan menemukan Anda saat mereka mencari kata-kata ini.',
          style: GoogleFonts.nunitoSans(fontSize: 12, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),

        if (suggestions.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((problem) {
              final isSelected = _selectedProblems.contains(problem);
              return FilterChip(
                label: Text(
                  problem,
                  style: GoogleFonts.nunitoSans(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 12,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
                selected: isSelected,
                selectedColor: primaryColor,
                checkmarkColor: Colors.white,
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                onSelected: (_) => _toggleProblem(problem),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Custom Skills Tag Input
        _inputLabel('Tambahkan Layanan Jasa Lain (Opsional)'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillInputCtrl,
                decoration: _inputDecoration('Contoh: Pompa Air, Pasang HPL', Icons.add_circle_outline_rounded, primaryColor),
                onSubmitted: (_) => _addSkill(),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: _addSkill,
              style: IconButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.all(14),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ],
        ),
        if (_skills.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills.map((skill) {
              return Chip(
                label: Text(
                  skill,
                  style: GoogleFonts.nunitoSans(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                backgroundColor: const Color(0xFFEFF6FF),
                deleteIcon: Icon(Icons.close_rounded, size: 14, color: primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                ),
                onDeleted: () {
                  setState(() {
                    _skills.remove(skill);
                  });
                },
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 20),

        // Availability Toggle
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Aktif (Online)',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Profil Anda langsung dapat dicari pengguna lain.',
                      style: GoogleFonts.nunitoSans(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isOnline,
                activeColor: primaryColor,
                onChanged: (v) => setState(() => _isOnline = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _inputLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF475569),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, Color primaryColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunitoSans(color: const Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// Global show helper function
void showWorkerOnboardingSheet(
  BuildContext context, {
  required String userName,
  required VoidCallback onCompleted,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => WorkerOnboardingSheet(
      userName: userName,
      onCompleted: onCompleted,
    ),
  );
}
