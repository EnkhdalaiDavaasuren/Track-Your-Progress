import 'package:flutter/material.dart';

void main() {
  // 1. The Entry Point: Starts the whole app.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. The Foundation: Sets up Material Design.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainScreen(), // Our starting screen widget
    );
  }
}

// --- THE MAIN SCREEN WIDGET ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 3. STATE: A single integer to remember which button is pressed (0, 1, 2, 3, 4)
  int _selectedIndex = 0; 

  // A list of simple widgets to show when a button is pressed.
  final List<Widget> _pages = [
    const Center(child: Text("Home Screen Content", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Progress Screen Content", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Add Screen Content", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Done Screen Content", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Settings Screen Content", style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    // 4. THE SCAFFOLD: Sets up the page structure (App Bar, Body, Bottom Bar)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minimal Nav App'),
      ),
      // 5. THE BODY: Shows the correct widget based on the state (_selectedIndex)
      body: _pages[_selectedIndex], 
      
      // 6. THE BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Keep labels visible for all 5 buttons
        currentIndex: _selectedIndex, // Show the correct button as highlighted
        
        // 7. THE ACTION: When a button is pressed, update the state
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Change the state variable
          });
        },
        
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: '+'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Done'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}