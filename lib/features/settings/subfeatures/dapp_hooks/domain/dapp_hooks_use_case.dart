import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:datadashwallet/app/app.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
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
      this._errorUseCase,
      this._contextLessTranslationUseCase) {
    initialize();
  }

  final DAppHooksRepository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final AccountUseCase _accountUseCase;
  final TokenContractUseCase _tokenContractUseCase;
  final ErrorUseCase _errorUseCase;
  final MinerUseCase _minerUseCase;
  final ContextLessTranslationUseCase _contextLessTranslationUseCase;

  // Context less translation, This should be only used for BG functions
  String cTranslate(String key) =>
      _contextLessTranslationUseCase.translate(key);

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

  String get dappHookTasksTaskId => BackgroundExecutionConfig.dappHookTasks;
  String get minerAutoClaimTaskTaskId =>
      BackgroundExecutionConfig.minerAutoClaimTask;

  void initialize() {
    _chainConfigurationUseCase.selectedNetwork.listen((network) {
      final isMXCChains =
          network != null && !MXCChains.isMXCChains(network.chainId);
      final dappHooksData = _repository.item;
      if (!isMXCChains) {
        bgFetch.BackgroundFetch.stop(BackgroundExecutionConfig.dappHookTasks);
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

  // location access + at least one time connection to wifi after opening app

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
            throw cTranslate(
                'unable_to_get_wifi_list_please_check_requirements_for_wifi_hexagon_location_hooks_services');
          } else if (canGetResults == CanGetScannedResults.notSupported) {
            throw cTranslate('getting_wifi_list_is_not_supported  ');
          }
        } else {
          final wifiName = await getWifiName();
          final wifiBSSID = await getWifiBSSID();

          print("wifiInfo: ${wifiName + wifiBSSID} ");
          final wifiInfo = WifiModel(wifiName: wifiName, wifiBSSID: wifiBSSID);

          finalWifiList = [wifiInfo];
        }

        if (finalWifiList.isEmpty) {
          throw cTranslate('wifi_list_is_empty');
        }

        final os = MXCFormatter.capitalizeFirstLetter(Platform.operatingSystem);

        final finalData = WifiHooksDataModel(
          version: BackgroundExecutionConfig.wifiHooksDataV,
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
          cTranslate('wifi_info_notifications_title'),
          cTranslate('wifi_info_notifications_text'),
        );
        print("tx : ${tx.hash}");
      } catch (e) {
        _errorUseCase.handleBackgroundServiceError(
            cTranslate('wifi_info_tx_failed'), e);
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
        foregroundNotificationConfig: geo.ForegroundNotificationConfig(
            notificationText: FlutterI18n.translate(
                appNavigatorKey.currentContext!,
                'axs_background_location_service_text'),
            notificationTitle: FlutterI18n.translate(
                appNavigatorKey.currentContext!,
                'axs_background_location_service_title'),
            enableWakeLock: true,
            notificationIcon: const geo.AndroidResource(
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

  Future<String> getWifiName() async {
    String? wifiName;
    // request permissions to get more info
    final networkInfo = NetworkInfo();

    wifiName = await networkInfo.getWifiName();

    if (wifiName == null) {
      throw cTranslate('unable_to_retrieve_wifi_info_successfully');
    }

    return wifiName.replaceAll('"', '');
  }

  Future<String> getWifiBSSID() async {
    String? wifiBSSID;
    // request permissions to get more info
    final networkInfo = NetworkInfo();

    wifiBSSID = await networkInfo.getWifiBSSID();

    if (wifiBSSID == null) {
      throw cTranslate('unable_to_retrieve_wifi_info_successfully');
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
        taskId: BackgroundExecutionConfig.dappHookTasks,
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
        taskId: BackgroundExecutionConfig.minerAutoClaimTask,
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
      AXSNotification()
          .showNotification(cTranslate('auto_claim_started'), null);

      if (selectedMinerListId.isEmpty) {
        AXSNotification().showNotification(
          cTranslate('no_miners_selected_notification_title'),
          cTranslate('no_miners_selected_notification_text'),
        );
      } else {
        final ableToClaim = await _minerUseCase.claimMinersReward(
            selectedMinerListId: selectedMinerListId,
            account: account,
            showNotification: AXSNotification().showLowPriorityNotification,
            translate: cTranslate);

        if (ableToClaim) {
          AXSNotification().showNotification(
            cTranslate('auto_claim_successful_notification_title'),
            cTranslate('auto_claim_successful_notification_text'),
          );
        } else {
          AXSNotification().showNotification(
            cTranslate('nothing_to_claim_notification_title'),
            cTranslate('nothing_to_claim_notification_text'),
          );
        }
        // Updating now date time + 1 day to set the timer for tomorrow
        updateAutoClaimTime(minerAutoClaimTime);
      }
    } catch (e) {
      _errorUseCase.handleBackgroundServiceError(
          cTranslate('auto_claim_failed'), e);
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
