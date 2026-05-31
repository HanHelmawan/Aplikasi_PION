import 'package:flutter/foundation.dart';

/// Konfigurasi runtime aplikasi Pion.
///
/// ✅ AUDIT FIX: mcp.json dihapus dari Flutter assets karena berisi API key
/// yang bisa di-extract dari APK menggunakan reverse engineering (apktool, dll).
///
/// Untuk production, gunakan --dart-define saat build:
///   flutter build apk \
///     --dart-define=STITCH_SERVER_URL=https://... \
///     --dart-define=STITCH_API_KEY=your_key_here
///
/// Nilai akan dikompilasi ke dalam binary (tidak bisa di-extract seperti file JSON).
class ConfigReader {
  // Nilai dikompilasi dari --dart-define flags saat build
  static const String _stitchServerUrl =
      String.fromEnvironment('STITCH_SERVER_URL', defaultValue: '');
  static const String _stitchApiKey =
      String.fromEnvironment('STITCH_API_KEY', defaultValue: '');

  /// Inisialisasi (tetap tersedia untuk kompatibilitas, tidak perlu async lagi)
  static Future<void> initialize() async {
    if (_stitchServerUrl.isNotEmpty) {
      debugPrint('✅ ConfigReader: Konfigurasi berhasil dimuat dari dart-define.');
    } else {
      debugPrint('⚠️  ConfigReader: STITCH_SERVER_URL tidak dikonfigurasi. '
          'Gunakan --dart-define=STITCH_SERVER_URL=... saat build.');
    }
  }

  /// URL Stitch server, atau null jika tidak dikonfigurasi.
  static String? getStitchServerUrl() =>
      _stitchServerUrl.isNotEmpty ? _stitchServerUrl : null;

  /// API Key Stitch, atau null jika tidak dikonfigurasi.
  static String? getStitchApiKey() =>
      _stitchApiKey.isNotEmpty ? _stitchApiKey : null;
}
