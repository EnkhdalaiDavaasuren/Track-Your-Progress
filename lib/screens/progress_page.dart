import 'package:flutter/material.dart';

// This is the "Public" part of the widget
class ProgressPage extends StatefulWidget {
  @override
  _ProgressPage createState() => _ProgressPage(); // Fixed: must be 'createState'
}

// This is the "Private" part where the logic lives
class _ProgressPage extends State<ProgressPage> { // Fixed: must extend State<HomePage>
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Progress")),
      body: Center(
        child: Text("No Tracks"),
      ),
    );
  }
}