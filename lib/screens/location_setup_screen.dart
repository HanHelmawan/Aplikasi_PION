import 'package:flutter/material.dart';
import '../core/auth_service.dart';
import '../main.dart';

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
  bool _isLoading = false;
  bool _gpsGranted = false;

  // Daftar kota besar Indonesia untuk pilihan manual
  static const List<String> _cities = [
    'Jakarta Pusat',
    'Jakarta Selatan',
    'Jakarta Barat',
    'Jakarta Timur',
    'Jakarta Utara',
    'Bogor',
    'Depok',
    'Tangerang',
    'Tangerang Selatan',
    'Bekasi',
    'Bandung',
    'Surabaya',
    'Medan',
    'Semarang',
    'Makassar',
    'Palembang',
    'Denpasar',
    'Yogyakarta',
    'Malang',
    'Solo',
  ];

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

  // â”€â”€ Simulated GPS Permission Request â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _requestGpsPermission() async {
    final granted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(ctx).primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 34,
                color: Theme.of(ctx).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Izinkan Akses Lokasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '"Pion" ingin mengakses lokasi Anda untuk menampilkan penyedia jasa terdekat dalam radius pencarian.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF475569),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF94A3B8)),
            child: const Text('Jangan Izinkan', style: TextStyle(fontFamily: 'Inter')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).primaryColor,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Izinkan', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );

    if (granted == true && mounted) {
      setState(() => _gpsGranted = true);
      // Simulate detecting location
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedCity = 'Jakarta Selatan'; // Simulated GPS result
        });
        _showSnack('Lokasi terdeteksi: Jakarta Selatan', isSuccess: true);
      }
    }
  }

  Future<void> _confirmAndContinue() async {
    if (_selectedCity == null) {
      _showSnack('Pilih lokasi Anda terlebih dahulu');
      return;
    }

    setState(() => _isLoading = true);
    await AuthService.saveLocation(_selectedCity!);
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
        content: Text(message, style: const TextStyle(fontFamily: 'Inter')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? const Color(0xFF10B981) : Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
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
                              child: const Text(
                                'Lewati',
                                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

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
                                      Theme.of(context).primaryColor.withOpacity(0.12),
                                      Theme.of(context).primaryColor.withOpacity(0.02),
                                    ],
                                  ),
                                ),
                              ),
                              // Inner circle with icon
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.my_location_rounded,
                                  size: 64,
                                  color: Theme.of(context).primaryColor,
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
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.location_pin,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // â”€â”€ Heading â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                        const Text(
                          'Di mana lokasi Anda?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Kami membutuhkan lokasi Anda untuk menampilkan penyedia jasa terverifikasi dalam radius 1â€“5 km dari Anda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: Color(0xFF475569),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // â”€â”€ GPS Button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: _gpsGranted
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFEEF0FF),
                            border: Border.all(
                              color: _gpsGranted
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFC7D0F8),
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            onTap: _gpsGranted ? null : _requestGpsPermission,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _gpsGranted
                                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                    : const Color(0xFF0525BB).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _gpsGranted
                                    ? Icons.check_circle_rounded
                                    : Icons.gps_fixed_rounded,
                                color: _gpsGranted
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF0525BB),
                                size: 24,
                              ),
                            ),
                            title: Text(
                              _gpsGranted
                                  ? 'Lokasi GPS aktif'
                                  : 'Gunakan Lokasi GPS',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: _gpsGranted
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF0525BB),
                              ),
                            ),
                            subtitle: Text(
                              _gpsGranted
                                  ? _selectedCity ?? 'Mendeteksi...'
                                  : 'Deteksi otomatis via perangkat',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: _gpsGranted
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            trailing: _gpsGranted
                                ? null
                                : const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF0525BB),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // â”€â”€ Divider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'atau pilih manual',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // â”€â”€ City Dropdown â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedCity != null && !_gpsGranted
                                  ? const Color(0xFF0525BB)
                                  : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: (!_gpsGranted) ? _selectedCity : null,
                              hint: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Pilih kota / area',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFF94A3B8),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              isExpanded: true,
                              icon: const Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              items: _cities
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Text(
                                            c,
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 15,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedCity = val;
                                  _gpsGranted = false; // Manual overrides GPS
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // â”€â”€ Confirm Button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_isLoading || _selectedCity == null)
                                ? null
                                : _confirmAndContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0525BB),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFE2E8F0),
                              shape: const StadiumBorder(),
                              elevation: _selectedCity != null ? 8 : 0,
                              shadowColor: const Color(0x400525BB),
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
                                      Text(
                                        _selectedCity != null
                                            ? 'Konfirmasi: $_selectedCity'
                                            : 'Pilih lokasi dulu',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
