import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_app/services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/track_model.dart';
import 'storage_service.dart';
import 'firebase_service.dart';

class TrackManager extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final StorageService _storage = StorageService();
  List<Track> _tracks = [];

  // GETTERS
  List<Track> get allTracks => _tracks;
  List<Track> get ongoingTracks => _tracks.where((t) => !t.isDone).toList();
  List<Track> get expiredTracks => _tracks.where((t) => t.isDone).take(10).toList();
  List<Track> get dashboardTracks => _tracks.where((t) => !t.isDone && t.startDate != null).take(3).toList();

  Future<void> init() async {
    final rawData = await _storage.loadTracks();
    _tracks = rawData.map((item) => Track.fromJson(item)).toList();
    notifyListeners();
  }

  Future<void> addTrack(String name) async {
    final newTrack = Track(id: const Uuid().v4(), name: name, dailyProgress: {});
    _tracks.insert(0, newTrack);
    notifyListeners();
    await _saveAll(newTrack);
  }

  Future<void> setSchedule(String id, DateTime start, DateTime end) async {
    var index = _tracks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tracks[index].startDate = start;
    _tracks[index].endDate = end;

    _tracks[index].dailyProgress.clear();
    notifyListeners();
    await _saveAll(_tracks[index]);

    await NotificationService.scheduleExpirationAlert(
    id, 
    _tracks[index].name, 
    end
    );

    int daysInRange = end.difference(start).inDays;
    for (int i = 0; i <= daysInRange; i++) {
      String dateKey = DateFormat('yyyy-MM-dd').format(start.add(Duration(days: i)));
      _tracks[index].dailyProgress[dateKey] = DayStatus.notSet;
    }
    notifyListeners();
    await _saveAll(_tracks[index]);
  }

  Future<void> updateDayStatus(String trackId, String dateKey, DayStatus status) async {
    int index = _tracks.indexWhere((t) => t.id == trackId);
    if (index == -1) return;
    _tracks[index].dailyProgress[dateKey] = status;
    notifyListeners();
    await _saveAll(_tracks[index]);
  }

  Future<void> deleteTrack(String id) async {
    _tracks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _storage.saveTracks(_tracks.map((t) => t.toJson()).toList());
    await _firebase.removeTrack(id);

    int dailyId = id.hashCode.abs();
    int expiryId = id.hashCode.abs() + 1000;
  
    final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
    await _notifications.cancel(dailyId);
    await _notifications.cancel(expiryId);
  }

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
    } catch (e) { print(e); }
  }

  Future<void> clearData() async {
    _tracks = [];
    notifyListeners();
    await _storage.saveTracks([]);
  }

  // Inside TrackManager class
  Future<void> updateFrequency(String id, String newFrequency) async {
  int index = _tracks.indexWhere((t) => t.id == id);
  if (index != -1) {
    _tracks[index].reminderFrequency = newFrequency;
    notifyListeners();
    
    // Save to Disk and Cloud
    await _storage.saveTracks(_tracks.map((t) => t.toJson()).toList());
    await _firebase.syncTrack(_tracks[index]);

    // This is where you would call your NotificationService.schedule logic later!
  }
}
}