import 'dart:async';

import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';

import '../bluetooth.dart';

final bluetoothServiceUUID =
    Guid.fromString('0000fff0-0000-1000-8000-00805f9b34fb');
final bluetoothCharacteristicUUID =
    Guid.fromString('0000fff6-0000-1000-8000-00805f9b34fb');
final bluetoothCharacteristicNotificationUUID =
    Guid.fromString('0000fff7-0000-1000-8000-00805f9b34fb');

class BlueberryRingUseCase extends ReactiveUseCase {
  BlueberryRingUseCase(this._repository, this._chainConfigurationUseCase,
      this._bluetoothUseCase) {
    // initBlueberryRingUseCase();
  }

  final Web3Repository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final BluetoothUseCase _bluetoothUseCase;

  late StreamSubscription<List<ScanResult>>? scannerListener;
  late StreamSubscription<BluetoothAdapterState>? stateListener;
  late StreamSubscription<bool>? isScanningStateListener;

  late final ValueStream<ScanResult?> selectedBlueberryRing = reactive(null);
  late final ValueStream<BluetoothAdapterState> bluetoothStatus =
      reactive(BluetoothAdapterState.off);

  //   if (state.selectedScanResult != null) {
  //   responseDevice = BluetoothDevice.getBluetoothDeviceFromScanResult(
  //       state.selectedScanResult!);
  // }

  void initBlueberryRingSelectedActions() {
    selectedBlueberryRing.listen((event) {
      if (event != null) {
        // Blueberry ring is selected
      }
    });
  }

  // Sets the selectedBlueberryRing
  Future<void> getBlueberryRingsNearby(BuildContext context) async {
    _bluetoothUseCase.startScanning(
      withServices: [bluetoothServiceUUID],
    );

    await Future.delayed(const Duration(seconds: 3), () async {
      final scanResults = _bluetoothUseCase.scanResults.value;
      if (scanResults.length > 1 || scanResults.isEmpty) {
        // We need to let the user to choose If two or more devices of rings are available and even If empty maybe let the user to wait
        final scanResult = await showBlueberryRingsBottomSheet(
          context,
        );
        if (scanResult != null) {
          update(selectedBlueberryRing, scanResult);
        }
      } else {
        // only one scan results
        final scanResult = scanResults.first;
        update(selectedBlueberryRing, scanResult);
      }
    });

    _bluetoothUseCase.stopScanner();
  }

  Future<void> connectToBlueberryRing() async {
    await selectedBlueberryRing.value!.device.connect();
  }

  Future<BluetoothService> getBlueberryRingBluetoothService() async {
    return await _getBlueberryRingPrimaryService(bluetoothServiceUUID);
  }

  Future<BluetoothCharacteristic> getBlueberryRingCharacteristic() async {
    final service = await getBlueberryRingBluetoothService();
    return _getBlueberryRingCharacteristic(
        service, bluetoothCharacteristicUUID);
  }

  Future<BluetoothCharacteristic> getBlueberryRingCharacteristicNotifications()async {
    final service = await getBlueberryRingBluetoothService();
        return _getBlueberryRingCharacteristic(
        service, bluetoothCharacteristicNotificationUUID);
  }

  Future<void> startBlueberryRingCharacteristicNotifications()async {
    final characteristicNotifications = await getBlueberryRingCharacteristicNotifications();
    await characteristicNotifications.setNotifyValue(true);
    characteristicNotifications.onValueReceived.listen((event) { });
    final value = characteristicNotifications.read();
  }

  Future<BluetoothService> _getBlueberryRingPrimaryService(
    Guid serviceUUID,
  ) async {
    return await BluePlusBluetoothUtils.getPrimaryService(
      selectedBlueberryRing.value!,
      serviceUUID,
    );
  }

  Future<BluetoothCharacteristic> _getBlueberryRingCharacteristic(
    BluetoothService service,
    Guid characteristicUUID,
  ) async {
    return await BluePlusBluetoothUtils.getCharacteristicWithService(
      service,
      characteristicUUID,
    );
  }
}
