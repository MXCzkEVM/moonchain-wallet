import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/common/contract/miner_use_case.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:flutter/material.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:background_fetch/background_fetch.dart' as bgFetch;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'dapp_hooks_repository.dart';

class DAppHooksUseCase extends ReactiveUseCase {
  DAppHooksUseCase(
      this._repository,
      this._chainConfigurationUseCase,
      this._tokenContractUseCase,
      this._minerUseCase,
      this._accountUseCase,
      this._errorUseCase) {
    initialize();
  }

  final DAppHooksRepository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final AccountUseCase _accountUseCase;
  final TokenContractUseCase _tokenContractUseCase;
  final ErrorUseCase _errorUseCase;
  final MinerUseCase _minerUseCase;

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

  String get dappHookTasksTaskId => Config.dappHookTasks;
  String get minerAutoClaimTaskTaskId => Config.minerAutoClaimTask;

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

  void updateDAppHooksEnabled(bool value) {
    final newDAppHooksData = dappHooksData.value.copyWith(enabled: value);
    updateItem(newDAppHooksData);
  }

  void updateDAppHooksDuration(PeriodicalCallDuration duration) {
    final newDAppHooksData =
        dappHooksData.value.copyWith(duration: duration.toMinutes());
    updateItem(newDAppHooksData);
  }

  void updateMinersList(List<String> miners) {
    final newDAppHooksData = dappHooksData.value.copyWith(
        minerHooks: dappHooksData.value.minerHooks.copyWith(
      selectedMiners: miners,
    ));
    updateItem(newDAppHooksData);
  }

  void updateMinerHookTiming(TimeOfDay value) {
    final newDAppHooksData = dappHooksData.value.copyWith(
        minerHooks: dappHooksData.value.minerHooks.copyWith(
      time: dappHooksData.value.minerHooks.time
          .copyWith(hour: value.hour, minute: value.minute, second: 0),
    ));
    updateItem(newDAppHooksData);
  }

  void updateMinerHooksEnabled(bool value) {
    final newDAppHooksData = dappHooksData.value.copyWith(
        minerHooks: dappHooksData.value.minerHooks.copyWith(
      enabled: value,
    ));
    updateItem(newDAppHooksData);
  }

