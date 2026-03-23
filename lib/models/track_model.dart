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

  // LOGIC: A track is DONE if time ran out OR if all circles are filled
  bool get isDone => isExpired || isFullyCompleted;

  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);

  bool get isFullyCompleted {
    if (dailyProgress.isEmpty) return false;
    return !dailyProgress.values.contains(DayStatus.notSet);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'checkText': checkText,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminderFrequency': reminderFrequency,
      'dailyProgress': dailyProgress.map((key, value) => MapEntry(key, value.index)),
    };
  }

  factory Track.fromJson(Map<String, dynamic> map) {
    return Track(
      id: map['id'],
      name: map['name'],
      checkText: map['checkText'] ?? "",
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      reminderFrequency: map['reminderFrequency'] ?? "everyday",
      dailyProgress: (map['dailyProgress'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, DayStatus.values[value as int]),
      ),
    );
  }
}