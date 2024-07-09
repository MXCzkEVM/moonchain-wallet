import 'dart:convert';

class PeriodicSleepData {
  int date;
  int value;
  PeriodicSleepData({
    required this.date,
    required this.value,
  });

  PeriodicSleepData copyWith({
    int? date,
    int? value,
  }) {
    return PeriodicSleepData(
      date: date ?? this.date,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'value': value,
    };
  }

  factory PeriodicSleepData.fromMap(Map<String, dynamic> map) {
    return PeriodicSleepData(
      date: map['date']?.toInt() ?? 0,
      value: map['value']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory PeriodicSleepData.fromJson(String source) =>
      PeriodicSleepData.fromMap(json.decode(source));

  @override
  String toString() => 'PeriodicSleepData(date: $date, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PeriodicSleepData &&
        other.date == date &&
        other.value == value;
  }

  @override
  int get hashCode => date.hashCode ^ value.hashCode;
}
