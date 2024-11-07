import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'logs_config_repository.dart';

class LogsConfigUseCase extends ReactiveUseCase {
  LogsConfigUseCase(this._repository,);

  final LogsConfigRepository _repository;

  late final ValueStream<bool> notImportantLogsEnabled =
      reactiveField(_repository.notImportantLogsEnabled);

  void updateItem(bool value) {
    _repository.updateItem(value);
    update(notImportantLogsEnabled, _repository.notImportantLogsEnabled.value);
  }
}
