import 'dart:async';
import 'package:datadashwallet/features/common/common.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';

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
    // Get spteps data from cache and compare
    // If steps is below a certain number then show a
    // Below 5000
    // if (DateTime.fromMillisecondsSinceEpoch(data.last.date * 1000) )
  }

  Future<void> checkSleepInsight() async {
    final data = await _blueberryRingUseCase.readSleep();
    // If sleeps is below standard level
  }

  Future<void> checkHeartAlert() async {
    final data = await _blueberryRingUseCase.readHeartRate();
    // If below standard but between person to person different
  }

  Future<void> checkLowBattery() async {
    final data = await _blueberryRingUseCase.readLevel();
    // What si the low battery level
    // Is 10 OK
    if (data < 20) {
      AXSNotification().showNotification(
        cTranslate('tx_fee_reached_expectation_notification_title'),
        cTranslate('tx_fee_reached_expectation_notification_text'),
      );
    }
  }
}
