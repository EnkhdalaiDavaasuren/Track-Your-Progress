import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPrefsPage extends StatefulWidget {
  const NotificationPrefsPage({super.key});

  @override
  State<NotificationPrefsPage> createState() => _NotificationPrefsPageState();
}

class _NotificationPrefsPageState extends State<NotificationPrefsPage> {
  bool shake = true;
  bool sound = true;
  bool _isLoading = true; // RELEASE FIX: Prevent UI flicker during load

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved preferences from disk
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        shake = prefs.getBool('notif_shake') ?? true;
        sound = prefs.getBool('notif_sound') ?? true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading notification prefs: $e");
      setState(() => _isLoading = false);
    }
  }

  // Save specific preference to disk
  Future<void> _saveSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint("Error saving preference $key: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Settings"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                SwitchListTile(
                  title: const Text("Vibrate (Shake)", 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Vibrate phone on reminder"),
                  activeThumbColor: borderColor,
                  value: shake,
                  onChanged: (v) {
                    setState(() => shake = v);
                    _saveSetting('notif_shake', v);
                  },
                ),
                Divider(color: borderColor.withOpacity(0.1)),
                SwitchListTile(
                  title: const Text("Notification Sound", 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Use phone default ringer"),
                  activeThumbColor: borderColor,
                  value: sound,
                  onChanged: (v) {
                    setState(() => sound = v);
                    _saveSetting('notif_sound', v);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Note: System-level notification settings may override these choices.",
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}