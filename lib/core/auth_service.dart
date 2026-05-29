import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static const String _locationSetupDoneKey = 'pion_location_setup_done';
  static const String _savedLocationKey = 'pion_saved_location';

  // ── Register ──────────────────────────────────────────────────────────────

  /// Creates a new account with email/password and saves user data to Firestore.
  /// Returns null on success, or an error message string on failure.
  static Future<String?> register(
      String name, String email, String password, bool isWorkerMode) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name in Firebase Auth
      await credential.user?.updateDisplayName(name);

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'isWorkerMode': isWorkerMode,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email sudah terdaftar. Silakan gunakan email lain.';
        case 'weak-password':
          return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        default:
          return 'Gagal mendaftar: ${e.message}';
      }
    } catch (e) {
      return 'Terjadi kesalahan. Coba lagi.';
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  /// Signs in with email/password and returns the user data map, or null on failure.
  /// Also returns an error message via [onError] callback.
  static Future<Map<String, dynamic>?> login(
      String email, String password, {Function(String)? onError}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return {
          'uid': uid,
          'name': doc['name'] ?? credential.user?.displayName ?? 'Pengguna',
          'email': email,
          'isWorkerMode': doc['isWorkerMode'] ?? false,
        };
      } else {
        // User exists in Auth but not in Firestore (edge case)
        return {
          'uid': uid,
          'name': credential.user?.displayName ?? 'Pengguna',
          'email': email,
          'isWorkerMode': false,
        };
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Email atau password salah.';
          break;
        case 'user-disabled':
          message = 'Akun ini telah dinonaktifkan.';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan. Coba lagi nanti.';
          break;
        default:
          message = 'Gagal masuk: ${e.message}';
      }
      onError?.call(message);
      return null;
    } catch (e) {
      onError?.call('Terjadi kesalahan. Coba lagi.');
      return null;
    }
  }

  // ── Get Current User ──────────────────────────────────────────────────────

  /// Returns the currently signed-in user data, or null if not logged in.
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return {
          'uid': firebaseUser.uid,
          'name': doc['name'] ?? firebaseUser.displayName ?? 'Pengguna',
          'email': firebaseUser.email ?? '',
          'isWorkerMode': doc['isWorkerMode'] ?? false,
        };
      }
    } catch (_) {}

    return {
      'uid': firebaseUser.uid,
      'name': firebaseUser.displayName ?? 'Pengguna',
      'email': firebaseUser.email ?? '',
      'isWorkerMode': false,
    };
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut(); // also sign out from Google
    // NOTE: We intentionally keep location preferences so users
    // don't have to re-setup location on every login.
  }

  // ── Google Sign-In ─────────────────────────────────────────────

  /// Signs in with a Google account.
  /// Returns the user data map on success, or null if cancelled/failed.
  /// Delivers error messages via the [onError] callback.
  static Future<Map<String, dynamic>?> loginWithGoogle(
      {Function(String)? onError}) async {
    try {
      // Trigger the Google authentication flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled the picker

      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;
      final uid = firebaseUser.uid;

      // Check if this is a new user; create their Firestore doc if so
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(uid).set({
          'name': firebaseUser.displayName ?? googleUser.displayName ?? 'Pengguna',
          'email': firebaseUser.email ?? '',
          'isWorkerMode': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Fetch the latest Firestore data to return
      final freshDoc = await _firestore.collection('users').doc(uid).get();
      return {
        'uid': uid,
        'name': freshDoc.exists
            ? (freshDoc['name'] ?? firebaseUser.displayName ?? 'Pengguna')
            : (firebaseUser.displayName ?? 'Pengguna'),
        'email': firebaseUser.email ?? '',
        'isWorkerMode': freshDoc.exists ? (freshDoc['isWorkerMode'] ?? false) : false,
      };
    } catch (e) {
      onError?.call('Gagal masuk dengan Google. Coba lagi.');
      return null;
    }
  }

  // ── Update Profile ────────────────────────────────────────────────────────

  /// Updates the user's profile data in Firestore (and displayName in Auth).
  /// Returns null on success, or an error message string on failure.
  static Future<String?> updateProfile({
    required String name,
    required String phone,
    required String bio,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return 'Anda belum masuk.';

    try {
      await firebaseUser.updateDisplayName(name);
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'name': name,
        'phone': phone,
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null; // success
    } catch (e) {
      return 'Gagal memperbarui profil. Coba lagi.';
    }
  }

  // ── Submit Rating ─────────────────────────────────────────────────────────

  /// Submits a worker rating to Firestore.
  /// Returns null on success, or an error message string on failure.
  static Future<String?> submitRating({
    required String taskId,
    required String workerName,
    required int rating,
    required List<String> tags,
    required String review,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return 'Anda belum masuk.';

    try {
      await _firestore.collection('ratings').add({
        'taskId': taskId,
        'userId': firebaseUser.uid,
        'workerName': workerName,
        'rating': rating,
        'tags': tags,
        'review': review,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null; // success
    } catch (e) {
      return 'Gagal mengirim ulasan. Coba lagi.';
    }
  }

  // ── Reset Password ────────────────────────────────────────────────────────

  /// Sends a password reset email. Returns null on success, error string on failure.
  static Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        default:
          return 'Gagal mengirim email: ${e.message}';
      }
    }
  }

  // ── Location Setup ────────────────────────────────────────────────────────

  /// Returns true if the user has NOT yet completed the location setup flow.
  static Future<bool> isFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_locationSetupDoneKey) ?? false);
  }

  /// Call this once the user completes (or skips) the location setup screen.
  static Future<void> markLocationSetupDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationSetupDoneKey, true);
  }

  /// Saves the user's chosen city/area name (e.g., "Jakarta Selatan").
  static Future<void> saveLocation(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedLocationKey, cityName);
  }

  /// Returns the previously saved city/area name, or null if not set.
  static Future<String?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedLocationKey);
  }
}
