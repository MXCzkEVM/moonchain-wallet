import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/dapp_hooks/dapp_hooks.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus;

import '../../../open_dapp.dart';

class BluetoothHelper {
  BluetoothHelper({
    required this.state,
    required this.context,
    required this.translate,
    required this.collectLog,
    required this.bluetoothUseCase,
    required this.navigator,
    required this.minerHooksHelper,
    required this.loading,
    required this.characteristicListenerTimer,
    required characteristicValueStreamSubscription,
  });

  OpenDAppState state;
  BluetoothUseCase bluetoothUseCase;
  void Function(String line) collectLog;
  NavigatorState? navigator;
  MinerHooksHelper minerHooksHelper;
  BuildContext? context;
  String? Function(String) translate;
  void Function(bool v) loading;
  Timer? characteristicListenerTimer;
  StreamSubscription<List<int>>? characteristicValueStreamSubscription;

  Future<Map<String, dynamic>> handleBluetoothRequestDevice(
    Map<String, dynamic> channelData,
  ) async {
    // final options = RequestDeviceOptions.fromJson(channelData['data']);
    final options = RequestDeviceOptions.fromMap(channelData);
    late BluetoothDevice responseDevice;

    await bluetoothUseCase.turnOnBluetoothAndProceed();

    //  Get the options data
    bluetoothUseCase.startScanning(
      withServices: options.filters != null
          ? options.filters!
              .expand((filter) => filter.services ?? [])
              .toList()
              .firstOrNull
          : [],
      withRemoteIds:
          null, // No direct mapping in RequestDeviceOptions, adjust as necessary
      withNames: options.filters != null
          ? options.filters!
              .where((filter) => filter.name != null)
              .map((filter) => filter.name!)
              .toList()
          : [],
      withKeywords: options.filters != null
          ? options.filters!
              .where((filter) => filter.namePrefix != null)
              .map((filter) => filter.namePrefix!)
              .toList()
          : [],
      withMsd: options.filters != null
          ? options.filters!
              .expand((filter) => filter.manufacturerData ?? [])
              .toList()
              .firstOrNull
          : [],
      withServiceData: options.filters != null
          ? options.filters!
              .expand((filter) => filter.serviceData ?? [])
              .toList()
              .firstOrNull
          : [],
      continuousUpdates: true,
      continuousDivisor: 2,
      androidUsesFineLocation: true,
    );

    final blueberryRing = await getBlueberryRing();
    bluetoothUseCase.stopScanner();
    if (blueberryRing == null) {
      return {};
    } else {
      responseDevice = blueberryRing;
    }

    return responseDevice.toMap();
  }

  // GATT server
  Future<Map<String, dynamic>> handleBluetoothRemoteGATTServerGetPrimaryService(
      Map<String, dynamic> data) async {
    collectLog('handleBluetoothRemoteGATTServerGetPrimaryService : $data');
    final selectedService = await BluetoothEntitiesUtils.getSelectedService(
        data['service'], state.selectedScanResult!);

    final device = BluetoothDevice.getBluetoothDeviceFromScanResult(
        state.selectedScanResult!);
    final bluetoothRemoteGATTService =
        BluetoothRemoteGATTService.fromBluetoothService(
            device, selectedService);
    return bluetoothRemoteGATTService.toMap();
  }

  void initJSCharacteristicValueEmitter(
    blue_plus.BluetoothCharacteristic characteristic,
  ) async {
    await characteristic.setNotifyValue(true);

    characteristicValueStreamSubscription =
        characteristic.lastValueStream.listen((event) async {
      final uInt8List = Uint8List.fromList(event);
      collectLog('characteristicValueStreamSubscription:event $event');
      collectLog(
          'characteristicValueStreamSubscription:uInt8List ${uInt8List.toString()}');
      final script = '''
      navigator.bluetooth.updateCharacteristicValue('${characteristic.uuid.str}', ${uInt8List.toString()},);
      ''';
      await state.webviewController!.evaluateJavascript(source: script);
    });
  }

  void removeJSCharacteristicValueEmitter(
    blue_plus.BluetoothCharacteristic characteristic,
  ) async {
    await characteristic.setNotifyValue(false);

    characteristicValueStreamSubscription?.cancel();
  }

  Future<Map<String, dynamic>> handleBluetoothRemoteGATTServerConnect(
      Map<String, dynamic> data) async {
    collectLog('handleBluetoothRemoteGATTServerConnect : $data');
    await bluetoothUseCase.connectionHandler(state.selectedScanResult!.device);

    return BluetoothRemoteGATTServer(
            device: BluetoothDevice.getBluetoothDeviceFromScanResult(
                state.selectedScanResult!),
            connected: true)
        .toMap();
  }

  // Service
  Future<Map<String, dynamic>>
      handleBluetoothRemoteGATTServiceGetCharacteristic(
          Map<String, dynamic> data) async {
    collectLog('handleBluetoothRemoteGATTServiceGetCharacteristic : $data');
    final targetCharacteristicUUID = data['characteristic'];

    final selectedService = await BluetoothEntitiesUtils.getSelectedService(
        data['this'], state.selectedScanResult!);
    final targetCharacteristic =
        BluetoothEntitiesUtils.getSelectedCharacteristic(
            targetCharacteristicUUID, selectedService);

    final device = BluetoothDevice.getBluetoothDeviceFromScanResult(
        state.selectedScanResult!);
    final bluetoothRemoteGATTService =
        BluetoothRemoteGATTService.fromBluetoothService(
            device, selectedService);
    final bluetoothRemoteGATTCharacteristic = BluetoothRemoteGATTCharacteristic(
        service: bluetoothRemoteGATTService,
        properties:
            BluetoothCharacteristicProperties.fromCharacteristicProperties(
                targetCharacteristic.properties),
        uuid: targetCharacteristic.uuid.str,
        value: null);
    return bluetoothRemoteGATTCharacteristic.toMap();
  }

