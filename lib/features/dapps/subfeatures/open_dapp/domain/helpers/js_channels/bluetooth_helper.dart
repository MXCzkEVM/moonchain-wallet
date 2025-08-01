import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/dapp_hooks/dapp_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus;
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../open_dapp.dart';

class BluetoothHelper {
  BluetoothHelper({
    required this.state,
    required this.context,
    required this.translate,
    required this.collectLog,
    required this.bluetoothUseCase,
    required this.blueberryRingUseCase,
    required this.navigator,
    required this.minerHooksHelper,
    required this.loading,
    required this.characteristicListenerTimer,
    required characteristicValueStreamSubscription,
    required this.currentUrl,
  });

  OpenDAppState state;
  BluetoothUseCase bluetoothUseCase;
  BlueberryRingUseCase blueberryRingUseCase;
  void Function(String line) collectLog;
  NavigatorState? navigator;
  MinerHooksHelper minerHooksHelper;
  BuildContext? context;
  String? Function(String) translate;
  void Function(bool v) loading;
  Timer? characteristicListenerTimer;
  StreamSubscription<List<int>>? characteristicValueStreamSubscription;
  Uri currentUrl;

  Future<Map<String, dynamic>> handleBluetoothRequestDevice(
    Map<String, dynamic> channelData,
    BuildContext? context,
  ) async {
    return (await bluetoothUseCase
            .alreadyScanningGuard<Map<String, dynamic>>(() async {
          collectLog('handleBluetoothRequestDevice:channelData : $channelData');
          late RequestDeviceOptions options =
              RequestDeviceOptions.fromMap(channelData);

          BluetoothDevice? responseDevice;

          await bluetoothUseCase.turnOnBluetoothAndProceed();

          //  Get the options data
          final isFiltersNotNull = options.filters != null;
          final List<String> withNames = isFiltersNotNull
              ? options.filters!
                  .where((filter) => filter.name != null)
                  .map((filter) => filter.name!)
                  .toList()
              : [];
          final List<String> withKeywords = isFiltersNotNull
              ? options.filters!
                  .where((filter) => filter.namePrefix != null)
                  .map((filter) => filter.namePrefix!)
                  .toList()
              : [];
          final List<blue_plus.MsdFilter>? withMsd = isFiltersNotNull
              ? options.filters!
                  .expand((filter) => filter.manufacturerData ?? [])
                  .toList()
                  .firstOrNull
              : [];
          final List<blue_plus.ServiceDataFilter>? withServiceData =
              isFiltersNotNull
                  ? options.filters!
                      .expand((filter) => filter.serviceData ?? [])
                      .toList()
                      .firstOrNull
                  : [];
          final optionalServices =
              options.optionalServices ?? <blue_plus.Guid>[];
          final filterServices = isFiltersNotNull
              ? options.filters!
                  .expand(
                    (filter) => filter.services ?? <blue_plus.Guid>[],
                  )
                  .toList()
              : [];
          final List<blue_plus.Guid> withServices =
              withKeywords.isNotEmpty && Platform.isAndroid
                  ? []
                  : isFiltersNotNull
                      ? [...filterServices, ...optionalServices]
                      : optionalServices;
          final queryName = withNames.firstOrNull;

          if (queryName != null) {
            state.selectedScanResult =
                bluetoothUseCase.checkRingCache(queryName);
          }
          if (state.selectedScanResult == null) {
            bluetoothUseCase.startScanning(
              withServices: withServices,
              withRemoteIds: null,
              withNames: withNames,
              withKeywords: withKeywords,
              withMsd: withMsd,
              withServiceData: withServiceData,
              continuousUpdates: true,
              continuousDivisor: 2,
              androidUsesFineLocation: true,
            );

            const equality = ListEquality<String>();
            final isRingDapp = -1 !=
                Urls.getRingDappUrls().indexWhere(
                  (element) =>
                      Uri.parse(element).host == currentUrl.host,
                );
            bool showNearbyBottomSheet = true;
            if (isRingDapp) {
              final isRegisterRing =
                  equality.equals(withKeywords, blueberryRingGeneralSearch);
              showNearbyBottomSheet = isRegisterRing;
            }

            await getBlueberryRing(showNearbyBottomSheet, isRingDapp);
            bluetoothUseCase.stopScanner();
          }

          state.selectedScanResult =
              bluetoothUseCase.selectedScanResult.valueOrNull;
          if (state.selectedScanResult != null) {
            responseDevice = BluetoothDevice.getBluetoothDeviceFromScanResult(
                state.selectedScanResult!);
          }

          return responseDevice == null ? {} : responseDevice.toMap();
        })) ??
        {};
  }

  // GATT server
  Future<Map<String, dynamic>> handleBluetoothRemoteGATTServerGetPrimaryService(
    Map<String, dynamic> data,
    BuildContext? context,
  ) async {
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
    Map<String, dynamic> data,
    BuildContext? context,
  ) async {
    collectLog('handleBluetoothRemoteGATTServerConnect : $data');
    await bluetoothUseCase.connectionHandler(state.selectedScanResult!.device);
    bluetoothUseCase.initDeviceConnectionState(handleDisconnection);
    return BluetoothRemoteGATTServer(
            device: BluetoothDevice.getBluetoothDeviceFromScanResult(
                state.selectedScanResult!),
            connected: true)
        .toMap();
  }

  void handleDisconnection() async {
    // listen to device connection state
    // handle disconnection
    const script = '''
        navigator.bluetooth.dispatchBluetoothEvent('gattserverdisconnected');
        ''';
    await state.webviewController!.evaluateJavascript(source: script);
    collectLog('Injected the disconnection state.');
  }

  // Service
  Future<Map<String, dynamic>>
      handleBluetoothRemoteGATTServiceGetCharacteristic(
    Map<String, dynamic> data,
    BuildContext? context,
  ) async {
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
    Map<String, dynamic> data,
    BuildContext? context,
  ) async {
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
    Map<String, dynamic> data,
    BuildContext? context,
  ) async {
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
    Map<String, dynamic> data,
    BuildContext? context,
  ) async {
    return handleWrites(data);
  }

  Future<Map<String, dynamic>>
      handleBluetoothRemoteGATTCharacteristicWriteValueWithResponse(
    Map<String, dynamic> data,
    BuildContext? context,
  ) async {
    return handleWrites(data);
  }

  Future<Map<String, dynamic>>
      handleBluetoothRemoteGATTCharacteristicWriteValueWithoutResponse(
    Map<String, dynamic> data,
    BuildContext? context,
  ) async {
    return handleWrites(data, withResponse: false);
  }

  Future<dynamic> handleBluetoothRemoteGATTCharacteristicReadValue(
    Map<String, dynamic> data,
    BuildContext? context,
  ) async {
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

  // isRegisterRing is to know wether to show the bottomsheet or not (On register we don't)
  // isRingDapp is to know and show right title
  Future<void> getBlueberryRing(bool isRegisterRing, bool isRingDapp) async {
    String title = isRingDapp ? 'nearby_blueberry_rings' : 'bluetooth_devices';
    showSnackBar(
        context: context!,
        content: translate('searching_for_x')!
            .replaceFirst('{0}', translate(title)!),
        leadingIcon: Container(
          padding: const EdgeInsets.all(Sizes.spaceXSmall),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF303746).withOpacity(0.5),
          ),
          child: const Center(
            child: Icon(
              Icons.bluetooth,
              color: Colors.white,
              size: 20,
            ),
          ),
        ));
    // Check register criteria for blueberry ring
    await bluetoothUseCase.getScanResults(context!, isRegisterRing, title);
  }
}
