import 'dart:convert';

class StepsData {
  int id;
  int step;
  int kcal;
  int km;
  int date;
  StepsData({
    required this.id,
    required this.step,
    required this.kcal,
    required this.km,
    required this.date,
  });

  StepsData copyWith({
    int? id,
    int? step,
    int? kcal,
    int? km,
    int? date,
  }) {
    return StepsData(
      id: id ?? this.id,
      step: step ?? this.step,
      kcal: kcal ?? this.kcal,
      km: km ?? this.km,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'step': step,
      'kcal': kcal,
      'km': km,
      'date': date,
    };
  }

  factory StepsData.fromMap(Map<String, dynamic> map) {
    return StepsData(
      id: map['id']?.toInt() ?? 0,
      step: map['step']?.toInt() ?? 0,
      kcal: map['kcal']?.toInt() ?? 0,
      km: map['km']?.toInt() ?? 0,
      date: map['date']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory StepsData.fromJson(String source) =>
      StepsData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StepsData(id: $id, step: $step, kcal: $kcal, km: $km, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StepsData &&
        other.id == id &&
        other.step == step &&
        other.kcal == kcal &&
        other.km == km &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        step.hashCode ^
        kcal.hashCode ^
        km.hashCode ^
        date.hashCode;
  }
}
