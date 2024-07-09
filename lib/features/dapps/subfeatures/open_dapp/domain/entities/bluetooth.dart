import 'dart:convert';
import 'package:equatable/equatable.dart';

import 'bluetooth_device.dart';

class Bluetooth extends Equatable {
  final BluetoothDevice? referringDevice;

  const Bluetooth({this.referringDevice});

  @override
  List<Object?> get props => [referringDevice];

  factory Bluetooth.fromMap(Map<String, dynamic> map) {
    return Bluetooth(
      referringDevice: map['referringDevice'] != null
          ? BluetoothDevice.fromMap(map['referringDevice'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'referringDevice': referringDevice?.toMap(),
      'getDevices': '''
        (async function() {
          var response = await window.axs.callHandler('Bluetooth.getDevices');
          return response;
        })()
      ''',
      'getAvailability': '''
        (async function() {
          var response = await window.axs.callHandler('Bluetooth.getAvailability');
          return response;
        })()
      ''',
      'requestDevice': '''
        (async function() {
          var response = await window.axs.callHandler('Bluetooth.requestDevice');
          return response;
        })()
      ''',
      'requestLEScan': '''
        (async function() {
          var response = await window.axs.callHandler('Bluetooth.requestLEScan');
          return response;
        })()
      '''
    };
  }

  factory Bluetooth.fromJson(String source) =>
      Bluetooth.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  Bluetooth copyWith({
    BluetoothDevice? referringDevice,
  }) {
    return Bluetooth(
      referringDevice: referringDevice ?? this.referringDevice,
    );
  }

  @override
  String toString() {
    return 'Bluetooth(referringDevice: $referringDevice)';
  }
}
