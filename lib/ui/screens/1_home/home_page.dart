import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/track_manager.dart';

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
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(children: [
            const Icon(Icons.account_circle, size: 45),
            const SizedBox(width: 15),
            Text(user?.email?.split('@')[0] ?? "Username", style: const TextStyle(fontSize: 22)),
          ]),
        ),
        const Divider(thickness: 2, color: Colors.black),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), child: Text("Active Progress", style: TextStyle(fontSize: 24))),
        Expanded(
          child: ListView.builder(
            itemCount: topTracks.length,
            itemBuilder: (context, index) {
              final track = topTracks[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), color: Colors.white),
                child: Text(track.name, style: const TextStyle(fontSize: 18)),
              );
            },
          ),
        ),
      ],
    );
  }
}