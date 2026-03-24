enum DayStatus { notSet, no, yes }

class Track {
  String id;
  String name;
  String checkText;
  DateTime? startDate;
  DateTime? endDate;
  String reminderFrequency;
  Map<String, DayStatus> dailyProgress;

  Track({
    required this.id,
    required this.name,
    this.checkText = "",
    this.startDate,
    this.endDate,
    this.reminderFrequency = "None",
    required this.dailyProgress,
  });

  // LOGIC FIX: A track is only 'Done' if it expired or is 100% filled
  bool get isDone => isExpired || isFullyCompleted;

  bool get isExpired {
    if (endDate == null) return false;
    
    // Normalize to compare only Year, Month, and Day
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    
    // It is only expired if Today is strictly AFTER the End Date
    return today.isAfter(end);
  }

  bool get isFullyCompleted {
    // If no range is set yet, it is definitely NOT completed
    if (dailyProgress.isEmpty) return false;
    
    // It is only fully completed if there are ZERO 'notSet' (Grey) items left
    return !dailyProgress.values.contains(DayStatus.notSet);
  }

  // --- DATABASE MAPPING ---

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'checkText': checkText,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminderFrequency': reminderFrequency,
      // Converts Enum to Index (0, 1, 2) for Database
      'dailyProgress': dailyProgress.map((k, v) => MapEntry(k, v.index)),
    };
  }

  factory Track.fromJson(Map<String, dynamic> map) {
    return Track(
      id: map['id'],
      name: map['name'],
      checkText: map['checkText'] ?? "",
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      reminderFrequency: map['reminderFrequency'] ?? "None",
      dailyProgress: (map['dailyProgress'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, DayStatus.values[v as int]),
      ),
    );
  }
}