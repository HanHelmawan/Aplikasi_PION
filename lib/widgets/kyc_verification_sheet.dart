import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/auth_service.dart';

class KycVerificationSheet extends StatefulWidget {
  final String userName;
  final VoidCallback? onCompleted;

  const KycVerificationSheet({
    super.key,
    required this.userName,
    this.onCompleted,
  });

  @override
  State<KycVerificationSheet> createState() => _KycVerificationSheetState();
}

class _KycVerificationSheetState extends State<KycVerificationSheet> {
  int _currentStep = 1; // 1: Intro, 2: KTP, 3: Face Scan, 4: Processing, 5: Success
  bool _ktpUploaded = false;
  bool _isUploadingKtp = false;
  bool _isSubmitting = false;

  // Liveness Check State
  String _livenessStatus = 'Menunggu wajah terdeteksi...';
  double _livenessPulse = 1.0;
  Timer? _livenessTimer;
  int _livenessStep = 0;

  @override
  void dispose() {
    _livenessTimer?.cancel();
    super.dispose();
  }

  void _startLivenessCheck() {
    setState(() {
      _livenessStatus = 'Mendeteksi wajah...';
      _livenessPulse = 1.1;
      _livenessStep = 1;
    });

    _livenessTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_livenessStep == 1) {
          _livenessStatus = 'Silakan berkedip...';
          _livenessPulse = 1.25;
          _livenessStep = 2;
        } else if (_livenessStep == 2) {
          _livenessStatus = 'Memindai kontur wajah...';
          _livenessPulse = 1.0;
          _livenessStep = 3;
        } else {
          timer.cancel();
          _nextStep(); // Advance to Step 4 (Processing)
        }
      });
    });
  }

  void _nextStep() {
    if (_currentStep == 4) {
      // Step 4 is transition to 5
      setState(() => _currentStep = 5);
    } else {
      setState(() {
        _currentStep++;
      });
      if (_currentStep == 3) {
        _startLivenessCheck();
      } else if (_currentStep == 4) {
        // Auto-advance Step 4 to 5 after processing delay
        Timer(const Duration(milliseconds: 2000), () {
          if (mounted) _nextStep();
        });
      }
    }
  }

  Future<void> _simulateKtpUpload() async {
    setState(() {
      _isUploadingKtp = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isUploadingKtp = false;
        _ktpUploaded = true;
      });
    }
  }

  Future<void> _completeKyc() async {
    setState(() => _isSubmitting = true);
    final error = await AuthService.verifyKyc();
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: GoogleFonts.nunitoSans()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.pop(context);
      widget.onCompleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Step Content Switcher
            if (_currentStep == 1) _buildIntroStep(colorScheme),
            if (_currentStep == 2) _buildKtpStep(colorScheme),
            if (_currentStep == 3) _buildLivenessStep(colorScheme),
            if (_currentStep == 4) _buildProcessingStep(colorScheme),
            if (_currentStep == 5) _buildSuccessStep(colorScheme),
          ],
        ),
      ),
    );
  }

  // ── STEP 1: INTRO ──────────────────────────────────────────────────────────
  Widget _buildIntroStep(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shield_outlined, color: colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verifikasi Identitas (KYC)',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Keamanan & Kepercayaan Pion',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Untuk menjaga keamanan komunitas Pion, calon penyedia jasa (pekerja) diwajibkan menyelesaikan verifikasi identitas resmi sebelum dapat beralih ke Mode Kerja.',
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            height: 1.6,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 20),
        _buildBulletPoint(
          Icons.badge_outlined,
          'Unggah Kartu Identitas (KTP)',
          'Ambil foto KTP Anda secara jelas untuk dicocokkan.',
          colorScheme,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint(
          Icons.face_retouching_natural_outlined,
          'Verifikasi Liveness Wajah',
          'Pindai wajah Anda langsung untuk menghindari pemalsuan.',
          colorScheme,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint(
          Icons.lock_person_outlined,
          'Data Terenkripsi & Aman',
          'Dokumen privasi dilindungi secara penuh dalam server Pion.',
          colorScheme,
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text('Mulai Verifikasi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(IconData icon, String title, String desc, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── STEP 2: UPLOAD KTP ──────────────────────────────────────────────────────
  Widget _buildKtpStep(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Langkah 1 dari 2',
          style: GoogleFonts.nunitoSans(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary),
        ),
        const SizedBox(height: 4),
        Text(
          'Unggah Foto KTP',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        Text(
          'Posisikan KTP Anda di tempat terang dan pastikan informasi nama & NIK terbaca dengan jelas.',
          style: GoogleFonts.nunitoSans(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: (_isUploadingKtp || _ktpUploaded) ? null : _simulateKtpUpload,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _ktpUploaded ? Colors.green : colorScheme.primary.withValues(alpha: 0.3),
                width: 2,
                style: _ktpUploaded ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isUploadingKtp)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(strokeWidth: 3),
                        const SizedBox(height: 14),
                        Text(
                          'Mengambil dan memindai foto KTP...',
                          style: GoogleFonts.nunitoSans(fontSize: 13, color: const Color(0xFF64748B)),
                        ),
                      ],
                    )
                  else if (_ktpUploaded)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'KARTU TANDA PENDUDUK',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            widget.userName.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'NIK: 3174xxxxxxxxxx',
                            style: GoogleFonts.nunitoSans(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded, size: 36, color: colorScheme.primary),
                        const SizedBox(height: 10),
                        Text(
                          'Ketuk untuk Ambil Foto KTP',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.primary),
                        ),
                        Text(
                          'Mendukung JPG, PNG hingga 5MB',
                          style: GoogleFonts.nunitoSans(fontSize: 11, color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Kembali', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _ktpUploaded ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Lanjut', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── STEP 3: LIVENESS SCAN ──────────────────────────────────────────────────
  Widget _buildLivenessStep(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Langkah 2 dari 2',
          style: GoogleFonts.nunitoSans(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary),
        ),
        const SizedBox(height: 4),
        Text(
          'Verifikasi Liveness Wajah',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        Text(
          'Silakan ikuti instruksi pada layar untuk melakukan pemindaian wajah.',
          style: GoogleFonts.nunitoSans(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.6),
                width: 4 * _livenessPulse,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.face_retouching_natural_outlined,
                  size: 80,
                  color: colorScheme.primary.withValues(alpha: 0.4),
                ),
                Positioned(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            _livenessStatus,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── STEP 4: PROCESSING ─────────────────────────────────────────────────────
  Widget _buildProcessingStep(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        const CircularProgressIndicator(strokeWidth: 4),
        const SizedBox(height: 24),
        Text(
          'Memverifikasi Data...',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mencocokkan NIK KTP dengan pemindaian wajah liveness Anda.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── STEP 5: SUCCESS ────────────────────────────────────────────────────────
  Widget _buildSuccessStep(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 52),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Verifikasi Berhasil! 🎉',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Identitas Anda telah terverifikasi penuh. Anda sekarang dapat mengaktifkan Mode Kerja untuk melayani pelanggan Pion.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                height: 1.6,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _completeKyc,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text('Selesai', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }
}

// ── Static Helper ──────────────────────────────────────────────────────────
void showKycVerificationSheet(
  BuildContext context, {
  required String userName,
  VoidCallback? onCompleted,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) => KycVerificationSheet(
      userName: userName,
      onCompleted: onCompleted,
    ),
  );
}
