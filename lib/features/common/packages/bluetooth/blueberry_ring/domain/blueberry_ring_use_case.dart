import 'dart:async';
import 'dart:typed_data';

import 'package:datadashwallet/app/logger.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';

import '../../bluetooth.dart';

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

  late final ValueStream<ScanResult?> selectedBlueberryRing = reactive(null);
  late final ValueStream<BluetoothCharacteristic?> blueberryRingCharacteristic =
      reactive(null);
  late final ValueStream<BluetoothCharacteristic?>
      blueberryRingNotificationsCharacteristic = reactive(null);

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

  Future<void> getBlueberryRingBackground() async {
    // if (bluetoothStatus.value == BluetoothAdapterState.off || bluetoothStatus.value = BluetoothAdapterState.unauthorized)
    _bluetoothUseCase.startScanning(
      withServices: [bluetoothServiceUUID],
      // withNames: ['Mi Smart Band 4'],
      withNames: ['2301'],
      withKeywords: ['2301'],
    );

    await Future.delayed(const Duration(seconds: 2), () async {
      final scanResults = _bluetoothUseCase.scanResults.value;
      if (scanResults.isNotEmpty) {
        // only one scan results
        final scanResult = scanResults.first;
        update(selectedBlueberryRing, scanResult);
      } else {
        throw 'Error: Unable to locate blueberry ring';
      }
    });

    _bluetoothUseCase.stopScanner();
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

  /// This function will check the blueberry ring, connection
  Future<T> checkEstablishment<T>(Future<T> Function() func) async {
    collectLog('checkEstablishment');

    final isBlueberryRingAvailable = selectedBlueberryRing.hasValue;
    collectLog(
        'checkEstablishment:isBlueberryRingAvailable $isBlueberryRingAvailable');

    if (!isBlueberryRingAvailable) {
      await getBlueberryRingBackground();
    }

    bool isBlueberryRingConnected =
        selectedBlueberryRing.value?.device.isConnected ?? false;
    collectLog(
        'checkEstablishment:isBlueberryRingConnected $isBlueberryRingConnected');

    if (!isBlueberryRingConnected) {
      await selectedBlueberryRing.value?.device.connect();
      isBlueberryRingConnected =
          selectedBlueberryRing.value?.device.isConnected ?? false;
      if (!isBlueberryRingConnected) {
        throw 'Error: Unable to connect to the bluetooth device';
      }
    }

    final isBlueberryRingCharacteristicAvailable =
        blueberryRingCharacteristic.hasValue;
    collectLog(
        'checkEstablishment:isBlueberryRingCharacteristicAvailable $isBlueberryRingCharacteristicAvailable');
    if (!isBlueberryRingCharacteristicAvailable) {
      await getBlueberryRingCharacteristic();
    }

    final isBlueberryRingNotificationsCharacteristicAvailable =
        blueberryRingNotificationsCharacteristic.hasValue;
    collectLog(
        'checkEstablishment:isBlueberryRingNotificationsCharacteristicAvailable $isBlueberryRingNotificationsCharacteristicAvailable');
    if (!isBlueberryRingNotificationsCharacteristicAvailable) {
      await getBlueberryRingNotificationsCharacteristic();
    }

    final isNotifying = blueberryRingNotificationsCharacteristic.value!.isNotifying;
    collectLog(
        'checkEstablishment:isBlueberryRingNotificationsCharacteristicNotifiying $isNotifying');
    if (!isNotifying) {
      blueberryRingNotificationsCharacteristic.value!.setNotifyValue(true);
    }

    return await func();
  }

  Future<int> readLevel() async {
    return checkEstablishment<int>(
      () async {
        final command = BlueberryCommands.readLevel();
        collectLog('readLevel:command $command');
        blueberryRingCharacteristic.value?.write(command);
        final value = await blueberryRingNotificationsCharacteristic.value?.lastValueStream.first;
        collectLog('readLevel:value $value');
        collectLog('readLevel:lastValue ${blueberryRingNotificationsCharacteristic.value!.lastValue}');
        return BlueberryResolves.readLevel(Uint8List.fromList(value!));
      },
    );
  }

  Future<String> readVersion() async {
    return checkEstablishment<String>(
      () async {
        final command = BlueberryCommands.readVersion();
        collectLog('readVersion:command $command');
        blueberryRingCharacteristic.value?.write(command);
        final value = await blueberryRingNotificationsCharacteristic.value?.lastValueStream.first;
        collectLog('readVersion:value $value');
        collectLog('readLevel:lastValue ${blueberryRingNotificationsCharacteristic.value!.lastValue}');
        return BlueberryResolves.readVersion(Uint8List.fromList(value!));
      },
    );
  }

  Future<Uint8List> readTime() async {
    return checkEstablishment<Uint8List>(
      () async {
        final command = BlueberryCommands.readTime();
        collectLog('readTime:command $command');
        blueberryRingCharacteristic.value?.write(command);
        final value = await blueberryRingNotificationsCharacteristic.value?.lastValueStream.first;
        collectLog('readTime:value $value');
        collectLog('readLevel:lastValue ${blueberryRingNotificationsCharacteristic.value!.lastValue}');
        return BlueberryResolves.readTime(Uint8List.fromList(value!));
      },
    );
  }

  Future<List<PeriodicSleepData>> readSleep() async {
    return checkEstablishment<List<PeriodicSleepData>>(
      () async {
        final command = BlueberryCommands.readSleep();
        collectLog('readSleep:command $command');
        blueberryRingCharacteristic.value?.write(command);
        final value = await blueberryRingNotificationsCharacteristic.value?.lastValueStream.first;
        collectLog('readSleep:value $value');
        collectLog('readLevel:lastValue ${blueberryRingNotificationsCharacteristic.value!.lastValue}');
        return BlueberryResolves.readSleep(Uint8List.fromList(value!));
      },
    );
  }

  Future<List<BloodOxygensData>> readBloodOxygens() async {
    return checkEstablishment<List<BloodOxygensData>>(
      () async {
        final command = BlueberryCommands.readBloodOxygens();
        collectLog('readBloodOxygens:command $command');
        blueberryRingCharacteristic.value?.write(command);
        final value = await blueberryRingNotificationsCharacteristic.value?.lastValueStream.first;
        collectLog('readBloodOxygens:value $value');
        collectLog('readLevel:lastValue ${blueberryRingNotificationsCharacteristic.value!.lastValue}');
        return BlueberryResolves.readBloodOxygens(Uint8List.fromList(value!));
      },
    );
  }

  Future<List<StepsData>> readSteps() async {
    return checkEstablishment<List<StepsData>>(
      () async {
        final command = BlueberryCommands.readSteps();
        collectLog('readSteps:command $command');
        blueberryRingCharacteristic.value?.write(command);
        final value = await blueberryRingNotificationsCharacteristic.value?.lastValueStream.first;
        collectLog('readSteps:value $value');
        collectLog('readLevel:lastValue ${blueberryRingNotificationsCharacteristic.value!.lastValue}');
        return BlueberryResolves.readSteps(Uint8List.fromList(value!));
      },
    );
  }

  Future<List<HeartRateData>> readHeartRate() async {
    return checkEstablishment<List<HeartRateData>>(
      () async {
        final command = BlueberryCommands.readHeartRates();
        collectLog('readHeartRate:command $command');
        blueberryRingCharacteristic.value?.write(command);
        final value = await blueberryRingNotificationsCharacteristic.value?.lastValueStream.first;
        collectLog('readHeartRate:value $value');
        collectLog('readLevel:lastValue ${blueberryRingNotificationsCharacteristic.value!.lastValue}');
        return BlueberryResolves.readHeartRates(Uint8List.fromList(value!));
      },
    );
  }

  Future<BluetoothCharacteristic> getBlueberryRingCharacteristic() async {
    final service = await getBlueberryRingBluetoothService();
    final resp = await _getBlueberryRingCharacteristic(
        service, bluetoothCharacteristicUUID);
    update(blueberryRingCharacteristic, resp);
    return resp;
  }


  Future<BluetoothCharacteristic> getBlueberryRingNotificationsCharacteristic() async {
    final service = await getBlueberryRingBluetoothService();
    final resp = await _getBlueberryRingCharacteristic(
        service, bluetoothCharacteristicNotificationUUID);
    update(blueberryRingNotificationsCharacteristic, resp);
    return resp;
  }

  // Future<BluetoothCharacteristic>
  //     getBlueberryRingCharacteristicNotifications() async {
  //   final service = await getBlueberryRingBluetoothService();
  //   final resp = await _getBlueberryRingCharacteristic(
  //       service, bluetoothCharacteristicNotificationUUID);
  //   update(blueberryRinNotificationsCharacteristic, resp);
  //   return resp;
  // }

  // Future<void> startBlueberryRingCharacteristicNotifications() async {
  //   final characteristicNotifications =
  //       await getBlueberryRingCharacteristicNotifications();
  //   await characteristicNotifications.setNotifyValue(true);
  //   characteristicNotifications.lastValueStream.listen((event) {});
  //   final value = characteristicNotifications.read();
  // }

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
    return BluePlusBluetoothUtils.getCharacteristicWithService(
      service,
      characteristicUUID,
    );
  }
}
