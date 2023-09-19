import 'package:datadashwallet/core/core.dart';
import '../entity/transaction_history_model.dart';
import 'transactions_repository.dart';

class TransactionsHistoryUseCase extends ReactiveUseCase {
  TransactionsHistoryUseCase(this._repository);

  final TransactionsHistoryRepository _repository;

  late final ValueStream<List<TransactionHistoryModel>> transactionsHistory =
      reactiveField(_repository.transactionsHistory);

  List<TransactionHistoryModel> getTransactionsHistory() => _repository.items;

  void addItem(TransactionHistoryModel item) {
    _repository.addItem(item);
    update(transactionsHistory, _repository.items);
  }

  void updateItem(TransactionHistoryModel item, int index) {
    _repository.updateItem(item, index);
    update(transactionsHistory, _repository.items);
  }

  void removeItem(TransactionHistoryModel item) {
    _repository.removeItem(item);
    update(transactionsHistory, _repository.items);
  }
}
