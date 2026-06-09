import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../core/location_service.dart';
import '../widgets/current_location_marker.dart';

/// Screen pemilih lokasi menggunakan OpenStreetMap (flutter_map).
///
/// Tidak menggunakan Google Maps API, Google Cloud, atau billing apapun.
/// Peta disajikan dari tile OpenStreetMap yang gratis dan terbuka.
///
/// Fitur:
/// - Peta interaktif (pinch zoom, drag, rotate)
/// - GPS auto-detect dengan akurasi tinggi
/// - Live tracking posisi perangkat
/// - Drag pin untuk memilih lokasi
/// - Search alamat
/// - Reverse geocoding (via Android built-in Geocoder)
/// - Koordinat ditampilkan realtime
///
/// Mengembalikan `Map<String, dynamic>` berisi:
/// ```dart
/// {
///   'latitude': double,
///   'longitude': double,
///   'address': String,
///   'cityName': String,
/// }
/// ```
class MapLocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? title;

  const MapLocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.title,
  });

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen>
    with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // ── Services ─────────────────────────────────────────────────────────────
  final LocationService _locationService = LocationService();

  // ── Default: Jakarta Pusat ────────────────────────────────────────────────
  static const LatLng _defaultCenter = LatLng(-6.2088, 106.8456);

  // ── State ─────────────────────────────────────────────────────────────────
  LatLng _selectedLocation = _defaultCenter;
  LatLng? _userLiveLocation;      // posisi GPS live (bisa beda dengan pin)
  double _userAccuracy = 20.0;

  String _selectedAddress = 'Memuat alamat...';
  String _selectedCity = '';
  LocationStatus _gpsStatus = LocationStatus.unknown;

  bool _isLoadingAddress = false;
  bool _isLoadingGps = false;
  bool _isSearching = false;
  bool _followUser = true;        // apakah kamera mengikuti user
  bool _mapReady = false;

  List<SearchLocationResult> _searchResults = [];
  Timer? _debounceTimer;
  Timer? _reverseGeocodeTimer;
  StreamSubscription<LocationData>? _locationSub;

  // ── Animations ────────────────────────────────────────────────────────────
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  // ── Zoom ─────────────────────────────────────────────────────────────────
  double _currentZoom = 15.0;

  @override
  void initState() {
    super.initState();

    _selectedLocation = LatLng(
      widget.initialLatitude ?? _defaultCenter.latitude,
      widget.initialLongitude ?? _defaultCenter.longitude,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    // Mulai GPS setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGps();
    });
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _locationService.dispose();
    _mapController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _reverseGeocodeTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  // ── GPS Init ──────────────────────────────────────────────────────────────

  Future<void> _initGps() async {
    setState(() {
      _isLoadingGps = true;
      _gpsStatus = LocationStatus.loading;
    });

    // Cek & minta permission
    final status = await _locationService.checkAndRequestPermission();
    if (!mounted) return;

    if (status != LocationStatus.active) {
      setState(() {
        _gpsStatus = status;
        _isLoadingGps = false;
      });
      // Tetap geocode lokasi default/initial
      _scheduleReverseGeocode(_selectedLocation);
      return;
    }

    // Dapatkan posisi saat ini (first fix)
    final position = await _locationService.getCurrentPosition();
    if (!mounted) return;

    if (position != null) {
      final loc = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLiveLocation = loc;
        _userAccuracy = position.accuracy;
        _selectedLocation = loc;
        _gpsStatus = LocationStatus.active;
        _isLoadingGps = false;
      });

      // Gerakkan kamera ke posisi GPS
      if (_mapReady) {
        _mapController.move(loc, 16.0);
        _currentZoom = 16.0;
      }
      _scheduleReverseGeocode(loc);
    } else {
      setState(() {
        _gpsStatus = _locationService.status;
        _isLoadingGps = false;
      });
      _scheduleReverseGeocode(_selectedLocation);
    }

    // Mulai live tracking stream
    await _locationService.startTracking(
      distanceFilter: 5,
      accuracy: LocationAccuracy.high,
    );
    if (!mounted) return;

    _locationSub = _locationService.locationStream.listen((data) {
      if (!mounted) return;
      final newLoc = LatLng(data.latitude, data.longitude);
      setState(() {
        _userLiveLocation = newLoc;
        _userAccuracy = data.accuracy;
        _gpsStatus = LocationStatus.active;
      });

      // Kamera mengikuti user hanya jika _followUser = true
      if (_followUser && _mapReady) {
        _mapController.move(newLoc, _currentZoom);
      }
    });
  }

  // ── Reverse Geocoding (debounced) ─────────────────────────────────────────

  void _scheduleReverseGeocode(LatLng location) {
    _reverseGeocodeTimer?.cancel();
    setState(() => _isLoadingAddress = true);

    _reverseGeocodeTimer = Timer(const Duration(milliseconds: 600), () async {
      final address = await _locationService.reverseGeocode(
        location.latitude,
        location.longitude,
      );
      if (!mounted) return;
      setState(() {
        _isLoadingAddress = false;
        if (address != null) {
          _selectedAddress = address.fullAddress;
          _selectedCity = address.cityName;
        } else {
          _selectedAddress =
              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
          _selectedCity = 'Lokasi Dipilih';
        }
      });
    });
  }

  // ── GPS Button (recenter) ─────────────────────────────────────────────────

  void _recenterToUser() {
    if (_userLiveLocation != null && _mapReady) {
      _mapController.move(_userLiveLocation!, 16.0);
      _currentZoom = 16.0;
    }
    setState(() => _followUser = true);
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounceTimer = Timer(const Duration(milliseconds: 700), () {
      _doSearch(query.trim());
    });
  }

  Future<void> _doSearch(String query) async {
    final results = await _locationService.searchAddress(query);
    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectSearchResult(SearchLocationResult result) {
    final loc = LatLng(result.latitude, result.longitude);
    setState(() {
      _selectedLocation = loc;
      _searchResults = [];
      _searchController.clear();
      _followUser = false;
    });
    _searchFocusNode.unfocus();

    if (_mapReady) {
      _mapController.move(loc, 16.0);
      _currentZoom = 16.0;
    }
    _scheduleReverseGeocode(loc);
  }

  // ── Confirm ───────────────────────────────────────────────────────────────

  void _confirmLocation() {
    Navigator.pop(context, {
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'address': _selectedAddress,
      'cityName': _selectedCity,
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get _gpsStatusLabel {
    switch (_gpsStatus) {
      case LocationStatus.active:
        return 'GPS Aktif';
      case LocationStatus.loading:
        return 'Mendapatkan GPS...';
      case LocationStatus.serviceDisabled:
        return 'GPS Mati';
      case LocationStatus.permissionDenied:
        return 'Izin Ditolak';
      case LocationStatus.permissionDeniedForever:
        return 'Izin Ditolak Permanen';
      case LocationStatus.timeout:
        return 'GPS Timeout';
      case LocationStatus.error:
        return 'Error GPS';
      case LocationStatus.unknown:
        return 'Memuat...';
    }
  }

  Color get _gpsStatusColor {
    switch (_gpsStatus) {
      case LocationStatus.active:
        return const Color(0xFF10B981);
      case LocationStatus.loading:
      case LocationStatus.unknown:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ── OpenStreetMap ──────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: _currentZoom,
                minZoom: 4,
                maxZoom: 19,
                onMapReady: () => setState(() => _mapReady = true),
                // Update selected location saat user menggeser peta
                onPositionChanged: (camera, hasGesture) {
                  if (hasGesture) {
                    // User menggeser manual → hentikan follow mode
                    setState(() {
                      _selectedLocation = camera.center;
                      _followUser = false;
                      _currentZoom = camera.zoom;
                    });
                    _scheduleReverseGeocode(camera.center);
                  }
                },
              ),
              children: [
                // Tile Layer — OpenStreetMap (gratis, tanpa API key)
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.pion',
                  // Fallback tile server
                  fallbackUrl:
                      'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  maxZoom: 19,
                ),

                // ── Live User Location Marker ────────────────────────────
                if (_userLiveLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _userLiveLocation!,
                        width: 60,
                        height: 60,
                        child: CurrentLocationMarker(
                          accuracy: _userAccuracy,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),

                // OSM Attribution (wajib sesuai lisensi OSM)
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),

            // ── Center Pin (lokasi yang dipilih) ──────────────────────────
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: SelectedLocationPin(),
              ),
            ),

            // ── Top Bar: Back + Search ─────────────────────────────────────
            Positioned(
              top: topPadding + 8,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Tombol kembali
                      _CircleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),

                      // Search Bar
                      Expanded(
                        child: _SearchBar(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _onSearchChanged,
                          onClear: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _isSearching = false;
                            });
                            _searchFocusNode.unfocus();
                          },
                        ),
                      ),
                    ],
                  ),

                  // ── Hasil Pencarian ──────────────────────────────────────
                  if (_isSearching)
                    _SearchLoadingCard(),

                  if (_searchResults.isNotEmpty)
                    _SearchResultsList(
                      results: _searchResults,
                      onSelect: _selectSearchResult,
                      primaryColor: theme.primaryColor,
                    ),
                ],
              ),
            ),

            // ── GPS Error Banner ──────────────────────────────────────────
            if (_gpsStatus != LocationStatus.active &&
                _gpsStatus != LocationStatus.loading &&
                _gpsStatus != LocationStatus.unknown)
              Positioned(
                top: topPadding + 80,
                left: 16,
                right: 16,
                child: _GpsErrorBanner(
                  message: _locationService.lastError ?? _gpsStatusLabel,
                  status: _gpsStatus,
                  onRetry: _gpsStatus == LocationStatus.permissionDeniedForever
                      ? null
                      : _initGps,
                ),
              ),

            // ── GPS Recenter Button ────────────────────────────────────────
            Positioned(
              right: 16,
              bottom: 280 + bottomPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Follow / Unfollow indicator
                  if (_userLiveLocation != null && !_followUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CircleButton(
                        icon: Icons.near_me_rounded,
                        onTap: _recenterToUser,
                        color: theme.primaryColor,
                        iconColor: Colors.white,
                        tooltip: 'Ikuti lokasi saya',
                      ),
                    ),

                  // GPS status button
                  _CircleButton(
                    icon: _isLoadingGps
                        ? Icons.hourglass_top_rounded
                        : (_gpsStatus == LocationStatus.active
                            ? Icons.my_location_rounded
                            : Icons.location_disabled_rounded),
                    onTap: _isLoadingGps ? null : _initGps,
                    color: _gpsStatus == LocationStatus.active
                        ? Colors.white
                        : const Color(0xFFFEF2F2),
                    iconColor: _gpsStatus == LocationStatus.active
                        ? theme.primaryColor
                        : const Color(0xFFEF4444),
                    isLoading: _isLoadingGps,
                    tooltip: _gpsStatusLabel,
                  ),
                ],
              ),
            ),

            // ── Bottom Card: Alamat + Koordinat + Tombol Konfirmasi ────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomCard(
                title: widget.title ?? 'Pilih Lokasi',
                address: _selectedAddress,
                city: _selectedCity,
                latitude: _selectedLocation.latitude,
                longitude: _selectedLocation.longitude,
                gpsStatus: _gpsStatus,
                gpsStatusLabel: _gpsStatusLabel,
                gpsStatusColor: _gpsStatusColor,
                isLoadingAddress: _isLoadingAddress,
                bottomPadding: bottomPadding,
                primaryColor: theme.primaryColor,
                onConfirm: _isLoadingAddress ? null : _confirmLocation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ── Sub-widgets (modular, tidak rebuild seluruh tree) ─────────────────────
