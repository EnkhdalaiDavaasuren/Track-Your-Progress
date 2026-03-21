import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/track_manager.dart';
import '../track_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<TrackManager>(context);
    final topTracks = manager.dashboardTracks; 
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header with Icon and Username
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              const Icon(Icons.account_circle, size: 45),
              const SizedBox(width: 15),
              Text(
                user?.email?.split('@')[0] ?? "Username", 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w400)
              ),
            ],
          ),
        ),
        
        // 2. The Horizontal Line
        const Divider(thickness: 2, color: Colors.black),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Text("Active Progress", style: TextStyle(fontSize: 24)),
        ),

        // 3. The List of Active Cards (Matches Image 5)
        Expanded(
          child: topTracks.isEmpty 
          ? const Center(child: Text("No active tracks", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: topTracks.length,
              itemBuilder: (context, index) {
                final track = topTracks[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to details if set
                    if (track.startDate != null) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => TrackDetailPage(track: track)
                      ));
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(track.name, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          track.startDate == null 
                            ? "Not Set" 
                            : "${track.startDate!.month}/${track.startDate!.day}/${track.startDate!.year} - ${track.endDate!.month}/${track.endDate!.day}/${track.endDate!.year}",
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ),
      ],
    );
  }
}