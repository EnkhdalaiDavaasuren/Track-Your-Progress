import 'package:flutter/material.dart';

// This is the "Public" part of the widget
class DonePage extends StatefulWidget {
  @override
  _DonePage createState() => _DonePage(); 
}

class _DonePage extends State<DonePage> { 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accomplishments"),
        centerTitle: true,
      ),
      body: Center(
        child: Text("Nothing has done."),
      ),
    );
  }
}