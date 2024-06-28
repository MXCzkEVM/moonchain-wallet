import 'dart:convert';

class BloodOxygensData {
  int id;
  int value;
  int date;
  BloodOxygensData({
    required this.id,
    required this.value,
    required this.date,
  });

  BloodOxygensData copyWith({
    int? id,
    int? value,
    int? date,
  }) {
    return BloodOxygensData(
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

  factory BloodOxygensData.fromMap(Map<String, dynamic> map) {
    return BloodOxygensData(
      id: map['id']?.toInt() ?? 0,
      value: map['value']?.toInt() ?? 0,
      date: map['date']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory BloodOxygensData.fromJson(String source) =>
      BloodOxygensData.fromMap(json.decode(source));

  @override
  String toString() => 'BloodOxygensData(id: $id, value: $value, date: $date)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BloodOxygensData &&
        other.id == id &&
        other.value == value &&
        other.date == date;
  }

  @override
  int get hashCode => id.hashCode ^ value.hashCode ^ date.hashCode;
}