// ════════════════════════════════════════════════════════════════════════════

/// Tombol bulat dengan shadow.
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? iconColor;
  final bool isLoading;
  final String? tooltip;

  const _CircleButton({
    required this.icon,
    this.onTap,
    this.color,
    this.iconColor,
    this.isLoading = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.all(13),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: iconColor ?? Theme.of(context).primaryColor,
                ),
              )
            : Icon(
                icon,
                color: iconColor ?? const Color(0xFF0F172A),
                size: 22,
              ),
      ),
    );

    return tooltip != null
        ? Tooltip(message: tooltip!, child: btn)
        : btn;
  }
}

/// Search bar di atas peta.
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: GoogleFonts.nunitoSans(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Cari alamat atau tempat...',
          hintStyle: GoogleFonts.nunitoSans(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: Color(0xFF94A3B8)),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// Card loading saat mencari alamat.
class _SearchLoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 60),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Mencari...',
            style: GoogleFonts.nunitoSans(
                fontSize: 13, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

/// Daftar hasil pencarian alamat.
class _SearchResultsList extends StatelessWidget {
  final List<SearchLocationResult> results;
  final ValueChanged<SearchLocationResult> onSelect;
  final Color primaryColor;

  const _SearchResultsList({
    required this.results,
    required this.onSelect,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 60),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: results.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, indent: 52, color: Color(0xFFF1F5F9)),
        itemBuilder: (ctx, i) {
          final r = results[i];
          return ListTile(
            onTap: () => onSelect(r),
            leading: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on_outlined,
                  color: primaryColor, size: 17),
            ),
            title: Text(
              r.address,
              style: GoogleFonts.nunitoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12),
            dense: true,
          );
        },
      ),
    );
  }
}

