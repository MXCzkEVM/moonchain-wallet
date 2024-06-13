import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'bluetooth_device.dart';
import 'bluetooth_remote_gatt_characteristic.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BluetoothRemoteGATTService extends Equatable {
  final BluetoothDevice device;
  final String uuid;
  final bool isPrimary;

  BluetoothRemoteGATTService({
    required this.device,
    required this.uuid,
    required this.isPrimary,
  });

  factory BluetoothRemoteGATTService.fromJson(Map<String, dynamic> json) {
    return BluetoothRemoteGATTService(
      device: BluetoothDevice.fromJson(json['device']),
      uuid: json['uuid'],
      isPrimary: json['isPrimary'],
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'device': device.toMap(),
      'uuid': uuid,
      'isPrimary': isPrimary,
      'getCharacteristic': '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTService.getCharacteristic', {  'characteristic': '$uuid', });
        return response;
      })()
    ''',
      'getCharacteristics': '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTService.getCharacteristics', {  'characteristic': '$uuid', });
        return response;
      })()
    ''',
      'getIncludedService': '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTService.getIncludedService', { 'service': '$uuid',});
        return response;
      })()
    ''',
      'getIncludedServices': '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTService.getIncludedServices', { 'service': '$uuid', });
        return response;
      })()
    ''',
    };
  }

  Future<BluetoothRemoteGATTCharacteristic> getCharacteristic(
      InAppWebViewController webViewController,
      String characteristicUuid) async {
    final result = await webViewController.evaluateJavascript(source: '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTService.getCharacteristic', { 'uuid': '$uuid', 'characteristic': '$characteristicUuid' });
        return response;
      })()
    ''');
    return BluetoothRemoteGATTCharacteristic.fromJson(result);
  }

  Future<List<BluetoothRemoteGATTCharacteristic>> getCharacteristics(
      InAppWebViewController webViewController,
      {String? characteristicUuid}) async {
    final result = await webViewController.evaluateJavascript(source: '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTService.getCharacteristics', { 'uuid': '$uuid', 'characteristic': '${characteristicUuid ?? ''}' });
        return response;
      })()
    ''');
    return (result as List)
        .map((e) => BluetoothRemoteGATTCharacteristic.fromJson(e))
        .toList();
  }

  Future<BluetoothRemoteGATTService> getIncludedService(
      InAppWebViewController webViewController, String serviceUuid) async {
    final result = await webViewController.evaluateJavascript(source: '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTService.getIncludedService', { 'uuid': '$uuid', 'service': '$serviceUuid' });
        return response;
      })()
    ''');
    return BluetoothRemoteGATTService.fromJson(result);
  }

  Future<List<BluetoothRemoteGATTService>> getIncludedServices(
      InAppWebViewController webViewController,
      {String? serviceUuid}) async {
    final result = await webViewController.evaluateJavascript(source: '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTService.getIncludedServices', { 'uuid': '$uuid', 'service': '${serviceUuid ?? ''}' });
        return response;
      })()
    ''');
    return (result as List)
        .map((e) => BluetoothRemoteGATTService.fromJson(e))
        .toList();
  }

  @override
  List<Object?> get props => [device, uuid, isPrimary];

  @override
  String toString() {
    return 'BluetoothRemoteGATTService(device: $device, uuid: $uuid, isPrimary: $isPrimary)';
  }

  BluetoothRemoteGATTService copyWith({
    BluetoothDevice? device,
    String? uuid,
    bool? isPrimary,
  }) {
    return BluetoothRemoteGATTService(
      device: device ?? this.device,
      uuid: uuid ?? this.uuid,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
