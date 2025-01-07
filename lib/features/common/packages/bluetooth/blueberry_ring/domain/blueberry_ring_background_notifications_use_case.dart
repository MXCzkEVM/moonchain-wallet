import 'dart:async';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';

class BlueberryRingBackgroundNotificationsUseCase extends ReactiveUseCase {
  BlueberryRingBackgroundNotificationsUseCase(
      this._repository,
      this._chainConfigurationUseCase,
      this._bluetoothUseCase,
      this._blueberryRingUseCase,
      this._contextLessTranslationUseCase);

  final Web3Repository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final BluetoothUseCase _bluetoothUseCase;
  final BlueberryRingUseCase _blueberryRingUseCase;
  final ContextLessTranslationUseCase _contextLessTranslationUseCase;

  // Context less translation, This should be only used for BG functions
  String cTranslate(String key) =>
      _contextLessTranslationUseCase.translate(key);

  Future<void> checkActivityReminder() async {
    final data = await _blueberryRingUseCase.readSteps();
    print('checkActivityReminder:data ${data.map((e) => e.toJson()).toList()}');
    // Get spteps data from cache and compare
    // If steps is below a certain number then show a
    // Below 5000
    final todaysData = data.where((e) => DateUtils.isDateOnToday(e.dateTime));
    print(
        'checkActivityReminder:todaysData ${todaysData.map((e) => e.toJson()).toList()}');
    final totalSteps = data.map((item) => item.step).reduce((a, b) => a + b);
    print('checkActivityReminder:totalSteps $totalSteps');

    if (totalSteps < 5000) {
      MoonchainWalletNotification().showNotification(
        cTranslate('activity_reminder'),
        cTranslate('blueberry_ring_inactive_alert_text'),
      );
    }
  }

  Future<void> checkSleepInsight() async {
    final data = await _blueberryRingUseCase.readSleep();
    print('checkSleepInsight:data ${data.map((e) => e.toJson()).toList()}');
    // If sleeps is below standard level
    // loop throug all and get average
    final todaysData = data.where((e) => DateUtils.isDateOnToday(e.dateTime));
    print(
        'checkSleepInsight:todaysData ${todaysData.map((e) => e.toJson()).toList()}');

    if (todaysData.isEmpty) {
      return;
    }

    final isNormal = BlueberryRingDataAnalyzer.isSleepQualityNormal(
        todaysData.map((e) => e.value).toList());

    if (!isNormal) {
      MoonchainWalletNotification().showNotification(
        cTranslate('sleep_insight'),
        cTranslate('blueberry_ring_sleep_alert_text'),
      );
    }
  }

  Future<void> checkHeartAlert() async {
    final data = await _blueberryRingUseCase.readHeartRate();
    print('checkHeartAlert:data ${data.map((e) => e.toJson()).toList()}');
    // If below standard but between person to person different
    final latestData = data.last;
    final isToday = DateUtils.isDateOnToday(latestData.dateTime);
    print('checkHeartAlert:isToday $isToday');
    print('checkHeartAlert:latestData $latestData');

    if (isToday && latestData.value >= 100) {
      MoonchainWalletNotification().showNotification(
        cTranslate('heart_alert'),
        cTranslate('blueberry_ring_heart_rate_alert_text'),
      );
    }
  }

  Future<void> checkLowBattery() async {
    final data = await _blueberryRingUseCase.readLevel();
    print('checkLowBattery:data $data');
    // What si the low battery level
    // Is 10 OK
    if (data < 20) {
      MoonchainWalletNotification().showNotification(
        cTranslate('low_battery'),
        cTranslate('blueberry_ring_battery_alert_text'),
      );
    }
  }
}
