class SleepEntry {
  final DateTime bedTime;
  final DateTime wakeTime;
  final double hours;
  final int quality; // 1 to 5 stars

  SleepEntry({
    required this.bedTime,
    required this.wakeTime,
    required this.hours,
    required this.quality,
  });

  Map<String, dynamic> toJson() => {
        'bedTime': bedTime.toIso8601String(),
        'wakeTime': wakeTime.toIso8601String(),
        'hours': hours,
        'quality': quality,
      };

  factory SleepEntry.fromJson(Map<String, dynamic> json) => SleepEntry(
        bedTime: DateTime.parse(json['bedTime']),
        wakeTime: DateTime.parse(json['wakeTime']),
        hours: json['hours'],
        quality: json['quality'],
      );
}
