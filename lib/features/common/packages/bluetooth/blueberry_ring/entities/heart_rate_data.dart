import 'dart:convert';

class HeartRateData {
  int id;
  int value;
  int date;
  HeartRateData({
    required this.id,
    required this.value,
    required this.date,
  });

  HeartRateData copyWith({
    int? id,
    int? value,
    int? date,
  }) {
    return HeartRateData(
      id: id ?? this.id,
      value: value ?? this.value,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'date': date,
    };
  }

  factory HeartRateData.fromMap(Map<String, dynamic> map) {
    return HeartRateData(
      id: map['id']?.toInt() ?? 0,
      value: map['value']?.toInt() ?? 0,
      date: map['date']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory HeartRateData.fromJson(String source) =>
      HeartRateData.fromMap(json.decode(source));

  @override
  String toString() => 'HeartRateData(id: $id, value: $value, date: $date)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HeartRateData &&
        other.id == id &&
        other.value == value &&
        other.date == date;
  }

  @override
  int get hashCode => id.hashCode ^ value.hashCode ^ date.hashCode;
}
