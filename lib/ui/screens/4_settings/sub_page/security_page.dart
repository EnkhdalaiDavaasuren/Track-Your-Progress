import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _isReloading = false;

  // --- THE FIX: RELOAD USER DATA ---
  Future<void> _checkVerificationStatus() async {
    setState(() => _isReloading = true);
    
    final user = FirebaseAuth.instance.currentUser;
    // This forces the app to ask Firebase: "Is this guy actually verified now?"
    await user?.reload(); 
    
    if (mounted) {
      setState(() => _isReloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account status updated.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Security"),
        actions: [
          // Refresh button so user can confirm they verified their email
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
                      onPressed: () async {
                        await user?.sendEmailVerification();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Verification email sent! Please check your inbox.")),
                        );
                      },
                      child: const Text("Verify Now"),
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
              onTap: () {
                if (user?.email != null) {
                  FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password reset link sent to your email.")),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 40),
          const Text(
            "Note: After clicking the link in your email, come back here and tap the refresh icon at the top to update your status.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          )
        ],
      ),
    );
  }
}