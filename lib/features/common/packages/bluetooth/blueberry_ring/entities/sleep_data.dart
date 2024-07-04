import 'dart:convert';

import 'package:flutter/foundation.dart';

class SleepData {
  int id;
  List<int> sleeps;
  int length;
  int date;
  SleepData({
    required this.id,
    required this.sleeps,
    required this.length,
    required this.date,
  });

  SleepData copyWith({
    int? id,
    List<int>? sleeps,
    int? length,
    int? date,
  }) {
    return SleepData(
      id: id ?? this.id,
      sleeps: sleeps ?? this.sleeps,
      length: length ?? this.length,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sleeps': sleeps,
      'length': length,
      'date': date,
    };
  }

  factory SleepData.fromMap(Map<String, dynamic> map) {
    return SleepData(
      id: map['id']?.toInt() ?? 0,
      sleeps: List<int>.from(map['sleeps']),
      length: map['length']?.toInt() ?? 0,
      date: map['date']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory SleepData.fromJson(String source) =>
      SleepData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SleepData(id: $id, sleeps: $sleeps, length: $length, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SleepData &&
        other.id == id &&
        listEquals(other.sleeps, sleeps) &&
        other.length == length &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^ sleeps.hashCode ^ length.hashCode ^ date.hashCode;
  }
}
