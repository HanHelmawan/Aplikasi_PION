import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Status GPS dan permission.
enum LocationStatus {
  /// Belum ditentukan.
  unknown,

  /// Sedang menunggu permission atau lokasi.
  loading,

  /// Lokasi berhasil didapatkan.
  active,

  /// Layanan lokasi (GPS) dimatikan oleh user.
  serviceDisabled,

  /// Permission lokasi ditolak oleh user.
  permissionDenied,

  /// Permission lokasi ditolak secara permanen.
  permissionDeniedForever,

  /// Timeout saat mendapatkan lokasi.
  timeout,

  /// Error lainnya.
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
      'LocationData(lat: ${latitude.toStringAsFixed(6)}, lng: ${longitude.toStringAsFixed(6)}, acc: ${accuracy.toStringAsFixed(1)}m)';
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

/// Service untuk mengelola lokasi GPS perangkat.
///
/// Menyediakan:
/// - Cek & request permission
/// - Mendapatkan lokasi saat ini
/// - Live tracking via stream
/// - Reverse geocoding
///
/// Seluruhnya menggunakan GPS asli perangkat, tanpa mock/hardcoded data.
class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final StreamController<LocationData> _locationController =
      StreamController<LocationData>.broadcast();

  /// Stream lokasi yang terus diperbarui secara real-time.
  Stream<LocationData> get locationStream => _locationController.stream;

  /// Status terakhir dari layanan lokasi.
  LocationStatus _status = LocationStatus.unknown;
  LocationStatus get status => _status;

  /// Pesan error terakhir (jika ada).
  String? _lastError;
  String? get lastError => _lastError;

  // ── Permission & Service Check ──────────────────────────────────────────

  /// Memeriksa apakah layanan lokasi aktif dan permission diberikan.
  /// Mengembalikan [LocationStatus] yang sesuai.
  Future<LocationStatus> checkAndRequestPermission() async {
    try {
      // 1. Cek apakah Location Service (GPS) aktif
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _status = LocationStatus.serviceDisabled;
        _lastError = 'Layanan lokasi tidak aktif. Silakan aktifkan GPS Anda.';
        return _status;
      }

      // 2. Cek permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Minta permission kepada user
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _status = LocationStatus.permissionDenied;
          _lastError = 'Izin lokasi ditolak. Aplikasi membutuhkan akses lokasi untuk menampilkan peta.';
          return _status;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _status = LocationStatus.permissionDeniedForever;
        _lastError = 'Izin lokasi ditolak secara permanen. Silakan ubah di Pengaturan perangkat Anda.';
        return _status;
      }

      // Permission diberikan (whileInUse atau always)
      _status = LocationStatus.active;
      _lastError = null;
      return _status;
    } catch (e) {
      _status = LocationStatus.error;
      _lastError = 'Gagal memeriksa izin lokasi: $e';
      debugPrint('LocationService.checkAndRequestPermission error: $e');
      return _status;
    }
  }

  // ── Get Current Position ────────────────────────────────────────────────

  /// Mendapatkan posisi GPS saat ini dengan akurasi tinggi.
  /// Mengembalikan null jika gagal (cek [lastError] untuk pesan error).
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

      final data = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );

      _status = LocationStatus.active;
      _lastError = null;
      return data;
    } on TimeoutException {
      _status = LocationStatus.timeout;
      _lastError = 'Timeout mendapatkan lokasi. Pastikan GPS aktif dan Anda berada di area terbuka.';
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
      debugPrint('LocationService.getCurrentPosition error: $e');
      return null;
    }
  }

  // ── Live Tracking Stream ────────────────────────────────────────────────

  /// Memulai live tracking lokasi.
  /// Lokasi akan diperbarui secara real-time melalui [locationStream].
  Future<void> startTracking({
    int distanceFilter = 5,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    // Pastikan permission sudah diberikan
    final permStatus = await checkAndRequestPermission();
    if (permStatus != LocationStatus.active) return;

    // Batalkan subscription sebelumnya jika ada
    await stopTracking();

    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        final data = LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          timestamp: position.timestamp,
        );
        _locationController.add(data);
        _status = LocationStatus.active;
      },
      onError: (error) {
        _status = LocationStatus.error;
        _lastError = 'Stream error: $error';
        debugPrint('LocationService.startTracking stream error: $error');
      },
    );
  }

  /// Menghentikan live tracking dan membersihkan stream.
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  // ── Reverse Geocoding ───────────────────────────────────────────────────

  /// Mengubah koordinat menjadi alamat (menggunakan platform geocoder, bukan Google API).
  /// Mengembalikan null jika gagal.
  Future<AddressData?> reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;

      final p = placemarks.first;
      final parts = <String>[];

      if (p.street != null && p.street!.isNotEmpty) parts.add(p.street!);
      if (p.subLocality != null && p.subLocality!.isNotEmpty) {
        parts.add(p.subLocality!);
      }
      if (p.locality != null && p.locality!.isNotEmpty) {
        parts.add(p.locality!);
      }
      if (p.subAdministrativeArea != null && p.subAdministrativeArea!.isNotEmpty) {
        parts.add(p.subAdministrativeArea!);
      }
      if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
        parts.add(p.administrativeArea!);
      }

      return AddressData(
        fullAddress: parts.isNotEmpty ? parts.join(', ') : 'Alamat tidak ditemukan',
        cityName: p.subAdministrativeArea ??
            p.locality ??
            p.administrativeArea ??
            'Lokasi Dipilih',
        street: p.street,
        subLocality: p.subLocality,
        locality: p.locality,
        administrativeArea: p.administrativeArea,
      );
    } catch (e) {
      debugPrint('LocationService.reverseGeocode error: $e');
      return null;
    }
  }

  /// Mencari lokasi berdasarkan query alamat.
  /// Mengembalikan list lokasi yang cocok.
  Future<List<SearchLocationResult>> searchAddress(String query) async {
    try {
      final locations = await locationFromAddress(query);
      final results = <SearchLocationResult>[];

      for (final loc in locations.take(5)) {
        final address = await reverseGeocode(loc.latitude, loc.longitude);
        results.add(SearchLocationResult(
          latitude: loc.latitude,
          longitude: loc.longitude,
          address: address?.fullAddress ?? '${loc.latitude}, ${loc.longitude}',
        ));
      }
      return results;
    } catch (e) {
      debugPrint('LocationService.searchAddress error: $e');
      return [];
    }
  }

  // ── Dispose ─────────────────────────────────────────────────────────────

  /// Membersihkan semua resource. Panggil di dispose() widget.
  void dispose() {
    stopTracking();
    _locationController.close();
  }
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
