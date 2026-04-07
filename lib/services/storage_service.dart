import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _key = 'user_tracks';

  Future<void> saveTracks(List<Map<String, dynamic>> tracks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String jsonString = jsonEncode(tracks);
      await prefs.setString(_key, jsonString);
    } catch (e) {
      print("Storage Save Error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> loadTracks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_key);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        // RELEASE FIX: Try-catch jsonDecode to prevent startup crashes
        final dynamic decoded = jsonDecode(jsonString);
        if (decoded is List) {
          return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }
      }
    } catch (e) {
      print("Storage Load Error: $e");
      return []; 
    }
    return []; 
  }
}