import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Public Getters ---
  bool get isLoggedIn => _auth.currentUser != null;
  String get userName => _auth.currentUser?.displayName ?? '';
  String get userEmail => _auth.currentUser?.email ?? '';
  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();


  Future<void> loadUser() async {
    notifyListeners();
  }

  /// ✅ Sign up new user
  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name);

        // Store in Firestore
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "email": email,
          "createdAt": Timestamp.now(),
        });

        debugPrint("✅ Firestore: User stored with UID ${user.uid}");
      }

      notifyListeners();
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Auth error: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("❌ Firestore error: $e");
      rethrow;
    }
  }

  /// ✅ Login existing user
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Login error: ${e.message}");
      rethrow;
    }
  }

  /// ✅ Logout
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }


  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Reset error: ${e.message}");
    }
  }
}
