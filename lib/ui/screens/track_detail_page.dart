import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/track_model.dart';
import '../../services/track_manager.dart';
import '../../services/pdf_service.dart';

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
    // Initialize to the start date or today
    final initialDate = widget.track.startDate ?? DateTime.now();
    displayMonth = DateTime(initialDate.year, initialDate.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).colorScheme.onSurface;

    return Consumer<TrackManager>(
      builder: (context, manager, child) {
        // RELEASE FIX: Robust track lookup to prevent "State Desync" crashes
        final track = manager.allTracks.firstWhere(
          (t) => t.id == widget.track.id,
          orElse: () => widget.track,
        );

        // Calendar Math
        final int daysInMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
        // weekday: 1 (Mon) to 7 (Sun). Sunday becomes 0 for our grid.
        final int firstDayOffset = DateTime(displayMonth.year, displayMonth.month, 1).weekday % 7;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Expanded(child: Text(track.name, overflow: TextOverflow.ellipsis)),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _showRenameDialog(context, track),
                )
              ],
            ),
            actions: [
              if (track.isDone)
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  onPressed: () => PdfService.generateTrackPdf(track),
                )
            ],
          ),
          body: Column(
            children: [
              // Goal Question Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: OutlinedButton(
                  onPressed: () => _showCheckTextDialog(context, track),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    side: BorderSide(color: borderColor.withValues(alpha: 0.2)),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: Text(
                    track.checkText.isEmpty ? "Add Check Text" : "Goal: ${track.checkText}",
                    style: TextStyle(color: borderColor, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),

              // Calendar Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(displayMonth),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(children: [
                      IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => setState(() => displayMonth = DateTime(displayMonth.year, displayMonth.month - 1))),
                      IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => setState(() => displayMonth = DateTime(displayMonth.year, displayMonth.month + 1))),
                    ]),
                  ],
                ),
              ),

              // --- DAY HEADERS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) => 
                    Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))
                  ).toList()
                ),
              ),

              // THE GRID
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, 
                    mainAxisSpacing: 10, 
                    crossAxisSpacing: 10
                  ),
                  itemCount: daysInMonth + firstDayOffset,
                  itemBuilder: (context, index) {
                    if (index < firstDayOffset) return const SizedBox.shrink();

                    int day = index - firstDayOffset + 1;
                    // RELEASE FIX: Normalized current cell date
                    DateTime date = DateTime(displayMonth.year, displayMonth.month, day);
                    String dateKey = DateFormat('yyyy-MM-dd').format(date);
                    
                    bool isInRange = false;
                    if (track.startDate != null && track.endDate != null) {
                      DateTime s = DateTime(track.startDate!.year, track.startDate!.month, track.startDate!.day);
                      DateTime e = DateTime(track.endDate!.year, track.endDate!.month, track.endDate!.day);
                      isInRange = !date.isBefore(s) && !date.isAfter(e);
                    }

                    DayStatus status = track.dailyProgress[dateKey] ?? DayStatus.notSet;

                    return GestureDetector(
                      onTap: isInRange ? () => _showProgressDialog(context, track, dateKey) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          color: isInRange ? _getColor(status) : Colors.transparent, 
                          border: isInRange ? null : Border.all(color: borderColor.withValues(alpha: 0.1))
                        ),
                        child: Center(
                          child: Text(
                            "$day", 
                            style: TextStyle(
                              color: isInRange ? borderColor : borderColor.withValues(alpha: 0.2),
                              fontWeight: isInRange ? FontWeight.bold : FontWeight.normal
                            )
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColor(DayStatus s) {
    if (s == DayStatus.yes) return Colors.green.withValues(alpha: 0.7);
    if (s == DayStatus.no) return Colors.red.withValues(alpha: 0.7);
    return Colors.grey.withValues(alpha: 0.4);
  }

  void _showProgressDialog(BuildContext context, Track track, String dateKey) {
    DayStatus currentStatus = track.dailyProgress[dateKey] ?? DayStatus.notSet;

    // Logic: In the Done Page, you can ONLY edit Grey circles
    if (track.isDone && currentStatus != DayStatus.notSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Finished days are locked and cannot be changed."))
      );
      return;
    }

    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2C) : const Color(0xFFF3EDF7), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Center(child: Text(track.checkText.isEmpty ? "Today's Progress" : track.checkText)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () {
              context.read<TrackManager>().updateDayStatus(track.id, dateKey, DayStatus.yes);
              Navigator.pop(ctx);
            }, 
            child: const Text("Yes", style: TextStyle(fontWeight: FontWeight.bold))
          ),
          TextButton(
            onPressed: () {
              context.read<TrackManager>().updateDayStatus(track.id, dateKey, DayStatus.no);
              Navigator.pop(ctx);
            }, 
            child: const Text("No", style: TextStyle(fontWeight: FontWeight.bold))
          ),
        ],
      )
    );
  }
  
  void _showRenameDialog(BuildContext context, Track track) {
    final c = TextEditingController(text: track.name);
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("Rename"), 
        content: TextField(controller: c, autofocus: true), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")), 
          TextButton(
            onPressed: () {
              context.read<TrackManager>().renameTrack(track.id, c.text.trim());
              Navigator.pop(ctx);
            }, 
            child: const Text("Save")
          )
        ]
      )
    );
  }

  void _showCheckTextDialog(BuildContext context, Track track) {
    final c = TextEditingController(text: track.checkText);
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("Goal Question"), 
        content: TextField(controller: c, maxLength: 40, autofocus: true), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")), 
          TextButton(
            onPressed: () {
              context.read<TrackManager>().updateCheckText(track.id, c.text.trim());
              Navigator.pop(ctx);
            }, 
            child: const Text("Apply")
          )
        ]
      )
    );
  }
}