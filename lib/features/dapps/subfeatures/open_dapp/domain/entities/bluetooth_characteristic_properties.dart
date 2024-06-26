import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothCharacteristicProperties extends Equatable {
  final bool broadcast;
  final bool read;
  final bool writeWithoutResponse;
  final bool write;
  final bool notify;
  final bool indicate;
  final bool authenticatedSignedWrites;
  final bool reliableWrite;
  final bool writableAuxiliaries;

  const BluetoothCharacteristicProperties({
    required this.broadcast,
    required this.read,
    required this.writeWithoutResponse,
    required this.write,
    required this.notify,
    required this.indicate,
    required this.authenticatedSignedWrites,
    required this.reliableWrite,
    required this.writableAuxiliaries,
  });

  factory BluetoothCharacteristicProperties.fromCharacteristicProperties(
          CharacteristicProperties source) =>
      BluetoothCharacteristicProperties(
        authenticatedSignedWrites: source.authenticatedSignedWrites,
        broadcast: source.broadcast,
        indicate: source.indicate,
        notify: source.notify,
        read: source.read,
        reliableWrite: source.write,
        writableAuxiliaries: source.write,
        write: source.write,
        writeWithoutResponse: source.writeWithoutResponse,
      );

  factory BluetoothCharacteristicProperties.fromJson(String source) =>
      BluetoothCharacteristicProperties.fromMap(json.decode(source));

  factory BluetoothCharacteristicProperties.fromMap(Map<String, dynamic> json) {
    return BluetoothCharacteristicProperties(
      broadcast: json['broadcast'],
      read: json['read'],
      writeWithoutResponse: json['writeWithoutResponse'],
      write: json['write'],
      notify: json['notify'],
      indicate: json['indicate'],
      authenticatedSignedWrites: json['authenticatedSignedWrites'],
      reliableWrite: json['reliableWrite'],
      writableAuxiliaries: json['writableAuxiliaries'],
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'broadcast': broadcast,
      'read': read,
      'writeWithoutResponse': writeWithoutResponse,
      'write': write,
      'notify': notify,
      'indicate': indicate,
      'authenticatedSignedWrites': authenticatedSignedWrites,
      'reliableWrite': reliableWrite,
      'writableAuxiliaries': writableAuxiliaries,
    };
  }

  @override
  List<Object?> get props => [
        broadcast,
        read,
        writeWithoutResponse,
        write,
        notify,
        indicate,
        authenticatedSignedWrites,
        reliableWrite,
        writableAuxiliaries
      ];

  @override
  String toString() {
    return 'BluetoothCharacteristicProperties(broadcast: $broadcast, read: $read, writeWithoutResponse: $writeWithoutResponse, write: $write, notify: $notify, indicate: $indicate, authenticatedSignedWrites: $authenticatedSignedWrites, reliableWrite: $reliableWrite, writableAuxiliaries: $writableAuxiliaries)';
  }

  BluetoothCharacteristicProperties copyWith({
    bool? broadcast,
    bool? read,
    bool? writeWithoutResponse,
    bool? write,
    bool? notify,
    bool? indicate,
    bool? authenticatedSignedWrites,
    bool? reliableWrite,
    bool? writableAuxiliaries,
  }) {
    return BluetoothCharacteristicProperties(
      broadcast: broadcast ?? this.broadcast,
      read: read ?? this.read,
      writeWithoutResponse: writeWithoutResponse ?? this.writeWithoutResponse,
      write: write ?? this.write,
      notify: notify ?? this.notify,
      indicate: indicate ?? this.indicate,
      authenticatedSignedWrites:
          authenticatedSignedWrites ?? this.authenticatedSignedWrites,
      reliableWrite: reliableWrite ?? this.reliableWrite,
      writableAuxiliaries: writableAuxiliaries ?? this.writableAuxiliaries,
    );
  }
}
