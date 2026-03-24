import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:provider/provider.dart';
import '../../models/track_model.dart';
import '../../services/track_manager.dart';

class SetupRangePage extends StatefulWidget {
  final Track track;
  const SetupRangePage({super.key, required this.track});

  @override
  State<SetupRangePage> createState() => _SetupRangePageState();
}

class _SetupRangePageState extends State<SetupRangePage> {
  // 1. Initialize with default (Today and Today + 3 days)
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 3));

  // 2. THE PICKER LOGIC: Opens the calendar with theme-aware colors
  Future<void> _selectDate(BuildContext context, bool isStartingDate) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartingDate ? _startDate : _endDate,
      firstDate: DateTime.now(), // Cannot pick the past
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 Year Limit
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark 
              ? const ColorScheme.dark(
                  primary: Color(0xFFD0BCFF),
                  onPrimary: Colors.black,
                  surface: Color(0xFF2C2C2C),
                  onSurface: Colors.white,
                )
              : const ColorScheme.light(
                  primary: Color(0xFF6750A4),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartingDate) {
          _startDate = picked;
          // Logic: End date cannot be before start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detect theme colors dynamically
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup Range"),
        foregroundColor: onSurfaceColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose your schedule range for '${widget.track.name}':", 
              style: TextStyle(color: onSurfaceColor.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 30),

            // START DATE (Clickable)
            _buildDateClickable(
              context,
              "Starting Date", 
              _startDate, 
              () => _selectDate(context, true)
            ),
            
            const SizedBox(height: 40),

            // END DATE (Clickable)
            _buildDateClickable(
              context,
              "Ending Date", 
              _endDate, 
              () => _selectDate(context, false)
            ),

            const Spacer(),

            // APPLY BUTTON: Sends user back to Progress Page
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), 
                ),
                onPressed: () async {
                  // Safety Check
                  if (_endDate.isBefore(_startDate)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("End date must be after start date")),
                    );
                    return;
                  }

                  // 1. SAVE TO CLOUD AND DISK
                  await context.read<TrackManager>().setSchedule(
                    widget.track.id, 
                    _startDate, 
                    _endDate
                  );
                  
                  // 2. NAVIGATE BACK: Return to Progress Page
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Apply & Start Tracking", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper widget for the clickable date rows
  Widget _buildDateClickable(BuildContext context, String label, DateTime date, VoidCallback onTap) {
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontSize: 14, 
              color: primaryColor, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy / MM / dd').format(date),
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.w300,
                  color: onSurfaceColor,
                ),
              ),
              Icon(Icons.calendar_month_outlined, color: onSurfaceColor.withValues(alpha: 0.5)),
            ],
          ),
          // Divider adapts to theme
          Divider(thickness: 1, color: onSurfaceColor.withValues(alpha: 0.2)),
        ],
      ),
    );
  }
}