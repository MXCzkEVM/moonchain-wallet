import 'dart:convert';
import 'dart:io';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/contract/token_contract_use_case.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:background_fetch/background_fetch.dart' as bgFetch;
import 'package:location/location.dart' as loc;
import 'package:network_info_plus/network_info_plus.dart';
import 'dapp_hooks_repository.dart';

class DAppHooksUseCase extends ReactiveUseCase {
  DAppHooksUseCase(
    this._repository,
    this._chainConfigurationUseCase,
    this._tokenContractUseCase,
  ) {
    initialize();
  }

  final DAppHooksRepository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final TokenContractUseCase _tokenContractUseCase;

  late final ValueStream<DAppHooksModel> dappHooksData =
      reactiveField(_repository.dappHooksData);

  void updateItem(DAppHooksModel item) {
    _repository.updateItem(item);
    update(dappHooksData, _repository.item);
  }

  void removeItem(DAppHooksModel item) {
    _repository.removeItem(item);
    update(dappHooksData, _repository.item);
  }

  void initialize() {
    _chainConfigurationUseCase.selectedNetwork.listen((network) {
      final isMXCChains =
          network != null && !Config.isMxcChains(network.chainId);
      final dappHooksData = _repository.item;
      if (!isMXCChains) {
        bgFetch.BackgroundFetch.stop(Config.dappHookTasks);
      } else if (isMXCChains && dappHooksData.enabled) {
        startDAppHooksService(dappHooksData.duration);
      }
    });
  }

  // location access + at least one time connectection to wifi after opening app

  Future<void> sendWifiInfo(
    Account account,
  ) async {
    print("sendWifiInfo");

    loc.Location location = loc.Location();

    final isGranted = await PermissionUtils.checkLocationPermission();
    print("isGranted: ${isGranted}");

    if (isGranted) {
      try {
//               setLocationSettings(
//         rationaleMessageForGPSRequest:
//             '....',
//         rationaleMessageForPermissionRequest:
//             '....',
//         askForPermission: true);
// final currentLocation = await getLocation(); //catch exception
        final currentLocation = await location.getLocation();

        print(
            "Location: ${currentLocation.latitude}, ${currentLocation.longitude}");

        final h3 = const H3Factory().load();

        final hexagonBigInt = h3.geoToH3(
            GeoCoord(
                lon: currentLocation.longitude!,
                lat: currentLocation.latitude!),
            Config.h3Resolution);

        print("hexagonBigInt: ${currentLocation.longitude}");

        final hexagon = MXCType.bigIntToHex(hexagonBigInt);

        print("hexagon: ${hexagon}");

        final wifiName = await getWifiName();
        final wifiBSSID = await getWifiBSSID();

        print("wifiInfo: ${wifiName + wifiBSSID} ");

        final finalJson = Map<String, String>();
        finalJson['version'] = 'v1';
        // finalJson['wifiList']= ;
        finalJson['wifiName'] = wifiName;
        finalJson['wifiBSSID'] = wifiBSSID;
        finalJson['hexagonId'] = hexagon;

        print("memo: ${finalJson.toString()}");

        print("tx");
        final tx = await _tokenContractUseCase.sendTransaction(
            from: account.address,
            to: account.address,
            privateKey: account.privateKey,
            data: MXCType.stringToUint8List(jsonEncode(finalJson)),
            amount: MxcAmount.zero());

        print("tx : ${tx.hash}");
      } catch (e) {
        print(e);
      }
    }
  }

  static Future<String> getWifiName() async {
    String? wifiName;
    // request permissions to get more info
    final networkInfo = NetworkInfo();

    wifiName = await networkInfo.getWifiName();

    if (wifiName == null) {
      throw 'Unable to retrieve wifi info successfully, Current info : Wifi name  $wifiName';
    }

    return wifiName.replaceAll('"', '');
  }

  static Future<String> getWifiBSSID() async {
    String? wifiBSSID;
    // request permissions to get more info
    final networkInfo = NetworkInfo();

    wifiBSSID = await networkInfo.getWifiBSSID();

    if (wifiBSSID == null) {
      throw 'Unable to retrieve wifi info successfully, Current info : Wifi BSSID $wifiBSSID';
    }

    return wifiBSSID;
  }

  // delay is in minutes
  Future<bool> startDAppHooksService(int delay) async {
    try {
      // Stop If any is running
      await stopDAppHooksService();

      final configurationState = await bgFetch.BackgroundFetch.configure(
          bgFetch.BackgroundFetchConfig(
              minimumFetchInterval: delay,
              stopOnTerminate: false,
              enableHeadless: true,
              startOnBoot: true,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresStorageNotLow: false,
              requiresDeviceIdle: false,
              requiredNetworkType: bgFetch.NetworkType.ANY),
          DAppHooksService.dappHooksServiceCallBackDispatcherForeground);
      // Android Only
      final backgroundFetchState =
          await bgFetch.BackgroundFetch.registerHeadlessTask(
              DAppHooksService.dappHooksServiceCallBackDispatcher);

      final scheduleState =
          await bgFetch.BackgroundFetch.scheduleTask(bgFetch.TaskConfig(
        taskId: Config.dappHookTasks,
        delay: delay * 60 * 1000,
        periodic: true,
        requiresNetworkConnectivity: true,
        startOnBoot: true,
        stopOnTerminate: false,
        requiredNetworkType: bgFetch.NetworkType.ANY,
      ));

      if (scheduleState &&
              configurationState == bgFetch.BackgroundFetch.STATUS_AVAILABLE ||
          configurationState == bgFetch.BackgroundFetch.STATUS_RESTRICTED &&
              (Platform.isAndroid ? backgroundFetchState : true)) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<int> stopDAppHooksService() async {
    return await bgFetch.BackgroundFetch.stop(Config.dappHookTasks);
  }
}
