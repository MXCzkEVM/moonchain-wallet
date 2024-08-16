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

  void initBlueberryRingSelectedActions() {
    selectedBlueberryRing.listen((event) {
      if (event != null) {
        // Blueberry ring is selected
      }
    });
  }

  Future<void> getBlueberryRingBackground() async {
    _bluetoothUseCase.startScanning(
      withServices: [bluetoothServiceUUID],
      // withNames: ['Mi Smart Band 4'],
      withNames: ['2301'],
      withKeywords: ['2301'],
    );

    await Future.delayed(const Duration(seconds: 4), () async {
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
    await _bluetoothUseCase
        .connectionHandler(selectedBlueberryRing.value!.device);
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
      await _bluetoothUseCase
          .connectionHandler(selectedBlueberryRing.value!.device);
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

    final isNotifying =
        blueberryRingNotificationsCharacteristic.value!.isNotifying;
    collectLog(
        'checkEstablishment:isBlueberryRingNotificationsCharacteristicNotifiying $isNotifying');
    if (!isNotifying) {
      blueberryRingNotificationsCharacteristic.value!.setNotifyValue(true);
    }

    return await func();
  }

  Future<T> readData<T>(Uint8List Function() getCommandFunc, String dataName,
      T Function(Uint8List) resolveData, bool isFrag) async {
    return checkEstablishment<T>(
      () async {
        final command = getCommandFunc();
        collectLog('read$dataName:command $command');

        // Prepare to listen for the response before writing
        final Stream<List<int>> stream =
            blueberryRingNotificationsCharacteristic.value!.lastValueStream;

        // Create a completer to handle the response
        final Completer<List<int>> completer = Completer<List<int>>();

        Timer? timer;
        List<int> data = [];

        // Subscribe to the stream and filter for the specific command
        final StreamSubscription<List<int>> subscription =
            stream.listen((element) {
          if (element.isNotEmpty && element.first == command.first) {
            timer?.cancel();
            collectLog('read$dataName:element $element');
            data.addAll(element);

            if (!completer.isCompleted && !isFrag) {
              completer.complete(data);
            } else if (!completer.isCompleted &&
                isFrag &&
                element.last == 255) {
              completer.complete(data);
            } else {
              timer = Timer(
                const Duration(milliseconds: 5000),
                () => completer.complete(data),
              );
            }
          }
        });

        blueberryRingCharacteristic.value?.write(command);

        // Wait for the expected value to be received
        final List<int> value = await completer.future;

        // Cancel the subscription to avoid memory leaks
        await subscription.cancel();

        collectLog('read$dataName:value $value');
        return resolveData(Uint8List.fromList(value));
      },
    );
  }

  Future<int> readLevel() async => readData<int>(BlueberryCommands.readLevel,
      'Level', BlueberryResolves.readLevel, BlueberryMethods.readLevel.frag);

  Future<String> readVersion() async => readData<String>(
      BlueberryCommands.readVersion,
      'Version',
      BlueberryResolves.readVersion,
      BlueberryMethods.readVersion.frag);

  Future<Uint8List> readTime() async => readData<Uint8List>(
      BlueberryCommands.readTime,
      'Time',
      BlueberryResolves.readTime,
      BlueberryMethods.readTime.frag);

  Future<List<PeriodicSleepData>> readSleep() async =>
      readData<List<PeriodicSleepData>>(BlueberryCommands.readSleep, 'Sleep',
          BlueberryResolves.readSleep, BlueberryMethods.readSleep.frag);

  Future<List<BloodOxygensData>> readBloodOxygens() async =>
      readData<List<BloodOxygensData>>(
          BlueberryCommands.readBloodOxygens,
          'BloodOxygens',
          BlueberryResolves.readBloodOxygens,
          BlueberryMethods.readBloodOxygens.frag);

  Future<List<StepsData>> readSteps() async => readData<List<StepsData>>(
      BlueberryCommands.readSteps,
      'Steps',
      BlueberryResolves.readSteps,
      BlueberryMethods.readSteps.frag);

  Future<List<HeartRateData>> readHeartRate() async =>
      readData<List<HeartRateData>>(
          BlueberryCommands.readHeartRates,
          'HeartRate',
          BlueberryResolves.readHeartRates,
          BlueberryMethods.readHeartRates.frag);

  Future<BluetoothCharacteristic> getBlueberryRingCharacteristic() async {
    final service = await getBlueberryRingBluetoothService();
    final resp = await _getBlueberryRingCharacteristic(
        service, bluetoothCharacteristicUUID);
    update(blueberryRingCharacteristic, resp);
    return resp;
  }

  Future<BluetoothCharacteristic>
      getBlueberryRingNotificationsCharacteristic() async {
    final service = await getBlueberryRingBluetoothService();
    final resp = await _getBlueberryRingCharacteristic(
        service, bluetoothCharacteristicNotificationUUID);
    update(blueberryRingNotificationsCharacteristic, resp);
    return resp;
  }

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
