import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Services & UI
import 'services/track_manager.dart';
import 'ui/screens/1_home/home_page.dart';
import 'ui/screens/2_progress/progress_page.dart';
import 'ui/screens/3_done/done_page.dart';
import 'ui/screens/4_settings/settings_page.dart';
import 'ui/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final manager = TrackManager();
  await manager.init(); // Load Database

  runApp(
    ChangeNotifierProvider(
      create: (context) => manager,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track Your Progress',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        // Using a clean font for that modern "Good" look
        fontFamily: 'Roboto', 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black, 
            fontSize: 22, 
            fontWeight: FontWeight.w400
          ),
        ),
      ),
      // Auth Flow: Automatic switch between Login and MainScreen
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const LoginPage(); 
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final TextEditingController _nameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // This runs as soon as the MainScreen is created.
    // We use Future.microtask to ensure the context is ready before calling the manager.
    Future.microtask(() {
      context.read<TrackManager>().loadFromFirebase();
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const ProgressPage(),
    const Center(child: Text("Add Logic")), // Placeholder for Index 2
    const DonePage(),
    const SettingsPage(),
  ];

  // Replicating the "Good" Screenshot Dialog (Image 2)
  void _showAddTrackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF3EDF7), // Light purple-grey from screenshot
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          "New Track", 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                // The simple underline style from Image 2
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.only(right: 20, bottom: 10),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              Navigator.pop(context);
            }, 
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF6750A4)))
          ),
          TextButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                context.read<TrackManager>().addTrack(_nameController.text);
                _nameController.clear();
                Navigator.pop(context);
                setState(() => _selectedIndex = 1); // Move to Progress Page
              }
            },
            child: const Text("Add", style: TextStyle(color: Color(0xFF6750A4), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      
      // Fixed Navigation Bar to match Image 5 exactly
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 1))
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF6750A4), // The deep purple/blue from screenshot
          unselectedItemColor: Colors.black54,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: (index) {
            if (index == 2) {
              _showAddTrackDialog();
            } else {
              setState(() => _selectedIndex = index);
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Progress'),
            // The solid black Plus icon from your screenshot
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 45, color: Colors.black), 
              label: ''
            ),
            BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Done'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}