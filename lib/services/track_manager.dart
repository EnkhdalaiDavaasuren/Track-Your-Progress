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

  // --- GETTERS ---

  List<Track> get allTracks => _tracks;

  List<Track> get ongoingTracks => 
      _tracks.where((t) => !t.isDone).toList();

  List<Track> get expiredTracks => 
      _tracks.where((t) => t.isDone).take(10).toList();

  List<Track> get dashboardTracks => 
      _tracks.where((t) => !t.isDone && t.startDate != null).take(3).toList();


  // --- INITIALIZATION ---

  Future<void> init() async {
    final rawData = await _storage.loadTracks();
    _tracks = rawData.map((item) => Track.fromJson(item)).toList();
    notifyListeners();
  }


  // --- CORE ACTIONS ---

  // 1. ADD TRACK
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

  // 2. SET RANGE
  Future<void> setSchedule(String id, DateTime start, DateTime end) async {
    var index = _tracks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    _tracks[index].startDate = start;
    _tracks[index].endDate = end;

    _tracks[index].dailyProgress.clear();
    int daysInRange = end.difference(start).inDays;
    
    for (int i = 0; i <= daysInRange; i++) {
      String dateKey = DateFormat('yyyy-MM-dd').format(start.add(Duration(days: i)));
      _tracks[index].dailyProgress[dateKey] = DayStatus.notSet;
    }

    notifyListeners();

    try {
      await _saveAll(_tracks[index]);
      await NotificationService.scheduleExpirationAlert(id, _tracks[index].name, end);
    } catch (e) {
      debugPrint("Notification/Save Error: $e");
    }
  }

  // 3. UPDATE DAY STATUS
  Future<void> updateDayStatus(String trackId, String dateKey, DayStatus status) async {
    int index = _tracks.indexWhere((t) => t.id == trackId);
    if (index == -1) return;

    _tracks[index].dailyProgress[dateKey] = status;
    notifyListeners(); 
    await _saveAll(_tracks[index]);
  }

  // 4. --- THE NEW CLOCK LOGIC ---
  Future<void> updateReminderTime(String id, int hour, int minute) async {
    int index = _tracks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tracks[index].reminderHour = hour;
      _tracks[index].reminderMinute = minute;
      
      notifyListeners();
      await _saveAll(_tracks[index]);

      // Sets the repeating alarm for the specific time chosen
      await NotificationService.scheduleDailyTimeNotification(
        id, 
        _tracks[index].name, 
        hour, 
        minute
      );
    }
  }

  // 5. UPDATE FREQUENCY (Every week, None, etc.)
  Future<void> updateFrequency(String id, String freq) async {
    int index = _tracks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tracks[index].reminderFrequency = freq;
      notifyListeners();
      await _saveAll(_tracks[index]);
      await NotificationService.scheduleNotification(id, _tracks[index].name, freq);
    }
  }

  // 6. DELETE
  Future<void> deleteTrack(String id) async {
    _tracks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _storage.saveTracks(_tracks.map((t) => t.toJson()).toList());
    await _firebase.removeTrack(id);
    await NotificationService.cancelAllForTrack(id);
  }

  // 7. RENAME & CHECK TEXT
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


  // --- SYNC ---

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
      debugPrint("Sync Error: $e");
    }
  }

  Future<void> clearData() async {
    _tracks = [];
    notifyListeners();
    await _storage.saveTracks([]); 
  }
}