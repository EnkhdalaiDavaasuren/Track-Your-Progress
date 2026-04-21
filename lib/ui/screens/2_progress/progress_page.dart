import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:provider/provider.dart';
import '../../../models/track_model.dart';
import '../../../services/track_manager.dart';
import '../setup_range_page.dart';
import '../track_detail_page.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  // THE FIX: Theme-aware Time Picker
  Future<void> _selectReminderTime(BuildContext context, TrackManager manager, Track track) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: track.reminderHour ?? 9, 
        minute: track.reminderMinute ?? 0
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Logic: Flip the picker theme based on app theme
            colorScheme: isDark 
              ? const ColorScheme.dark(
                  primary: Color(0xFFD0BCFF), // Light purple
                  onPrimary: Colors.black,
                  surface: Color(0xFF2C2C2C),
                  onSurface: Colors.white,
                )
              : const ColorScheme.light(
                  primary: Color(0xFF6750A4), // Deep purple
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6750A4),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      manager.updateReminderTime(track.id, picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<TrackManager>(context);
    final tracks = manager.ongoingTracks;

    // Detect theme colors dynamically
    final Color borderColor = Theme.of(context).colorScheme.onSurface;
    final Color cardBackground = Theme.of(context).cardColor;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress"), 
        centerTitle: true,
        foregroundColor: borderColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: tracks.isEmpty
                ? Center(
                    child: Text(
                      "No active tracks. Click + to add one!",
                      style: TextStyle(color: borderColor.withValues(alpha: 0.5)),
                    ),
                  )
                : ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      bool hasDates = track.startDate != null && track.endDate != null;
                      bool isNotSet = track.startDate == null;
                      bool hasTime = track.reminderHour != null;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor, width: 1.5),
                          color: cardBackground,
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
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                      color: borderColor,
                                    ),
                                  ),
                                ),
                                
                                Row(
                                  children: [
                                    // 1. CLOCK PICKER ICON
                                    IconButton(
                                      icon: Icon(
                                        Icons.access_time, 
                                        color: hasTime 
                                          ? (isDark ? Colors.orangeAccent : Colors.orange) 
                                          : borderColor.withValues(alpha: 0.3), 
                                        size: 22
                                      ),
                                      onPressed: () => _selectReminderTime(context, manager, track),
                                    ),

                                    // 2. NOTIFICATION FREQUENCY
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.notifications_active_outlined, 
                                        color: isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6750A4), 
                                        size: 24,
                                      ),
                                      onSelected: (String value) {
                                        manager.updateFrequency(track.id, value);
                                      },
                                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                        const PopupMenuItem(value: "Every day", child: Text("Every day")),
                                        const PopupMenuItem(value: "Every week", child: Text("Every week")),
                                        const PopupMenuDivider(),
                                        const PopupMenuItem(value: "None", child: Text("Turn off")),
                                      ],
                                    ),
                                    
                                    // 3. DELETE
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () => manager.deleteTrack(track.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            // DISPLAY THE REMINDER TIME
                            if (hasTime)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.alarm, size: 14, color: isDark ? Colors.orangeAccent : Colors.orange),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Daily Reminder: ${track.reminderHour.toString().padLeft(2, '0')}:${track.reminderMinute.toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        color: isDark ? Colors.orangeAccent : Colors.orange, 
                                        fontSize: 12, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // DATE RANGE DISPLAY
                            if (hasDates)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  "${DateFormat('yyyy/MM/dd').format(track.startDate!)} - ${DateFormat('yyyy/MM/dd').format(track.endDate!)}",
                                  style: TextStyle(
                                    color: borderColor.withValues(alpha: 0.6), 
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  side: BorderSide(color: borderColor),
                                  foregroundColor: borderColor,
                                ),
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
                                child: Text(isNotSet ? "Set" : "View"),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              "Active tracks: ${tracks.length}/10",
              style: TextStyle(
                color: borderColor.withValues(alpha: 0.5), 
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}