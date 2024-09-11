import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'balance_repository.dart';

class BalanceUseCase extends ReactiveUseCase {
  BalanceUseCase(this._repository);

  final BalanceRepository _repository;

  late final ValueStream<List<BalanceData>> balanceHistory =
      reactiveField(_repository.balanceHistory);

  List<BalanceData> getBalanceHistory() => _repository.items;

  void addItem(BalanceData item) {
    _repository.addItem(item);
    update(balanceHistory, _repository.items);
  }

  void removeItem(BalanceData item) {
    _repository.removeItem(item);
    update(balanceHistory, _repository.items);
  }
}
