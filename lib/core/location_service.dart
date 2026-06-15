import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

/// Status GPS dan permission.
enum LocationStatus {
  unknown,
  loading,
  active,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  error,
}

/// Data lokasi beserta metadata.
class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  @override
  String toString() =>
      'LocationData(lat: ${latitude.toStringAsFixed(6)}, '
      'lng: ${longitude.toStringAsFixed(6)}, '
      'acc: ${accuracy.toStringAsFixed(1)}m)';
}

/// Data alamat dari reverse geocoding.
class AddressData {
  final String fullAddress;
  final String cityName;
  final String? street;
  final String? subLocality;
  final String? locality;
  final String? administrativeArea;

  const AddressData({
    required this.fullAddress,
    required this.cityName,
    this.street,
    this.subLocality,
    this.locality,
    this.administrativeArea,
  });
}

/// Hasil pencarian alamat.
class SearchLocationResult {
  final double latitude;
  final double longitude;
  final String address;

  const SearchLocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

// ── Nominatim HTTP headers ────────────────────────────────────────────────────

const Map<String, String> _nominatimHeaders = {
  'User-Agent': 'PionApp/1.1 (Flutter; contact@pion.id)',
  'Accept': 'application/json; charset=utf-8',
  'Accept-Language': 'id,en;q=0.9',
};

// ── LocationService ───────────────────────────────────────────────────────────

/// Service untuk mengelola lokasi GPS perangkat.
///
/// Reverse geocoding menggunakan Nominatim OSM API (utama) sebagai sumber
/// nama alamat yang akurat untuk Indonesia, dengan geocoding package sebagai
/// fallback.
class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final StreamController<LocationData> _locationController =
      StreamController<LocationData>.broadcast();

  Stream<LocationData> get locationStream => _locationController.stream;

  LocationStatus _status = LocationStatus.unknown;
  LocationStatus get status => _status;

  String? _lastError;
  String? get lastError => _lastError;

  // ── Permission & Service Check ──────────────────────────────────────────────

