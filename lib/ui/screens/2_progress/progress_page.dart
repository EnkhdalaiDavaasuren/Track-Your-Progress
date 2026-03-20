import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/track_manager.dart';
import '../setup_range_page.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<TrackManager>(context);
    final tracks = manager.ongoingTracks;

    return Scaffold(
      appBar: AppBar(title: const Text("Progress"), centerTitle: true),
      body: ListView.builder(
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          bool isNotSet = track.startDate == null;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${track.name} ${isNotSet ? '(Not Set)' : '(In process)'}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => context.read<TrackManager>().deleteTrack(track.id),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {
                      if (isNotSet) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SetupRangePage(track: track)),
                        );
                      } else {
                        // This will be your Calendar/Circle Grid page
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Detail View Coming Soon")));
                      }
                    },
                    child: Text(isNotSet ? "Set" : "View", style: const TextStyle(color: Colors.black)),
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