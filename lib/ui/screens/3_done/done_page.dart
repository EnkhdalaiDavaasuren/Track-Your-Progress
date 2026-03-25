import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../services/track_manager.dart';
import '../../../services/pdf_service.dart';
import '../track_detail_page.dart';

class DonePage extends StatelessWidget {
  const DonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<TrackManager>(context);
    final tracks = manager.expiredTracks;

    // --- DYNAMIC THEME COLORS ---
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color cardColor = Theme.of(context).cardColor;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(title: const Text("Accomplishments"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: tracks.isEmpty
                ? Center(
                    child: Text(
                      "No finished tracks yet.",
                      style: TextStyle(color: onSurfaceColor.withValues(alpha: 0.5)),
                    ),
                  )
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
                              // Logic preserved: Green if done, theme-border if not
                              color: fullyDone ? Colors.green : onSurfaceColor,
                              width: 1.5),
                          color: cardColor, // FIXED: Now dark in Dark Mode
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
                                  icon: Icon(Icons.delete_outline,
                                      color: onSurfaceColor.withValues(alpha: 0.5)),
                                  onPressed: () => manager.deleteTrack(track.id),
                                ),
                              ],
                            ),
                            
                            if (track.startDate != null)
                              Text(
                                "${DateFormat('yyyy/MM/dd').format(track.startDate!)} - ${DateFormat('yyyy/MM/dd').format(track.endDate!)}",
                                style: TextStyle(
                                    color: onSurfaceColor.withValues(alpha: 0.6), 
                                    fontSize: 13),
                              ),

                            const SizedBox(height: 15),
                            
                            // BUTTON ROW (PDF and VIEW)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // 1. THE PDF BUTTON
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: onSurfaceColor),
                                    foregroundColor: onSurfaceColor,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero),
                                  ),
                                  onPressed: () => PdfService.generateTrackPdf(track),
                                  icon: const Icon(Icons.picture_as_pdf, 
                                      size: 18, color: Colors.red),
                                  label: const Text("PDF"),
                                ),
                                
                                const SizedBox(width: 10),

                                // 2. THE VIEW BUTTON
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: onSurfaceColor),
                                    foregroundColor: onSurfaceColor,
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
                                  child: const Text("View"),
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
            color: scaffoldBg, // FIXED: Blends with the page background
            child: Text(
              "Completed history: ${tracks.length}/10\nDelete old tracks to add more.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: onSurfaceColor.withValues(alpha: 0.5), 
                  fontSize: 12, 
                  fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}