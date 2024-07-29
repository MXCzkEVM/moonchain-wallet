import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';

class BluetoothTimeoutError extends Error {
  static const String message = 'unable_to_continue_bluetooth_is_turned_off';

  BluetoothTimeoutError();

  @override
  String toString() {
    return "TimeoutError: $message";
  }
}

class BluetoothUseCase extends ReactiveUseCase {
  BluetoothUseCase(
    this._repository,
    this._chainConfigurationUseCase,
    this._authUseCase,
  ) {
    initBluetoothUseCase();
  }

  final Web3Repository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final AuthUseCase _authUseCase;

  StreamSubscription<List<ScanResult>>? scannerListener;
  StreamSubscription<BluetoothAdapterState>? stateListener;
  StreamSubscription<bool>? isScanningStateListener;

  late final ValueStream<bool> isScanning = reactive(false);
  late final ValueStream<BluetoothAdapterState> bluetoothStatus =
      reactive(BluetoothAdapterState.off);
  late final ValueStream<List<ScanResult>> scanResults = reactive([]);

  void initBluetoothUseCase() {
    initStateListener();
    bluetoothStatus.listen((state) {
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
        isScanningListener();
        initScannerListener();
      } else if (state == BluetoothAdapterState.unauthorized ||
          state == BluetoothAdapterState.unavailable ||
          state == BluetoothAdapterState.off ||
          state == BluetoothAdapterState.unknown) {
        // show an error to the user, etc
        cancelIsScanningListener();
        _cancelScannerListen();
      }
    });
  }

  Future<void> checkBluetoothSupport() async {
    final isSupported = await isBluetoothSupported();
    if (!isSupported) {
      // TODO:  show error snack bar
    }
  }

  Future<bool> isBluetoothSupported() async {
    // first, check if bluetooth is supported by your hardware
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    final res = await FlutterBluePlus.isSupported;
    return res;
  }

  void initStateListener() {
    // handle bluetooth on & off
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    stateListener =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      update(bluetoothStatus, state);
    });
  }

  void initScannerListener() {
    // listen to scan results
    // Note: `onScanResults` only returns live scan results, i.e. during scanning. Use
    //  `scanResults` if you want live scan results *or* the results from a previous scan.
    scannerListener = FlutterBluePlus.onScanResults.listen(
      (results) {
        inspect(results);
        if (results.isNotEmpty) {
          update(scanResults, results);
        }
      },
      onError: (e) => print(e),
    );
  }

  void isScanningListener() async {
    isScanningStateListener = FlutterBluePlus.isScanning.listen((event) {
      update(isScanning, event);
    });
  }

  Future<void> turnOnBluetoothAndProceed() async {
    // Try to turn on
    await turnOnBluetooth();

    // Wait till IT's turned on
    await bluetoothStatus
        .firstWhere((event) => event == BluetoothAdapterState.on)
        .timeout(const Duration(seconds: 5),
            onTimeout: () => throw BluetoothTimeoutError());
  }

  Future<void> checkBluetoothTurnedOn(
      Future<void> Function() turnOnBluetoothFunction) async {
    final isBluetoothOn = await isBluetoothTurnedOn();

    if (!isBluetoothOn) {
      await turnOnBluetoothFunction();
    }
  }

  Future<void> turnOnBluetooth() async {
    await checkBluetoothTurnedOn(() async {
      // turn on bluetooth ourself if we can
      // for iOS, the user controls bluetooth enable/disable
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      } else {
        // IOS
        await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
      }
    });
  }

  Future<bool> isBluetoothTurnedOn() async {
    if (bluetoothStatus.value == BluetoothAdapterState.on) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> connectionHandler(BluetoothDevice device) async {
    int attempts = 0;
    const maxAttempts = 4;
    while (attempts < maxAttempts) {
      try {
        print('Attempt ${attempts + 1} to connect to device...');
        await device.connect();
        print('Connected to device successfully.');
        break; // Exit the loop if the connection is successful
      } catch (e) {
        if (e is FlutterBluePlusException && e.function == 'connect') {
          attempts++;
          print('Failed to connect. Attempt $attempts of $maxAttempts.');
          if (attempts >= maxAttempts) {
            print('Max attempts reached. Could not connect to device.');
            break;
          }
        } else {
          print('Unexpected error: $e');
          break; // Exit on unexpected errors
        }
      }
    }
  }

  void startScanning({
    List<Guid>? withServices,
    List<String>? withRemoteIds,
    List<String>? withNames,
    List<String>? withKeywords,
    List<MsdFilter>? withMsd,
    List<ServiceDataFilter>? withServiceData,
    Duration? timeout,
    Duration? removeIfGone,
    bool? continuousUpdates,
    int? continuousDivisor,
    bool? oneByOne,
    AndroidScanMode? androidScanMode,
    bool? androidUsesFineLocation,
  }) async {
    // Start scanning w/ timeout
    // Optional: use `stopScan()` as an alternative to timeout
    if (isScanning.value == true) {
      return;
    }

    await FlutterBluePlus.startScan(
      withServices: withServices ?? [],
      withNames: withNames ?? [],
      withMsd: withMsd ?? [],
      withRemoteIds: withRemoteIds ?? [],
      withServiceData: withServiceData ?? [],
      withKeywords: withKeywords ?? [],
      timeout: timeout,
      removeIfGone: removeIfGone,
      continuousUpdates: continuousUpdates ?? false,
      continuousDivisor: continuousDivisor ?? 1,
      oneByOne: oneByOne ?? false,
      androidScanMode: androidScanMode ?? AndroidScanMode.lowLatency,
      androidUsesFineLocation: androidUsesFineLocation ?? false,
    );
  }

  void _cancelScannerListen() {
    // cleanup: cancel subscription when scanning stops
    if (scannerListener != null) {
      FlutterBluePlus.cancelWhenScanComplete(scannerListener!);
    }
  }

  void cancelStateListener() {
    stateListener?.cancel();
  }

  void cancelIsScanningListener() {
    isScanningStateListener?.cancel();
  }

  void stopScanner() {
    FlutterBluePlus.stopScan();
  }
}
