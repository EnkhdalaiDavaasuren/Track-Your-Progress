import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/ui/screens/4_settings/sub_page/change_profile_page.dart';
import 'package:my_app/ui/screens/4_settings/sub_page/notification_prefs_page.dart';
import 'package:my_app/ui/screens/4_settings/sub_page/security_page.dart';
import 'package:provider/provider.dart';
import 'package:app_settings/app_settings.dart';
import 'dart:io'; // CRITICAL: Needed for File()
import '../../../services/track_manager.dart';
import '../../../services/theme_manager.dart';
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = themeManager.isDarkMode;
    final borderColor = isDark ? Colors.white24 : Colors.black;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          final userName = user?.displayName ?? user?.email?.split('@')[0] ?? "User";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CLICKABLE PROFILE CARD ---
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ChangeProfilePage()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2),
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3EDF7),
                    ),
                    child: Row(
                      children: [
                        // --- UPDATED DYNAMIC ICON LOGIC ---
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          // LOGIC: Check if path exists and is a real file on this phone
                          backgroundImage: (user?.photoURL != null && File(user!.photoURL!).existsSync())
                              ? FileImage(File(user.photoURL!)) 
                              : null,
                          child: (user?.photoURL == null || !File(user!.photoURL!).existsSync())
                            ? Icon(Icons.person, color: isDark ? Colors.black : Colors.white, size: 35)
                            : null,
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
                        const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                const Text("Preferences", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(border: Border.all(color: borderColor, width: 2)),
                  child: Column(
                    children: [
                      _settingRow(context, "Change Profile", Icons.person_outline, () {
                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ChangeProfilePage()));
                      }),
                      _settingRow(context, "Security", Icons.lock_outline, () {
                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => const SecurityPage()));
                      }),
                      _settingRowWithSwitch(
                        context,
                        "Dark Mode",
                        Icons.dark_mode_outlined,
                        isDark,
                        (val) => themeManager.toggleTheme(val),
                      ),
                      _settingRow(context, "Notification", Icons.notifications_none_outlined, () {
                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => const NotificationPrefsPage()));
                      }),
                      _settingRow(context, "System Settings", Icons.tune_outlined, () {
                        AppSettings.openAppSettings(type: AppSettingsType.notification);
                      }, isLast: true),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

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
          );
        }
      ),
    );
  }

  Widget _settingRow(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isLast = false}) {
    final borderColor = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: borderColor.withValues(alpha: 0.1)))),
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

  Widget _settingRowWithSwitch(BuildContext context, String title, IconData icon, bool value, Function(bool) onChanged) {
    final borderColor = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor.withValues(alpha: 0.1)))),
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
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Log out?"),
        content: const Text("Are you sure you want to log out?"),
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