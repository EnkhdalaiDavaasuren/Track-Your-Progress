import 'package:flutter/material.dart';

// This is the "Public" part of the widget
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState(); // Fixed: must be 'createState'
}

// This is the "Private" part where the logic lives
class _HomePageState extends State<HomePage> {
  
  // Fixed: must extend State<HomePage>
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Text("No Recent Tracks"),
      ),
    );
  }
}