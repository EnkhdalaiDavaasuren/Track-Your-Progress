import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import '../models/track_model.dart';
import 'storage_service.dart';
import 'firebase_service.dart';

class TrackManager extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final StorageService _storage = StorageService();
  List<Track> _tracks = [];

  // --- GETTERS ---
  // This is the missing piece! Detail page needs this to prevent crashes.
  List<Track> get allTracks => _tracks; 

  List<Track> get ongoingTracks => _tracks.where((t) => !t.isExpired).toList();
  List<Track> get expiredTracks => _tracks.where((t) => t.isExpired).take(10).toList();
  List<Track> get dashboardTracks => _tracks.where((t) => !t.isExpired).take(3).toList();

  // Load Local Database on Startup
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
      startDate: null,
      endDate: null,
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

    _tracks[index].dailyProgress.clear();
    int daysInRange = end.difference(start).inDays;
    for (int i = 0; i <= daysInRange; i++) {
      // Use intl to format consistently
      String dateKey = DateFormat('yyyy-MM-dd').format(start.add(Duration(days: i)));
      _tracks[index].dailyProgress[dateKey] = DayStatus.notSet;
    }

    notifyListeners();
    await _saveAll(_tracks[index]);
  }

  // 3. UPDATE DAY STATUS: The Circle Grid Logic
  Future<void> updateDayStatus(String trackId, String dateKey, DayStatus status) async {
    int index = _tracks.indexWhere((t) => t.id == trackId);
    if (index == -1) return;

    _tracks[index].dailyProgress[dateKey] = status;
    notifyListeners();
    await _saveAll(_tracks[index]);
  }

  // 4. DELETE TRACK
  Future<void> deleteTrack(String id) async {
    _tracks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _storage.saveTracks(_tracks.map((t) => t.toJson()).toList());
    await _firebase.removeTrack(id);
  }

  // 5. RENAME TRACK
  Future<void> renameTrack(String id, String newName) async {
    int index = _tracks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tracks[index].name = newName;
      notifyListeners();
      await _saveAll(_tracks[index]);
    }
  }

  // 6. UPDATE CHECK TEXT ("Did I eat today?")
  Future<void> updateCheckText(String id, String text) async {
    int index = _tracks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tracks[index].checkText = text;
      notifyListeners();
      await _saveAll(_tracks[index]);
    }
  }

  // --- THE SYNC LOGIC ---

  Future<void> _saveAll(Track track) async {
    await _storage.saveTracks(_tracks.map((t) => t.toJson()).toList());
    await _firebase.syncTrack(track);
  }

  Future<void> loadFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; 

    try {
      List<Track> cloudTracks = await _firebase.fetchTracks();
      if (cloudTracks.isNotEmpty) {
        _tracks = cloudTracks;
        await _storage.saveTracks(_tracks.map((t) => t.toJson()).toList());
        notifyListeners();
      }
    } catch (e) {
      print("Error loading from Firebase: $e");
    }
  }

  Future<void> clearData() async {
    _tracks = [];
    notifyListeners();
    await _storage.saveTracks([]); 
  }
}