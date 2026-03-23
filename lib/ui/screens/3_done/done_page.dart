import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/track_model.dart';
import '../../../services/track_manager.dart';
import '../track_detail_page.dart';

class DonePage extends StatelessWidget {
  const DonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<TrackManager>(context);
    // Use our getter to find expired tracks (limited to 10)
    final tracks = manager.expiredTracks;

    return Scaffold(
      appBar: AppBar(title: const Text("Accomplishments"), centerTitle: true),
      body: tracks.isEmpty
          ? const Center(child: Text("No finished tracks yet.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                // Logic: Check if there are any Grey blocks (notSet) left
                bool fullyDone = track.isFullyCompleted;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: fullyDone ? Colors.green : Colors.black, width: 1.5),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              fullyDone 
                                ? "${track.name} (Completed)" 
                                : "${track.name} (Incomplete - Unchecked days exist)",
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                color: fullyDone ? Colors.green : Colors.redAccent
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                            onPressed: () => manager.deleteTrack(track.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TrackDetailPage(track: track)),
                            );
                          },
                          child: const Text("View", style: TextStyle(color: Colors.black)),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}