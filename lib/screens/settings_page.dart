import 'package:flutter/material.dart';

// This is the "Public" part of the widget
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPage createState() => _SettingsPage(); // Fixed: must be 'createState'
}

// This is the "Private" part where the logic lives
class _SettingsPage extends State<SettingsPage> { // Fixed: must extend State<HomePage>
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Center(
        child: Text("User Settings..."),
      ),
    );
  }
}