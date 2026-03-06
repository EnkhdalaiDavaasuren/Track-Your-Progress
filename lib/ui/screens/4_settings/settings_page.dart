import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.account_circle_outlined, size: 50),
              const SizedBox(width: 10),
              const Text("Username", style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Column(
              children: [
                _settingRow("Change Profile"),
                _settingRow("Security"),
                _settingRow("Privacy"),
                _settingRow("Notification"),
                _settingRow("Settings"),
                _settingRow("Log out", isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRow(String title, {bool isLast = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Colors.black)),
      ),
      child: Text(title, textAlign: isLast ? TextAlign.center : TextAlign.left),
    );
  }
}