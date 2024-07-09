// import 'dart:async';
// import 'dart:typed_data';

// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// class JSBluetoothDevice {
//   static JSBluetoothDevice getJSBluetoothDeviceFromScanResult(
//       ScanResult scanResult) {
//     final id = scanResult.device.remoteId;
//     final name = scanResult.device.platformName;
//     final isConnected = scanResult.device.isConnected;

//     return JSBluetoothDevice(
//         id: id.str,
//         name: name,
//         watchingAdvertisements: true,
//         gatt: BluetoothRemoteGATTServer(
//           connected: isConnected,
//           device: JSBluetoothDevice(
//             id: id.str,
//             name: name,
//             watchingAdvertisements: true,
//           ),
//         ));
//   }

//   final String id;
//   final String? name;
//   final BluetoothRemoteGATTServer? gatt;
//   final bool watchingAdvertisements;

//   final StreamController<String> _gattServerDisconnectedController =
//       StreamController<String>.broadcast();
//   final StreamController<BluetoothAdvertisingEvent>
//       _advertisementReceivedController =
//       StreamController<BluetoothAdvertisingEvent>.broadcast();

//   Stream<String> get onGattServerDisconnected =>
//       _gattServerDisconnectedController.stream;
//   Stream<BluetoothAdvertisingEvent> get onAdvertisementReceived =>
//       _advertisementReceivedController.stream;

//   JSBluetoothDevice({
//     required this.id,
//     this.name,
//     this.gatt,
//     required this.watchingAdvertisements,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'gatt': gatt?.toJson(),
//       'watchingAdvertisements': watchingAdvertisements,
//       // Methods defined by the interface
//       'forget': '''function() {
//         return new Promise((resolve, reject) => {
//             // Implementation to forget the device
//             resolve();
//         });
//     }''',
//       //   'watchAdvertisements': '''function(options) {
//       //     return new Promise((resolve, reject) => {
//       //         // Implementation to watch advertisements with the provided options
//       //         resolve();
//       //     });
//       // }''',

//       //   // Methods to add event listeners
//       //   'addEventListener': '''function(type, listener, useCapture) {
//       //     // Implementation to add event listeners
//       // }''',

//       //   // Specific event listener methods
//       //   'addEventListener': '''function(type, listener, useCapture) {
//       //     if (type === "gattserverdisconnected") {
//       //         // Implementation for gattserverdisconnected
//       //     } else if (type === "advertisementreceived") {
//       //         // Implementation for advertisementreceived
//       //     } else {
//       //         // General event listener implementation
//       //     }
//       // }'''
//     };
//   }

//   void dispatchEvent(String type, dynamic event) {
//     if (type == 'gattserverdisconnected') {
//       _gattServerDisconnectedController.add(event);
//     } else if (type == 'advertisementreceived') {
//       _advertisementReceivedController.add(event);
//     }
//   }
// }

// class BluetoothRemoteGATTService {
//   final JSBluetoothDevice device;
//   final String uuid;
//   final bool isPrimary;

//   BluetoothRemoteGATTService({
//     required this.device,
//     required this.uuid,
//     required this.isPrimary,
//   });

//   // factory BluetoothRemoteGATTService.fromJson(Map<String, dynamic> json) {
//   //   return BluetoothRemoteGATTService(
//   //     device: BluetoothDevice.fromJson(json['device']),
//   //     uuid: json['uuid'],
//   //     isPrimary: json['isPrimary'],
//   //   );
//   // }

//   Map<String, dynamic> toJson() {
//     return {
//       'device': device.toJson(),
//       'uuid': uuid,
//       'isPrimary': isPrimary,
//     };
//   }

//   Future<BluetoothRemoteGATTCharacteristic> getCharacteristic(String characteristic) async {
//     // Call to JS to get characteristic
//     final result = await callJsMethod('getCharacteristic', [characteristic]);
//     return BluetoothRemoteGATTCharacteristic.fromJson(jsonDecode(result));
//   }

//   Future<List<BluetoothRemoteGATTCharacteristic>> getCharacteristics([String? characteristic]) async {
//     // Call to JS to get characteristics
//     final result = await callJsMethod('getCharacteristics', [characteristic]);
//     final List<dynamic> list = jsonDecode(result);
//     return list.map((e) => BluetoothRemoteGATTCharacteristic.fromJson(e)).toList();
//   }

//   Future<BluetoothRemoteGATTService> getIncludedService(String service) async {
//     // Call to JS to get included service
//     final result = await callJsMethod('getIncludedService', [service]);
//     return BluetoothRemoteGATTService.fromJson(jsonDecode(result));
//   }

//   Future<List<BluetoothRemoteGATTService>> getIncludedServices([String? service]) async {
//     // Call to JS to get included services
//     final result = await callJsMethod('getIncludedServices', [service]);
//     final List<dynamic> list = jsonDecode(result);
//     return list.map((e) => BluetoothRemoteGATTService.fromJson(e)).toList();
//   }

//   // Placeholder for calling JS method via JS channel
//   Future<String> callJsMethod(String method, List<dynamic> args) async {
//     // This method should be implemented to call the appropriate JavaScript method
//     // using the InAppWebView JavaScript channels.
//     return '';
//   }
// }

// class BluetoothRemoteGATTServer {
//   final JSBluetoothDevice device;
//   final bool connected;

//   BluetoothRemoteGATTServer({
//     required this.device,
//     required this.connected,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'device': device.toJson(),
//       'connected': connected,
//       'connect': '''function() {
//         return new Promise((resolve, reject) => {
//             // Implementation to forget the device
//             var response = await window.axs.callHandler('BluetoothRemoteGATTServer.connect', { 'id': ${device.id}})
//             resolve(response);
//         });
//     }''',
//       'getPrimaryService': '''function(service) {
//         return new Promise((resolve, reject) => {
//             // Implementation to forget the device
//             var response = await window.axs.callHandler('BluetoothRemoteGATTServer.getPrimaryService', { 'id': '${device.id}', 'service': service})
//             resolve(response);
//         });
//     }''',
//     };
//   }
// }

// class BluetoothAdvertisingEvent {
//   final JSBluetoothDevice device;
//   final List<String> uuids;
//   final Map<String, Uint8List> manufacturerData;
//   final Map<String, Uint8List> serviceData;
//   final String? name;
//   final int? appearance;
//   final int? rssi;
//   final int? txPower;

//   BluetoothAdvertisingEvent({
//     required this.device,
//     required this.uuids,
//     required this.manufacturerData,
//     required this.serviceData,
//     this.name,
//     this.appearance,
//     this.rssi,
//     this.txPower,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'device': device.toJson(),
//       'uuids': uuids,
//       'manufacturerData': manufacturerData,
//       'serviceData': serviceData,
//       'name': name,
//       'appearance': appearance,
//       'rssi': rssi,
//       'txPower': txPower,
//     };
//   }
// }
