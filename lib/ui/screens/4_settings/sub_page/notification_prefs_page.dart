import 'package:flutter/material.dart';

class NotificationPrefsPage extends StatefulWidget {
  const NotificationPrefsPage({super.key});

  @override
  State<NotificationPrefsPage> createState() => _NotificationPrefsPageState();
}

class _NotificationPrefsPageState extends State<NotificationPrefsPage> {
  bool shake = true;
  bool sound = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Settings")),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Vibrate (Shake)"),
            subtitle: const Text("Vibrate phone on reminder"),
            value: shake,
            onChanged: (v) => setState(() => shake = v),
          ),
          SwitchListTile(
            title: const Text("Notification Sound"),
            subtitle: const Text("Use phone default ringer"),
            value: sound,
            onChanged: (v) => setState(() => sound = v),
          ),
        ],
      ),
    );
  }
}