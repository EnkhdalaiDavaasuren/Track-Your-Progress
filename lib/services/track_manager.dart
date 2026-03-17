import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; 
import '../models/track_model.dart';
import 'storage_service.dart';
import 'firebase_service.dart';

class TrackManager extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final StorageService _storage = StorageService();
  List<Track> _tracks = [];

  List<Track> get dashboardTracks => _tracks.take(3).toList();
  List<Track> get ongoingTracks => _tracks.where((t) => !t.isExpired).toList();
  List<Track> get expiredTracks => _tracks.where((t) => t.isExpired).toList();

  // Load from Disk on Startup
  Future<void> init() async {
    final rawData = await _storage.loadTracks();
    // FIXED: Changed fromJSON to fromJson to match standard naming
    _tracks = rawData.map((item) => Track.fromJson(item)).toList();
    notifyListeners();
  }

  // CREATE
  Future<void> addTrack(String name) async {
    final newTrack = Track(
      id: const Uuid().v4(), 
      name: name, 
      dailyProgress: {}
    );
    
    _tracks.insert(0, newTrack);
    notifyListeners();
    
    await _saveLocal();
    await _firebase.syncTrack(newTrack);
  }

  // DELETE
  Future<void> deleteTrack(String id) async {
    _tracks.removeWhere((t) => t.id == id);
    notifyListeners();
    
    await _saveLocal();
    await _firebase.removeTrack(id); 
  }

  // UPDATE SCHEDULE
  Future<void> setSchedule(String id, DateTime start, DateTime end) async {
    var index = _tracks.indexWhere((t) => t.id == id);
    if (index == -1 || end.year - start.year > 10) return;

    _tracks[index].startDate = start;
    _tracks[index].endDate = end;
    
    _tracks[index].dailyProgress.clear();
    int daysInRange = end.difference(start).inDays;
    
    for (int i = 0; i <= daysInRange; i++) {
      String dateKey = start.add(Duration(days: i)).toString().split(' ')[0];
      _tracks[index].dailyProgress[dateKey] = DayStatus.notSet;
    }
    
    notifyListeners();
    await _saveLocal();
    await _firebase.syncTrack(_tracks[index]);
  }

  // UPDATE DAY STATUS
  Future<void> updateDayStatus(String trackId, String dateKey, DayStatus status) async {
    var index = _tracks.indexWhere((t) => t.id == trackId);
    if (index == -1) return;

    _tracks[index].dailyProgress[dateKey] = status;
    notifyListeners();
    
    await _saveLocal();
    await _firebase.syncTrack(_tracks[index]);
  }

  // Helper to save to SharedPreferences
  Future<void> _saveLocal() async {
    // Ensure this matches the method name in your Track model
    await _storage.saveTracks(_tracks.map((t) => t.toJson()).toList());
  }
}