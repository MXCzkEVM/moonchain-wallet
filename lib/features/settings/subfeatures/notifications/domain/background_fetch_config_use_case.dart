import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:url_launcher/url_launcher.dart';

import 'background_fetch_config_repository.dart';

class BackgroundFetchConfigUseCase extends ReactiveUseCase {
  BackgroundFetchConfigUseCase(
    this._repository,
  );

  final BackgroundFetchConfigRepository _repository;

  late final ValueStream<PeriodicalCallData> periodicalCallData =
      reactiveField(_repository.periodicalCallData);

  void updateItem(PeriodicalCallData item) {
    _repository.updateItem(item);
    update(periodicalCallData, _repository.item);
  }

  void removeItem(PeriodicalCallData item) {
    _repository.removeItem(item);
    update(periodicalCallData, _repository.item);
  }
}
