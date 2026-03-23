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
    displayMonth = widget.track.startDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackManager>(
      builder: (context, manager, child) {
        final track = manager.allTracks.firstWhere((t) => t.id == widget.track.id, orElse: () => widget.track);
        final int daysInMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
        final int firstDayOffset = DateTime(displayMonth.year, displayMonth.month, 1).weekday % 7;

        return Scaffold(
          appBar: AppBar(
            title: Row(children: [
              Text(track.name),
              IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showRenameDialog(context, track))
            ]),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: OutlinedButton(
                  onPressed: () => _showCheckTextDialog(context, track),
                  child: Text(track.checkText.isEmpty ? "Add Check Text" : "Goal: ${track.checkText}"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMMM yyyy').format(displayMonth), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Row(children: [
                      IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => displayMonth = DateTime(displayMonth.year, displayMonth.month - 1))),
                      IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => displayMonth = DateTime(displayMonth.year, displayMonth.month + 1))),
                    ]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))).toList()),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 10, crossAxisSpacing: 10),
                  itemCount: daysInMonth + firstDayOffset,
                  itemBuilder: (context, index) {
                    if (index < firstDayOffset) return const SizedBox.shrink();
                    int day = index - firstDayOffset + 1;
                    DateTime date = DateTime(displayMonth.year, displayMonth.month, day);
                    String dateKey = DateFormat('yyyy-MM-dd').format(date);
                    bool isInRange = track.startDate != null && track.endDate != null && !date.isBefore(DateTime(track.startDate!.year, track.startDate!.month, track.startDate!.day)) && !date.isAfter(DateTime(track.endDate!.year, track.endDate!.month, track.endDate!.day));
                    DayStatus status = track.dailyProgress[dateKey] ?? DayStatus.notSet;
                    return GestureDetector(
                      onTap: isInRange ? () => _showProgressDialog(context, track, dateKey) : null,
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: isInRange ? _getColor(status) : Colors.transparent, border: isInRange ? null : Border.all(color: Colors.black12)),
                        child: Center(child: Text("$day", style: TextStyle(color: isInRange ? Colors.black : Colors.grey.withValues(alpha: 0.2)))),
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
    if (track.isDone && (track.dailyProgress[dateKey] ?? DayStatus.notSet) != DayStatus.notSet) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Finished days are locked.")));
      return;
    }
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFFF3EDF7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Center(child: Text(track.checkText.isEmpty ? "Today's Progress" : track.checkText)),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(onPressed: () { context.read<TrackManager>().updateDayStatus(track.id, dateKey, DayStatus.yes); Navigator.pop(ctx); }, child: const Text("Yes", style: TextStyle(fontWeight: FontWeight.bold))),
        TextButton(onPressed: () { context.read<TrackManager>().updateDayStatus(track.id, dateKey, DayStatus.no); Navigator.pop(ctx); }, child: const Text("No", style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    ));
  }
  
  void _showRenameDialog(BuildContext context, Track track) {
    final c = TextEditingController(text: track.name);
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Rename"), content: TextField(controller: c), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")), TextButton(onPressed: () { context.read<TrackManager>().renameTrack(track.id, c.text); Navigator.pop(ctx); }, child: const Text("Save"))]));
  }

  void _showCheckTextDialog(BuildContext context, Track track) {
    final c = TextEditingController(text: track.checkText);
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Goal Question"), content: TextField(controller: c, maxLength: 40), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")), TextButton(onPressed: () { context.read<TrackManager>().updateCheckText(track.id, c.text); Navigator.pop(ctx); }, child: const Text("Apply"))]));
  }
}