  Future<LocationStatus> checkAndRequestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _status = LocationStatus.serviceDisabled;
        _lastError = 'Layanan lokasi tidak aktif. Silakan aktifkan GPS Anda.';
        return _status;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _status = LocationStatus.permissionDenied;
          _lastError =
              'Izin lokasi ditolak. Aplikasi membutuhkan akses lokasi.';
          return _status;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _status = LocationStatus.permissionDeniedForever;
        _lastError =
            'Izin lokasi ditolak permanen. Silakan ubah di Pengaturan.';
        return _status;
      }

      _status = LocationStatus.active;
      _lastError = null;
      return _status;
    } catch (e) {
      _status = LocationStatus.error;
      _lastError = 'Gagal memeriksa izin lokasi: $e';
      debugPrint('checkAndRequestPermission error: $e');
      return _status;
    }
  }

  // ── Get Current Position ────────────────────────────────────────────────────

  Future<LocationData?> getCurrentPosition() async {
    try {
      _status = LocationStatus.loading;
      final permStatus = await checkAndRequestPermission();
      if (permStatus != LocationStatus.active) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      _status = LocationStatus.active;
      _lastError = null;
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } on TimeoutException {
      _status = LocationStatus.timeout;
      _lastError = 'Timeout. Pastikan GPS aktif dan berada di area terbuka.';
      return null;
    } on LocationServiceDisabledException {
      _status = LocationStatus.serviceDisabled;
      _lastError = 'Layanan lokasi tidak aktif.';
      return null;
    } on PermissionDeniedException {
      _status = LocationStatus.permissionDenied;
      _lastError = 'Izin lokasi ditolak.';
      return null;
    } catch (e) {
      _status = LocationStatus.error;
      _lastError = 'Gagal mendapatkan lokasi: $e';
      debugPrint('getCurrentPosition error: $e');
      return null;
    }
  }

  // ── Live Tracking Stream ────────────────────────────────────────────────────

  Future<void> startTracking({
    int distanceFilter = 5,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    final permStatus = await checkAndRequestPermission();
    if (permStatus != LocationStatus.active) return;
    await stopTracking();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    ).listen(
      (position) {
        _locationController.add(LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          timestamp: position.timestamp,
        ));
        _status = LocationStatus.active;
      },
      onError: (error) {
        _status = LocationStatus.error;
        _lastError = 'Stream error: $error';
        debugPrint('startTracking stream error: $error');
      },
    );
  }

  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  // ── Reverse Geocoding ───────────────────────────────────────────────────────

  /// Mengubah koordinat GPS menjadi nama alamat teks yang mudah dibaca.
  ///
  /// Strategi:
  /// 1. Nominatim OSM API (via package http) — akurat untuk Indonesia
  /// 2. geocoding package (platform) — cadangan offline
  Future<AddressData?> reverseGeocode(
      double latitude, double longitude) async {
    // 1. Nominatim (utama)
    try {
      final result = await _nominatimReverse(latitude, longitude);
      if (result != null) {
        debugPrint('reverseGeocode[Nominatim OK]: ${result.fullAddress}');
        return result;
      }
    } catch (e) {
      debugPrint('reverseGeocode Nominatim error: $e');
    }

    // 2. Platform geocoder (fallback)
    try {
      final result = await _platformReverse(latitude, longitude);
      if (result != null) {
        debugPrint('reverseGeocode[Platform OK]: ${result.fullAddress}');
        return result;
      }
    } catch (e) {
      debugPrint('reverseGeocode Platform error: $e');
    }

    debugPrint('reverseGeocode: semua metode gagal untuk $latitude, $longitude');
    return null;
  }

  /// Nominatim OSM reverse geocoding menggunakan package http.
  Future<AddressData?> _nominatimReverse(
      double latitude, double longitude) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      {
        'format': 'jsonv2',
        'lat': latitude.toStringAsFixed(7),
        'lon': longitude.toStringAsFixed(7),
        'addressdetails': '1',
        'zoom': '18',          // Detail jalan/gang
        'accept-language': 'id',
      },
    );

    debugPrint('Nominatim reverse URL: $uri');

    final response = await http
        .get(uri, headers: _nominatimHeaders)
        .timeout(const Duration(seconds: 10));

    debugPrint('Nominatim reverse status: ${response.statusCode}');

    if (response.statusCode != 200) return null;

    final body = utf8.decode(response.bodyBytes);
    final data = jsonDecode(body) as Map<String, dynamic>?;
    if (data == null) return null;

    // Cek apakah Nominatim menemukan hasil
    if (data['error'] != null) {
      debugPrint('Nominatim error response: ${data['error']}');
      return null;
    }

    final addrMap = data['address'] as Map<String, dynamic>?;
    if (addrMap == null) return null;

    debugPrint('Nominatim address map: $addrMap');

    // Komponen alamat OSM untuk Indonesia
    // Urutan: jalan → kelurahan → kecamatan → kota/kab → provinsi
    final road          = _pick(addrMap, ['road', 'pedestrian', 'footway', 'path', 'cycleway']);
    final neighbourhood = _pick(addrMap, ['neighbourhood', 'hamlet', 'quarter']);
    final village       = _pick(addrMap, ['village', 'suburb', 'residential', 'allotments']);
    final subdistrict   = _pick(addrMap, ['city_district', 'district', 'borough', 'subdistrict']);
    final city          = _pick(addrMap, ['city', 'town', 'municipality', 'county', 'region']);
    final state         = _pick(addrMap, ['state', 'province']);

    // Susun bagian-bagian alamat yang tidak kosong
    final parts = <String>[];
    if (road != null && road.isNotEmpty) parts.add(road);
    if (neighbourhood != null && neighbourhood.isNotEmpty && neighbourhood != road) {
      parts.add(neighbourhood);
    }
    if (village != null && village.isNotEmpty && village != neighbourhood) {
      parts.add(village);
    }
    if (subdistrict != null && subdistrict.isNotEmpty && subdistrict != village) {
      parts.add(subdistrict);
    }
    if (city != null && city.isNotEmpty && city != subdistrict) {
      parts.add(city);
    }
    if (state != null && state.isNotEmpty && state != city) {
      parts.add(state);
    }

    // Nama kota/daerah singkat sebagai judul
    final cityName = city ?? subdistrict ?? village ?? neighbourhood ?? state ?? 'Lokasi Dipilih';

    // Jika parts kosong, gunakan display_name dari Nominatim
    String fullAddress;
    if (parts.isNotEmpty) {
      fullAddress = parts.join(', ');
    } else {
      final displayName = data['display_name'] as String? ?? '';
      // Potong agar tidak terlalu panjang
      fullAddress = displayName.isNotEmpty
          ? (displayName.length > 100
              ? displayName.substring(0, 100).trim()
              : displayName)
          : 'Alamat tidak ditemukan';
    }

    return AddressData(
      fullAddress: fullAddress,
      cityName: cityName,
      street: road,
      subLocality: neighbourhood ?? village,
      locality: city,
      administrativeArea: state,
    );
  }

  /// Fallback: platform geocoder bawaan (geocoding package).
  Future<AddressData?> _platformReverse(
      double latitude, double longitude) async {
    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) return null;

    final p = placemarks.first;
    final parts = <String>[];

    if (p.street?.isNotEmpty == true) parts.add(p.street!);
    if (p.subLocality?.isNotEmpty == true) parts.add(p.subLocality!);
    if (p.locality?.isNotEmpty == true) parts.add(p.locality!);
    if (p.subAdministrativeArea?.isNotEmpty == true) {
      parts.add(p.subAdministrativeArea!);
    }
    if (p.administrativeArea?.isNotEmpty == true) {
      parts.add(p.administrativeArea!);
    }

    return AddressData(
      fullAddress:
          parts.isNotEmpty ? parts.join(', ') : 'Alamat tidak ditemukan',
      cityName: p.subAdministrativeArea ??
          p.locality ??
          p.administrativeArea ??
          'Lokasi Dipilih',
      street: p.street,
      subLocality: p.subLocality,
      locality: p.locality,
      administrativeArea: p.administrativeArea,
    );
  }

  // ── Search Address ──────────────────────────────────────────────────────────

  /// Mencari lokasi berdasarkan query teks.
  /// Menggunakan Nominatim OSM search API, dengan fallback ke geocoding package.
  Future<List<SearchLocationResult>> searchAddress(String query) async {
    // 1. Nominatim search
    try {
      final results = await _nominatimSearch(query);
      if (results.isNotEmpty) {
        debugPrint('searchAddress[Nominatim]: ${results.length} hasil');
        return results;
      }
    } catch (e) {
      debugPrint('searchAddress Nominatim error: $e');
    }

    // 2. Platform geocoder fallback
    try {
      final locations = await locationFromAddress(query);
      final results = <SearchLocationResult>[];
      for (final loc in locations.take(5)) {
        final address = await reverseGeocode(loc.latitude, loc.longitude);
        results.add(SearchLocationResult(
          latitude: loc.latitude,
          longitude: loc.longitude,
          address: address?.fullAddress ??
              '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
        ));
      }
      debugPrint('searchAddress[Platform]: ${results.length} hasil');
      return results;
    } catch (e) {
      debugPrint('searchAddress Platform error: $e');
      return [];
    }
  }

  /// Nominatim OSM search API.
  Future<List<SearchLocationResult>> _nominatimSearch(String query) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'format': 'jsonv2',
        'q': query,
        'addressdetails': '1',
        'limit': '7',
        'accept-language': 'id',
        'countrycodes': 'id',   // Prioritaskan hasil Indonesia
      },
    );

    debugPrint('Nominatim search URL: $uri');

    final response = await http
        .get(uri, headers: _nominatimHeaders)
        .timeout(const Duration(seconds: 10));

    debugPrint('Nominatim search status: ${response.statusCode}');

    if (response.statusCode != 200) return [];

    final body = utf8.decode(response.bodyBytes);
    final list = jsonDecode(body);
    if (list is! List || list.isEmpty) return [];

    final results = <SearchLocationResult>[];
    for (final item in list.take(7)) {
      if (item is! Map<String, dynamic>) continue;
      final lat = double.tryParse(item['lat']?.toString() ?? '');
      final lon = double.tryParse(item['lon']?.toString() ?? '');
      if (lat == null || lon == null) continue;

      // Gunakan display_name sebagai label pencarian (lebih detail)
      final displayName = item['display_name'] as String? ?? '';
      results.add(SearchLocationResult(
        latitude: lat,
        longitude: lon,
        address: displayName.isNotEmpty ? displayName : '$lat, $lon',
      ));
    }
    return results;
  }

  // ── Dispose ─────────────────────────────────────────────────────────────────

  void dispose() {
    stopTracking();
    _locationController.close();
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Ambil nilai pertama yang tidak null/kosong dari daftar kunci di map.
String? _pick(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final val = map[key];
    if (val is String && val.isNotEmpty) return val;
  }
  return null;
}
