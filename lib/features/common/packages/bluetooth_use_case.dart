import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mxc_logic/mxc_logic.dart';

class BluetoothUseCase extends ReactiveUseCase {
  BluetoothUseCase(
      this._repository, this._chainConfigurationUseCase, this._authUseCase) {
    initBluetoothUseCase();
  }

  final Web3Repository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final AuthUseCase _authUseCase;

  late StreamSubscription<List<ScanResult>>? scannerListener;
  late StreamSubscription<BluetoothAdapterState>? stateListener;
  late StreamSubscription<bool>? isScanningStateListener;

  late final ValueStream<bool> isScanning = reactive(false);
  late final ValueStream<BluetoothAdapterState> bluetoothStatus =
      reactive(BluetoothAdapterState.off);

  void initBluetoothUseCase() {
    initStateListener();

    bluetoothStatus.listen((state) {
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
        initScannerListener();
        startScanning();
      } else {
        // show an error to the user, etc
      }
    });
  }

  Future<ChainsList> getChainsRpcUrls() async {
    return await _repository.chainsRepository.getChainsRpcUrls();
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
          // for (ScanResult r in results) {

          //   print(
          //       '${r.device.remoteId}: "${r.advertisementData.advName}" "${r.advertisementData.manufacturerData.toString()}" "${r.advertisementData.manufacturerData}" found!');
          // }
        }
      },
      onError: (e) => print(e),
    );

    _cancelScannerListen();
  }

  void isScanningListener() async {
    isScanningStateListener = FlutterBluePlus.isScanning.listen((event) {
      update(isScanning, event);
    });
  }

  void turnOnBluetooth() async {
    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  void startScanning({
    List<Guid> withServices = const [],
    List<String> withRemoteIds = const [],
    List<String> withNames = const [],
    List<String> withKeywords = const [],
    List<MsdFilter> withMsd = const [],
    List<ServiceDataFilter> withServiceData = const [],
    Duration? timeout,
    Duration? removeIfGone,
    bool continuousUpdates = false,
    int continuousDivisor = 1,
    bool oneByOne = false,
    AndroidScanMode androidScanMode = AndroidScanMode.lowLatency,
    bool androidUsesFineLocation = false,
  }) async {
    // Start scanning w/ timeout
    // Optional: use `stopScan()` as an alternative to timeout
    await FlutterBluePlus.startScan(
      // withServices: [Guid("180D")], // match any of the specified services
      // withNames: ["Bluno"], // *or* any of the specified names
      continuousUpdates: true,
      timeout: const Duration(seconds: 15),
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
