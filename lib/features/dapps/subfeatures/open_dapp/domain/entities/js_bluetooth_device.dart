import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class JSBluetoothDevice {
  static JSBluetoothDevice getJSBluetoothDeviceFromScanResult(ScanResult scanResult) {
    final id = scanResult.device.remoteId;
    final name = scanResult.device.platformName;

    return JSBluetoothDevice(
        id: id.str, name: name, watchingAdvertisements: true);
  }

  final String id;
  final String? name;
  final BluetoothRemoteGATTServer? gatt;
  final bool watchingAdvertisements;

  final StreamController<String> _gattServerDisconnectedController =
      StreamController<String>.broadcast();
  final StreamController<BluetoothAdvertisingEvent>
      _advertisementReceivedController =
      StreamController<BluetoothAdvertisingEvent>.broadcast();

  Stream<String> get onGattServerDisconnected =>
      _gattServerDisconnectedController.stream;
  Stream<BluetoothAdvertisingEvent> get onAdvertisementReceived =>
      _advertisementReceivedController.stream;

  JSBluetoothDevice({
    required this.id,
    this.name,
    this.gatt,
    required this.watchingAdvertisements,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gatt': gatt?.toJson(),
      'watchingAdvertisements': watchingAdvertisements,
      // Methods defined by the interface
      'forget': '''function() {
        return new Promise((resolve, reject) => {
            // Implementation to forget the device
            resolve();
        });
    }''',
      //   'watchAdvertisements': '''function(options) {
      //     return new Promise((resolve, reject) => {
      //         // Implementation to watch advertisements with the provided options
      //         resolve();
      //     });
      // }''',

      //   // Methods to add event listeners
      //   'addEventListener': '''function(type, listener, useCapture) {
      //     // Implementation to add event listeners
      // }''',

      //   // Specific event listener methods
      //   'addEventListener': '''function(type, listener, useCapture) {
      //     if (type === "gattserverdisconnected") {
      //         // Implementation for gattserverdisconnected
      //     } else if (type === "advertisementreceived") {
      //         // Implementation for advertisementreceived
      //     } else {
      //         // General event listener implementation
      //     }
      // }'''
    };
  }

  void dispatchEvent(String type, dynamic event) {
    if (type == 'gattserverdisconnected') {
      _gattServerDisconnectedController.add(event);
    } else if (type == 'advertisementreceived') {
      _advertisementReceivedController.add(event);
    }
  }
}

class BluetoothRemoteGATTServer {
  final JSBluetoothDevice device;
  final bool connected;

  BluetoothRemoteGATTServer({
    required this.device,
    required this.connected,
  });

  Map<String, dynamic> toJson() {
    return {
      'device': device.toJson(),
      'connected': connected,
    };
  }
}

class BluetoothAdvertisingEvent {
  final JSBluetoothDevice device;
  final List<String> uuids;
  final Map<String, Uint8List> manufacturerData;
  final Map<String, Uint8List> serviceData;
  final String? name;
  final int? appearance;
  final int? rssi;
  final int? txPower;

  BluetoothAdvertisingEvent({
    required this.device,
    required this.uuids,
    required this.manufacturerData,
    required this.serviceData,
    this.name,
    this.appearance,
    this.rssi,
    this.txPower,
  });

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
}
