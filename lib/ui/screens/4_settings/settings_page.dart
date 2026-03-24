import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../services/track_manager.dart';
import '../../../services/theme_manager.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = themeManager.isDarkMode;
    final userName = user?.email?.split('@')[0] ?? "User";

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROFILE HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2),
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3EDF7),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    child: Icon(Icons.person, color: isDark ? Colors.black : Colors.white, size: 35),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName.toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(user?.email ?? "", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text("Preferences", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 10),

            // SETTINGS GROUP
            Container(
              decoration: BoxDecoration(border: Border.all(color: isDark ? Colors.white24 : Colors.black, width: 2)),
              child: Column(
                children: [
                  _settingRow(context, "Change Profile", Icons.person_outline),
                  _settingRow(context, "Security", Icons.lock_outline),
                  
                  // DARK MODE TOGGLE
                  _settingRowWithSwitch(
                    "Dark Mode",
                    Icons.dark_mode_outlined,
                    isDark,
                    (val) => themeManager.toggleTheme(val),
                  ),
                  
                  _settingRow(context, "Notification", Icons.notifications_none_outlined),
                  _settingRow(context, "System Settings", Icons.tune_outlined, isLast: true),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // LOGOUT
            InkWell(
              onTap: () => _showLogoutConfirm(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 2)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text("LOG OUT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingRow(BuildContext context, String title, IconData icon, {bool isLast = false}) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$title coming soon!"))),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _settingRowWithSwitch(String title, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Switch.adaptive(value: value, activeColor: const Color(0xFF6750A4), onChanged: onChanged),
        ],
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Log out?"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Provider.of<TrackManager>(context, listen: false).clearData();
              FirebaseAuth.instance.signOut();
              Navigator.pop(ctx);
            },
            child: const Text("Log out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}