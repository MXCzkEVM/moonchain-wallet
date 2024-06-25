import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'bluetooth_device.dart';
import 'bluetooth_remote_gatt_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BluetoothRemoteGATTServer extends Equatable {
  final BluetoothDevice device;
  final bool connected;

  const BluetoothRemoteGATTServer({
    required this.device,
    required this.connected,
  });

  factory BluetoothRemoteGATTServer.fromMap(Map<String, dynamic> map) {
    return BluetoothRemoteGATTServer(
      device: BluetoothDevice.fromMap(map['device']),
      connected: map['connected'],
    );
  }
  factory BluetoothRemoteGATTServer.fromJson(String source) =>
      BluetoothRemoteGATTServer.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'device': device.toMap(),
      'connected': connected,
    //   'connect': '''
    //   (async function() {
    //     var response = await navigator.bluetooth.bluetoothRemoteGATTServer.connect();
    //     return response;
    //   })
    // ''',
    //   'disconnect': '''
    //   (async function() {
    //     await window.axs.callHandler('BluetoothRemoteGATTServer.disconnect', {} );
    //   })
    // ''',
    //   'getPrimaryService': '''
    //   (async function(service) {
    //     var response = await navigator.bluetooth.bluetoothRemoteGATTServer.getPrimaryService({  'service': service });
    //     return response;
    //   })
    // ''',
    //   'getPrimaryServices': '''
    //   (async function(service) {
    //     var response = await window.axs.callHandler('BluetoothRemoteGATTServer.getPrimaryServices', {  'service': service });
    //     return response;
    //   })
    // ''',
    };
  }

  Future<BluetoothRemoteGATTServer> connect(
      InAppWebViewController webViewController) async {
    final result = await webViewController.evaluateJavascript(source: '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTServer.connect', { 'id': '${device.id}' });
        return response;
      })()
    ''');
    return BluetoothRemoteGATTServer.fromJson(result);
  }

  void disconnect(InAppWebViewController webViewController) async {
    await webViewController.evaluateJavascript(source: '''
      (async function() {
        await window.axs.callHandler('BluetoothRemoteGATTServer.disconnect', { 'id': '${device.id}' });
      })()
    ''');
  }

  Future<BluetoothRemoteGATTService> getPrimaryService(
      InAppWebViewController webViewController, String serviceUuid) async {
    final result = await webViewController.evaluateJavascript(source: '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTServer.getPrimaryService', { 'id': '${device.id}', 'service': '$serviceUuid' });
        return response;
      })()
    ''');
    return BluetoothRemoteGATTService.fromJson(result);
  }

  Future<List<BluetoothRemoteGATTService>> getPrimaryServices(
      InAppWebViewController webViewController,
      {String? serviceUuid}) async {
    final result = await webViewController.evaluateJavascript(source: '''
      (async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTServer.getPrimaryServices', { 'id': '${device.id}', 'service': '${serviceUuid ?? ''}' });
        return response;
      })()
    ''');
    return (result as List)
        .map((e) => BluetoothRemoteGATTService.fromJson(e))
        .toList();
  }

  @override
  List<Object?> get props => [device, connected];

  @override
  String toString() {
    return 'BluetoothRemoteGATTServer(device: $device, connected: $connected)';
  }

  BluetoothRemoteGATTServer copyWith({
    BluetoothDevice? device,
    bool? connected,
  }) {
    return BluetoothRemoteGATTServer(
      device: device ?? this.device,
      connected: connected ?? this.connected,
    );
  }
}