/// Banner error GPS.
class _GpsErrorBanner extends StatelessWidget {
  final String message;
  final LocationStatus status;
  final VoidCallback? onRetry;

  const _GpsErrorBanner({
    required this.message,
    required this.status,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                color: const Color(0xFFB91C1C),
                height: 1.4,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Coba lagi',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom card: alamat, koordinat, status GPS, dan tombol konfirmasi.
class _BottomCard extends StatelessWidget {
  final String title;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final LocationStatus gpsStatus;
  final String gpsStatusLabel;
  final Color gpsStatusColor;
  final bool isLoadingAddress;
  final double bottomPadding;
  final Color primaryColor;
  final VoidCallback? onConfirm;

  const _BottomCard({
    required this.title,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.gpsStatus,
    required this.gpsStatusLabel,
    required this.gpsStatusColor,
    required this.isLoadingAddress,
    required this.bottomPadding,
    required this.primaryColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title + GPS Status badge
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              // GPS Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: gpsStatusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: gpsStatusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: gpsStatusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      gpsStatusLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: gpsStatusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Alamat yang dipilih
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_on_rounded,
                      color: primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: isLoadingAddress
                      ? Row(
                          children: [
                            SizedBox(
                              width: 13,
                              height: 13,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Memuat alamat...',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              city,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              address,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Koordinat realtime
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed_rounded,
                    size: 15, color: Color(0xFF0284C7)),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      _CoordChip(
                        label: 'Lat',
                        value: latitude.toStringAsFixed(6),
                      ),
                      const SizedBox(width: 12),
                      _CoordChip(
                        label: 'Lng',
                        value: longitude.toStringAsFixed(6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tombol Konfirmasi
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: onConfirm != null ? 4 : 0,
                shadowColor: primaryColor.withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Pilih Lokasi Ini',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip koordinat kecil.
class _CoordChip extends StatelessWidget {
  final String label;
  final String value;

  const _CoordChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0369A1),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
