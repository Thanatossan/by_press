import 'dart:ffi';

final String tableUser = 'user';

class UserFields {
  static final List<String> values = [
    /// Add all fields
    id, name, surname , gender, age , weight , bmi , surgery ,createAt
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String surname = 'surname';
  static final String gender = 'gender';
  static final String age = 'age';
  static final String weight = 'weight';
  static final String bmi = 'bmi';
  static final String surgery = 'surgery';
  static final String createAt = 'createAt';
}

class User {
  final int? id;
  final String name;
  final String surname;
  final String gender;
  final int age;
  final double weight;
  final double bmi;
  final String surgery;
  final DateTime createAt;

  const User({
    this.id,
    required this.name,
    required this.surname,
    required this.gender,
    required this.age,
    required this.weight,
    required this.bmi,
    required this.surgery,
    required this.createAt,
  });

  User copy({
    int? id,
    String? name,
    String? surname,
    String? gender,
    int? age,
    double? weight,
    double? bmi,
    String? surgery,
    DateTime? createAt,

  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        surname: surname ?? this.surname,
        gender : gender ?? this.gender,
        age: age?? this.age,
        weight : weight ?? this.weight,
        bmi : bmi ?? this.bmi,
        surgery : surgery ?? this.surgery,
        createAt: createAt ?? this.createAt,

      );

  static User fromJson(Map<String, Object?> json) => User(
    id: json[UserFields.id] as int?,
    name: json[UserFields.name] as String,
    surname: json[UserFields.surname] as String,
    gender: json[UserFields.gender] as String,
    age: json[UserFields.age] as int,
    weight: json[UserFields.weight] as double,
    bmi: json[UserFields.bmi] as double,
    surgery: json[UserFields.surgery] as String,
    createAt: DateTime.parse(json[UserFields.createAt] as String),

  );

  Map<String, Object?> toJson() => {
    UserFields.id: id,
    UserFields.name: name,
    UserFields.surname: surname,
    UserFields.gender : gender,
    UserFields.age : age,
    UserFields.weight :weight,
    UserFields.bmi : bmi,
    UserFields.surgery : surgery,
    UserFields.createAt: createAt.toIso8601String(),

  };
}
