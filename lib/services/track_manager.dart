import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/track_model.dart';
import 'storage_service.dart';
import 'firebase_service.dart';
import 'notification_service.dart';

class TrackManager extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final StorageService _storage = StorageService();
  List<Track> _tracks = [];

  // --- GETTERS (The logic filters for your UI) ---

  // Master list for Detail Page search (Prevents Crashes)
  List<Track> get allTracks => _tracks;

  // LOGIC FIX: 'ongoing' now includes both 'Not Set' and 'In Process'
  // It only hides a track if it is officially Done.
  List<Track> get ongoingTracks => 
      _tracks.where((t) => !t.isDone).toList();

  // Show only finished/expired tracks
  List<Track> get expiredTracks => 
      _tracks.where((t) => t.isDone).take(10).toList();

  // Dashboard shows top 3 that actually have a schedule set
  List<Track> get dashboardTracks => 
      _tracks.where((t) => !t.isDone && t.startDate != null).take(3).toList();


  // --- INITIALIZATION ---

  Future<void> init() async {
    final rawData = await _storage.loadTracks();
    _tracks = rawData.map((item) => Track.fromJson(item)).toList();
    notifyListeners();
  }


  // --- CORE ACTIONS ---

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

  // 2. SET RANGE: From SetupRangePage
  Future<void> setSchedule(String id, DateTime start, DateTime end) async {
    var index = _tracks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    // 1. Set the dates
    _tracks[index].startDate = start;
    _tracks[index].endDate = end;

    // 2. BUILD THE DATA FIRST (Critical)
    _tracks[index].dailyProgress.clear();
    int daysInRange = end.difference(start).inDays;
    
    for (int i = 0; i <= daysInRange; i++) {
      String dateKey = DateFormat('yyyy-MM-dd').format(start.add(Duration(days: i)));
      _tracks[index].dailyProgress[dateKey] = DayStatus.notSet;
    }

    // 3. NOW NOTIFY THE UI
    notifyListeners();

    // 4. SAVE AND SCHEDULE NOTIFICATIONS
    try {
      await _saveAll(_tracks[index]);
      await NotificationService.scheduleExpirationAlert(id, _tracks[index].name, end);
    } catch (e) {
      print("Notification or Save Error: $e");
      // App keeps running even if notification fails
    }
  }

  // 3. UPDATE DAY STATUS: From TrackDetailPage
  Future<void> updateDayStatus(String trackId, String dateKey, DayStatus status) async {
    int index = _tracks.indexWhere((t) => t.id == trackId);
    if (index == -1) return;

    _tracks[index].dailyProgress[dateKey] = status;
    notifyListeners(); 
    await _saveAll(_tracks[index]);
  }

  // 4. DELETE
  Future<void> deleteTrack(String id) async {
    _tracks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _storage.saveTracks(_tracks.map((t) => t.toJson()).toList());
    await _firebase.removeTrack(id);
  }

  // 5. RENAME & CHECK TEXT
  Future<void> renameTrack(String id, String newName) async {
    int index = _tracks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tracks[index].name = newName;
      notifyListeners();
      await _saveAll(_tracks[index]);
    }
  }

  Future<void> updateCheckText(String id, String text) async {
    int index = _tracks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tracks[index].checkText = text;
      notifyListeners();
      await _saveAll(_tracks[index]);
    }
  }

  // 6. NOTIFICATION FREQUENCY
  Future<void> updateFrequency(String id, String freq) async {
    int index = _tracks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tracks[index].reminderFrequency = freq;
      notifyListeners();
      await _saveAll(_tracks[index]);
      await NotificationService.scheduleNotification(id, _tracks[index].name, freq);
    }
  }


  // --- DATABASE SYNC ---

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
      print("Sync Error: $e");
    }
  }

  Future<void> clearData() async {
    _tracks = [];
    notifyListeners();
    await _storage.saveTracks([]); 
  }
}