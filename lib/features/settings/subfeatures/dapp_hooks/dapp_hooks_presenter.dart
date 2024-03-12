import 'dart:async';
import 'dart:io';
import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/utils/utils.dart';
import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/utils/wifi_hooks_helper.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mxc_logic/mxc_logic.dart';

import 'dapp_hooks_state.dart';
import 'widgets/dapp_hooks_frequency_dialog.dart';

final notificationsContainer =
    PresenterContainer<DAppHooksPresenter, DAppHooksState>(
        () => DAppHooksPresenter());

class DAppHooksPresenter extends CompletePresenter<DAppHooksState>
    with WidgetsBindingObserver {
  DAppHooksPresenter() : super(DAppHooksState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  late final _dAppHooksUseCase = ref.read(dAppHooksUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _backgroundFetchConfigUseCase =
      ref.read(backgroundFetchConfigUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);

  final geo.GeolocatorPlatform _geoLocatorPlatform =
      geo.GeolocatorPlatform.instance;
  late StreamSubscription<geo.ServiceStatus> streamSubscription;

  DappHooksSnackBarUtils get dappHooksSnackBarUtils =>
      DappHooksSnackBarUtils(translate: translate, context: context);
  MinerHooksHelper get minerHooksHelper => MinerHooksHelper(
      translate: translate,
      context: context,
      dAppHooksUseCase: _dAppHooksUseCase,
      accountUseCase: _accountUseCase,
      backgroundFetchConfigUseCase: _backgroundFetchConfigUseCase);

  WiFiHooksHelper get wifiHooksHelper => WiFiHooksHelper(
      translate: translate,
      context: context,
      dAppHooksUseCase: _dAppHooksUseCase,
      state: state,
      geoLocatorPlatform: _geoLocatorPlatform);

  DAppHooksHelper get dappHooksHelper => DAppHooksHelper(
      translate: translate,
      context: context,
      dAppHooksUseCase: _dAppHooksUseCase,
      state: state,
      backgroundFetchConfigUseCase: _backgroundFetchConfigUseCase);

  @override
  void initState() {
    super.initState();

    listen(_dAppHooksUseCase.dappHooksData, (value) {
      notify(() => state.dAppHooksData = value);
    });

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      notify(() => state.network = value);
    });

    listen(_accountUseCase.account, (value) {
      if (value != null) notify(() => state.account = value);
    });

    // I am doing this because It throws error when trying to do immediately
    Future.delayed(
      const Duration(seconds: 1),
      () => wifiHooksHelper.initLocationServiceStateStream(),
    );
  }

  void changeDAppHooksEnabled(bool value) =>
      dappHooksHelper.changeDAppHooksEnabled(value);

  void changeWifiHooksEnabled(bool value) =>
      wifiHooksHelper.changeWifiHooksEnabled(value);

  void changeMinerHooksEnabled(bool value) =>
      minerHooksHelper.changeMinerHooksEnabled(value);

  void showDAppHooksFrequency() {
    showDAppHooksFrequencyDialog(context!,
        onTap: dappHooksHelper.handleFrequencyChange,
        selectedFrequency:
            getPeriodicalCallDurationFromInt(state.dAppHooksData!.duration));
  }

  void showTimePickerDialog() async {
    final currentTimeOfDay = state.dAppHooksData!.minerHooks.time;
    final initialTime = TimeOfDay.fromDateTime(currentTimeOfDay);
    final newTimeOfDay = await showTimePicker(
      context: context!,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );

    if (newTimeOfDay != null) {
      minerHooksHelper.changeMinerHookTiming(newTimeOfDay);
    }
  }

  @override
  Future<void> dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamSubscription.cancel();
    return super.dispose();
  }
}
