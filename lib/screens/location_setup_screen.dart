import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/auth_service.dart';
import '../core/theme.dart';
import '../main.dart';
import 'map_location_picker_screen.dart';

class LocationSetupScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const LocationSetupScreen({super.key, required this.user});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  String? _selectedCity;
  String? _selectedAddress;
  double? _selectedLat;
  double? _selectedLng;
  bool _isLoading = false;
  bool _locationSelected = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Open Map Picker ──────────────────────────────────────────────────────
  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPickerScreen(
          initialLatitude: _selectedLat,
          initialLongitude: _selectedLng,
          title: 'Pilih Lokasi Anda',
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedLat = result['latitude'] as double;
        _selectedLng = result['longitude'] as double;
        _selectedAddress = result['address'] as String;
        _selectedCity = result['cityName'] as String;
        _locationSelected = true;
      });
      _showSnack('Lokasi berhasil dipilih: $_selectedCity', isSuccess: true);
    }
  }

  Future<void> _confirmAndContinue() async {
    if (_selectedCity == null) {
      _showSnack('Pilih lokasi Anda terlebih dahulu');
      return;
    }

    setState(() => _isLoading = true);
    await AuthService.saveLocation(_selectedCity!);
    if (_selectedLat != null && _selectedLng != null) {
      await AuthService.saveLocationCoordinates(_selectedLat!, _selectedLng!);
    }
    if (_selectedAddress != null) {
      await AuthService.saveFullAddress(_selectedAddress!);
    }
    await AuthService.markLocationSetupDone();
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, anim, secAnim) =>
            MainNavigation(isWorkerMode: widget.user['isWorkerMode'] ?? false),
        transitionsBuilder: (ctx, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _skipSetup() async {
    await AuthService.markLocationSetupDone();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, anim, secAnim) =>
            MainNavigation(isWorkerMode: widget.user['isWorkerMode'] ?? false),
        transitionsBuilder: (ctx, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showSnack(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.nunitoSans()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? const Color(0xFF10B981) : Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWorker = widget.user['isWorkerMode'] ?? false;
    final theme = PionTheme.buildTheme(isWorkerMode: isWorker);

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                        // ── Skip Button ──────────────────────────────────────
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextButton(
                              onPressed: _skipSetup,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF94A3B8),
                              ),
                              child: Text(
                                'Lewati',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Illustration ──────────────────────────────────────
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow ring
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Theme.of(context).primaryColor.withValues(alpha: 0.12), // ✅ AUDIT FIX (L-1)
                                      Theme.of(context).primaryColor.withValues(alpha: 0.02),
                                    ],
                                  ),
                                ),
                              ),
                              // Inner circle with icon
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.08), // ✅ AUDIT FIX (L-1)
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _locationSelected ? Icons.check_circle_rounded : Icons.my_location_rounded,
                                  size: 64,
                                  color: _locationSelected ? const Color(0xFF10B981) : Theme.of(context).primaryColor,
                                ),
                              ),
                              // Small pin badge
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _locationSelected ? const Color(0xFF10B981) : Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _locationSelected ? Icons.map_rounded : Icons.location_pin,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Heading ──────────────────────────────────────────
                        Text(
                          'Di mana lokasi Anda?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Kami membutuhkan lokasi Anda untuk menampilkan penyedia jasa terverifikasi dalam radius 1-5 km dari Anda.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 15,
                            color: const Color(0xFF475569),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Map Picker Button ──────────────────────────────────
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: _locationSelected
                                ? const Color(0xFFD1FAE5)
                                : (Theme.of(context).chipTheme.backgroundColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.08)),
                            border: Border.all(
                              color: _locationSelected
                                  ? const Color(0xFF10B981)
                                  : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            onTap: _openMapPicker,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _locationSelected
                                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                    : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _locationSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.map_rounded,
                                color: _locationSelected
                                    ? const Color(0xFF10B981)
                                    : Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              _locationSelected
                                  ? _selectedCity ?? 'Lokasi Dipilih'
                                  : 'Pilih Lokasi di Peta',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: _locationSelected
                                    ? const Color(0xFF059669)
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                            subtitle: Text(
                              _locationSelected
                                  ? (_selectedAddress ?? 'Alamat terpilih')
                                  : 'Gunakan peta interaktif & GPS',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 13,
                                color: _locationSelected
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF64748B),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Icon(
                              _locationSelected
                                  ? Icons.edit_rounded
                                  : Icons.chevron_right_rounded,
                              color: _locationSelected
                                  ? const Color(0xFF10B981)
                                  : Theme.of(context).primaryColor,
                              size: 22,
                            ),
                          ),
                        ),

                        // ── Hint text ──────────────────────────────────────────
                        if (!_locationSelected) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF0284C7)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Anda bisa memilih lokasi dengan mengetuk peta, drag pin, mencari alamat, atau menggunakan GPS otomatis.',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 12,
                                      color: const Color(0xFF0369A1),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // ── Confirm Button ──────────────────────────────────
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_isLoading || _selectedCity == null)
                                ? null
                                : _confirmAndContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFE2E8F0),
                              shape: const StadiumBorder(),
                              elevation: _selectedCity != null ? 8 : 0,
                              shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.25), // ✅ AUDIT FIX (L-1)
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_rounded, size: 20),
                                      const SizedBox(width: 8),
                                      Flexible(child: Text(_selectedCity != null ? 'Konfirmasi: $_selectedCity' : 'Pilih lokasi dulu', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    ),
  );
}
}
