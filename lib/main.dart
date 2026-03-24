import 'package:flutter/material.dart';
import 'package:my_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/track_manager.dart';
import 'ui/screens/1_home/home_page.dart';
import 'ui/screens/2_progress/progress_page.dart';
import 'ui/screens/3_done/done_page.dart';
import 'ui/screens/4_settings/settings_page.dart';
import 'ui/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();
  final manager = TrackManager();
  await manager.init();
  runApp(ChangeNotifierProvider(create: (context) => manager, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white, fontFamily: 'Roboto'),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
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
    Future.microtask(() => context.read<TrackManager>().loadFromFirebase());
  }

  void _showAddTrackDialog() {
    final manager = context.read<TrackManager>();

    // WARNING 1: Too many ACTIVE tracks (Current Ongoing + Not Set)
    // We calculate active by looking at anything that isn't 'isDone'
    int activeCount = manager.allTracks.where((t) => !t.isDone).length;

    if (activeCount >= 10) {
      _showLimitAlert(
        "Active Limit Reached", 
        "You already have 10 active tracks. Please complete or delete some before creating a new one."
      );
      return;
    }

    // WARNING 2: History is full (Too many total tracks)
    // If they have 10 completed tracks and 0 active, they still hit the 10-slot limit
    if (manager.allTracks.length >= 10) {
      _showLimitAlert(
        "History Full", 
        "Please delete completed tracks from the Done page to add more."
      );
      return;
    }

    // If both checks pass, show the input
    _showActualInputDialog();
  }

  // 2. HELPER: The Alert Dialog (Purple rounded style)
  void _showLimitAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF3EDF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(color: Color(0xFF6750A4), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 3. HELPER: The Actual Input Dialog
  void _showActualInputDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF3EDF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("New Track", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Track Name",
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              Navigator.pop(ctx);
            }, 
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF6750A4)))
          ),
          TextButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                context.read<TrackManager>().addTrack(_nameController.text);
                _nameController.clear();
                Navigator.pop(ctx);
                setState(() => _selectedIndex = 1); // Go to Progress Page
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
    final List<Widget> pages = [const HomePage(), const ProgressPage(), const SizedBox(), const DonePage(), const SettingsPage()];
    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, currentIndex: _selectedIndex, selectedItemColor: const Color(0xFF6750A4),
        onTap: (i) => i == 2 ? _showAddTrackDialog() : setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 45, color: Colors.black), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Done'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}