import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/contract/token_contract_use_case.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:background_fetch/background_fetch.dart' as bgFetch;
// import 'package:location2/location2.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';
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

  StreamSubscription<geo.Position>? positionStream;

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

    final isGranted = await PermissionUtils.checkLocationPermission();
    print("isGranted: ${isGranted}");

    if (isGranted) {
      try {
        final geo.GeolocatorPlatform geoLocatorPlatform =
            geo.GeolocatorPlatform.instance;
        final currentLocation = await geoLocatorPlatform.getCurrentPosition();

        print(
            "Location: ${currentLocation.latitude}, ${currentLocation.longitude}");

        final h3 = const H3Factory().load();

        final hexagonBigInt = h3.geoToH3(
            GeoCoord(
                lon: currentLocation.longitude, lat: currentLocation.latitude),
            Config.h3Resolution);

        print("hexagonBigInt: ${currentLocation.longitude}");

        final hexagonId = MXCType.bigIntToHex(hexagonBigInt);

        print("hexagon: ${hexagonId}");

        List<WifiModel> finalWifiList = [];

        if (Platform.isAndroid) {
          final wifiScan = WiFiScan.instance;
          final canGetResults = await wifiScan.canGetScannedResults();

          if (canGetResults == CanGetScannedResults.yes) {
            final wifiAccessPoints = await wifiScan.getScannedResults();

            finalWifiList = getWifiModels(wifiAccessPoints);
          } else if (canGetResults ==
                  CanGetScannedResults.noLocationPermissionDenied ||
              canGetResults ==
                  CanGetScannedResults.noLocationPermissionRequired ||
              canGetResults ==
                  CanGetScannedResults.noLocationPermissionUpgradeAccuracy ||
              canGetResults == CanGetScannedResults.noLocationServiceDisabled) {
            throw 'Permission required for getting wifi list';
          } else if (canGetResults == CanGetScannedResults.notSupported) {
            throw 'Not supported for getting wifi list';
          }
        } else {
          final wifiName = await getWifiName();
          final wifiBSSID = await getWifiBSSID();

          print("wifiInfo: ${wifiName + wifiBSSID} ");
          final wifiInfo = WifiModel(wifiName: wifiName, wifiBSSID: wifiBSSID);

          finalWifiList = [wifiInfo];
        }

        if (finalWifiList.isEmpty) {
          throw 'Preventing transaction because final wifi list is empty';
        }

        final os = MXCFormatter.capitalizeFirstLetter(Platform.operatingSystem);

        final finalData = WifiHooksDataModel(
          version: Config.wifiHooksDataV,
          hexagonId: hexagonId,
          wifiList: finalWifiList,
          os: os,
        );

        print("memo: ${finalData.toString()}");

        print("tx");
        final tx = await _tokenContractUseCase.sendTransaction(
            from: account.address,
            to: account.address,
            privateKey: account.privateKey,
            data: MXCType.stringToUint8List(jsonEncode(finalData.toMap())),
            amount: MxcAmount.zero());
        AXSNotification().showNotification(
          "Successful Wi-Fi Transaction Update",
          "You have successfully updated the list of Wi-Fi networks by submitting a transaction to the MXC zkEVM.",
        );
        print("tx : ${tx.hash}");
      } catch (e) {
        print(e);
        AXSNotification().showNotification(
          "Wi-Fi Transaction Update failed ",
          e.toString(),
        );
      }
    }
  }

  void setLocationSettings() {
    late geo.LocationSettings locationSettings;

    if (Platform.isAndroid) {
      locationSettings = geo.AndroidSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(minutes: 15),
        //(Optional) Set foreground notification config to keep the app alive
        //when going to the background
        foregroundNotificationConfig: const geo.ForegroundNotificationConfig(
            notificationText:
                "AXS wallet background location service for Wi-Fi hooks is running, Please do not dismiss this notification.",
            notificationTitle: "AXS wallet location service",
            enableWakeLock: true,
            notificationIcon: geo.AndroidResource(
              name: 'axs_logo',
            )),
      );
    } else if (Platform.isIOS) {
      locationSettings = geo.AppleSettings(
        accuracy: geo.LocationAccuracy.high,
        activityType: geo.ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: false,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
        allowBackgroundLocationUpdates: true,
      );
    }

    positionStream =
        geo.Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((geo.Position? position) {
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
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

  List<WifiModel> getWifiModels(List<WiFiAccessPoint> wifiList) {
    return wifiList
        .map((e) => WifiModel(wifiName: e.ssid, wifiBSSID: e.bssid))
        .toList();
  }

  @override
  Future<void> dispose() async {
    if (positionStream != null) positionStream!.cancel();
  }
}
