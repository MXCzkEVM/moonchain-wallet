import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'bluetooth_remove_gatt_server.dart';

class BluetoothDevice extends Equatable {
  final String id;
  final String? name;
  final BluetoothRemoteGATTServer? gatt;
  final bool watchingAdvertisements;

  const BluetoothDevice({
    required this.id,
    this.name,
    this.gatt,
    required this.watchingAdvertisements,
  });

  @override
  List<Object?> get props => [id, name, gatt, watchingAdvertisements];

  factory BluetoothDevice.getBluetoothDeviceFromScanResult(
      ScanResult scanResult) {
    final id = scanResult.device.remoteId;
    final name = scanResult.device.platformName;
    final isConnected = scanResult.device.isConnected;

    return BluetoothDevice(
        id: id.str,
        name: name,
        watchingAdvertisements: true,
        gatt: BluetoothRemoteGATTServer(
          connected: isConnected,
          device: BluetoothDevice(
            id: id.str,
            name: name,
            watchingAdvertisements: true,
          ),
        ));
  }

  factory BluetoothDevice.fromMap(Map<String, dynamic> map) {
    return BluetoothDevice(
      id: map['id'],
      name: map['name'],
      gatt: map['gatt'] != null
          ? BluetoothRemoteGATTServer.fromMap(map['gatt'])
          : null,
      watchingAdvertisements: map['watchingAdvertisements'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gatt': gatt?.toMap(),
      'watchingAdvertisements': watchingAdvertisements,
      // 'forget': '''
      //   (async function() {
      //     await window.axs.callHandler('BluetoothDevice.forget', { 'id': '$id' });
      //   })
      // ''',
      // 'watchAdvertisements': '''
      //   (async function() {
      //     await window.axs.callHandler('BluetoothDevice.watchAdvertisements', { 'id': '$id' });
      //   })
      // '''
    };
  }

  factory BluetoothDevice.fromJson(String source) =>
      BluetoothDevice.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  BluetoothDevice copyWith({
    String? id,
    String? name,
    BluetoothRemoteGATTServer? gatt,
    bool? watchingAdvertisements,
  }) {
    return BluetoothDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      gatt: gatt ?? this.gatt,
      watchingAdvertisements:
          watchingAdvertisements ?? this.watchingAdvertisements,
    );
  }

  @override
  String toString() {
    return 'BluetoothDevice(id: $id, name: $name, gatt: $gatt, watchingAdvertisements: $watchingAdvertisements)';
  }
}

// class BluetoothRemoteGATTServer extends Equatable {
//   final BluetoothDevice device;
//   final bool connected;

//   BluetoothRemoteGATTServer({
//     required this.device,
//     required this.connected,
//   });

//   @override
//   List<Object?> get props => [device, connected];

//   factory BluetoothRemoteGATTServer.fromMap(Map<String, dynamic> map) {
//     return BluetoothRemoteGATTServer(
//       device: BluetoothDevice.fromMap(map['device']),
//       connected: map['connected'],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'device': device.toMap(),
//       'connected': connected,
//       'connect': '''
//         (async function() {
//           var response = await window.axs.callHandler('BluetoothRemoteGATTServer.connect', { 'id': '${device.id}' });
//           return response;
//         })()
//       ''',
//       'disconnect': '''
//         (async function() {
//           await window.axs.callHandler('BluetoothRemoteGATTServer.disconnect', { 'id': '${device.id}' });
//         })()
//       ''',
//       'getPrimaryService': '''
//         (async function() {
//           var response = await window.axs.callHandler('BluetoothRemoteGATTServer.getPrimaryService', { 'service': '${device.id}' });
//           return response;
//         })()
//       ''',
//       'getPrimaryServices': '''
//         (async function() {
//           var response = await window.axs.callHandler('BluetoothRemoteGATTServer.getPrimaryServices', { 'service': '${device.id}' });
//           return response;
//         })()
//       '''
//     };
//   }

//   factory BluetoothRemoteGATTServer.fromJson(String source) => BluetoothRemoteGATTServer.fromMap(json.decode(source));

//   String toJson() => json.encode(toMap());

//   BluetoothRemoteGATTServer copyWith({
//     BluetoothDevice? device,
//     bool? connected,
//   }) {
//     return BluetoothRemoteGATTServer(
//       device: device ?? this.device,
//       connected: connected ?? this.connected,
//     );
//   }

//   @override
//   String toString() {
//     return 'BluetoothRemoteGATTServer(device: $device, connected: $connected)';
//   }
// }
