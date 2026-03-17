import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/track_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Get current user ID
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? "unknown";

  // SAVE/UPDATE
  Future<void> syncTrack(Track track) async {
    // FIXED: Changed toMap() to toJson()
    await _db.collection('users').doc(uid).collection('tracks').doc(track.id).set(track.toJson());
  }

  // DELETE
  Future<void> removeTrack(String trackId) async {
    await _db.collection('users').doc(uid).collection('tracks').doc(trackId).delete();
  }

  // FETCH ALL FROM CLOUD
  Future<List<Track>> fetchTracks() async {
    final snapshot = await _db.collection('users').doc(uid).collection('tracks').get();
    
    // FIXED: Changed fromMap to fromJson
    return snapshot.docs.map((doc) => Track.fromJson(doc.data())).toList();
  }
}