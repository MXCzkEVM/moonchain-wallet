import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/notifications/widgets/background_fetch_dialog.dart';
import 'package:datadashwallet/features/settings/subfeatures/notifications/widgets/bg_notifications_frequency_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:background_fetch/background_fetch.dart' as bgFetch;
import 'package:mxc_logic/mxc_logic.dart';
import '../../../../main.dart';
import 'notifications_state.dart';

final notificationsContainer =
    PresenterContainer<NotificationsPresenter, NotificationsState>(
        () => NotificationsPresenter());

class NotificationsPresenter extends CompletePresenter<NotificationsState>
    with WidgetsBindingObserver {
  NotificationsPresenter() : super(NotificationsState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  late final backgroundFetchConfigUseCase =
      ref.read(backgroundFetchConfigUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);

  // this is used to show the bg fetch dialog
  bool noneEnabled = true;

  final TextEditingController lowBalanceController = TextEditingController();
  final TextEditingController transactionFeeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    checkNotificationsStatus();

    listen(backgroundFetchConfigUseCase.periodicalCallData, (value) {
      checkPeriodicalCallDataChange(value);
    });

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      notify(() => state.network = value);
    });

    lowBalanceController.text =
        state.periodicalCallData!.lowBalanceLimit.toString();
    transactionFeeController.text =
        state.periodicalCallData!.expectedTransactionFee.toString();

    lowBalanceController.addListener(onLowBalanceChange);
    transactionFeeController.addListener(onTransactionFeeChange);
  }

  void onLowBalanceChange() {
    if (state.formKey.currentState!.validate()) {
      handleLowBalanceChange();
    }
  }

  void onTransactionFeeChange() {
    if (state.formKey.currentState!.validate()) {
      handleExpectedTransactionFeeChange();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // If user went to settings to change notifications state
    if (state == AppLifecycleState.resumed) {
      checkNotificationsStatus();
    }
  }

  void changeNotificationsState(bool shouldEnable) {
    if (shouldEnable) {
      turnNotificationsOn();
    } else {
      turnNotificationsOff();
    }
  }

  void turnNotificationsOn() async {
    final isGranted = await PermissionUtils.initNotificationPermission();
    if (isGranted) {
      // change state
      notify(() => state.isNotificationsEnabled = isGranted);
    } else {
      // Looks like the notification is blocked permanently
      // send to settings
      openNotificationSettings();
    }
  }

  void turnNotificationsOff() {
    openNotificationSettings();
  }

  void openNotificationSettings() {
    if (Platform.isAndroid) {
      AppSettings.openAppSettings(
          type: AppSettingsType.notification, asAnotherTask: false);
    } else {
      // IOS
      AppSettings.openAppSettings(
        type: AppSettingsType.settings,
      );
    }
  }

  void checkNotificationsStatus() async {
    final isGranted = await PermissionUtils.checkNotificationPermission();
    if (state.isNotificationsEnabled == false && isGranted == true) {
      await AXSFireBase.initializeFirebase();
      AXSFireBase.initLocalNotificationsAndListeners();
    }
    notify(() => state.isNotificationsEnabled = isGranted);
  }

  void enableLowBalanceLimit(bool value) {
    final newPeriodicalCallData =
        state.periodicalCallData!.copyWith(lowBalanceLimitEnabled: value);
    backgroundFetchConfigUseCase.updateItem(newPeriodicalCallData);
  }

  void showBGFetchFrequencyDialog() {
    showBGNotificationsFrequencyDialog(context!,
        onTap: handleFrequencyChange,
        selectedFrequency: getPeriodicalCallDurationFromInt(
            state.periodicalCallData!.duration));
  }

  void changeEnableService(bool value) {
    final newPeriodicalCallData =
        state.periodicalCallData!.copyWith(serviceEnabled: value);
    backgroundFetchConfigUseCase.updateItem(newPeriodicalCallData);
  }

  void enableExpectedGasPrice(bool value) {
    final newPeriodicalCallData = state.periodicalCallData!
        .copyWith(expectedTransactionFeeEnabled: value);
    backgroundFetchConfigUseCase.updateItem(newPeriodicalCallData);
  }

  void enableExpectedEpochQuantity(bool value) {
    final newPeriodicalCallData = state.periodicalCallData!
        .copyWith(expectedEpochOccurrenceEnabled: value);
    backgroundFetchConfigUseCase.updateItem(newPeriodicalCallData);
  }

  void selectEpochOccur(int value) {
    final newPeriodicalCallData =
        state.periodicalCallData!.copyWith(expectedEpochOccurrence: value);
    backgroundFetchConfigUseCase.updateItem(newPeriodicalCallData);
  }

  void handleFrequencyChange(PeriodicalCallDuration duration) {
    final newPeriodicalCallData =
        state.periodicalCallData!.copyWith(duration: duration.toMinutes());
    backgroundFetchConfigUseCase.updateItem(newPeriodicalCallData);
  }

  void handleLowBalanceChange() {
    final lowBalanceString = lowBalanceController.text;
    final lowBalance = double.parse(lowBalanceString);
    final newPeriodicalCallData =
        state.periodicalCallData!.copyWith(lowBalanceLimit: lowBalance);
    backgroundFetchConfigUseCase.updateItem(newPeriodicalCallData);
  }

  void handleExpectedTransactionFeeChange() {
    final expectedTransactionFeeString = transactionFeeController.text;
    final expectedTransactionFee = double.parse(expectedTransactionFeeString);
    final newPeriodicalCallData = state.periodicalCallData!
        .copyWith(expectedTransactionFee: expectedTransactionFee);
    backgroundFetchConfigUseCase.updateItem(newPeriodicalCallData);
  }

  void checkPeriodicalCallDataChange(
      PeriodicalCallData newPeriodicalCallData) async {
    if (state.periodicalCallData != null) {
      final isBGServiceChanged = state.periodicalCallData!.serviceEnabled !=
          newPeriodicalCallData.serviceEnabled;
      final bgServiceDurationChanged =
          state.periodicalCallData!.duration != newPeriodicalCallData.duration;

      if (isBGServiceChanged && newPeriodicalCallData.serviceEnabled == true) {
        startBGFetch(
            delay: newPeriodicalCallData.duration, showBGFetchAlert: true);
      } else if (isBGServiceChanged &&
          newPeriodicalCallData.serviceEnabled == false) {
        stopBGFetch(showSnackbar: true);
      } else if (bgServiceDurationChanged) {
        startBGFetch(
            delay: newPeriodicalCallData.duration, showBGFetchAlert: false);
      }
    }

    notify(() => state.periodicalCallData = newPeriodicalCallData);
  }

  // delay is in minutes
  void startBGFetch(
      {required int delay, required bool showBGFetchAlert}) async {
    if (showBGFetchAlert) {
      await showBackgroundFetchAlertDialog(context: context!);
    }
    final success = await backgroundFetchConfigUseCase.startBGFetch(delay);
    if (success) {
      showBGFetchSuccessSnackBar();
    } else {
      showBGFetchFailureSnackBar();
    }
  }

  Future<int> stopBGFetch({required bool showSnackbar}) async {
    final res = await bgFetch.BackgroundFetch.stop(Config.axsPeriodicalTask);
    if (showSnackbar) {
      showBGFetchDisableSuccessSnackBar();
    }
    return res;
  }

  void showBGFetchFailureSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('unable_to_launch_background_notification_service')!,
        type: SnackBarType.fail);
  }

  void showBGFetchSuccessSnackBar() {
    showSnackBar(
        context: context!,
        content: translate(
            'background_notifications_service_launched_successfully')!);
  }

  void showBGFetchDisableSuccessSnackBar() {
    showSnackBar(
        context: context!,
        content: translate(
            'background_notifications_service_disabled_successfully')!);
  }

  @override
  Future<void> dispose() {
    WidgetsBinding.instance.removeObserver(this);
    return super.dispose();
  }
}
