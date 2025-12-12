class SleepEntry {
  final String id; // Firestore document ID
  final DateTime bedTime;
  final DateTime wakeTime;
  final int quality;

  SleepEntry({
    required this.id,
    required this.bedTime,
    required this.wakeTime,
    required this.quality,
  });

  double get hours => wakeTime.difference(bedTime).inMinutes / 60;

  Map<String, dynamic> toMap() => {
        'bedTime': bedTime.toIso8601String(),
        'wakeTime': wakeTime.toIso8601String(),
        'quality': quality,
      };

  factory SleepEntry.fromMap(Map<String, dynamic> map, String docId) => SleepEntry(
        id: docId,
        bedTime: DateTime.parse(map['bedTime']),
        wakeTime: DateTime.parse(map['wakeTime']),
        quality: map['quality'] ?? 3,
      );
}