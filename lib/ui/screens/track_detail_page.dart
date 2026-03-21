import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/track_model.dart';
import '../../services/track_manager.dart';

class TrackDetailPage extends StatefulWidget {
  final Track track;
  const TrackDetailPage({super.key, required this.track});

  @override
  State<TrackDetailPage> createState() => _TrackDetailPageState();
}

class _TrackDetailPageState extends State<TrackDetailPage> {
  late DateTime displayMonth;

  @override
  void initState() {
    super.initState();
    // Safety: Initialize displayMonth to the track's start date or right now
    displayMonth = widget.track.startDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // 1. We wrap the whole body in a Consumer. 
    // This is safer than using .firstWhere because it handles updates automatically.
    return Consumer<TrackManager>(
      builder: (context, manager, child) {
        
        // Safety check: Find the latest data for THIS track ID
        // If it's not found in ongoing, look in expired.
        Track currentTrack;
        try {
          currentTrack = manager.ongoingTracks
              .followedBy(manager.expiredTracks)
              .firstWhere((t) => t.id == widget.track.id);
        } catch (e) {
          // If something goes wrong, use the track passed from the previous screen
          currentTrack = widget.track;
        }

        // --- CALENDAR MATH ---
        final int daysInMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
        final int firstDayOffset = DateTime(displayMonth.year, displayMonth.month, 1).weekday % 7;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(currentTrack.name),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _showRenameDialog(context, currentTrack),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // CHECK TEXT BUTTON
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: OutlinedButton(
                  onPressed: () => _showCheckTextDialog(context, currentTrack),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    side: const BorderSide(color: Colors.black12),
                  ),
                  child: Text(
                    currentTrack.checkText.isEmpty ? "Add Check Text" : "Goal: ${currentTrack.checkText}",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),

              // MONTH SELECTOR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(displayMonth),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => setState(() => displayMonth = DateTime(displayMonth.year, displayMonth.month - 1)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => setState(() => displayMonth = DateTime(displayMonth.year, displayMonth.month + 1)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // GRID
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: daysInMonth + firstDayOffset,
                    itemBuilder: (context, index) {
                      if (index < firstDayOffset) return const SizedBox.shrink();

                      int day = index - firstDayOffset + 1;
                      DateTime date = DateTime(displayMonth.year, displayMonth.month, day);
                      String dateKey = DateFormat('yyyy-MM-dd').format(date);

                      // Range check logic
                      bool isInRange = false;
                      if (currentTrack.startDate != null && currentTrack.endDate != null) {
                        DateTime start = DateTime(currentTrack.startDate!.year, currentTrack.startDate!.month, currentTrack.startDate!.day);
                        DateTime end = DateTime(currentTrack.endDate!.year, currentTrack.endDate!.month, currentTrack.endDate!.day);
                        isInRange = !date.isBefore(start) && !date.isAfter(end);
                      }

                      DayStatus status = currentTrack.dailyProgress[dateKey] ?? DayStatus.notSet;

                      return GestureDetector(
                        onTap: isInRange ? () => _showProgressDialog(context, currentTrack, dateKey) : null,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getCircleColor(status, isInRange),
                            border: isInRange ? null : Border.all(color: Colors.black12),
                          ),
                          child: Center(
                            child: Text(
                              "$day",
                              style: TextStyle(
                                color: isInRange ? Colors.black : Colors.grey.withValues(alpha: 0.3),
                                fontWeight: isInRange ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCircleColor(DayStatus status, bool isInRange) {
    if (!isInRange) return Colors.transparent;
    switch (status) {
      case DayStatus.yes: return Colors.green.withValues(alpha: 0.7);
      case DayStatus.no: return Colors.red.withValues(alpha: 0.7);
      case DayStatus.notSet: return Colors.grey.withValues(alpha: 0.4);
    }
  }

  // --- DIALOGS ---

  void _showProgressDialog(BuildContext context, Track track, String dateKey) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF3EDF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Center(child: Text(track.checkText.isEmpty ? "Today's Progress" : track.checkText)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () {
              context.read<TrackManager>().updateDayStatus(track.id, dateKey, DayStatus.yes);
              Navigator.pop(ctx);
            },
            child: const Text("Yes", style: TextStyle(color: Color(0xFF6750A4), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.read<TrackManager>().updateDayStatus(track.id, dateKey, DayStatus.no);
              Navigator.pop(ctx);
            },
            child: const Text("No", style: TextStyle(color: Color(0xFF6750A4), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCheckTextDialog(BuildContext context, Track track) {
    final controller = TextEditingController(text: track.checkText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Goal Question"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "e.g. Did I workout?")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              context.read<TrackManager>().updateCheckText(track.id, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, Track track) {
    final controller = TextEditingController(text: track.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rename Track"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              context.read<TrackManager>().renameTrack(track.id, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text("Rename"),
          )
        ],
      ),
    );
  }
}