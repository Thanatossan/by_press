import 'dart:ffi';

final String tableWeightTest = 'weightTest';
//todo
//fix to save left right total timestamp
class WeightTestFields {
  static final List<String> values = [
    /// Add all fields
    id, userId, time, first, second, third
  ];

  static final String id = '_id';
  static final String userId = 'userId';
  static final String time = 'time';
  static final String first = 'first';
  static final String second = 'second';
  static final String third = 'third';
}

class WeightTest {
  final int? id;
  final int? userId;
  final DateTime time;
  final double first;
  final double second;
  final double third;

  const WeightTest({
    this.id,
    required this.userId,
    required this.time,
    required this.first,
    required this.second,
    required this.third
  });

  WeightTest copy({
    int? id,
    int? userId,
    DateTime? time,
    double? first,
    double? second,
    double? third
  }) =>
      WeightTest(
          id: id ?? this.id,
          userId: userId ?? this.userId,
          time: time ?? this.time,
          first: first ?? this.first,
          second: second ?? this.second,
          third: third ?? this.third
      );

  static WeightTest fromJson(Map<String, Object?> json) => WeightTest(
    id: json[WeightTestFields.id] as int?,
    userId: json[WeightTestFields.userId] as int?,
    time: DateTime.parse(json[WeightTestFields.time] as String),
      first: json[WeightTestFields.first] as double,
      second: json[WeightTestFields.second] as double,
      third: json[WeightTestFields.third] as double
  );

  Map<String, Object?> toJson() => {
    WeightTestFields.id: id,
    WeightTestFields.userId: userId,
    WeightTestFields.time: time.toIso8601String(),
    WeightTestFields.first: first,
    WeightTestFields.second:second,
    WeightTestFields.third:third
  };
}
