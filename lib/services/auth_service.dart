import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to tell main.dart if user is logged in
  Stream<User?> get userStream => _auth.authStateChanges();

  // LOGIN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message to show in UI
    }
  }
  
  // Inside your AuthService class
  Future<String?> resetPassword(String email) async {
    try {
        await _auth.sendPasswordResetEmail(email: email);
        print("Reset email sent to $email successfully!"); // Check if this prints in VS Code
        return null; 
    } on FirebaseAuthException catch (e) {
        print("Firebase Auth Error Code: ${e.code}"); // This tells us the REAL reason
       return e.message;
    } catch (e) {
       return "An error occurred.";
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

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }
}