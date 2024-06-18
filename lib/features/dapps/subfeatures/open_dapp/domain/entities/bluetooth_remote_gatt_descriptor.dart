import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'bluetooth_remote_gatt_characteristic.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BluetoothRemoteGATTDescriptor extends Equatable {
  final BluetoothRemoteGATTCharacteristic characteristic;
  final String uuid;
  final ByteData? value;

  BluetoothRemoteGATTDescriptor({
    required this.characteristic,
    required this.uuid,
    this.value,
  });

  factory BluetoothRemoteGATTDescriptor.fromJson(String source) =>
      BluetoothRemoteGATTDescriptor.fromMap(json.decode(source));

  factory BluetoothRemoteGATTDescriptor.fromMap(Map<String, dynamic> json) {
    return BluetoothRemoteGATTDescriptor(
      characteristic: BluetoothRemoteGATTCharacteristic.fromMap(json['characteristic']),
      uuid: json['uuid'],
      value: json['value'] != null ? ByteData.sublistView(Uint8List.fromList(List<int>.from(json['value']))) : null,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'characteristic': characteristic.toMap(),
      'uuid': uuid,
      'value': value?.buffer.asUint8List(),
      'readValue': '''(async function() {
        var response = await window.axs.callHandler('BluetoothRemoteGATTDescriptor.readValue', { 'this': '$uuid' });
        return response;
      })
      ''',
      'writeValue': '''
      (async function(value) {
        await window.axs.callHandler('BluetoothRemoteGATTDescriptor.writeValue', { 'this': '$uuid', 'value': ${value?.buffer.asUint8List()} });
      })
    '''
    };
  }

  Future<ByteData> readValue(InAppWebViewController webViewController) async {
    
    final result = await webViewController.evaluateJavascript(source: '''
      
    ''');
    return ByteData.sublistView(Uint8List.fromList(List<int>.from(result)));
  }

  Future<void> writeValue(InAppWebViewController webViewController, ByteData value) async {
    // await webViewController.evaluateJavascript(source: );
  }

  @override
  List<Object?> get props => [characteristic, uuid, value];
  
  @override
  String toString() {
    return 'BluetoothRemoteGATTDescriptor(characteristic: $characteristic, uuid: $uuid, value: $value)';
  }

  BluetoothRemoteGATTDescriptor copyWith({
    BluetoothRemoteGATTCharacteristic? characteristic,
    String? uuid,
    ByteData? value,
  }) {
    return BluetoothRemoteGATTDescriptor(
      characteristic: characteristic ?? this.characteristic,
      uuid: uuid ?? this.uuid,
      value: value ?? this.value,
    );
  }
}
