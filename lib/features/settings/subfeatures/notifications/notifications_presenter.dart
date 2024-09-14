import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'helpers/notifications_helper.dart';
import 'notifications_state.dart';
import 'widgets/widgets.dart';

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
  late final _dAppHooksUseCase = ref.read(dAppHooksUseCaseProvider);
  late final bluetoothUseCase = ref.read(bluetoothUseCaseProvider);

  final TextEditingController lowBalanceController = TextEditingController();
  final TextEditingController transactionFeeController =
      TextEditingController();

  NotificationsHelper get notificationsHelper => NotificationsHelper(
        translate: translate,
        context: context,
        dAppHooksUseCase: _dAppHooksUseCase,
        state: state,
        backgroundFetchConfigUseCase: backgroundFetchConfigUseCase,
        bluetoothUseCase: bluetoothUseCase,
        notify: notify,
      );

  @override
  void initState() {
    super.initState();

    listen(backgroundFetchConfigUseCase.periodicalCallData, (value) {
      notify(
        () => state.periodicalCallData = value,
      );
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

    Future.delayed(
      const Duration(
        milliseconds: 1,
      ),
      () => showSnackBar(
          context: context!,
          content: translate(
              'let_us_personalize_your_notifications_choose_which_ones_you_want_to_see')!),
    );

    Future.delayed(
        const Duration(
          milliseconds: 1,
        ),
        () => notificationsHelper.checkNotificationsStatus());
  }

  void onLowBalanceChange() {
    if (state.formKey.currentState!.validate()) {
      backgroundFetchConfigUseCase.updateLowBalance(lowBalanceController.text);
    }
  }

  void onTransactionFeeChange() {
    if (state.formKey.currentState!.validate()) {
      backgroundFetchConfigUseCase
          .updateExpectedTransactionFee(transactionFeeController.text);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // If user went to settings to change notifications state
    if (state == AppLifecycleState.resumed) {
      notificationsHelper.checkNotificationsStatus();
    }
  }

  void showChangeSnackBarWrapper(Function func) {
    func();
    showSnackBar(
        context: context!,
        content: translate(
            'weve_updated_our_notification_settings_based_on_your_feedback_let_us_know_what_you_think')!);
  }

  void changeNotificationsServiceEnabled(bool value) =>
      notificationsHelper.changeNotificationsServiceEnabled(value);

  void changeLowBalanceLimitEnabled(bool value) => showChangeSnackBarWrapper(
      () => notificationsHelper.changeLowBalanceLimitEnabled(value));

  void changeExpectedTransactionFeeEnabled(bool value) =>
      showChangeSnackBarWrapper(
          () => notificationsHelper.changeExpectedTransactionFeeEnabled(value));

  void changeExpectedEpochQuantityEnabled(bool value) =>
      showChangeSnackBarWrapper(
          () => notificationsHelper.changeExpectedEpochQuantityEnabled(value));

  void changeActivityReminderEnabled(bool value) => showChangeSnackBarWrapper(
      () => notificationsHelper.changeActivityReminderEnabled(value));

  void changeSleepInsightEnabled(bool value) => showChangeSnackBarWrapper(
      () => notificationsHelper.changeSleepInsightEnabled(value));

  void changeHeartAlertEnabled(bool value) => showChangeSnackBarWrapper(
      () => notificationsHelper.changeHeartAlertEnabled(value));

  void changeLowBatteryEnabled(bool value) => showChangeSnackBarWrapper(
      () => notificationsHelper.changeLowBatteryEnabled(value));

  void updateEpochOccur(int value) =>
      notificationsHelper.updateEpochOccur(value);

  void showBGFetchFrequencyDialog() {
    showBGNotificationsFrequencyDialog(context!,
        onTap: notificationsHelper.handleFrequencyChange,
        selectedFrequency: getPeriodicalCallDurationFromInt(
            state.periodicalCallData!.duration));
  }

  void changeNotificationsState(bool value) =>
      notificationsHelper.changeNotificationsState(value);

  @override
  Future<void> dispose() {
    WidgetsBinding.instance.removeObserver(this);
    return super.dispose();
  }
}
