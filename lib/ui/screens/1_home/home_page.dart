import 'package:flutter/material.dart';
import 'package:my_app/ui/screens/4_settings/sub_page/change_profile_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io'; // CRITICAL: Added for File() support
import '../../../services/track_manager.dart';
// Using relative import to avoid project name errors
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<TrackManager>(context);
    final topTracks = manager.dashboardTracks;
    final borderColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          // RELEASE FIX: Handle the waiting state to prevent flashing
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          String displayName = user?.displayName ?? user?.email?.split('@')[0] ?? "User";

          // LOGIC FIX: Check if the photo path actually exists on the phone's memory
          bool hasLocalImage = user?.photoURL != null && 
                               user!.photoURL!.isNotEmpty && 
                               File(user.photoURL!).existsSync();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CLICKABLE HEADER ---
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangeProfilePage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Row(
                    children: [
                      // --- DYNAMIC ICON (FIXED) ---
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(context).cardColor,
                        // If it's a local file path, use FileImage.
                        backgroundImage: hasLocalImage 
                          ? FileImage(File(user!.photoURL!)) 
                          : null,
                        child: !hasLocalImage
                          ? Icon(Icons.person, size: 30, color: borderColor)
                          : null,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName.toUpperCase(), 
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.1)
                            ),
                            Text(
                              "Tap to edit profile", 
                              style: TextStyle(fontSize: 12, color: borderColor.withValues(alpha: 0.5))
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Divider(thickness: 1, color: borderColor.withValues(alpha: 0.1)),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
                child: Text("Active Progress", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400))
              ),

              Expanded(
                child: topTracks.isEmpty 
                ? Center(child: Text("No ongoing tracks.", style: TextStyle(color: borderColor.withValues(alpha: 0.3))))
                : ListView.builder(
                  itemCount: topTracks.length,
                  itemBuilder: (context, index) {
                    final track = topTracks[index];
                    final bool hasValidRange = track.startDate != null && track.endDate != null;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 2),
                        color: Theme.of(context).cardColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(track.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(
                            !hasValidRange 
                              ? "Not Set" 
                              : "${track.startDate!.month}/${track.startDate!.day} - ${track.endDate!.month}/${track.endDate!.day}",
                            style: TextStyle(color: borderColor.withValues(alpha: 0.5), fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}