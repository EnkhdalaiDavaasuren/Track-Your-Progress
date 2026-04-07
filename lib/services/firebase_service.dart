import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/track_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> syncTrack(Track track) async {
    final currentUid = uid;
    if (currentUid == null) return;
    try {
      await _db.collection('users').doc(currentUid).collection('tracks').doc(track.id).set(track.toJson());
    } catch (e) {
      print("Firestore Sync Error: $e");
    }
  }

  Future<void> removeTrack(String trackId) async {
    final currentUid = uid;
    if (currentUid == null) return;
    await _db.collection('users').doc(currentUid).collection('tracks').doc(trackId).delete();
  }

  Future<List<Track>> fetchTracks() async {
    final currentUid = uid;
    if (currentUid == null) return [];

    try {
      final snapshot = await _db.collection('users').doc(currentUid).collection('tracks').get();
      List<Track> tracks = [];
      for (var doc in snapshot.docs) {
        try {
          // RELEASE FIX: Wrap individual track parsing to prevent one error from breaking the whole app
          tracks.add(Track.fromJson(doc.data()));
        } catch (e) {
          print("Skipping corrupted track ${doc.id}: $e");
        }
      }
      return tracks;
    } catch (e) {
      print("Firestore Fetch Error: $e");
      return [];
    }
  }
}