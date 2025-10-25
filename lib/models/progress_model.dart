class ProgressModel {
  final double weight;
  final DateTime date;

  ProgressModel({required this.weight, required this.date});

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'date': date.toIso8601String(),
      };

  factory ProgressModel.fromJson(Map<String, dynamic> json) => ProgressModel(
        weight: json['weight'],
        date: DateTime.parse(json['date']),
      );
}
