import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'services/track_manager.dart';
import 'services/theme_manager.dart';
import 'services/notification_service.dart';

import 'ui/screens/1_home/home_page.dart';
import 'ui/screens/2_progress/progress_page.dart';
import 'ui/screens/3_done/done_page.dart';
import 'ui/screens/4_settings/settings_page.dart';
import 'ui/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // 3. Start Notifications
    await NotificationService.init();

    // 4. Load Database
    final trackManager = TrackManager();
    await trackManager.init();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => trackManager),
          ChangeNotifierProvider(create: (_) => ThemeManager()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    // If it crashes, this prints to the logs so you can see it in Google Play Console
    debugPrint("CRITICAL STARTUP ERROR: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track Your Progress',
      
      // --- THEME CONFIGURATION ---
      themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF6750A4), // Purple from your screenshot
          onSurface: Colors.black, // Used for boxy borders
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E), // Dark grey for cards
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFD0BCFF), // Light purple for dark mode
          onSurface: Colors.white, // Used for boxy borders
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121212), foregroundColor: Colors.white),
      ),

      // --- AUTH GATEKEEPER ---
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // If session exists, go to app. If not, go to login.
          if (snapshot.hasData) return const MainScreen();
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
    // Background cloud sync as soon as app opens
    Future.microtask(() => context.read<TrackManager>().loadFromFirebase());
  }

  // --- LOGIC: 10 TRACK LIMIT CHECKS ---
  void _showAddTrackDialog() {
    final manager = context.read<TrackManager>();

    // Check 1: Active tracks limit (Ongoing + Not Set)
    if (manager.ongoingTracks.length >= 10) {
      _showLimitAlert(
        "Active Limit Reached", 
        "You have 10 ongoing tracks. Please complete or delete some first."
      );
      return;
    }

    // Check 2: History storage limit (Total slots)
    if (manager.allTracks.length >= 20) {
      _showLimitAlert(
        "Storage Full", 
        "Please delete completed tracks from the Done page to add more."
      );
      return;
    }

    _showActualInputDialog();
  }

  void _showLimitAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showActualInputDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3EDF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("New Track", style: TextStyle(fontSize: 24)),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "What are you tracking?",
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          ),
        ),
        actions: [
          TextButton(onPressed: () { _nameController.clear(); Navigator.pop(ctx); }, child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                context.read<TrackManager>().addTrack(_nameController.text);
                _nameController.clear();
                Navigator.pop(ctx);
                setState(() => _selectedIndex = 1); // Go to Progress Page to see it
              }
            },
            child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(), 
      const ProgressPage(), 
      const SizedBox(), // Spacer for the center button
      const DonePage(), 
      const SettingsPage()
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            _showAddTrackDialog();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Progress'),
          // The Big Black Plus Icon from your screenshot
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 48, color: Colors.black), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Done'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}