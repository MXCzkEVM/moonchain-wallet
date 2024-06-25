import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'bluetooth_remote_gatt_service.dart';
import 'bluetooth_characteristic_properties.dart';
import 'bluetooth_remote_gatt_descriptor.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BluetoothRemoteGATTCharacteristic extends Equatable {
  final BluetoothRemoteGATTService service;
  final String uuid;
  final BluetoothCharacteristicProperties properties;
  final ByteData? value;

  const BluetoothRemoteGATTCharacteristic({
    required this.service,
    required this.uuid,
    required this.properties,
    this.value,
  });

  factory BluetoothRemoteGATTCharacteristic.fromJson(String source) =>
      BluetoothRemoteGATTCharacteristic.fromMap(json.decode(source));

  factory BluetoothRemoteGATTCharacteristic.fromMap(Map<String, dynamic> json) {
    return BluetoothRemoteGATTCharacteristic(
      service: BluetoothRemoteGATTService.fromMap(json['service']),
      uuid: json['uuid'],
      properties: BluetoothCharacteristicProperties.fromMap(json['properties']),
      value: json['value'] != null
          ? ByteData.sublistView(
              Uint8List.fromList(List<int>.from(json['value'])))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'service': service.toMap(),
      'uuid': uuid,
      'properties': properties.toMap(),
      'value': value?.buffer.asUint8List(),
    //   'getDescriptor': '''
    //   (async function(descriptor) {
    //     var response = await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.getDescriptor', { 'this': '$uuid', 'serviceUUID': '${service.uuid}', 'descriptor': descriptor });
    //     return response;
    //   })
    // ''',
    //   'getDescriptors': '''
    //   (async function(descriptor) {
    //     var response = await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.getDescriptors', { 'this': '$uuid', 'serviceUUID': '${service.uuid}', 'descriptor': descriptor });
    //     return response;
    //   })
    // ''',
    //   'readValue': '''
    //   (async function() {
    //     var response = await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.readValue', { 'this': '$uuid', 'serviceUUID': '${service.uuid}' });
    //     return response;
    //   })
    // ''',
    //   'writeValue': '''
    //   (async function(value) {
    //     await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.writeValue', { 'this': '$uuid', 'serviceUUID': '${service.uuid}', 'value': ${value?.buffer.asUint8List()} });
    //   })
    // ''',
    //   'writeValueWithResponse': '''
    //   (async function(value) {
    //     await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.writeValue', { 'this': '$uuid', 'serviceUUID': '${service.uuid}', 'value': ${value?.buffer.asUint8List()} });
    //   })
    // ''',
    //   'writeValueWithoutResponse': '''
    //   (async function(value) {
    //     await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.writeValue', { 'this': '$uuid',  'serviceUUID': '${service.uuid}', 'value': ${value?.buffer.asUint8List()} });
    //   })
    // ''',
    //   'startNotifications': '''
    //   (async function() {
    //     var response = await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.stopNotifications', { 'this': '$uuid', 'serviceUUID': '${service.uuid}', });
    //     return response;
    //   })
    // ''',
    //   'stopNotifications': '''
    //   (async function() {
    //     var response = await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.stopNotifications', { 'this': '$uuid',  'serviceUUID': '${service.uuid}', });
    //     return response;
    //   })
    // '''
    };
  }

  Future<BluetoothRemoteGATTDescriptor> getDescriptor(
      InAppWebViewController webViewController, String descriptorUuid) async {
    final result = await webViewController.evaluateJavascript(source: '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.getDescriptor', { 'uuid': '$uuid', 'descriptor': '$descriptorUuid' });
        return response;
      })()
    ''');
    return BluetoothRemoteGATTDescriptor.fromJson(result);
  }

  Future<List<BluetoothRemoteGATTDescriptor>> getDescriptors(
      InAppWebViewController webViewController,
      {String? descriptorUuid}) async {
    final result = await webViewController.evaluateJavascript(source: '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.getDescriptors', { 'uuid': '$uuid', 'descriptor': '${descriptorUuid ?? ''}' });
        return response;
      })()
    ''');
    return (result as List)
        .map((e) => BluetoothRemoteGATTDescriptor.fromJson(e))
        .toList();
  }

  Future<ByteData> readValue(InAppWebViewController webViewController) async {
    final result = await webViewController.evaluateJavascript(source: '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.readValue', { 'uuid': '$uuid' });
        return response;
      })()
    ''');
    return ByteData.sublistView(Uint8List.fromList(List<int>.from(result)));
  }

  Future<void> writeValue(
      InAppWebViewController webViewController, ByteData value) async {
    await webViewController.evaluateJavascript(source: '''
      (async function() {
        await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.writeValue', { 'uuid': '$uuid', 'value': ${value.buffer.asUint8List()} });
      })()
    ''');
  }

  Future<BluetoothRemoteGATTCharacteristic> startNotifications(
      InAppWebViewController webViewController) async {
    final result = await webViewController.evaluateJavascript(source: '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.startNotifications', { 'uuid': '$uuid' });
        return response;
      })()
    ''');
    return BluetoothRemoteGATTCharacteristic.fromJson(result);
  }

  Future<BluetoothRemoteGATTCharacteristic> stopNotifications(
      InAppWebViewController webViewController) async {
    final result = await webViewController.evaluateJavascript(source: '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.stopNotifications', { 'uuid': '$uuid' });
        return response;
      })()
    ''');
    return BluetoothRemoteGATTCharacteristic.fromJson(result);
  }

  @override
  List<Object?> get props => [service, uuid, properties, value];

  @override
  String toString() {
    return 'BluetoothRemoteGATTCharacteristic(service: $service, uuid: $uuid, properties: $properties, value: $value)';
  }

  BluetoothRemoteGATTCharacteristic copyWith({
    BluetoothRemoteGATTService? service,
    String? uuid,
    BluetoothCharacteristicProperties? properties,
    ByteData? value,
  }) {
    return BluetoothRemoteGATTCharacteristic(
      service: service ?? this.service,
      uuid: uuid ?? this.uuid,
      properties: properties ?? this.properties,
      value: value ?? this.value,
    );
  }
}
