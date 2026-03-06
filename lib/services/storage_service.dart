import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _key = 'user_tracks';

  // Save the list of tracks to the phone's memory
  Future<void> saveTracks(List<Map<String, dynamic>> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(tracks);
    await prefs.setString(_key, jsonString);
  }

  // Load the list from the phone's memory
  Future<List<Map<String, dynamic>>> loadTracks() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_key);
    
    if (jsonString != null) {
      List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return []; // Return empty list if nothing saved yet
  }
}