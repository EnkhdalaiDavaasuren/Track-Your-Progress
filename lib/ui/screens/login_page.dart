import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/track_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  
  bool isLogin = true; 
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false; // RELEASE FIX: Prevent multiple taps and show progress

  // --- LOGIC: Strong Password Validation ---
  bool _isPasswordStrong(String password) {
    // 8+ characters, at least one digit, one special character
    final regex = RegExp(r'^(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    return regex.hasMatch(password);
  }

  bool _isValid() {
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();
    final confirm = _confirmPassController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showError("Please enter a valid email address.");
      return false;
    }

    if (!isLogin) {
      if (!_isPasswordStrong(pass)) {
        _showError("Password must be 8+ characters, include a number and a special character (!@#\$&*~).");
        return false;
      }
      if (pass != confirm) {
        _showError("Passwords do not match!");
        return false;
      }
    } else {
      if (pass.isEmpty) {
        _showError("Please enter your password.");
        return false;
      }
    }
    
    return true;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleAuth() async {
    if (!_isValid() || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final auth = AuthService();
      String? error;

      if (isLogin) {
        error = await auth.login(_emailController.text.trim(), _passController.text.trim());
      } else {
        error = await auth.signUp(_emailController.text.trim(), _passController.text.trim());
      }

      if (!mounted) return;

      if (error == null) {
        // Success: Load data from Firebase before entering app
        await context.read<TrackManager>().loadFromFirebase();
      } else {
        _showError(error);
      }
    } catch (e) {
      _showError("An unexpected error occurred. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).colorScheme.onSurface;
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: AutofillGroup( // RELEASE FIX: Allows OS to suggest saved emails/passwords
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.track_changes_outlined, size: 80, color: primaryColor),
                const SizedBox(height: 20),
                Text(
                  isLogin ? "LOG IN" : "SIGN UP",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3),
                ),
                const SizedBox(height: 40),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.mail_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: borderColor)),
                  ),
                ),
                const SizedBox(height: 15),

                // Password
                TextField(
                  controller: _passController,
                  obscureText: _obscurePass,
                  autofillHints: const [AutofillHints.password],
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: borderColor)),
                  ),
                ),
                const SizedBox(height: 15),

                // Repeat Password (Sign Up Only)
                if (!isLogin) ...[
                  TextField(
                    controller: _confirmPassController,
                    obscureText: _obscureConfirm,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: "Repeat Password",
                      prefixIcon: const Icon(Icons.lock_reset),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: borderColor)),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: borderColor,
                      foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: _isLoading ? null : _handleAuth,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isLogin ? "ENTER" : "CREATE ACCOUNT", 
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)
                        ),
                  ),
                ),

                const SizedBox(height: 10),
                TextButton(
                  onPressed: _isLoading ? null : () => setState(() {
                    isLogin = !isLogin;
                    _emailController.clear();
                    _passController.clear();
                    _confirmPassController.clear();
                  }),
                  child: Text(
                    isLogin ? "Need an account? Sign Up" : "Have an account? Log In",
                    style: TextStyle(color: primaryColor),
                  ),
                ),

                if (isLogin)
                  TextButton(
                    onPressed: _isLoading ? null : _showForgotPasswordDialog,
                    child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final resetController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("A reset link will be sent to your email."),
            const SizedBox(height: 15),
            TextField(
              controller: resetController,
              decoration: const InputDecoration(
                hintText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async {
              final auth = AuthService();
              final error = await auth.resetPassword(resetController.text.trim());
              if (mounted) {
                Navigator.pop(context);
                _showError(error ?? "Success! Check your email inbox.");
              }
            },
            child: const Text("SEND", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}