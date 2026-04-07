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
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 3));
  }

  Future<void> _selectDate(BuildContext context, bool isStartingDate) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartingDate ? _startDate : _endDate,
      firstDate: today, 
      lastDate: today.add(const Duration(days: 3650)), // Picker already allows 10 years
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
        final normalized = DateTime(picked.year, picked.month, picked.day);
        if (isStartingDate) {
          _startDate = normalized;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = normalized;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup Range"),
        centerTitle: true,
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

            _buildDateClickable(
              context,
              "Starting Date", 
              _startDate, 
              () => _selectDate(context, true)
            ),
            
            const SizedBox(height: 40),

            _buildDateClickable(
              context,
              "Ending Date", 
              _endDate, 
              () => _selectDate(context, false)
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), 
                ),
                onPressed: _isSaving ? null : () async {
                  if (_endDate.isBefore(_startDate)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("End date must be after start date")),
                    );
                    return;
                  }

                  // --- LOGIC FIX FOR ISSUE #3 ---
                  // Changed 730 (2 years) to 3650 (10 years)
                  if (_endDate.difference(_startDate).inDays > 3650) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Maximum range is 10 years.")),
                    );
                    return;
                  }

                  setState(() => _isSaving = true);

                  try {
                    await context.read<TrackManager>().setSchedule(
                      widget.track.id, 
                      _startDate, 
                      _endDate
                    );
                    
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error saving schedule: $e")),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                },
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
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
          Divider(thickness: 1, color: onSurfaceColor.withValues(alpha: 0.2)),
        ],
      ),
    );
  }
}