  Future<Map<String, dynamic>>
      handleBluetoothRemoteGATTCharacteristicStartNotifications(
          Map<String, dynamic> data) async {
    collectLog(
        'handleBluetoothRemoteGATTCharacteristicStartNotifications : $data');
    final selectedService = await BluetoothEntitiesUtils.getSelectedService(
        data['serviceUUID'], state.selectedScanResult!);
    final selectedCharacteristic =
        BluetoothEntitiesUtils.getSelectedCharacteristic(
            data['this'], selectedService);

    final bluetoothRemoteGATTCharacteristic =
        BluetoothEntitiesUtils.getBluetoothRemoteGATTCharacteristic(
            selectedCharacteristic, selectedService, state.selectedScanResult!);

    initJSCharacteristicValueEmitter(selectedCharacteristic);

    return bluetoothRemoteGATTCharacteristic.toMap();
  }

  Future<Map<String, dynamic>>
      handleBluetoothRemoteGATTCharacteristicStopNotifications(
          Map<String, dynamic> data) async {
    collectLog(
        'handleBluetoothRemoteGATTCharacteristicStopNotifications : $data');
    final selectedService = await BluetoothEntitiesUtils.getSelectedService(
        data['serviceUUID'], state.selectedScanResult!);
    final selectedCharacteristic =
        BluetoothEntitiesUtils.getSelectedCharacteristic(
            data['this'], selectedService);

    final bluetoothRemoteGATTCharacteristic =
        BluetoothEntitiesUtils.getBluetoothRemoteGATTCharacteristic(
            selectedCharacteristic, selectedService, state.selectedScanResult!);

    removeJSCharacteristicValueEmitter(selectedCharacteristic);

    return bluetoothRemoteGATTCharacteristic.toMap();
  }

  Future<Map<String, dynamic>> handleWrites(Map<String, dynamic> data,
      {bool withResponse = true}) async {
    collectLog('handleWrites : $data');
    final selectedService = await BluetoothEntitiesUtils.getSelectedService(
        data['serviceUUID'], state.selectedScanResult!);
    final selectedCharacteristic =
        BluetoothEntitiesUtils.getSelectedCharacteristic(
            data['this'], selectedService);
    final value = Uint8List.fromList(List<int>.from(
        (data['value'] as Map<String, dynamic>).values.toList()));

    collectLog('handleWrites:value $value');
    if (withResponse) {
      await selectedCharacteristic.write(value);
    } else {
      await selectedCharacteristic.write(value, withoutResponse: true);
    }
    return {};
  }

  Future<Map<String, dynamic>>
      handleBluetoothRemoteGATTCharacteristicWriteValue(
          Map<String, dynamic> data) async {
    return handleWrites(data);
  }

  Future<Map<String, dynamic>>
      handleBluetoothRemoteGATTCharacteristicWriteValueWithResponse(
          Map<String, dynamic> data) async {
    return handleWrites(data);
  }

  Future<Map<String, dynamic>>
      handleBluetoothRemoteGATTCharacteristicWriteValueWithoutResponse(
          Map<String, dynamic> data) async {
    return handleWrites(data, withResponse: false);
  }

  Future<dynamic> handleBluetoothRemoteGATTCharacteristicReadValue(
      Map<String, dynamic> data) async {
    collectLog('handleBluetoothRemoteGATTCharacteristicReadValue : $data');
    final selectedService = await BluetoothEntitiesUtils.getSelectedService(
        data['serviceUUID'], state.selectedScanResult!);
    final selectedCharacteristic =
        BluetoothEntitiesUtils.getSelectedCharacteristic(
            data['this'], selectedService);
    final value = selectedCharacteristic.lastValue;

    final uInt8List = Uint8List.fromList(value);

    collectLog('handleBluetoothRemoteGATTCharacteristicReadValue:value $value');
    collectLog(
        'handleBluetoothRemoteGATTCharacteristicReadValue:uInt8List ${uInt8List.toString()}');

    return uInt8List;
  }

  Future<BluetoothDevice?> getBlueberryRing() async {
    loading(true);
    return Future.delayed(const Duration(seconds: 3), () async {
      loading(false);
      BluetoothDevice? responseDevice;
      final scanResults = bluetoothUseCase.scanResults.value;
      if (scanResults.length == 1) {
        // only one scan results
        final scanResult = scanResults.first;
        state.selectedScanResult = scanResult;
      } else {
        // We need to let the user to choose If two or more devices of rings are available and even If empty maybe let the user to wait
        final scanResult = await showBlueberryRingsBottomSheet(
          context!,
        );
        if (scanResult != null) {
          state.selectedScanResult = scanResult;
        }
      }
      if (state.selectedScanResult != null) {
        responseDevice = BluetoothDevice.getBluetoothDeviceFromScanResult(
            state.selectedScanResult!);
      }

      return responseDevice;
    });
  }
}
