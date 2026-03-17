import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import this for logout logic

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user email/name from Firebase
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.account_circle_outlined, size: 50),
              const SizedBox(width: 10),
              // Display the actual email or "User"
              Text(user?.email ?? "User", style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Column(
              children: [
                _settingRow(context, "Change Profile"),
                _settingRow(context, "Security"),
                _settingRow(context, "Privacy"),
                _settingRow(context, "Notification"),
                _settingRow(context, "Settings"),
                // Logout is special
                _settingRow(context, "Log out", isLast: true, isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRow(BuildContext context, String title, {bool isLast = false, bool isLogout = false}) {
    return GestureDetector(
      onTap: () async {
        if (isLogout) {
          // LOGOUT LOGIC
          await FirebaseAuth.instance.signOut();
        } else {
          // Placeholder for other settings
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title clicked")),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white, // Ensures the whole row is tappable
          border: isLast ? null : const Border(bottom: BorderSide(color: Colors.black)),
        ),
        child: Text(
          title, 
          textAlign: isLast ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.black, // Make logout red for safety
            fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}