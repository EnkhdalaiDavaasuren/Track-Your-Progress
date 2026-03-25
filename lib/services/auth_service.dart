import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- STREAMS ---

  // 1. Tells MainScreen if someone is logged in
  Stream<User?> get userStream => _auth.authStateChanges();

  // 2. Tells HomePage if Name/Icon changed (Essential for your fix)
  Stream<User?> get userChanges => _auth.userChanges();


  // --- CORE AUTHENTICATION ---

  // LOGIN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // SIGN UP
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // PASSWORD RESET
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }


  // --- PROFILE MANAGEMENT (The "Stuff" you requested) ---

  // Update Display Name
  Future<void> updateProfileName(String newName) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(newName);
      // CRITICAL: Reload forces the app to "see" the new name without logging out
      await user.reload(); 
    }
  }

  // Update Profile Image URL
  Future<void> updateProfileImage(String url) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePhotoURL(url);
      // CRITICAL: Reload forces the app to "see" the new icon without logging out
      await user.reload();
    }
  }


  // --- SECURITY FEATURES ---

  // Verify Email Address
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Change Password while logged in
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }
}