import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _isReloading = false;
  bool _isProcessing = false; // RELEASE FIX: Prevent multiple rapid API calls

  // --- THE FIX: RELOAD USER DATA ---
  Future<void> _checkVerificationStatus() async {
    if (_isReloading) return;
    setState(() => _isReloading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      // This forces the app to ask Firebase: "Is this guy actually verified now?"
      await user?.reload(); 
      
      if (mounted) {
        setState(() => _isReloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account status updated.")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isReloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating status: $e")),
        );
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification email sent! Please check your inbox.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Failed to send email.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      if (email != null) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password reset link sent to your email.")),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Failed to send reset link.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calling currentUser here ensures we get the latest state after a reload()
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Security"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isReloading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Icon(Icons.refresh),
            onPressed: _checkVerificationStatus,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. EMAIL VERIFICATION
          Container(
            decoration: BoxDecoration(border: Border.all(color: borderColor, width: 2)),
            child: ListTile(
              title: const Text("Email Verification", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                user?.emailVerified == true ? "Status: Verified" : "Status: Not Verified",
                style: TextStyle(color: user?.emailVerified == true ? Colors.green : Colors.orange),
              ),
              trailing: user?.emailVerified == true 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : TextButton(
                      onPressed: _isProcessing ? null : _sendVerificationEmail,
                      child: _isProcessing 
                        ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Verify Now"),
                    ),
            ),
          ),
          
          const SizedBox(height: 20),

          // 2. PASSWORD RESET
          Container(
            decoration: BoxDecoration(border: Border.all(color: borderColor, width: 2)),
            child: ListTile(
              title: const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Request a secure reset link to your email"),
              onTap: _isProcessing ? null : _sendPasswordReset,
              trailing: _isProcessing 
                ? const CircularProgressIndicator(strokeWidth: 2)
                : const Icon(Icons.chevron_right),
            ),
          ),

          const SizedBox(height: 40),
          const Text(
            "Note: After clicking the link in your email, come back here and tap the refresh icon at the top to update your status.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }
}