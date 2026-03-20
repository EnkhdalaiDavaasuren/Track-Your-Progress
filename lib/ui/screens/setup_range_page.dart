import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Make sure 'intl' is in your pubspec.yaml
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
  // 1. Initialize with your default (Today and Today + 3)
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 3));

  // 2. THE PICKER LOGIC: Opens the calendar when a date is clicked
  Future<void> _selectDate(BuildContext context, bool isStartingDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartingDate ? _startDate : _endDate,
      firstDate: DateTime.now(), // Cannot pick the past
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 Year Limit
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6750A4), // The purple from your "Good" version
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
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Range")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose your schedule range:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // START DATE (Clickable)
            _buildDateClickable("Starting Date", _startDate, () => _selectDate(context, true)),
            
            const SizedBox(height: 40),

            // END DATE (Clickable)
            _buildDateClickable("Ending Date", _endDate, () => _selectDate(context, false)),

            const Spacer(),

            // APPLY BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Boxy
                ),
                onPressed: () async {
                  // Final check: Range must be valid
                  if (_endDate.isBefore(_startDate)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("End date must be after start date")),
                    );
                    return;
                  }

                  // SAVE TO CLOUD AND DISK
                  await context.read<TrackManager>().setSchedule(
                    widget.track.id, 
                    _startDate, 
                    _endDate
                  );
                  
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Apply & Start Tracking", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper to make the dates look like your "Good" screenshots
  Widget _buildDateClickable(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, // This makes it clickable!
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy / MM / dd').format(date),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
              ),
              const Icon(Icons.calendar_month_outlined, color: Colors.grey),
            ],
          ),
          const Divider(thickness: 1, color: Colors.black),
        ],
      ),
    );
  }
}