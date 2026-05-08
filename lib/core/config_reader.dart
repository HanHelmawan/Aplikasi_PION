import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ConfigReader {
  static Map<String, dynamic>? _config;

  static Future<void> initialize() async {
    try {
      final configString = await rootBundle.loadString('mcp.json');
      _config = json.decode(configString) as Map<String, dynamic>;
      debugPrint('✅ Konfigurasi mcp.json berhasil dimuat.');
    } catch (e) {
      debugPrint('❌ Gagal memuat mcp.json: $e');
      _config = {};
    }
  }

  static String? getStitchServerUrl() {
    try {
      return _config?['mcpServers']?['stitch']?['serverUrl'];
    } catch (e) {
      return null;
    }
  }

  static String? getStitchApiKey() {
    try {
      return _config?['mcpServers']?['stitch']?['headers']?['X-Goog-Api-Key'];
    } catch (e) {
      return null;
    }
  }
}
