import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/track_manager.dart';
// Note: Ensure this import path matches your project name exactly
import 'package:my_app/ui/screens/4_settings/sub_page/change_profile_page.dart'; 

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
          // RELEASE FIX: Handle the waiting state to prevent "User" flashing
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          String displayName = user?.displayName ?? user?.email?.split('@')[0] ?? "User";

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
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Theme.of(context).cardColor,
                        // RELEASE FIX: Safer Image Handling
                        backgroundImage: (user?.photoURL != null && 
                                          user!.photoURL!.isNotEmpty && 
                                          user.photoURL!.startsWith('http'))
                          ? NetworkImage(user.photoURL!)
                          : null,
                        child: (user?.photoURL == null || 
                                user!.photoURL!.isEmpty || 
                                !user.photoURL!.startsWith('http'))
                          ? Icon(Icons.person, size: 30, color: Theme.of(context).colorScheme.onSurface)
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
                            const Text("Tap to edit profile", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Divider(thickness: 1, color: borderColor.withValues(alpha: 0.2)),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
                child: Text("Active Progress", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400))
              ),

              Expanded(
                child: topTracks.isEmpty 
                ? const Center(child: Text("No active tracks with schedules set.", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                  itemCount: topTracks.length,
                  itemBuilder: (context, index) {
                    final track = topTracks[index];
                    
                    // RELEASE FIX: Double check both dates aren't null before forced unwrapping
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