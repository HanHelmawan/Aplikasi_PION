import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersKey = 'pion_users';
  static const String _currentUserKey = 'pion_current_user';

  // ── Demo accounts for Play Store review / closed testing ─────────────────
  // These credentials are hardcoded and always work, regardless of local storage.
  static const List<Map<String, dynamic>> _demoAccounts = [
    {
      'name': 'Demo User',
      'email': 'tester@pion.com',
      'password': 'pion2024',
      'isWorkerMode': false,
    },
    {
      'name': 'Demo Worker',
      'email': 'worker@pion.com',
      'password': 'pion2024',
      'isWorkerMode': true,
    },
  ];

  // Format: [{email, password, name, isWorkerMode}]
  static Future<bool> register(String name, String email, String password, bool isWorkerMode) async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersString);

    // Check if email already exists (including demo accounts)
    if (_demoAccounts.any((u) => u['email'] == email)) {
      return false; // Demo account, cannot overwrite
    }
    // Check if email already exists
    if (users.any((u) => u['email'] == email)) {
      return false; // Already exists
    }

    final newUser = {
      'name': name,
      'email': email,
      'password': password, // In a real app, hash this!
      'isWorkerMode': isWorkerMode,
    };

    users.add(newUser);
    await prefs.setString(_usersKey, jsonEncode(users));
    return true;
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    // Check demo accounts first (always available for reviewers)
    for (final demo in _demoAccounts) {
      if (demo['email'] == email && demo['password'] == password) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_currentUserKey, jsonEncode(demo));
        return demo;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersString);

    for (var u in users) {
      if (u['email'] == email && u['password'] == password) {
        await prefs.setString(_currentUserKey, jsonEncode(u));
        return u as Map<String, dynamic>;
      }
    }
    return null; // Login failed
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_currentUserKey);
    if (userString != null) {
      return jsonDecode(userString) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}
