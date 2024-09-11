import 'dart:async';
import 'package:moonchain_wallet/features/settings/subfeatures/dapp_hooks/utils/utils.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/dapp_hooks/utils/wifi_hooks_helper.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mxc_logic/mxc_logic.dart';

import 'dapp_hooks_state.dart';
import 'widgets/wifi_hooks_frequency_bottom_sheet.dart';

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

  DappHooksSnackBarUtils get dappHooksSnackBarUtils =>
      DappHooksSnackBarUtils(translate: translate, context: context);
  MinerHooksHelper get minerHooksHelper => MinerHooksHelper(
      translate: translate,
      context: context,
      dAppHooksUseCase: _dAppHooksUseCase,
      accountUseCase: _accountUseCase,
      backgroundFetchConfigUseCase: _backgroundFetchConfigUseCase);

  BlueberryHooksHelper get blueberryRingHooksHelper => BlueberryHooksHelper(
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
        geoLocatorPlatform: _geoLocatorPlatform,
        backgroundFetchConfigUseCase: _backgroundFetchConfigUseCase,
      );

  DAppHooksHelper get dappHooksHelper => DAppHooksHelper(
        translate: translate,
        context: context,
        state: state,
      );

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

  void changeWiFiHooksEnabled(bool value) =>
      wifiHooksHelper.changeWiFiHooksEnabled(value);

  void changeMinerHooksEnabled(bool value) =>
      minerHooksHelper.changeMinerHooksEnabled(value);

  void changeBlueberryHooksEnabled(bool value) =>
      blueberryRingHooksHelper.changeBLueberryRingHooksEnabled(value);

  void showWiFiHooksFrequency() {
    showWiFiHooksFrequencyBottomSheet(context!,
        onTap: wifiHooksHelper.handleFrequencyChange,
        selectedFrequency: getPeriodicalCallDurationFromInt(
            state.dAppHooksData!.wifiHooks.duration));
  }

  void showTimePickerMinerDialog() async {
    final currentTimeOfDay = state.dAppHooksData!.minerHooks.time;
    showTimePickerDialog(
        currentTimeOfDay, minerHooksHelper.changeMinerHookTiming);
  }

  void showTimePickerBlueberryRingDialog() async {
    final currentTimeOfDay = state.dAppHooksData!.blueberryRingHooks.time;
    showTimePickerDialog(currentTimeOfDay,
        blueberryRingHooksHelper.changeBlueberryRingHookTiming);
  }

  void showTimePickerDialog(DateTime currentTimeOfDay,
      Future<void> Function(TimeOfDay value) changeTimeFunction) async {
    final initialTime = TimeOfDay.fromDateTime(currentTimeOfDay);
    final newTimeOfDay = await showTimePicker(
      context: context!,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );

    if (newTimeOfDay != null) {
      changeTimeFunction(newTimeOfDay);
    }
  }

  @override
  Future<void> dispose() {
    WidgetsBinding.instance.removeObserver(this);
    return super.dispose();
  }
}
