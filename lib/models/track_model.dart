enum DayStatus { notSet, no, yes }
int? reminderHour;


class Track {
  String id;
  String name;
  String checkText;
  DateTime? startDate;
  DateTime? endDate;
  String reminderFrequency;
  Map<String, DayStatus> dailyProgress;
  int? reminderHour;
  int? reminderMinute;

  Track({
    required this.id,
    required this.name,
    this.checkText = "",
    this.startDate,
    this.endDate,
    this.reminderHour,
    this.reminderMinute,
    this.reminderFrequency = "None",
    required this.dailyProgress,
  });

  bool get isDone => isExpired || isFullyCompleted;

  bool get isExpired {
    if (endDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return today.isAfter(end);
  }

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
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'reminderFrequency': reminderFrequency,
      'dailyProgress': dailyProgress.map((k, v) => MapEntry(k, v.index)),
    };
  }

  factory Track.fromJson(Map<String, dynamic> map) {
    return Track(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unnamed',
      checkText: map['checkText'] ?? "",
      startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
      reminderHour: map['reminderHour'],
      reminderMinute: map['reminderMinute'],
      reminderFrequency: map['reminderFrequency'] ?? "None",
      dailyProgress: (map['dailyProgress'] as Map? ?? {}).map(
        (k, v) {
          // RELEASE FIX: Cast to num first, then int, to prevent Double vs Int crashes
          int index = (v as num).toInt();
          if (index < 0 || index >= DayStatus.values.length) index = 0;
          return MapEntry(k.toString(), DayStatus.values[index]);
        },
      ),
    );
  }
}