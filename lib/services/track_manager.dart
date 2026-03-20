import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/track_model.dart';
import 'storage_service.dart';
import 'firebase_service.dart';

class TrackManager extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final StorageService _storage = StorageService();
  List<Track> _tracks = [];

  List<Track> get ongoingTracks => _tracks.where((t) => !t.isExpired).toList();

  // Load Database on Startup
  Future<void> init() async {
    final rawData = await _storage.loadTracks();
    _tracks = rawData.map((item) => Track.fromJson(item)).toList();
    notifyListeners();
  }

  // 1. ADD TRACK: Starts as (Not Set)
  Future<void> addTrack(String name) async {
    final newTrack = Track(
      id: const Uuid().v4(),
      name: name,
      startDate: null, // No date yet
      endDate: null,   // No date yet
      dailyProgress: {},
    );
    _tracks.insert(0, newTrack);
    notifyListeners();
    await _saveAll(newTrack);
  }

  // 2. SET RANGE: Called from SetupRangePage
  Future<void> setSchedule(String id, DateTime start, DateTime end) async {
    var index = _tracks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    _tracks[index].startDate = start;
    _tracks[index].endDate = end;
    
    // Initialize the grey circles for the range
    _tracks[index].dailyProgress.clear();
    int daysInRange = end.difference(start).inDays;
    for (int i = 0; i <= daysInRange; i++) {
      String dateKey = start.add(Duration(days: i)).toString().split(' ')[0];
      _tracks[index].dailyProgress[dateKey] = DayStatus.notSet;
    }
    
    notifyListeners();
    await _saveAll(_tracks[index]);
  }

  // 3. DELETE TRACK
  Future<void> deleteTrack(String id) async {
    _tracks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _storage.saveTracks(_tracks.map((t) => t.toJson()).toList());
    await _firebase.removeTrack(id);
  }

  // Private helper to sync both Local and Firebase
  Future<void> _saveAll(Track track) async {
    await _storage.saveTracks(_tracks.map((t) => t.toJson()).toList());
    await _firebase.syncTrack(track);
  }

  // This downloads tracks from Firebase and saves them to the phone
  Future<void> loadFromFirebase() async {
    try {
      // 1. Ask Firebase for this user's tracks
      List<Track> cloudTracks = await _firebase.fetchTracks();
      
      // 2. Update our local list with the cloud data
      _tracks = cloudTracks;
      
      // 3. Save these tracks to the phone's memory (Local Storage)
      await _storage.saveTracks(_tracks.map((t) => t.toJson()).toList());
      
      // 4. Tell the UI to refresh (so the Progress page shows the new tracks)
      notifyListeners();
      
      print("Sync Complete: Loaded ${cloudTracks.length} tracks from cloud.");
    } catch (e) {
      print("Error loading from Firebase: $e");
    }
  }

  // Also add this to handle the "Log out" cleanup
  Future<void> clearData() async {
    _tracks = [];
    notifyListeners();
    await _storage.saveTracks([]); // Wipe the phone's memory
  }
}