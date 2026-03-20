import 'package:flutter/material.dart';
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
  // DEFAULTS: Today and Today + 3 days
  final DateTime _startDate = DateTime.now();
  final DateTime _endDate = DateTime.now().add(const Duration(days: 3));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Range")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildDateInfo("Starting Date", _startDate),
            const SizedBox(height: 20),
            _buildDateInfo("Ending Date", _endDate),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () async {
                  // SAVE and WAIT
                  await context.read<TrackManager>().setSchedule(
                    widget.track.id, 
                    _startDate, 
                    _endDate
                  );
                  // GO BACK
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Apply", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 5),
        Text(
          "${date.year}/${date.month}/${date.day}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Divider(thickness: 1),
      ],
    );
  }
}