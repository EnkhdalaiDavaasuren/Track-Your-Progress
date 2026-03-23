import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import this for DateFormat
import 'package:provider/provider.dart';
import '../../../models/track_model.dart';
import '../../../services/track_manager.dart';
import '../setup_range_page.dart';
import '../track_detail_page.dart';

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
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
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
                        "${track.name} ${isNotSet ? '(Not Set)' : '(In process)'}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => manager.deleteTrack(track.id),
                    ),
                  ],
                ),
                
                // --- ADDED: THE DATE RANGE DISPLAY ---
                if (!isNotSet)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Text(
                      "${DateFormat('yyyy/MM/dd').format(track.startDate!)} - ${DateFormat('yyyy/MM/dd').format(track.endDate!)}",
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ),
                
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {
                      if (track.startDate == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SetupRangePage(track: track)),
                        );
                      } else {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => TrackDetailPage(track: track)),
                        );
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