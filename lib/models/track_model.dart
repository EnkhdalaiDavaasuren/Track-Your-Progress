
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
    this.reminderFrequency = "everyday",
    required this.dailyProgress,
  });

  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);

  bool get isFullyCompleted {
    if (dailyProgress.isEmpty) return false;
    return !dailyProgress.values.contains(DayStatus.notSet);
  }

  // Convert Track to JSON for Storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'checkText': checkText,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'reminderFrequency': reminderFrequency,
    'dailyProgress': dailyProgress.map((key, value) => MapEntry(key, value.index)),
  };

  // Create Track from JSON
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      checkText: json['checkText'] ?? "",
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      reminderFrequency: json['reminderFrequency'] ?? "everyday",
      dailyProgress: (json['dailyProgress'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, DayStatus.values[value as int]),
      ),
    );
  }
}