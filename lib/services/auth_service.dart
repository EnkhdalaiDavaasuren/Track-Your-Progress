import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      // RELEASE FIX: Fallback string if message is null
      return e.message ?? "Login failed. Please check your credentials.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // SIGN UP
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      // RELEASE FIX: Fallback string if message is null
      return e.message ?? "Sign up failed. Please try again.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // PASSWORD RESET
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Could not send reset email.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }


  // --- PROFILE MANAGEMENT ---

  // Update Display Name
  Future<void> updateProfileName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        // CRITICAL: Reload forces the app to "see" the new name without logging out
        await user.reload(); 
      }
    } catch (e) {
      debugPrint("Error updating profile name: $e");
    }
  }

  // Update Profile Image URL
  Future<void> updateProfileImage(String url) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(url);
        // CRITICAL: Reload forces the app to "see" the new icon without logging out
        await user.reload();
      }
    } catch (e) {
      debugPrint("Error updating profile image: $e");
    }
  }


  // --- SECURITY FEATURES ---

  // Verify Email Address
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint("Error sending verification: $e");
    }
  }

  // Change Password while logged in
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      debugPrint("Error updating password: $e");
    }
  }
}