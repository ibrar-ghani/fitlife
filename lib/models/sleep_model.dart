class SleepEntry {
  final String id;
  final DateTime bedTime;
  final DateTime wakeTime;
  final int quality;

  SleepEntry({
    required this.id,
    required this.bedTime,
    required this.wakeTime,
    required this.quality,
  });

  double get hours => wakeTime.difference(bedTime).inMinutes / 60.0;

  factory SleepEntry.fromMap(Map<String, dynamic> map, String id) {
    return SleepEntry(
      id: id,
      bedTime: DateTime.parse(map['bedTime']),
      wakeTime: DateTime.parse(map['wakeTime']),
      quality: map['quality'] ?? 3,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'quality': quality,
    };
  }
}
