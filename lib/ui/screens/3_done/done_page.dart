import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../services/track_manager.dart';
import '../../../services/pdf_service.dart'; // Make sure this path is correct
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
      body: Column(
        children: [
          Expanded(
            child: tracks.isEmpty
                ? const Center(
                    child: Text("No finished tracks yet.",
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      bool fullyDone = track.isFullyCompleted;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: fullyDone ? Colors.green : Colors.black,
                              width: 1.5),
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
                                        : "${track.name} (Incomplete)",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: fullyDone
                                            ? Colors.green
                                            : Colors.redAccent),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.grey),
                                  onPressed: () => manager.deleteTrack(track.id),
                                ),
                              ],
                            ),
                            
                            // Show dates so user knows what they are printing
                            if (track.startDate != null)
                              Text(
                                "${DateFormat('yyyy/MM/dd').format(track.startDate!)} - ${DateFormat('yyyy/MM/dd').format(track.endDate!)}",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),

                            const SizedBox(height: 15),
                            
                            // BUTTON ROW (PDF and VIEW)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // 1. THE PDF BUTTON
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.black),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero),
                                  ),
                                  onPressed: () => PdfService.generateTrackPdf(track),
                                  icon: const Icon(Icons.picture_as_pdf, 
                                      size: 18, color: Colors.red),
                                  label: const Text("PDF", 
                                      style: TextStyle(color: Colors.black)),
                                ),
                                
                                const SizedBox(width: 10),

                                // 2. THE VIEW BUTTON
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.black),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TrackDetailPage(track: track)),
                                    );
                                  },
                                  child: const Text("View",
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // --- FOOTER LIMIT MESSAGE ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Text(
              "Completed history: ${tracks.length}/10\nDelete old tracks to add more.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black54, 
                  fontSize: 12, 
                  fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}