import 'package:flutter/material.dart';
import 'package:my_app/models/track_model.dart';
import 'package:provider/provider.dart';
import 'package:my_app/services/track_manager.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<TrackManager>(context);
    final tracks = manager.ongoingTracks;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) => _buildTrackCard(tracks[index], context),
            ),
          ),
          const Text("You may add up to 10 tracks", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTrackCard(Track track, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${track.name} (${track.startDate == null ? 'Not Set' : 'In process'})"),
              IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {
                Provider.of<TrackManager>(context, listen: false).deleteTrack(track.id);
              }),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                // Navigator.push to Detail Page
              },
              child: const Text("View", style: TextStyle(color: Colors.black)),
            ),
          )
        ],
      ),
    );
  }
}