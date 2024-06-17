import 'dart:convert';
import 'package:equatable/equatable.dart';

import 'bluetooth_device.dart';

class BluetoothAdvertisingEvent extends Equatable {
  final BluetoothDevice device;
  final List<String> uuids;
  final Map<String, dynamic> manufacturerData;
  final Map<String, dynamic> serviceData;
  final String? name;
  final int? appearance;
  final int? rssi;
  final int? txPower;

  const BluetoothAdvertisingEvent({
    required this.device,
    required this.uuids,
    required this.manufacturerData,
    required this.serviceData,
    this.name,
    this.appearance,
    this.rssi,
    this.txPower,
  });

  factory BluetoothAdvertisingEvent.fromJson(String source) =>
      BluetoothAdvertisingEvent.fromMap(json.decode(source));

  factory BluetoothAdvertisingEvent.fromMap(Map<String, dynamic> json) {
    return BluetoothAdvertisingEvent(
      device: BluetoothDevice.fromMap(json['device']),
      uuids: List<String>.from(json['uuids']),
      manufacturerData: Map<String, dynamic>.from(json['manufacturerData']),
      serviceData: Map<String, dynamic>.from(json['serviceData']),
      name: json['name'],
      appearance: json['appearance'],
      rssi: json['rssi'],
      txPower: json['txPower'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device': device.toJson(),
      'uuids': uuids,
      'manufacturerData': manufacturerData,
      'serviceData': serviceData,
      'name': name,
      'appearance': appearance,
      'rssi': rssi,
      'txPower': txPower,
    };
  }

  @override
  List<Object?> get props => [
        device,
        uuids,
        manufacturerData,
        serviceData,
        name,
        appearance,
        rssi,
        txPower
      ];

  @override
  String toString() {
    return 'BluetoothAdvertisingEvent(device: $device, uuids: $uuids, manufacturerData: $manufacturerData, serviceData: $serviceData, name: $name, appearance: $appearance, rssi: $rssi, txPower: $txPower)';
  }

  BluetoothAdvertisingEvent copyWith({
    BluetoothDevice? device,
    List<String>? uuids,
    Map<String, dynamic>? manufacturerData,
    Map<String, dynamic>? serviceData,
    String? name,
    int? appearance,
    int? rssi,
    int? txPower,
  }) {
    return BluetoothAdvertisingEvent(
      device: device ?? this.device,
      uuids: uuids ?? this.uuids,
      manufacturerData: manufacturerData ?? this.manufacturerData,
      serviceData: serviceData ?? this.serviceData,
      name: name ?? this.name,
      appearance: appearance ?? this.appearance,
      rssi: rssi ?? this.rssi,
      txPower: txPower ?? this.txPower,
    );
  }
}