  void updatedWifiHooksEnabled(bool value) {
    final newDAppHooksData = dappHooksData.value.copyWith(
        wifiHooks: dappHooksData.value.wifiHooks.copyWith(enabled: value));
    updateItem(newDAppHooksData);
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
        final address = EthereumAddress.fromHex(account.address);
        final nonce = await _tokenContractUseCase.getAddressNonce(address,
            atBlock: const BlockNum.pending());

        final tx = await _tokenContractUseCase.sendTransaction(
          from: account.address,
          to: account.address,
          privateKey: account.privateKey,
          data: MXCType.stringToUint8List(jsonEncode(finalData.toMap())),
          amount: MxcAmount.zero(),
          nonce: nonce,
        );
        AXSNotification().showNotification(
          "Successful Wi-Fi Transaction Update",
          "You have successfully updated the list of Wi-Fi networks by submitting a transaction to the MXC zkEVM.",
        );
        print("tx : ${tx.hash}");
      } catch (e) {
        _errorUseCase.handleBackgroundServiceError(
            "Wi-Fi Transaction Update failed ", e);
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
                "AXS wallet background location service for Wi-Fi hooks is running... .",
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
      final result = await AXSBackgroundFetch.startBackgroundProcess(
          taskId: dappHookTasksTaskId);

      if (!result) return result;

      final scheduleState =
          await bgFetch.BackgroundFetch.scheduleTask(bgFetch.TaskConfig(
        taskId: Config.dappHookTasks,
        delay: delay * 60 * 1000,
        periodic: true,
        requiresNetworkConnectivity: true,
        startOnBoot: true,
        stopOnTerminate: false,
        enableHeadless: true,
        forceAlarmManager: false,
        requiredNetworkType: bgFetch.NetworkType.ANY,
      ));

      return scheduleState;
    } catch (e) {
      return false;
    }
  }

  bool isTimeReached(DateTime dateTime) {
    final difference = MXCTime.getMinutesDifferenceByDateTime(dateTime);
    return difference <= 15;
  }

  // This function is called after execusion & for scheduling
  Future<bool> scheduleAutoClaimTransaction(
    DateTime dateTime,
  ) async {
    final difference = MXCTime.getMinutesDifferenceByDateTime(dateTime);
    final delay = difference.isNegative ? (24 * 60 + difference) : difference;
    return await startAutoClaimService(delay);
  }

  Future<bool> executeMinerAutoClaim(
      {required Account account,
      required List<String> selectedMinerListId,
      required DateTime minerAutoClaimTime}) async {
    await claimMiners(
        selectedMinerListId: dappHooksData.value.minerHooks.selectedMiners,
        account: account,
        minerAutoClaimTime: minerAutoClaimTime);
    return await scheduleAutoClaimTransaction(
      minerAutoClaimTime,
    );
  }

  // delay is in minutes
  Future<bool> startAutoClaimService(int delay) async {
    try {
      final result = await AXSBackgroundFetch.startBackgroundProcess(
          taskId: minerAutoClaimTaskTaskId);

      if (!result) return result;

      final scheduleState =
          await bgFetch.BackgroundFetch.scheduleTask(bgFetch.TaskConfig(
        taskId: Config.minerAutoClaimTask,
        delay: delay * 60 * 1000,
        periodic: false,
        requiresNetworkConnectivity: true,
        startOnBoot: true,
        stopOnTerminate: false,
        enableHeadless: true,
        forceAlarmManager: true,
        requiredNetworkType: bgFetch.NetworkType.ANY,
      ));

      return scheduleState;
    } catch (e) {
      return false;
    }
  }

  Future<int> stopMinerAutoClaimService({required bool turnOffAll}) async {
    return await AXSBackgroundFetch.stopServices(
        taskId: minerAutoClaimTaskTaskId, turnOffAll: turnOffAll);
  }

  Future<int> stopDAppHooksService({required bool turnOffAll}) async {
    return await AXSBackgroundFetch.stopServices(
        taskId: dappHookTasksTaskId, turnOffAll: turnOffAll);
  }

  List<WifiModel> getWifiModels(List<WiFiAccessPoint> wifiList) {
    return wifiList
        .map((e) => WifiModel(wifiName: e.ssid, wifiBSSID: e.bssid))
        .toList();
  }

  // List of miners
  Future<void> claimMiners(
      {required List<String> selectedMinerListId,
      required Account account,
      required DateTime minerAutoClaimTime}) async {
    try {
      AXSNotification().showNotification('Auto Claim Started 🏁', null);

      if (selectedMinerListId.isEmpty) {
        AXSNotification().showNotification(
          'Looks like you haven\'t selected any miners. ℹ️',
          'Please head over to miner DApp for selecting miners.',
        );
      } else {
        final ableToClaim = await _minerUseCase.claimMinersReward(
            selectedMinerListId: selectedMinerListId,
            account: account,
            showNotification: AXSNotification().showLowPriorityNotification);

        if (ableToClaim) {
          AXSNotification().showNotification(
            'Miner aut-claim successful ✅',
            'AXS wallet has been successfully claimed you mined tokens',
          );
        } else {
          AXSNotification().showNotification(
            "Oops, Nothing to claim ℹ️",
            'AXS wallet tried to claim your mined tokens, But didn\'t find any tokens to claim.',
          );
        }
        // Updating now date time + 1 day to set the timer for tomorrow
        updateAutoClaimTime(minerAutoClaimTime);
      }
    } catch (e) {
      _errorUseCase.handleBackgroundServiceError("Miner aut-claim failed ❌", e);
    }
  }

  Future<void> updateAutoClaimTime(DateTime minerAutoClaimTime) async {
    final now = DateTime.now();
    DateTime updatedAutoClaimTime = now.copyWith(
        hour: minerAutoClaimTime.hour,
        minute: minerAutoClaimTime.minute,
        second: 0);
    updatedAutoClaimTime = updatedAutoClaimTime.add(const Duration(days: 1));
    final updatedDappHooksData = dappHooksData.value.copyWith(
        minerHooks: dappHooksData.value.minerHooks
            .copyWith(time: updatedAutoClaimTime));
    updateItem(updatedDappHooksData);
  }

  @override
  Future<void> dispose() async {
    if (positionStream != null) positionStream!.cancel();
  }
}
