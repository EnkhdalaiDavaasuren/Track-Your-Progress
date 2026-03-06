import 'package:flutter/material.dart';
import 'storage_service.dart';

class TrackManager extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Map<String, dynamic>> _tracks = [];

  List<Map<String, dynamic>> get tracks => _tracks;

  // Initialize: Load data when the app starts
  Future<void> init() async {
    _tracks = await _storage.loadTracks();
    notifyListeners();
  }

  // Logic: Add a new track and save it
  void addTrack(String name, int totalDays) async {
    _tracks.add({
      'name': name,
      'status': 'In process',
      'days_completed': [], // List of days (e.g. 1, 2, 5)
      'total_days': totalDays,
    });
    
    notifyListeners();
    await _storage.saveTracks(_tracks); // Save to local storage
  }

  // Logic: Toggle a day on/off
  void toggleDay(int trackIndex, int day) async {
    List<dynamic> completed = _tracks[trackIndex]['days_completed'];
    
    if (completed.contains(day)) {
      completed.remove(day);
    } else {
      completed.add(day);
    }

    notifyListeners();
    await _storage.saveTracks(_tracks);
  }
  
  // Logic: Update Status (For the "Done" page logic)
  void setStatus(int index, String status) async {
    _tracks[index]['status'] = status;
    notifyListeners();
    await _storage.saveTracks(_tracks);
  }
}